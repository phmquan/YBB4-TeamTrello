SELECT * FROM members
SELECT * FROM menu
SELECT * FROM sales

-- JOIN 3 Tables
SELECT 
	*
FROM 
	sales s
LEFT JOIN
	members ms ON s.customer_id = ms.customer_id
LEFT JOIN
	menu mu ON s.product_id = mu.product_id

--What is the total amount each customer spent at the restaurant?
SELECT 
	s.customer_id, SUM(mu.price) as total_amount
FROM 
	sales s
JOIN
	menu mu ON s.product_id = mu.product_id
GROUP BY
	s.customer_id

--How many days has each customer visited the restaurant?
SELECT 
	s.customer_id, COUNT(DISTINCT order_date) AS visit_count
FROM 
	sales s
LEFT JOIN
	members ms ON s.customer_id = ms.customer_id
GROUP BY
	s.customer_id

--What was the first item from the menu purchased by each customer?
SELECT
	DISTINCT sa.customer_id, product_name AS first_item
FROM
	sales sa
JOIN
	menu mu ON sa.product_id = mu.product_id
WHERE
	sa.product_id = (
	SELECT 
		TOP 1 product_id
	FROM 
		sales
	WHERE
		customer_id = sa.customer_id
)
	
--What is the most purchased item on the menu and how many times was it purchased by all customers?
	--count number of order by each item
WITH ordered_count AS (
	SELECT product_id,count(s.product_id) as total_purchased
	FROM sales s
	GROUP BY s.product_id
),
	--query max in count of order
max_ordered AS (
	SELECT MAX(total_purchased) as max_ordered_count
	FROM ordered_count
)
	--from product_id get product_name in menu, display most purchased item
SELECT m.product_name, mp.max_ordered_count
FROM ordered_count pc
JOIN max_ordered mp ON pc.total_purchased = mp.max_ordered_count
JOIN menu m ON m.product_id = pc.product_id

--Which item was the most popular for each customer?
WITH order_count AS (
	--count purchased item by each customer
	SELECT customer_id,product_id, COUNT(product_id) as order_number
	FROM sales
	GROUP BY customer_id, product_id
	
),
max_order AS (
	--query max purchased item by each customer
	SELECT customer_id,MAX(order_number) as max_order_count
	FROM order_count
	GROUP BY customer_id
)
	--join with menu to get name of item
SELECT mo.customer_id, product_name, max_order_count 
FROM max_order mo
JOIN order_count oc ON oc.order_number = mo.max_order_count
JOIN menu me ON oc.product_id = me.product_id
WHERE mo.customer_id = oc.customer_id
ORDER BY mo.customer_id

--Which item was purchased first by the customer after they became a member?
	--query item after became member by each customer
WITH purchased_after_member AS (
	SELECT s.*,m.join_date,
	--store row number by order_date to get top 1
	ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rn
	FROM sales s
	JOIN members m ON s.customer_id = m.customer_id
	WHERE s.order_date >= m.join_date
)
	--join to get item's name and get row 1 by each customer
SELECT customer_id, m.product_name AS first_item_being_member, p.order_date, p.join_date
FROM purchased_after_member p
JOIN menu m ON p.product_id = m.product_id
WHERE p.rn = 1

--Which item was purchased just before the customer became a member?

WITH order_before_member AS (
	--query ordered before became memebr, 
	--FIRST order by order_date desceasing, 
	--SECOND order by product_id
	--** product_id is temporary approach bc not enough data to specify last order of the same date
 	SELECT s.customer_id, product_id, order_date, join_date,
	ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC,s.product_id DESC) AS rn
	FROM sales s
	JOIN members m ON s.customer_id = m.customer_id
	WHERE s.order_date < m.join_date
)
	--join with Menu table to get product_name, get first row by each customer
SELECT customer_id, product_name, order_date, join_date
FROM order_before_member obm
JOIN menu m ON obm.product_id = m.product_id
WHERE rn = 1

--What is the total items and amount spent for each member before they became a member?

SELECT s.customer_id, COUNT(s.customer_id) AS totel_purhased_items, SUM(mu.price) AS amount_spent
FROM sales s
JOIN members ms ON s.customer_id = ms.customer_id
JOIN menu mu ON mu.product_id = s.product_id
	--ensure order before became member
WHERE s.order_date < ms.join_date
	--count items and sum price by each customer 
GROUP BY s.customer_id;

--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
	--normal $1 -> 10 points
	--sushi 1$ -> 20 points
	--A 860 pts, B 940 pts, C 360 pts
WITH order_points AS (
	SELECT customer_id,
		CASE
			WHEN m.product_name = 'sushi' THEN m.price * 10 * 2
			ELSE m.price * 10
		END AS points
	FROM sales s
	JOIN menu m ON m.product_id = s.product_id
)

SELECT customer_id, SUM(points) as total_points
FROM order_points
GROUP BY customer_id;

--In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
	--first week after join member x2 points
	--query points each customer got until 31/1
	--A , B
	/*
	A 
	1 -200
	2- 150 - 350
	3- 300 - 650
	4- 240 - 890
	5 - 240 - 1130
	6 - 240 - 1370
	*/
WITH order_points AS (
	SELECT s.customer_id,
		CASE
			WHEN s.order_date BETWEEN ms.join_date AND DATEADD(DAY, 6,ms.join_date) --1 week after join memeber will x2 pts
				THEN mu.price * 10 * 2
			WHEN mu.product_name = 'sushi' --normal date with product sushi x2 pts
				THEN mu.price * 10 * 2
			ELSE mu.price * 10 --other product NOT x2 pts
		END AS points
	FROM sales s
	JOIN members ms ON ms.customer_id = s.customer_id
	JOIN menu mu ON mu.product_id = s.product_id
	--at the end of January
	WHERE s.order_date < '2021-1-31'
)

SELECT customer_id, 
	SUM(points) as total_points --sum point by each customer
FROM order_points
GROUP BY customer_id;
