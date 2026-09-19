-- CHANGE-OVER-TIME-TRENDS

select
year(order_date) as Order_Year,
sum(sales_amount) as Total_Amount,
count(distinct customer_id) as Total_customers,
sum(quanity) as total_quanity
from gold.fact_sales
where order_date is not null
group by year(order_date)
order by year(order_date) ;

select
month(order_date) as Order_month,
sum(sales_amount) as Total_Amount,
count(distinct customer_id) as Total_customers,
sum(quanity) as total_quanity
from gold.fact_sales
where order_date is not null
group by month(order_date)
order by month(order_date) ;



select
year(order_date) as Order_year,
month(order_date) as Order_month,
sum(sales_amount) as Total_Amount,
count(distinct customer_id) as Total_customers,
sum(quanity) as total_quanity
from gold.fact_sales
where order_date is not null
group by year(order_date),month(order_date)
order by year(order_date),month(order_date) ;

-- CHANGE-OVER-TIME-TRENDS
select
datetrunc(month,order_date) as Order_date,
sum(sales_amount) as Total_Amount,
count(distinct customer_id) as Total_customers,
sum(quanity) as Total_quanity
from gold.fact_sales
where order_date is not null
group by datetrunc(month,order_date)
order by datetrunc(month,order_date);

-- sorting problem in this that why not recommened 
select
format(order_date, 'yyyy-MMM') as Order_date,
sum(sales_amount) as Total_Amount,
count(distinct customer_id) as Total_customers,
sum(quanity) as total_quanity
from gold.fact_sales
where order_date is not null
group by format(order_date, 'yyyy-MMM')
order by format(order_date, 'yyyy-MMM');


-- CUMULATIVE ANALYSIS

select
datetrunc(month,order_date) as Order_date,
sum(sales_amount) as Total_Amount,
sum(sum(sales_amount)) over (partition by datetrunc(month,order_date) order by datetrunc(month,order_date)) as Running_Total
from gold.fact_sales
where order_date is not null
group by datetrunc(month,order_date)
order by datetrunc(month,order_date);


-- by parition this way you see the difference
select
Order_date,
Total_Amount,
sum(Total_Amount) over (partition by Order_date  order by Order_date ) as Running_Total
  from
 (
select
datetrunc(month,order_date) as Order_date,
sum(sales_amount) as Total_Amount
from gold.fact_sales
where order_date is not null
group by datetrunc(month,order_date)
) as t


-- not partition
select
Order_date,
Total_Amount,
sum(Total_Amount) over (  order by Order_date ) as Running_Total
  from
 (
select
datetrunc(month,order_date) as Order_date,
sum(sales_amount) as Total_Amount
from gold.fact_sales
where order_date is not null
group by datetrunc(month,order_date)
) as t

-- by year running total
select
Order_date,
Total_Amount,
sum(Total_Amount) over (  order by Order_date ) as Running_Total,
Avg(avg_price) over (  order by Order_date ) as moving_average_price
  from
 (
select
datetrunc(year,order_date) as Order_date,
sum(sales_amount) as Total_Amount,
avg(sls_price) as avg_price
from gold.fact_sales
where order_date is not null
group by datetrunc(year,order_date)
) as t



-- PERFORMANCE ANALYSIS
with yearly_product_sales as (
 select 
 year(fs.order_date) as order_year,
 pr.product_name,
 sum(fs.sales_amount) as current_sales
from gold.fact_sales fs left join  gold.dim_products pr
 on pr.product_key = fs.product_key
 where order_date is not null
 group by  year(fs.order_date), pr.product_name
 )
select 
order_year,
product_name,
current_sales,
avg(current_sales) over (partition by product_name) as avg_sales,
current_sales - avg(current_sales) over (partition by product_name) as diff_avg,
case 
when current_sales - avg(current_sales) over (partition by product_name) > 0 then 'Above Avg'
when current_sales - avg(current_sales) over (partition by product_name) < 0 then 'Below Avg'
else 'Avg'
end as avg_change,
lag(current_sales) over (partition by product_name order by order_year) as previous_sales,
current_sales - lag(current_sales) over (partition by product_name order by order_year) as diff_py,

case 
when current_sales - lag(current_sales) over (partition by product_name order by order_year) > 0 then 'Increase'
when current_sales - lag(current_sales) over (partition by product_name order by order_year) < 0 then 'Decrease'
else 'No Change'
end as py_change
from yearly_product_sales
order by product_name,order_year;

--  part to whole of analysis

 select 
 pr.category,
 sum(fs.sales_amount) as Total_sales,
 sum( sum(fs.sales_amount)) over() as Overall_sales,
concat( round(cast(sum(fs.sales_amount) as float)*100/sum( sum(fs.sales_amount)) over() ,2) ,'%')  as percent_wise_category
from gold.fact_sales fs left join  gold.dim_products pr
 on pr.product_key = fs.product_key
  group by  pr.category
order by 2 desc;

-- DATA SEGMENTATION
with product_segments as 
(
 select 
 product_key,
 product_name,
 cost ,
 case 
	 when cost < 100 then 'Below 100'
	  when cost between  100 and 500 then '100-500'
	   when cost between 500 and 1000 then '500-1000'
	   else 'Above 1000'
	   end cost_range
from  gold.dim_products
 
 )
 select
 cost_range,
 count(product_key) as Total_Products
 from product_segments
 group by cost_range
 order by count(product_key) desc;

with customer_spending as (
 select 
 cu.customer_id ,
 sum(fs.sales_amount) as total_spending,
 min(fs.order_date) as first_order,
 max(fs.order_date) as last_order,
 datediff(month,min(fs.order_date),max(fs.order_date)) as lifespan
from gold.fact_sales fs left join gold.dim_customers cu on
fs.customer_id = cu.customer_id
group by  cu.customer_id, fs.order_date
)

select
customer_segment,
count(customer_id) as total_customers
from(
select
customer_id,
case 
	when lifespan >= 12 and total_spending > 5000 then 'VIP'
	when lifespan >= 12 and total_spending <= 5000 then 'Regular'
	else 'New'
	end customer_segment,
	count (customer_id) as Total_customer
from customer_spending)t
group by 1
order by 2 desc;


 








 select 
 
  distinct cost 
from  gold.dim_products
 order by cost desc; 

 




































