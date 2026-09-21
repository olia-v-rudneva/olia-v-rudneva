SELECT  
  user_pseudo_id,
  i.item_name  
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131`,
  unnest(items) as i
where i.item_name != 'not set' and i.item_name !='(not set)'
limit 100;

-- user_pseudo_id picked from the sample above and reused in the queries below: 1973757.8722046630

--- Q1 ---
SELECT  
  user_pseudo_id,
  TIMESTAMP_MICROS(event_timestamp) as event_datetime,
  event_name,
  event_params,
  user_properties,
  items
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131`
CROSS JOIN UNNEST(items) AS i
where i.item_name != 'not set' and i.item_name !='(not set)'
  and i.item_name != '' and i.item_name is not null
  and user_pseudo_id = '1973757.8722046630'
limit 1;

--- Q2 ---
SELECT  
  user_pseudo_id,
  TIMESTAMP_MICROS(event_timestamp) as event_datetime,
  event_name,
  event_params,
  user_properties,
  items,
  ARRAY_LENGTH(event_params) as event_params_count,
  ARRAY_LENGTH(user_properties) as user_properties_count,
  ARRAY_LENGTH(items) as items_count
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131`
CROSS JOIN UNNEST(items) AS i
where i.item_name != 'not set' and i.item_name !='(not set)'
  and i.item_name != '' and i.item_name is not null
  and user_pseudo_id = '1973757.8722046630'
limit 1;

--- Q3 ---
With user_event as
(
  SELECT  
    user_pseudo_id,
    event_name,
    event_params
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131`
  JOIN unnest(items) as i
  where i.item_name != 'not set' and i.item_name !='(not set)'
    and i.item_name != '' and i.item_name is not null
    and user_pseudo_id = '1973757.8722046630'
  limit 1
)
select 
  u.user_pseudo_id,
  u.event_name,
  ep.key,
  ep.value.string_value,
  ep.value.int_value,
  ep.value.double_value
from user_event as u
JOIN unnest(u.event_params) as ep
order by ep.key asc;

--- Q4 ---
SELECT
  e.key,
  count(*) as event_frequency
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_2021*`
JOIN unnest(event_params) as e
group by e.key
order by event_frequency desc;

--- Q5 ---
SELECT  
  user_pseudo_id,
  TIMESTAMP_MICROS(event_timestamp) as event_datetime,
  i.item_id,
  i.item_name,
  i.item_category,
  i.price,
  i.quantity  
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131`
JOIN unnest(items) as i;

--- Q6 ---
select
  i.item_id,
  i.item_name,
  count(*) as events_count,
  sum(i.quantity) as total_quantity,
  sum(i.price * i.quantity) as total_revenue
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131`
JOIN unnest(items) as i
group by all
order by total_revenue desc;

--- Q7 ---
select *
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131`
where exists
  (
    select 1
    from unnest(items) as ii
    where ii.item_category = 'Apparel'
  );

--- Q8 ---
select 
  _TABLE_SUFFIX as event_date,
  count(distinct user_pseudo_id) as count_users,
  count(*) as count_event,
  countif(event_name = 'purchase') AS count_purchase
  -- countif is the BigQuery shorthand here; the portable equivalent is a count over a case expression
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
group by _TABLE_SUFFIX
order by _TABLE_SUFFIX asc;

--- Q9 ---
select
  user_pseudo_id,
  sum(i.price * i.quantity) as revenue,
  RANK() over (order by sum(i.price * i.quantity) desc) as rank_num,
  DENSE_RANK() over (order by sum(i.price * i.quantity) desc) as dense_rank_num,
  ROW_NUMBER() over (order by sum(i.price * i.quantity) desc) as row_num
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
JOIN unnest(items) as i
group by user_pseudo_id
order by revenue desc
limit 20;

--- Q10 ---
with ga_sessions as
(
  select
    user_pseudo_id,
    e.value.int_value as ga_session_id,
    event_timestamp,
    event_name
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131`
  JOIN unnest(event_params) as e
  where e.key = 'ga_session_id'
),
  first_event as 
(  
  select
    user_pseudo_id,
    ga_session_id,
    event_timestamp,
    event_name,
    ROW_NUMBER() OVER (PARTITION BY user_pseudo_id, ga_session_id ORDER BY event_timestamp) as row_num
  FROM ga_sessions
 )
 select 
  event_name
from first_event 
where row_num = 1
group by event_name
order by count(*) desc
limit 1;