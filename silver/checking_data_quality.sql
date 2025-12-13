------------------------------------------------------------
-- BRONZE.CAMPAIGNS – basic inspection & quality checks
-- (dataset_fashion_store_campaigns)
------------------------------------------------------------

-- 1) Look at all the raw rows in the campaigns table
SELECT *
FROM bronze.dataset_fashion_store_campaigns;

-- 2) How many campaigns do we have?
SELECT COUNT(*) AS row_count
FROM bronze.dataset_fashion_store_campaigns;

-- 3) List distinct discount types (e.g. Percentage, Fixed)
SELECT DISTINCT discount_type
FROM bronze.dataset_fashion_store_campaigns;

-- 4) List distinct channels used in campaigns
SELECT DISTINCT channel
FROM bronze.dataset_fashion_store_campaigns;

-- 5) Check for duplicate campaign IDs
SELECT campaign_id, COUNT(*) AS cnt
FROM bronze.dataset_fashion_store_campaigns
GROUP BY campaign_id
HAVING COUNT(*) > 1;

-- 6) Check campaigns where start_date > end_date
--    (invalid campaign period)
SELECT campaign_id, campaign_name, start_date, end_date
FROM bronze.dataset_fashion_store_campaigns
WHERE start_date > end_date;

-- 7) Look for NULLs in key columns
SELECT *
FROM bronze.dataset_fashion_store_campaigns
WHERE campaign_id IS NULL
   OR channel IS NULL
   OR start_date IS NULL
   OR end_date IS NULL;



------------------------------------------------------------
-- BRONZE.CHANNELS – basic inspection & quality checks
-- (dataset_fashion_store_channels)
------------------------------------------------------------

-- 1) Look at all channels
SELECT *
FROM bronze.dataset_fashion_store_channels;

-- 2) Count how many channels we have
SELECT COUNT(*) AS row_count
FROM bronze.dataset_fashion_store_channels;

-- 3) Check for duplicate channel names
SELECT channel, COUNT(*) AS cnt
FROM bronze.dataset_fashion_store_channels
GROUP BY channel
HAVING COUNT(*) > 1;

-- 4) Look for NULL or empty channel names
SELECT *
FROM bronze.dataset_fashion_store_channels
WHERE channel IS NULL
   OR LTRIM(RTRIM(channel)) = '';



------------------------------------------------------------
-- BRONZE.CUSTOMERS – basic inspection & quality checks
-- (dataset_fashion_store_customers)
------------------------------------------------------------

-- 1) Look at raw customer rows
SELECT *
FROM bronze.dataset_fashion_store_customers;

-- 2) Count customers
SELECT COUNT(*) AS row_count
FROM bronze.dataset_fashion_store_customers;

-- 3) Check for duplicate customer IDs
SELECT customer_id, COUNT(*) AS cnt
FROM bronze.dataset_fashion_store_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- 4) List distinct countries
SELECT DISTINCT country
FROM bronze.dataset_fashion_store_customers;

-- 5) List distinct age ranges
SELECT DISTINCT age_range
FROM bronze.dataset_fashion_store_customers;

-- 6) Customers with NULL or empty key fields
SELECT *
FROM bronze.dataset_fashion_store_customers
WHERE customer_id IS NULL
   OR country IS NULL
   OR LTRIM(RTRIM(country)) = '';

-- 7) Check signup dates that are in the future (suspicious)
SELECT *
FROM bronze.dataset_fashion_store_customers
WHERE signup_date > GETDATE();



------------------------------------------------------------
-- BRONZE.PRODUCTS – basic inspection & quality checks
-- (dataset_fashion_store_products)
------------------------------------------------------------

-- 1) Look at raw product rows
SELECT *
FROM bronze.dataset_fashion_store_products;

-- 2) Count products
SELECT COUNT(*) AS row_count
FROM bronze.dataset_fashion_store_products;

-- 3) Check for duplicate product IDs
SELECT product_id, COUNT(*) AS cnt
FROM bronze.dataset_fashion_store_products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- 4) Check for duplicate product names
SELECT product_name, COUNT(*) AS cnt
FROM bronze.dataset_fashion_store_products
GROUP BY product_name
HAVING COUNT(*) > 1;

-- 5) List distinct categories and genders
SELECT DISTINCT category
FROM bronze.dataset_fashion_store_products;

SELECT DISTINCT gender
FROM bronze.dataset_fashion_store_products;

-- 6) Products with NULL or invalid prices / costs
SELECT *
FROM bronze.dataset_fashion_store_products
WHERE catalog_price IS NULL
   OR cost_price    IS NULL
   OR catalog_price <= 0
   OR cost_price    <= 0;

-- 7) Products with negative or very low margin (catalog_price < cost_price)
SELECT *
FROM bronze.dataset_fashion_store_products
WHERE catalog_price < cost_price;



------------------------------------------------------------
-- BRONZE.SALES – basic inspection & quality checks
-- (dataset_fashion_store_sales)
------------------------------------------------------------

-- 1) Look at raw sales (order header) rows
SELECT *
FROM bronze.dataset_fashion_store_sales;

-- 2) Count sales (orders)
SELECT COUNT(*) AS row_count
FROM bronze.dataset_fashion_store_sales;

-- 3) Check for duplicate sale IDs
SELECT sale_id, COUNT(*) AS cnt
FROM bronze.dataset_fashion_store_sales
GROUP BY sale_id
HAVING COUNT(*) > 1;

-- 4) Distinct channels and countries in sales
SELECT DISTINCT channel
FROM bronze.dataset_fashion_store_sales;

SELECT DISTINCT country
FROM bronze.dataset_fashion_store_sales;

-- 5) Sales with NULL or suspicious total_amount
SELECT *
FROM bronze.dataset_fashion_store_sales
WHERE total_amount IS NULL
   OR total_amount <= 0;

-- 6) Sales with sale_date in the future
SELECT *
FROM bronze.dataset_fashion_store_sales
WHERE sale_date > GETDATE();

-- 7) Sales with missing customer or channel
SELECT *
FROM bronze.dataset_fashion_store_sales
WHERE customer_id IS NULL
   OR channel     IS NULL;



------------------------------------------------------------
-- BRONZE.SALESITEMS – basic inspection & quality checks
-- (dataset_fashion_store_salesitems)
------------------------------------------------------------

-- 1) Look at raw sales item rows (order lines)
SELECT *
FROM bronze.dataset_fashion_store_salesitems;

-- 2) Count sales items
SELECT COUNT(*) AS row_count
FROM bronze.dataset_fashion_store_salesitems;

-- 3) Check for duplicate item IDs
SELECT item_id, COUNT(*) AS cnt
FROM bronze.dataset_fashion_store_salesitems
GROUP BY item_id
HAVING COUNT(*) > 1;

-- 4) Check that quantity is positive
SELECT *
FROM bronze.dataset_fashion_store_salesitems
WHERE quantity IS NULL
   OR quantity <= 0;

-- 5) Distinct channels used in salesitems
SELECT DISTINCT channel
FROM bronze.dataset_fashion_store_salesitems;

-- 6) Check consistency between unit_price, quantity and item_total
--    (item_total should be roughly unit_price * quantity)
SELECT 
    item_id,
    sale_id,
    product_id,
    quantity,
    unit_price,
    item_total,
    (unit_price * quantity) AS calc_item_total
FROM bronze.dataset_fashion_store_salesitems
WHERE item_total IS NULL
   OR ABS(item_total - (unit_price * quantity)) > 0.01;

-- 7) Check discount_percent values (e.g. text like '10.00%')
SELECT DISTINCT discount_percent
FROM bronze.dataset_fashion_store_salesitems;

-- 8) Sales items with sale_date in the future
SELECT *
FROM bronze.dataset_fashion_store_salesitems
WHERE sale_date > GETDATE();



------------------------------------------------------------
-- BRONZE.STOCK – basic inspection & quality checks
-- (dataset_fashion_store_stock)
------------------------------------------------------------

-- 1) Look at raw stock rows
SELECT *
FROM bronze.dataset_fashion_store_stock;

-- 2) Count stock records
SELECT COUNT(*) AS row_count
FROM bronze.dataset_fashion_store_stock;

-- 3) Check for duplicate (country, product_id) combinations
SELECT country, product_id, COUNT(*) AS cnt
FROM bronze.dataset_fashion_store_stock
GROUP BY country, product_id
HAVING COUNT(*) > 1;

-- 4) Check for negative or NULL stock quantities
SELECT *
FROM bronze.dataset_fashion_store_stock
WHERE stock_quantity IS NULL
   OR stock_quantity < 0;

-- 5) List distinct countries in stock
SELECT DISTINCT country
FROM bronze.dataset_fashion_store_stock;
