ALTER TABLE silver.campaigns
ALTER COLUMN discount_value INT

TRUNCATE TABLE silver.campaigns;
INSERT INTO silver.campaigns (
    campaign_id,
    campaign_name,
    channel,
    start_date,
    end_date,
    discount,          -- Percentage / Fixed
    discount_value     -- INT in Silver
)
SELECT
    campaign_id,
    campaign_name,
    channel,
    TRY_CONVERT(date, start_date) AS start_date,
    TRY_CONVERT(date, end_date)   AS end_date,
    discount,
    CASE
        WHEN discount = 'Percentage' THEN
            -- '10.00%' -> remove '%' -> 10.00 -> 10 (INT)
            CAST(CAST(REPLACE(discount_value, '%', '') AS DECIMAL(10,2)) AS INT)
        WHEN discount = 'Fixed' THEN
            -- '10' or '12' -> 10 / 12 (INT)
            CAST(discount_value AS INT)
        ELSE
            NULL
    END AS discount_value
FROM bronze.fashion_store_campaigns;

TRUNCATE TABLE silver.channels;
INSERT INTO silver.channels(
           channel,
           description)
SELECT channel, description FROM bronze.fashion_store_channels


TRUNCATE TABLE silver.customers;
INSERT INTO silver.customers (
    customer_id,
    country,
    age_range,
    signup_date
)
SELECT
    customer_id,
    LTRIM(RTRIM(country))    AS country,
    LTRIM(RTRIM(age_range))  AS age_range,
    signup_date
FROM bronze.fashion_store_customers;

TRUNCATE TABLE silver.products;
INSERT INTO silver.products (
    product_id,
    product_name,
    category,
    brand,
    color,
    size,
    gender,
    catalog_price,
    cost_price
)
SELECT
    product_id,
    LTRIM(RTRIM(product_name)) AS product_name,
    LTRIM(RTRIM(category))     AS category,
    LTRIM(RTRIM(brand))        AS brand,
    LTRIM(RTRIM(color))        AS color,
    LTRIM(RTRIM(size))         AS size,
    LTRIM(RTRIM(gender))       AS gender,
    catalog_price,
    cost_price
FROM bronze.fashion_store_products;


TRUNCATE TABLE silver.sales;
INSERT INTO silver.sales (
    sale_id,
    channel,
    discounted,
    total_amount,
    sale_date,
    customer_id,
    country
)
SELECT
    sale_id,
    LTRIM(RTRIM(channel))  AS channel,
    TRY_CONVERT(int, discounted) AS discounted,
    TRY_CONVERT(decimal(18,2), total_amount) AS total_amount,
    sale_date,
    customer_id,
    LTRIM(RTRIM(country))  AS country
FROM bronze.fashion_store_sales;


TRUNCATE TABLE silver.salesitems;
INSERT INTO silver.salesitems (
    item_id,
    sale_id,
    product_id,
    quantity,
    original_price,
    unit_price,
    discount_applied,
    discount_percent,
    discounted,
    item_total,
    sale_date,
    channel,
    channel_campaigns
)
SELECT
    item_id,
    sale_id,
    product_id,
    TRY_CONVERT(int, quantity) AS quantity,
    TRY_CONVERT(decimal(18,2), original_price) AS original_price,
    TRY_CONVERT(decimal(18,2), unit_price)     AS unit_price,
    TRY_CONVERT(decimal(18,2), discount_applied) AS discount_applied,

    -- '10.00%' -> 10.00 (DECIMAL)
    CASE
        WHEN discount_percent IS NULL THEN NULL
        ELSE TRY_CONVERT(decimal(5,2), REPLACE(discount_percent, '%', ''))
    END AS discount_percent,
    discounted,
    item_total,
    sale_date,
    LTRIM(RTRIM(channel)) AS channel,
    LTRIM(RTRIM(channel_campaigns)) AS channel_campaigns
FROM bronze.fashion_store_salesitems;


TRUNCATE TABLE silver.stock;
INSERT INTO silver.stock (
    country,
    product_id,
    stock_quantity
)
SELECT
    LTRIM(RTRIM(country)) AS country,
    product_id,
    stock_quantity
FROM bronze.fashion_store_stock;

