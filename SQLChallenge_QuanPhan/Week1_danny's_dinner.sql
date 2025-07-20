--1.What is the total amount each customer spent at the restaurant?**
SELECT sales.customer_id,
	SUM(menu.price) AS total_amount_spent
FROM sales
JOIN menu ON sales.product_id=menu.product_id
GROUP BY
sales.customer_id
--2. How many days has each customer visited the restaurant?
SELECT sales.customer_id,
	COUNT(sales.order_date) AS total_day_visited
FROM sales
JOIN menu ON sales.product_id=menu.product_id
GROUP BY sales.customer_id
--3.What was the first item from the menu purchased by each customer?
with ranked_sales as(
	select
		s.customer_id,
		m.product_name,
		s.order_date,
		ROW_NUMBER() over (
			partition BY s.customer_id
			ORDER BY s.order_date
		) AS rank
	from sales s
	join menu m on s.product_id=m.product_id
)
select 
	customer_id, 
	product_name as first_product
from ranked_sales
where rank =1
