TRUNCATE TABLE bronze.fashion_store_campaigns;
BULK INSERT bronze.fashion_store_campaigns
FROM 'C:\Users\USER\Desktop\career\fashion store\dataset_fashion_store_campaigns.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
    TABLOCK );

TRUNCATE TABLE bronze.fashion_store_channels;
BULK INSERT bronze.fashion_store_channels
FROM 'C:\Users\USER\Desktop\career\fashion store\dataset_fashion_store_channels.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
    TABLOCK );

ALTER TABLE bronze.fashion_store_customers
DROP COLUMN revenue


TRUNCATE TABLE bronze.fashion_store_customers;
BULK INSERT bronze.fashion_store_customers
FROM 'C:\Users\USER\Desktop\career\fashion store\dataset_fashion_store_customers.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
    TABLOCK );


TRUNCATE TABLE bronze.fashion_store_products;
BULK INSERT bronze.fashion_store_products
FROM 'C:\Users\USER\Desktop\career\fashion store\dataset_fashion_store_products.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
    TABLOCK );

TRUNCATE TABLE bronze.fashion_store_sales;
BULK INSERT bronze.fashion_store_sales
FROM 'C:\Users\USER\Desktop\career\fashion store\dataset_fashion_store_sales.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
    TABLOCK );

ALTER TABLE bronze.fashion_store_salesitems
ALTER COLUMN discount_applied DECIMAL(18,2)

TRUNCATE TABLE bronze.fashion_store_salesitems;
BULK INSERT bronze.fashion_store_salesitems
FROM 'C:\Users\USER\Desktop\career\fashion store\dataset_fashion_store_salesitems.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
    TABLOCK );

TRUNCATE TABLE bronze.fashion_store_stock;
BULK INSERT bronze.fashion_store_stock
FROM 'C:\Users\USER\Desktop\career\fashion store\dataset_fashion_store_stock.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
    TABLOCK );
