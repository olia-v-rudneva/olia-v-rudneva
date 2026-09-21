--- Q1 ---
select usp.user_city, count(distinct usp.user_id) as quantity_unique_users
from users_sql_project usp 
group by user_city 
order by quantity_unique_users desc;

--- Q2 ---
select oisp.order_id
from order_items_sql_project oisp 
group by oisp.order_id 
order by sum(oisp.quantity) desc
limit 1;

--- Q3 ---
select count(distinct psp.order_id) as accepted_orders_quantity
from payments_sql_project psp 
where psp.payment_status <> 'Відхилено'
	and (psp.payment_method = 'Банківський переказ' or psp.payment_method = 'Картка');

--- Q4 ---
select osp.user_id, count(osp.order_id) as quantity_of_orders
from orders_sql_project osp 
group by osp.user_id
having count(osp.order_id) >= 5
order by quantity_of_orders desc;

--- Q5 ---
select sum(oisp.quantity) as total_quantity, count(distinct oisp.order_id) as total_orders
from order_items_sql_project oisp 
where oisp.product_id in (
	select psp.product_id
	from products_sql_project psp 
	where psp.product_brand = 'DigitalUA'
);

--- Q6 ---
select ssp.tracking_number, coalesce(ssp.delivery_date::text, 'в роботі') as delivery_description
from shipments_sql_project ssp;

--- Q7 ---
select 
	case
		when user_age < 25 then 'молоді'
		when user_age >= 45 then 'старший вік'
		else 'середній вік'
	end as category_age,
	count(user_id) as users_quantity
from users_sql_project usp 
group by category_age;

--- Q8 ---
select usp.user_city, count(distinct usp.loyalty_status) as loyalty_quantity_status
from users_sql_project usp 
group by user_city 
having count(distinct usp.loyalty_status) >= 3
order by loyalty_quantity_status;

--- Q9 ---
select *
from users_sql_project usp 
	where usp.user_email like '%@gmail.com'

--- Q10 ---
select ssp.courier,
	avg(ssp.delivery_date - shipment_date) as avg_days_delivery
from shipments_sql_project ssp
	where ssp.shipment_date is not null 	
	and delivery_date is not null
group by courier
order by avg_days_delivery;
