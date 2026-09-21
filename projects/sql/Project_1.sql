with users_parsed as
--- очищення дати в таблиці cohort_users_raw / clean up the raw timestamp strings in cohort_users_raw
(
select 
	u.user_id,
	u.promo_signup_flag,
	replace(replace(trim(u.signup_datetime), '/', '-'), '.', '-') as signup_ts
	--- прибираємо зайві пробіли на початку і кінці стоки за допомогою trim, заміняємо різні делімітери за допомогою replace / trim leading and trailing spaces with trim, normalise the different delimiters with replace
from
	cohort_users_raw as u
),
users_parsed_date as (
--- трансформування дати зі строкового формата у формат дати / convert the date from string format into a date type
select
		up.user_id,
	up.promo_signup_flag,
		case 
			when regexp_match(signup_ts, '^\d{1,2}-\d{1,2}-\d{4} \d{1,2}:\d{1,2}$') is not null
		--- перевіряємо, що поле signup_ts відповідає формату / check that the signup_ts field matches the expected format
	            then TO_DATE(split_part(signup_ts, ' ', 1), 'DD-MM-YYYY')
		--- з поля signup_ts беремо тільки дату, і отриманний текст перетворюємо в формат дати / take only the date part from signup_ts and cast the resulting text to a date
		when regexp_match(signup_ts, '^\d{1,2}-\d{1,2}-\d{2} \d{1,2}:\d{1,2}$') is not null 
	            then TO_DATE(split_part(signup_ts, ' ', 1), 'DD-MM-YY')
		else null
	end as signup_ts
from
		users_parsed as up
),
events_parsed as
--- очищення дати в таблиці cohort_events_raw / clean up the raw timestamp strings in cohort_events_raw
(
select
	e.user_id,
	e.event_type,
	replace(replace(trim(e.event_datetime), '/', '-'), '.', '-') as event_ts
	--- прибираємо зайві пробіли на початку і кінці стоки за допомогою trim, заміняємо різні делімітери за допомогою replace / trim leading and trailing spaces with trim, normalise the different delimiters with replace
from
	cohort_events_raw as e
where
	e.event_type != 'test_event'
	--- перевірка тестової події і події без зазначеного типу / filter out test events and events with no type specified
	and e.event_type is not null
),
events_parsed_date as
--- трансформування дати зі строкового формата у формат дати / convert the date from string format into a date type
(
select
	ep.user_id,
	ep.event_type,
	case 
		when regexp_match(event_ts, '^\d{1,2}-\d{1,2}-\d{4} \d{1,2}:\d{1,2}$') is not null
		--- перевіряємо, що поле event_ts відповідає формату / check that the event_ts field matches the expected format
            then TO_DATE(split_part(event_ts, ' ', 1), 'DD-MM-YYYY')
		--- з поля event_ts беремо тільки дату, і отриманний текст перетворюємо в формат дати / take only the date part from event_ts and cast the resulting text to a date
		when regexp_match(event_ts, '^\d{1,2}-\d{1,2}-\d{2} \d{1,2}:\d{1,2}$') is not null 
            then TO_DATE(split_part(event_ts, ' ', 1), 'DD-MM-YY')
		else null
	end as event_ts
from
	events_parsed as ep
),
user_activity as
---об'єднання таблиць / join the tables
(
select 
	upd.user_id,
	upd.promo_signup_flag,
	date_trunc('month', upd.signup_ts)::date as cohort_month,
	epd.event_type,
	date_trunc('month', epd.event_ts)::date as event_month
from
	users_parsed_date upd
left join events_parsed_date epd on
	upd.user_id = epd.user_id
where
	upd.signup_ts is not null
	---прибираємо записи з відсутньою датою реєстрації і відсутньою датою події / drop rows with a missing signup date or a missing event date
	and epd.event_ts is not null
)
select
	promo_signup_flag,
	cohort_month,
	extract(year from age(event_month, cohort_month)) * 12 +
    extract(month from age(event_month, cohort_month)) as month_offset,
	---знаходимо різницю між датою події і датою реєстрації в місяцях / calculate the difference between the event date and the signup date in months
	count(distinct user_id) as users_total
	--- підраховуємо кількість унікальних користувачів / count the number of unique users
from
	user_activity
where
	event_month between '2025-01-01' and '2025-06-01'
	---обмежуємо період спостереження / limit the observation period
group by
	promo_signup_flag,
	cohort_month,
	month_offset
order by
	promo_signup_flag,
	cohort_month,
	month_offset;
