USE master;
GO
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse_project')
BEGIN
    ALTER DATABASE DataWarehouse_project SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse_project;
END;
GO
CREATE DATABASE DataWarehouse_project;

USE DataWarehouse_project;

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
