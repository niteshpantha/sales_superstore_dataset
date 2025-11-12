create table to fetch data from csv file
CREATE TABLE sales_superstore (
row_id SERIAL PRIMARY KEY,
order_id VARCHAR(50) NOT NULL,
order_date DATE,
ship_date DATE,
ship_mode VARCHAR(50),
customer_id VARCHAR(50) NOT NULL,
customer_name VARCHAR(50),
segment VARCHAR(50),
country VARCHAR(50),
city VARCHAR(50),
state VARCHAR(50),
postal_code VARCHAR(50),
region VARCHAR(50),
product_id VARCHAR(50) NOT NULL,
category VARCHAR(50),
sub_category VARCHAR(50),
product_name TEXT,
sales FLOAT
);


-- let's check if the csv file's imported or not
SELECT * FROM sales_superstore
LIMIT 5;


--Lets normalize the table
CREATE TABLE customers (
	customer_id VARCHAR(50) PRIMARY KEY,
	customer_name VARCHAR(50) NOT NULL,
	segment VARCHAR(50)
);
CREATE TABLE geography (
	geo_id SERIAL PRIMARY KEY,
	country VARCHAR(50),
	city VARCHAR(50),
	state VARCHAR(100),
	postal_code VARCHAR(50),
	region VARCHAR(50),
	UNIQUE(country, city, state, postal_code, region)
);

CREATE TABLE categories(
	cat_id SERIAL PRIMARY KEY,
	category VARCHAR(50) UNIQUE
);

CREATE TABLE sub_categories(
	sub_cat_id SERIAL PRIMARY KEY,
	sub_category VARCHAR(50),
	cat_id INT REFERENCES categories(cat_id) ON DELETE CASCADE,
	UNIQUE(sub_category, cat_id)
);

CREATE TABLE products (
	product_id VARCHAR(50) PRIMARY KEY,
	product_name TEXT,
	sub_cat_id INT REFERENCES sub_categories(sub_cat_id) ON DELETE CASCADE
);

CREATE TABLE orders (
	order_id VARCHAR(50) PRIMARY KEY,
	order_date DATE,
	geo_id INT REFERENCES geography(geo_id) ON DELETE CASCADE,
	customer_id VARCHAR(50) REFERENCES customers(customer_id) ON DELETE CASCADE
);

--order-items helps to connects orders with product
CREATE TABLE order_items (
	order_items_id SERIAL PRIMARY KEY,
	order_id VARCHAR(50) REFERENCES orders(order_id) ON DELETE CASCADE ON UPDATE CASCADE,
	product_id VARCHAR(50) REFERENCES products(product_id) ON DELETE CASCADE,
	sales_amount FLOAT,
	quantity INT DEFAULT 1
);

CREATE TABLE shipping_items (
	shipping_id SERIAL PRIMARY KEY,
	ship_date DATE,
	ship_mode VARCHAR(50),
	order_items_id INT REFERENCES order_items(order_items_id) ON DELETE CASCADE
);

-- lets insert values on the corresponding tables just created
--insert distinct values on corresponding tables 


-- lets insert values in customer table
INSERT INTO customers (customer_id, customer_name, segment)
SELECT DISTINCT  customer_id, customer_name, segment
FROM sales_superstore;
--lets confirm by running a simple code
SELECT* FROM customers
LIMIT 5;

-- inserting values in geography table
INSERT INTO geography (country, city, state, postal_code, region)
SELECT DISTINCT country, city, state, postal_code, region
FROM sales_superstore;
--lets confirm if the data has been retrieved
SELECT * FROM geography
LIMIT 5;

--insert distinct categories in categories table from csv
INSERT INTO categories (category)
SELECT DISTINCT category
FROM sales_superstore;
--lets confirm if the data has been inserted on categories table
SELECT * FROM categories
LIMIT 5;

--insert sub-categories into sub-categories table from csv
INSERT INTO sub_categories (sub_category, cat_id)
SELECT DISTINCT s.sub_category, c.cat_id
FROM sales_superstore s
JOIN categories c
ON s.category = c.category;
-- checking first 5 entries to validate the data is inserted
SELECT * FROM sub_categories
LIMIT 5;


-- inserting values in products table
INSERT INTO products (product_id, product_name, sub_cat_id)
SELECT DISTINCT ON (s.product_id)  -- helps to pick one row per product_id as we have multiple product_ids which throws error
       s.product_id, s.product_name, sc.sub_cat_id
FROM sales_superstore s
JOIN sub_categories sc
  ON s.sub_category = sc.sub_category
ORDER BY s.product_id, s.product_name;

-- inserting data into orders table
INSERT INTO orders (order_id, order_date, geo_id, customer_id)
SELECT DISTINCT s.order_id, s.order_date, g.geo_id, s.customer_id
FROM sales_superstore s
JOIN geography g
  ON s.country = g.country
 AND s.city = g.city
 AND s.state = g.state
 AND s.postal_code = g.postal_code
 AND s.region = g.region;
-- checking the fetched data
SELECT * FROM orders LIMIT 5;


-- inserting values in order_items table
INSERT INTO order_items (order_id, product_id, sales_amount)
SELECT s.order_id, s.product_id, s.sales
FROM sales_superstore s;
-- checking the inserted values
SELECT * FROM order_items LIMIT 5;

-- inserting data into shipping items from sales_superstore
INSERT INTO shipping_items (ship_date, ship_mode, order_items_id)
SELECT s.ship_date, s.ship_mode, oi.order_items_id
FROM sales_superstore s
JOIN order_items oi
	ON s.product_id = oi.product_id
	AND s.order_id = oi.order_id
-- fetching data using select keyword
SELECT * FROM shipping_items LIMIT 5;




