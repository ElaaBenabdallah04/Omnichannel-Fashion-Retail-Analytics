IF OBJECT_ID('silver.fashion_store_campaigns', 'U') IS NOT NULL
    DROP TABLE silver.fashion_store_campaigns;
GO
CREATE TABLE silver.fashion_store_campaigns(
    campaign_id NVARCHAR(50),
    campaign_name NVARCHAR(50),
    start_date DATE,
    end_date DATE,
    channel NVARCHAR(50),
    discount NVARCHAR(50),
    discount_value NVARCHAR(50)
    );
GO
IF OBJECT_ID('silver.fashion_store_channels', 'U') IS NOT NULL
    DROP TABLE silver.fashion_store_channels;
GO
CREATE TABLE silver.fashion_store_channels (
    channel      NVARCHAR(50),
    description       NVARCHAR(50)
);
GO
IF OBJECT_ID('silver.fashion_store_customers', 'U') IS NOT NULL
    DROP TABLE silver.fashion_store_customers;
GO
CREATE TABLE silver.fashion_store_customers(
    customer_id      NVARCHAR(50),
    country          NVARCHAR(50),
    age_range        NVARCHAR(50),
    signup_date      DATE
);
GO
IF OBJECT_ID('silver.fashion_store_products', 'U') IS NOT NULL
    DROP TABLE silver.fashion_store_products;
GO
CREATE TABLE silver.fashion_store_products(
    product_id NVARCHAR(50),
    product_name    NVARCHAR(50),
    category        NVARCHAR(50),
    brand       NVARCHAR(50),
    color     NVARCHAR(50),
    size     NVARCHAR(50), 
    catalog_price    DECIMAL(18,2),
    cost_price    DECIMAL(18,2),
    gender NVARCHAR(50)
);

IF OBJECT_ID('silver.fashion_store_sales', 'U') IS NOT NULL
    DROP TABLE silver.fashion_store_sales;
GO
CREATE TABLE silver.fashion_store_sales(
    sale_id NVARCHAR(50),
    channel    NVARCHAR(50),
    discounted        NVARCHAR(50),
    total_amount    DECIMAL(18,2),
    sale_date     DATE,
    customer_id    NVARCHAR(50), 
    country    NVARCHAR(50)
);

IF OBJECT_ID('silver.fashion_store_salesitems', 'U') IS NOT NULL
    DROP TABLE silver.fashion_store_salesitems;
GO
CREATE TABLE silver.fashion_store_salesitems(
    item_id NVARCHAR(50),
    sale_id    NVARCHAR(50),
    product_id        NVARCHAR(50),
    quantity    INT,
    original_price DECIMAL(18,2),
    unit_price DECIMAL(18,2),
    discount_applied DECIMAL(18,2),
    discount_percent NVARCHAR(50),
    discounted INT,
    item_total DECIMAL(18,2),
    sale_date DATE,
    channel NVARCHAR(50),
    channel_campaigns NVARCHAR(50)
);

IF OBJECT_ID('silver.fashion_store_stock', 'U') IS NOT NULL
    DROP TABLE silver.fashion_store_stock;
GO
CREATE TABLE silver.fashion_store_stock(
    country NVARCHAR(50),
    product_id INT,
    stock_quantity INT
);
