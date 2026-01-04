# Omnichannel Fashion Retail Analytics

## Project Overview
This project analyzes the performance of an omnichannel fashion retailer using transactional sales data.  
The objective is to transform raw data into actionable business insights by combining a modern data architecture (bronze–silver–gold layers), a star schema analytical model, and an interactive Power BI dashboard.

The project focuses on understanding revenue drivers, profitability patterns, customer behavior, and channel performance in order to support data-driven decision-making.

---

## Business Questions
The analysis aims to answer the following key business questions:
- Which products and categories generate the most revenue?
- How does profitability vary across products, categories, and channels?
- What is the impact of discounting on revenue and gross margin?
- How do customers behave across different sales channels?
- Which KPIs should management monitor to drive profitable growth?

---

## Data Architecture (Bronze / Silver / Gold)
The project follows a layered data architecture to ensure data quality, scalability, and clarity.

### Bronze Layer
- Stores raw ingested data
- Minimal transformations
- Preserves source structure for traceability

---

### Silver Layer
- Cleans and standardizes data
- Applies data quality checks
- Prepares data for analytical modeling


### Gold Layer
- Analytical layer optimized for reporting
- Implements a star schema
- Serves as the data source for Power BI


## Data Model (Star Schema)
The analytical model is based on a star schema with:
- **Fact table:** `Fact_SalesItem` (item-level sales transactions)
- **Dimension tables:** Products, Customers, Date, Channels, Campaigns

This structure enables efficient aggregation, flexible filtering, and consistent KPI calculations.

## Power BI Dashboard
An interactive Power BI dashboard was built on top of the gold layer to explore performance across multiple dimensions.
