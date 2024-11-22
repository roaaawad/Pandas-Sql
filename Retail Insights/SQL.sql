--select * from df_orders
--quetions
WITH x AS (
    SELECT 
        SUM(list_price) AS sales,
        product_id,
        ROW_NUMBER() OVER (ORDER BY SUM(list_price) DESC) AS rn
    FROM df_orders
    GROUP BY product_id
)
SELECT sales,
        product_id
FROM x
WHERE rn <= 10;

--select top 10 product_id,sum(list_price) as sales
--from df_orders
--group by product_id
--order by sales desc
with x as(
select product_id,region,sum(list_price) s
from df_orders
group by product_id,region
)

select product_id, region,s as sales from (
select * , ROW_NUMBER() over (partition by region order by s desc ) rn
from x) as M
where rn<=5

----find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
with x as (
select year(order_date) year,month(order_date) month ,SUM(list_price) s
from df_orders
group by   year(order_date),month(order_date)
)

select month,
sum(case when year = 2022 then s else 0   end) as Sales2022,
sum(case when year = 2023 then s else 0   end) as Sales2023
 
from x
group by month
order by month

--for each category which month had highest sales 

with x as(
select  category,format(order_date,'yyyyMM') m ,sum(list_price) s
from df_orders
group by category,format(order_date,'yyyyMM'))
select category,m as month , s as sales from (
select *, ROW_NUMBER() over (partition by category order by s desc) rn from x
) a
where rn=1


--which sub category had highest growth by profit in 2023 compare to 2022

with x as (
select  sub_category ,  year(order_date) year,SUM(list_price) s
from df_orders
group by   year(order_date),sub_category
)
, x2 as(
select sub_category,
sum(case when year = 2022 then s else 0   end) as Sales2022,
sum(case when year = 2023 then s else 0   end) as Sales2023
 
from x
group by sub_category)

select top 1 *
,(Sales2023-Sales2022) difference_of_growth
from  x2
order by difference_of_growth desc
