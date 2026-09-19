Use Data_Ware_House;


-- reporting
 with base_query as (
 
 select 
	f.orderr_number,
	f.product_key,
	f.order_date,
	f.sales_amount,
	f.quanity,
	c.customer_key,
	c.customer_number,
	concat(c.first_name ,' ',c.last_name) as customer_name,
	datediff(year,c.brithdate,getdate()) as age
from gold.fact_sales f left join gold.dim_customers c
on f.customer_id =  c.customer_id
where f.order_date is not null 
) ,
t as (
select 
	customer_key,
	customer_number,
	customer_name,
	age,
	count(distinct orderr_number) as total_orders,
	sum(quanity) as total_quantity,
	sum(sales_amount) as total_amount,
	count(distinct product_key) as total_product,
	max(order_date) as last_order_date,
	datediff(month,min(order_date),max(order_date)) as lifespan
from base_query
group by 
	customer_key,
	customer_number,
	customer_name,
	age
	)
select 
customer_key,
customer_number,
customer_name,
age,
case 
	when age < 20 then 'Under 20'
	when age between 20 and 29 then '20-29'
	when age between 30 and 39 then '30-39'
	when age between 40 and 49 then '40-49'
	else '50 and above'
end as age_group,
case
	when lifespan>=12 and total_amount > 5000 then 'VIP'
	when lifespan>=12 and total_amount > 5000 then 'Regular'
	else 'New'
end as customer_segment,
datediff (month ,last_order_date ,getdate()) as recency,
total_orders,
total_amount,
total_quantity,
total_amount,
total_product,
last_order_date,
lifespan,
case when total_amount = 0 then 0 
else total_amount/total_orders
end as avg_order_value,
total_amount/total_orders as avg_order_value
from t

