/* --------------------
   Case Study Questions
   --------------------*/
SELECT *
FROM members 

SELECT *
FROM menu

SELECT *
FROM sales 

-- 1. What is the total amount each customer spent at the restaurant?

SELECT s.customer_id, SUM(m.price) AS total_amount
FROM sales as s
INNER JOIN menu as m ON s.product_id = m.product_id
GROUP BY s.customer_id


-- 2. How many days has each customer visited the restaurant?
SELECT s.customer_id,COUNT(DISTINCT(s.order_date)) as total_days
FROM sales as s
GROUP BY s.customer_id

-- 3. What was the first item from the menu purchased by each customer?
SELECT customer_id, product_name
FROM (
  SELECT s.customer_id,s.order_date,m.product_name,
    ROW_NUMBER() OVER (
      PARTITION BY s.customer_id
      ORDER BY s.order_date
    ) AS rn
  FROM sales s
  JOIN menu m ON s.product_id = m.product_id
) AS first_item
WHERE rn = 1;

			


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT TOP 1 m.product_id, m.product_name, COUNT(*) AS total_purchased
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY m.product_id, m.product_name
ORDER BY total_purchased DESC;

-- 5. Which item was the most popular for each customer?

SELECT customer_id, product_id, total
FROM (
  SELECT s.customer_id,s.product_id, COUNT(*) as total,
    ROW_NUMBER() OVER (
      PARTITION BY s.customer_id
      ORDER BY COUNT(*) DESC
    ) AS rn
  FROM sales s
  INNER JOIN menu m ON s.product_id = m.product_id
  GROUP BY s.customer_id, s.product_id 
) AS first_item
WHERE rn = 1;

-- 6. Which item was purchased first by the customer after they became a member?
(
SELECT s.customer_id, s.order_date, ROW_NUMBER() OVER (
      PARTITION BY s.customer_id
      ORDER BY COUNT(*) DESC
    ) AS rn
FROM sales s
INNER JOIN members mem ON s.customer_id = mem.customer_id
WHERE s.order_date > mem.join_date
GROUP BY s.customer_id, s.order_date 
) AS first_item

-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
