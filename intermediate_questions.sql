--Intermediate Level
--1. What are the monthly sales trends?
SELECT
	DATE_TRUNC('month', o.order_date) AS month,
	SUM(oi.sales_amount) AS total_sales
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY month
ORDER BY month;

--2. Which products had the highest sales?

SELECT 
	product_name,
	ROUND(SUM(oi.sales_amount)::numeric, 2) AS highest_sales
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP By product_name
ORDER BY highest_sales DESC;
	

--3. How many orders were shipped via each shipping mode?
SELECT
	s.ship_mode,
	COUNT(DISTINCT oi.order_id) AS total_orders
FROM shipping_items s
JOIN order_items oi
	ON s.order_items_id = oi.order_items_id
GROUP BY ship_mode
ORDER BY total_orders DESC;


--4. What is the average sales per customer?

SELECT
	c.customer_name AS customers,
	AVG(oi.sales_amount) AS avg_sales
FROM customers c
JOIN orders o
	ON c.customer_id = o.customer_id
JOIN order_items oi
	ON o.order_id = oi.order_id
GROUP BY c.customer_name
ORDER BY avg_sales DESC;

	
--5. Which customers placed the most orders?

SELECT 
	c.customer_name AS Customers,
	COUNT(DISTINCT o.order_id) AS most_orders
FROM customers c
JOIN orders o
	ON c.customer_id = o.customer_id
GROUP BY c.customer_name
ORDER BY most_orders DESC;