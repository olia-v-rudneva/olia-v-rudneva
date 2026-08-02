--- тимчасова функція для декодування URL-параметрів (percent-encoding, наприклад %20 -> пробіл)
--- потрібна, щоб коректно витягнути utm_campaign з рядка url_parameters
CREATE OR REPLACE FUNCTION pg_temp.decode_url_part(p varchar)
RETURNS varchar AS
$$
SELECT convert_from(
        CAST(
          E'\\x' ||
          string_agg(
            CASE
              WHEN length(r.m[1]) = 1
                THEN encode(convert_to(r.m[1], 'SQL_ASCII'), 'hex')

              ELSE substring(r.m[1] from 2 for 2)
            END,
            ''
          ) AS bytea
        ),
        'UTF8'
      )
FROM regexp_matches(
      replace($1, '+', ' '),
      '%[0-9a-f][0-9a-f]|.',
      'gi'
    ) AS r(m);
$$ LANGUAGE SQL IMMUTABLE STRICT;


--- дані Facebook Ads: приєднуємо довідники кампаній та adset, coalesce замінює NULL на 0
with facebook_ads as
(
select
	fabd.ad_date,
	'Facebook' as source,
	fc.campaign_name,
	fa.adset_name,
	coalesce(fabd.spend, 0) as spend,
	coalesce(fabd.impressions, 0) as impressions,
	coalesce(fabd.reach, 0) as reach,
	coalesce(fabd.clicks, 0) as clicks,
	coalesce(fabd.leads, 0) as leads,
	coalesce(fabd.value, 0) as value,
	pg_temp.decode_url_part(fabd.url_parameters) as url_parameters
from
	facebook_ads_basic_daily fabd
left join facebook_campaign fc on
	fabd.campaign_id = fc.campaign_id
left join facebook_adset fa on
	fabd.adset_id = fa.adset_id
),
--- дані Google Ads: назви кампаній вже є в основній таблиці, довідники не потрібні
google_ads as
(
select
	gabd.ad_date,
	'Google' as source,
	gabd.campaign_name,
	gabd.adset_name,
	coalesce(gabd.spend, 0) as spend,
	coalesce(gabd.impressions, 0) as impressions,
	coalesce(gabd.reach, 0) as reach,
	coalesce(gabd.clicks, 0) as clicks,
	coalesce(gabd.leads, 0) as leads,
	coalesce(gabd.value, 0) as value,
	pg_temp.decode_url_part(gabd.url_parameters) as url_parameters
from
	google_ads_basic_daily gabd 
),
--- об'єднуємо обидві платформи в один набір даних через union all
ads as
(
select
	*
from
	facebook_ads
union all
select
	*
from
	google_ads
)
--- фінальна агрегація: витягуємо utm_campaign регуляркою, 'nan' та NULL приводимо до 'empty',
--- сумуємо метрики в розрізі дата × джерело × кампанія × adset × utm_campaign
select
	ad_date,
	source,
	campaign_name,
	adset_name,
	case
		when lower(substring(url_parameters from 'utm_campaign=([^&]+)')) = 'nan' 
            then 'empty'
		when lower(substring(url_parameters from 'utm_campaign=([^&]+)')) is null
			then 'empty'
		else lower(substring(url_parameters from 'utm_campaign=([^&]+)'))
	end as utm_campaign,
	sum(spend) as total_spend,
	sum(impressions) as total_impressions,
	sum(reach) as total_reach,
	sum(clicks) as total_clicks,
	sum(leads) as total_leads,
	sum(value) as total_value
from
	ads
where
	ad_date is not null
group by
	ad_date,
	source,
	campaign_name,
	adset_name,
	utm_campaign
;


