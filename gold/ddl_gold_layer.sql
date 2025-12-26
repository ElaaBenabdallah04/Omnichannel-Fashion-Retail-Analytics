------------------------------------------------------------
-- GOLD.DIM_CUSTOMERS – Customer dimension table
------------------------------------------------------------
IF OBJECT_ID('gold.Dim_Customers','U') IS NOT NULL DROP TABLE gold.Dim_Customers;
GO

CREATE TABLE gold.Dim_Customers (
    Customer_Key INT IDENTITY(1,1) PRIMARY KEY,
    customer_id  INT NOT NULL,
    country      NVARCHAR(50) NULL,
    age_range    NVARCHAR(20) NULL,
    signup_date  DATE NULL
);
GO
INSERT INTO gold.Dim_Customers (customer_id, country, age_range, signup_date)
SELECT DISTINCT
    customer_id, country, age_range, signup_date
FROM silver.customers
WHERE customer_id IS NOT NULL;
GO
IF OBJECT_ID('gold.Dim_Products','U') IS NOT NULL DROP TABLE gold.Dim_Products;
GO
  
------------------------------------------------------------
-- GOLD.DIM_PRODUCTS – Product dimension table
------------------------------------------------------------
CREATE TABLE gold.Dim_Products (
    Product_Key   INT IDENTITY(1,1) PRIMARY KEY,
    product_id    INT NOT NULL,
    product_name  NVARCHAR(200) NULL,
    category      NVARCHAR(100) NULL,
    brand         NVARCHAR(100) NULL,
    color         NVARCHAR(50) NULL,
    size          NVARCHAR(20) NULL,
    gender        NVARCHAR(20) NULL,
    catalog_price DECIMAL(18,2) NULL,
    cost_price    DECIMAL(18,2) NULL
);
GO

INSERT INTO gold.Dim_Products (product_id, product_name, category, brand, color, size, gender, catalog_price, cost_price)
SELECT DISTINCT
    product_id, product_name, category, brand, color, size, gender, catalog_price, cost_price
FROM silver.products
WHERE product_id IS NOT NULL;
GO

------------------------------------------------------------
-- GOLD.DIM_CHANNELS – Channel dimension table
------------------------------------------------------------
IF OBJECT_ID('gold.Dim_Channels','U') IS NOT NULL DROP TABLE gold.Dim_Channels;
GO

CREATE TABLE gold.Dim_Channels (
    Channel_Key  INT IDENTITY(1,1) PRIMARY KEY,
    channel      NVARCHAR(50) NOT NULL,
    description  NVARCHAR(255) NULL
);
GO
INSERT INTO gold.Dim_Channels (channel, description)
SELECT DISTINCT
    channel, description
FROM silver.channels
WHERE channel IS NOT NULL;
GO
IF OBJECT_ID('gold.Dim_Campaigns','U') IS NOT NULL DROP TABLE gold.Dim_Campaigns;
GO

------------------------------------------------------------
-- GOLD.DIM_CAMPAIGNS – Campaign dimension table
------------------------------------------------------------
CREATE TABLE gold.Dim_Campaigns (
    Campaign_Key  INT IDENTITY(1,1) PRIMARY KEY,
    campaign_id   INT NOT NULL,
    campaign_name NVARCHAR(150) NULL,
    start_date    DATE NULL,
    end_date      DATE NULL,
    Channel_Key   INT NULL,
    discount_type NVARCHAR(20) NULL,
    discount_value INT NULL
);
GO

INSERT INTO gold.Dim_Campaigns (campaign_id, campaign_name, start_date, end_date, Channel_Key, discount_type, discount_value)
SELECT DISTINCT
    c.campaign_id,
    c.campaign_name,
    c.start_date,
    c.end_date,
    ch.Channel_Key,
    c.discount,
    c.discount_value
FROM silver.campaigns c
LEFT JOIN gold.Dim_Channels ch
    ON ch.channel = c.channel;
GO

------------------------------------------------------------
-- GOLD.DIM_DATE – Date dimension table
------------------------------------------------------------
IF OBJECT_ID('gold.Dim_Date', 'U') IS NOT NULL DROP TABLE gold.Dim_Date;
GO

CREATE TABLE gold.Dim_Date (
    Date_Key       INT         NOT NULL PRIMARY KEY,  -- yyyymmdd
    Full_Date      DATE        NOT NULL,
    [Year]         INT         NOT NULL,
    [Quarter]      TINYINT     NOT NULL,
    [Month]        TINYINT     NOT NULL,
    Month_Name     NVARCHAR(20) NOT NULL,
    [Day]          TINYINT     NOT NULL,
    Day_Of_Week    TINYINT     NOT NULL,
    Day_Name       NVARCHAR(20) NOT NULL
);
GO

DECLARE @min_date DATE, @max_date DATE;

SELECT
    @min_date = MIN(sale_date),
    @max_date = MAX(sale_date)
FROM silver.sales
WHERE sale_date IS NOT NULL;

;WITH d AS (
    SELECT @min_date AS dt
    UNION ALL
    SELECT DATEADD(DAY, 1, dt)
    FROM d
    WHERE dt < @max_date
)
INSERT INTO gold.Dim_Date (Date_Key, Full_Date, [Year], [Quarter], [Month], Month_Name, [Day], Day_Of_Week, Day_Name)
SELECT
    CONVERT(INT, FORMAT(dt, 'yyyyMMdd')) AS Date_Key,
    dt AS Full_Date,
    YEAR(dt) AS [Year],
    DATEPART(QUARTER, dt) AS [Quarter],
    MONTH(dt) AS [Month],
    DATENAME(MONTH, dt) AS Month_Name,
    DAY(dt) AS [Day],
    DATEPART(WEEKDAY, dt) AS Day_Of_Week,
    DATENAME(WEEKDAY, dt) AS Day_Name
FROM d
OPTION (MAXRECURSION 0);
GO

------------------------------------------------------------
-- GOLD.FACT_SALESITEMS – build the fact table (Gold layer)
-- Grain: 1 row per sales item (item_id) = product per order
-- Source: silver.salesitems + silver.sales + dimension lookups
------------------------------------------------------------

-- 1) Drop the fact table if it exists (rebuild from scratch)
IF OBJECT_ID('gold.Fact_SalesItems','U') IS NOT NULL
    DROP TABLE gold.Fact_SalesItems;
GO

-- 2) Create the fact table structure
CREATE TABLE gold.Fact_SalesItems (
    SalesItem_Key     INT IDENTITY(1,1) PRIMARY KEY,

    -- Business IDs (degenerate dimensions)
    item_id           INT NULL,
    sale_id           INT NULL,

    -- Foreign keys to dimensions
    Date_Key          INT NULL,
    Customer_Key      INT NULL,
    Product_Key       INT NULL,
    Channel_Key       INT NULL,

    -- Measures
    quantity          INT           NULL,
    original_price    DECIMAL(18,2) NULL,
    unit_price        DECIMAL(18,2) NULL,
    discount_applied  DECIMAL(18,2) NULL,
    discount_percent  DECIMAL(5,2)  NULL,
    item_total        DECIMAL(18,2) NULL,

    -- Derived measures
    net_revenue       DECIMAL(18,2) NULL,
    gross_margin      DECIMAL(18,2) NULL
);
GO

-- 3) Load data into the fact table
INSERT INTO gold.Fact_SalesItems (
    item_id, sale_id,
    Date_Key, Customer_Key, Product_Key, Channel_Key,
    quantity, original_price, unit_price, discount_applied, discount_percent, item_total,
    net_revenue, gross_margin
)
SELECT
    si.item_id,
    si.sale_id,

    -- Date lookup (prefer sales.sale_date; fallback to salesitems.sale_date)
    dd.Date_Key,

    -- Customer lookup (from sales header)
    dc.Customer_Key,

    -- Product lookup (from salesitems)
    dp.Product_Key,

    -- Channel lookup (prefer sales.channel; fallback to salesitems.channel)
    dch.Channel_Key,

    -- Measures from salesitems
    si.quantity,
    si.original_price,
    si.unit_price,
    si.discount_applied,
    si.discount_percent,
    si.item_total,

    -- Derived measures
    si.item_total AS net_revenue,
    (si.item_total - (dp.cost_price * si.quantity)) AS gross_margin

FROM silver.salesitems si
LEFT JOIN silver.sales s
    ON si.sale_id = s.sale_id

LEFT JOIN gold.Dim_Date dd
    ON dd.Full_Date = COALESCE(s.sale_date, si.sale_date)

LEFT JOIN gold.Dim_Customers dc
    ON dc.customer_id = s.customer_id

LEFT JOIN gold.Dim_Products dp
    ON dp.product_id = si.product_id

LEFT JOIN gold.Dim_Channels dch
    ON dch.channel = COALESCE(s.channel, si.channel)

GO
