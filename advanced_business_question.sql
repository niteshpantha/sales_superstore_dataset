-- Advanced Level
-- 1. Calculate the total sales for each category in each region
SELECT
	c.category,
	g.region,
	ROUND(SUM(oi.sales_amount)::numeric, 2) AS total_sales
FROM order_items oi
JOIN orders o
	ON o.order_id = oi.order_id
JOIN geography g
	ON g.geo_id = o.geo_id
JOIN products p
	ON p.product_id = oi.product_id
JOIN sub_categories sc
	ON p.sub_cat_id = sc.sub_cat_id
JOIN categories c
	ON sc.cat_id = c.cat_id
GROUP BY c.category, g.region
ORDER BY c.category, total_sales DESC;


-- 2. Identify repeat customers and compare their total sales to single-time customers.
With my_cte AS (
SELECT
	c.customer_id,
	c.customer_name,
	SUM(oi.sales_amount) AS total_sales,
	COUNT(DISTINCT o.order_id) AS order_count
FROM customers c
INNER JOIN orders o
	ON c.customer_id = o.customer_id
INNER JOIN order_items oi
	ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name
)
SELECT 
	CASE WHEN order_count > 1 THEN 'Repeat-Customer' ELSE 'One-Time-Customer' END AS customer_type,
	COUNT(*) as num_customers,
	SUM(total_sales) AS combined_total_sales
FROM my_cte
GROUP BY customer_type
ORDER BY combined_total_sales DESC;


-- 3. Calculate days between order_date and ship_date and find the fastest shipping mode.
WITH shipping AS (
SELECT 
	o.order_id,
	o.order_date,
	si.ship_date,
	si.ship_mode,
	(si.ship_date - o.order_date) AS days_for_shipping
FROM shipping_items si
JOIN order_items oi
	ON oi.order_items_id = si.order_items_id
JOIN orders o
	ON o.order_id = oi.order_id
WHERE si.ship_date IS NOT NULL
	AND o.order_date IS NOT NULL
)
SELECT 
	ship_mode,
COUNT(*) AS shipment_count,
MIN(days_for_shipping) as min_shipping_days,
MAX(days_for_shipping) AS max_shipping_days,
ROUND(AVG(days_for_shipping)::numeric, 2) AS avg_shipping_days
FROM shipping
GROUP BY ship_mode
ORDER BY avg_shipping_days;


-- 4. What percentage of total sales comes from each region?
WITH region_sales AS (
SELECT 
	g.region,
	ROUND(SUM(oi.sales_amount)::numeric,2) AS total_region_sales
FROM geography g
JOIN orders o
	ON o.geo_id = g.geo_id
JOIN order_items oi
	ON oi.order_id = o.order_id
GROUP BY region
), 
total AS (
SELECT SUM(total_region_sales) AS total_sales FROM region_sales
)
SELECT
	rs.region,
	rs.total_region_sales,
	ROUND((rs.total_region_sales / t.total_sales * 100)::numeric, 2) AS per_total_sales
FROM region_sales rs
CROSS JOIN total t
ORDER BY per_total_sales DESC;

-- 5. Compare year-over-year sales growth and identify the year with the highest growth.

WITH yearly_data AS (
	SELECT
	EXTRACT(YEAR FROM o.order_date)::int AS yr,
	SUM(oi.sales_amount) AS total_sales
	FROM orders o
	JOIN order_items oi
	ON o.order_id = oi.order_id
	GROUP BY yr
	), 
	with_lag AS (
	SELECT
		yr,
		total_sales,
		LAG(total_sales) OVER (ORDER BY yr) AS prev_year_sales
	FROM yearly_data
)

SELECT
yr,
total_sales,
prev_year_sales,
CASE
	WHEN prev_year_sales IS NULL THEN NULL
	WHEN prev_year_sales = 0 THEN NULL
	ELSE ROUND((((total_sales - prev_year_sales) / total_sales) * 100)::numeric, 2)
END AS yoy_pct_growth
FROM with_lag 
ORDER BY yr;



-- 6. Identify customers who buy from more than one category.

-- solution using cte
WITH customers_data AS (
	SELECT
		c.customer_id,
		c.customer_name,
		COUNT(DISTINCT cat.category) as unique_cat_count
	FROM categories cat
	JOIN sub_categories sc
		ON sc.cat_id = cat.cat_id
	JOIN products p
		ON p.sub_cat_id = sc.sub_cat_id
	JOIN order_items oi
		ON oi.product_id = p.product_id
	JOIN orders o
		ON o.order_id = oi.order_id
	JOIN customers c
		ON o.customer_id = c.customer_id
	GROUP BY c.customer_id,c.customer_name

)
SELECT
	cd.customer_id,
	cd.customer_name,
	cd.unique_cat_count,
	(cd.unique_cat_count > 1) AS multiple_purchase
FROM customers_data cd
ORDER BY multiple_purchase DESC, cd.unique_cat_count DESC;


-- solution without using cte
SELECT
	c.customer_id,
	c.customer_name,
	COUNT(DISTINCT cat.category) as unique_cat_count
FROM categories cat
JOIN sub_categories sc
	ON sc.cat_id = cat.cat_id
JOIN products p
	ON p.sub_cat_id = sc.sub_cat_id
JOIN order_items oi
	ON oi.product_id = p.product_id
JOIN orders o
	ON o.order_id = oi.order_id
JOIN customers c
	ON o.customer_id = c.customer_id
GROUP BY c.customer_id,c.customer_name
HAVING COUNT(DISTINCT cat.category) > 1
ORDER BY unique_cat_count DESC;

