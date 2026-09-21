--- Q1 ---
-- Аналіз витрат користувачів / analysis of user spending
select
	osp.user_id, 
	SUM(oisp.quantity * psp.product_price) as total_revenu_order
from order_items_sql_project oisp 
left join products_sql_project psp 
	on psp.product_id = oisp.product_id
left join orders_sql_project osp 
	on osp.order_id = oisp.order_id
group by osp.user_id
order by total_revenu_order desc;		

--- Q2 ---
-- Об'єднання даних з різних каналів / combining data from the different channels
select osp.user_id, osp.order_date, osp.order_id
from orders_sql_project osp 
where osp.user_id is not Null
union all
select so.user_id, so.order_date, so.store_order_id as order_id
from store_orders so 
where so.user_id is not Null
order by user_id, order_date, order_id; 

--- Q3 ---
-- Пошук товарів в обох каналах / finding products present in both channels
select oisp.product_id 
from order_items_sql_project oisp 
intersect 
select soi.product_id 
from store_order_items soi 
order by 1;

--- Q4 ---
-- Визначення активних покупців / identifying active buyers
select user_id
from orders_sql_project osp 
where osp.order_id in 
(
	select oisp.order_id
	from order_items_sql_project oisp 
	where oisp.quantity > 2
)
intersect 
select user_id
from store_orders so  
where so.store_order_id in
(
	select soi.store_order_id 
	from store_order_items soi  
	where soi.quantity > 2
)
and so.user_id is not null
order by 1;
		
--- Q5 ---
-- Розрахунок середнього чека онлайн / calculating the average online order value
select avg(total_check) as avg_total_check
from 
(
	select oisp.order_id, sum(oisp.quantity * psp.product_price) as total_check
	from order_items_sql_project oisp 
	left join products_sql_project psp 
		on psp.product_id = oisp.product_id 
	left join payments_sql_project p 
		on p.order_id = oisp.order_id
	where p.payment_status = 'Оплачено'
	group by oisp.order_id 
) as avg_check;
 
--- Q6 ---
-- Статистика покупок по каналах / purchase statistics by channel
with total_orders as
(
	select oisp.order_id, oisp.quantity, 'online' as order_type
	from order_items_sql_project oisp 
	union all
	select soi.store_order_id, soi.quantity, 'offline'
	from store_order_items soi 
)
select order_type, sum(quantity) as total_quantity, count(distinct order_id) as total_unique_orders
from total_orders
group by order_type
order by order_type, total_quantity, total_unique_orders;

--- Q7 ---
-- Визначення найпопулярніших товарів(важливо не кількість купленого товару, а кількість унікальних користувачів які купили цей товар) / identifying the most popular products (what matters is not the quantity sold but the number of unique users who bought the product)
-- один і той же користувач міг купити Пр: клавіатуру 3 рази, а порахуємо ми його 1 раз / the same user may have bought e.g. a keyboard 3 times, but we count them once
with product_by_users as 
(
	select oisp.order_id, oisp.product_id, osp.user_id 
	from order_items_sql_project oisp 
	inner join orders_sql_project osp 
		on oisp.order_id = osp.order_id
	union all
	select so.store_order_id, soi.product_id, so.user_id 
	from store_order_items soi 
	inner join store_orders so 
		on so.store_order_id = soi.store_order_id
)
select product_id, count(distinct user_id) as popular_unique_users
from product_by_users
where user_id is not null
group by product_id
order by popular_unique_users desc
limit 3;

--- Q8 ---
-- Порівняння середніх чеків / comparing the average order values
with total_orders as
(
	select oisp.order_id, sum(oisp.quantity * psp.product_price) as total_by_orders, 'online' as order_type
	from order_items_sql_project oisp 
	left join products_sql_project psp 
		on oisp.product_id = psp.product_id 
	group by oisp.order_id	
	union all
	select soi.store_order_id, sum(soi.quantity * psp.product_price), 'offline'
	from store_order_items soi 
	left join products_sql_project psp
		on soi.product_id = psp.product_id
	group by soi.store_order_id 
)
select order_type, avg(total_by_orders) as avg_total_orders
from total_orders
group by order_type
order by avg_total_orders;

--- Q9 ---
-- Пошук клієнтів з дорогими онлайн-покупка * / finding customers with expensive online purchases
with order_product_price as 
(
	select osp.user_id, oisp.order_id, psp.product_price 
	from order_items_sql_project oisp 
	left join products_sql_project psp 
		on psp.product_id = oisp.product_id
	left join orders_sql_project osp 
		on osp.order_id = oisp.order_id 
)
select distinct user_id 
from order_product_price
where product_price > 
(
	select avg(psp.product_price) as avg_price_offline
	from store_order_items soi 
	left join products_sql_project psp 
		on psp.product_id = soi.product_id
)	
order by 1;

--- Q10 ---
-- Аналіз великих сум замовлень по місяцях / analysis of large order totals by month
with all_orders as
(
	select oisp.order_id, oisp.product_id, oisp.quantity 
	from order_items_sql_project oisp 
	union all
	select soi.store_order_id, soi.product_id, soi.quantity 
	from store_order_items soi
),
orders_price as 
(
	select ao.order_id, sum(ao.quantity * psp.product_price) as order_price 
	from all_orders ao
	left join products_sql_project psp 
		on psp.product_id = ao.product_id 
	group by ao.order_id 
),
user_by_order as 
(
	select osp.order_id, osp.user_id, to_char(osp.order_date, 'yyyy-mm') as order_month
	from orders_sql_project osp 
	union all
	select so.store_order_id, so.user_id, to_char(so.order_date, 'yyyy-mm')
	from store_orders so 
)
select order_month, count(distinct osp.user_id) as user_quantity
from orders_price op
inner join user_by_order osp
	on osp.order_id = op.order_id
where op.order_price >
	(
		select avg(order_price)
		from orders_price 
	)
	and osp.user_id is not null
group by order_month
order by 1;

