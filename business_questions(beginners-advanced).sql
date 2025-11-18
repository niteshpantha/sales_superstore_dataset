---Beginner Level
-- 1. What is the total sales in the dataset?
SELECT
	COUNT(sales_amount) AS Total_sales 
FROM order_items;

-- 2. How much did each category sell in total?
SELECT 
	c.category AS Categories,
	SUM(oi.sales_amount) as Total_sales
FROM categories c
JOIN sub_categories sc
ON c.cat_id = sc.cat_id
JOIN products p
ON p.sub_cat_id = sc.sub_cat_id
JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY Categories
ORDER BY Total_sales DESC;

-- 3. Which customers generated the highest sales?
SELECT
	c.customer_name,
	ROUND(SUM(oi.sales_amount)::numeric, 2) AS Highest_Sales
FROM customers c
JOIN orders o
	ON c.customer_id = o.customer_id
JOIN order_items oi
	ON o.order_id = oi.order_id
GROUP BY c.customer_name
ORDER BY Highest_Sales DESC;

-- 4. How many orders are there for each customer segment?
SELECT
	c.segment,
	COUNT(o.order_id) as total_orders
FROM customers c
LEFT JOIN orders o  ---using left join instead of inner join to include all the customers who doesnot even make any order
	ON c.customer_id = o.customer_id
GROUP BY c.segment
ORDER BY total_orders DESC;

-- 5. What is the total sales in the South region?
SELECT 
	ROUND(SUM(oi.sales_amount)::numeric, 2) AS total_south_sales
FROM geography g
JOIN orders o
ON g.geo_id = o.geo_id
JOIN order_items oi
ON o.order_id = oi.order_id
WHERE g.region = 'South';

