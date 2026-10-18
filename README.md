# 🛒 E-Commerce Sales & Customer Analytics Using SQL

## 📌 Project Overview

This project focuses on analyzing e-commerce transactions using **SQL and SQLite** to uncover insights into sales performance, customer purchasing behavior, product categories, seller performance, delivery efficiency, and customer satisfaction.

Using the **Olist Brazilian E-Commerce Public Dataset**, I performed data validation, exploratory analysis, multi-table joins, advanced SQL analysis, and business-focused KPI calculations to demonstrate how SQL can transform raw transactional data into meaningful business insights.

The project follows an end-to-end analytical workflow, from database validation to business recommendations.

## 🎯 Business Objectives

- Analyze overall sales performance and monthly revenue trends.
- Identify top-performing product categories and sellers.
- Understand customer purchasing patterns and repeat purchases.
- Evaluate order delivery times and late-delivery rates.
- Analyze customer review scores and satisfaction.
- Examine payment methods and payment-value contribution.
- Identify business improvement opportunities using data-driven analysis.

## 🗂️ Dataset

**Dataset:** Olist Brazilian E-Commerce Public Dataset

**Source:** [Kaggle — Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

The dataset contains anonymized e-commerce order information from a Brazilian marketplace, including customers, orders, payments, products, sellers, and reviews.

### Database Tables

The project uses the following nine tables:

| Table | Purpose |
|---|---|
| `olist_customers_dataset` | Customer identifiers and location details |
| `olist_orders_dataset` | Order status and purchase, delivery, and estimated-delivery timestamps |
| `olist_order_items_dataset` | Products purchased, sellers, item prices, and freight values |
| `olist_order_payments_dataset` | Payment methods, installments, and payment values |
| `olist_order_reviews_dataset` | Review scores, comments, and timestamps |
| `olist_products_dataset` | Product identifiers, categories, and product attributes |
| `olist_sellers_dataset` | Seller identifiers and locations |
| `olist_geolocation_dataset` | Geographic coordinates and location information |
| `product_category_name_translation` | Original product category names and English translations |

### Dataset Size

The imported dataset contains approximately **2.5 million rows across nine tables**.

| Table | Rows |
|---|---:|
| Customers | 99,441 |
| Orders | 99,441 |
| Order Items | 112,650 |
| Payments | 103,886 |
| Reviews | 99,224 |
| Products | 32,951 |
| Sellers | 3,095 |
| Geolocation | 1,000,163 |
| Category Translation | 71 |

*Row counts reflect the imported tables used during database validation.*

## 🛠️ Tools & Technologies

- **SQL** — Data querying, transformation, aggregation, and analysis
- **SQLite** — Relational database engine
- **DB Browser for SQLite** — Database exploration and query execution
- **GitHub** — Source-code management and project portfolio

## 📊 Project Workflow

### Part 1 — Database Setup & Validation
- Verified database tables and schemas.
- Checked table row counts and key identifiers.
- Reviewed order statuses and missing values in important fields.

### Part 2 — Data Exploration & Quality
- Investigated missing values and duplicate identifiers.
- Validated relationships between orders, customers, products, sellers, payments, and reviews.
- Checked timestamp consistency, review scores, payment values, and category translation coverage.

### Part 3 — Sales Performance Analysis
- Analyzed the dataset's date range and order status distribution.
- Calculated item revenue, freight value, and average order value.
- Examined monthly revenue trends, month-over-month growth, and cumulative revenue.
- Compared order-item values with recorded payment totals.

### Part 4 — Joins, Product & Seller Analysis
- Practiced INNER JOIN and LEFT JOIN operations.
- Analyzed revenue by product category.
- Identified leading products and sellers by item revenue.
- Investigated untranslated categories and checked for join-related row duplication.

### Part 5 — Customer, Delivery & Review Analysis
- Examined customer distribution by state.
- Analyzed repeat purchasing behavior.
- Calculated average delivery duration and late-delivery rates.
- Compared delivery performance with review scores.
- Investigated review response times.

### Part 6 — Advanced SQL Analysis
- Applied CTEs and window functions.
- Used RANK, DENSE_RANK, LAG, and cumulative SUM calculations.
- Created customer and order-value segments.
- Analyzed repeat-purchase intervals, payment methods, customer lifetime item revenue, and seller revenue contribution.

### Part 7 — Business Insights & Recommendations
- Developed executive-level KPI summaries.
- Evaluated cancellation rates, category revenue contribution, and delivery delays.
- Examined customer satisfaction and category-associated review scores.
- Analyzed freight relative to item revenue and seller revenue concentration.
- Created rule-based recommendations to support business decision-making.

## 🧠 SQL Skills Demonstrated

- SELECT, WHERE, ORDER BY, GROUP BY, and HAVING
- Aggregate functions: COUNT, SUM, AVG, MIN, and MAX
- CASE expressions and conditional aggregation
- INNER JOIN, LEFT JOIN, and multi-table joins
- Common Table Expressions (CTEs)
- Subqueries and NULL handling
- Date and timestamp calculations using SQLite functions
- Window functions: RANK, DENSE_RANK, ROW_NUMBER, LAG, and SUM OVER
- Running totals, moving averages, and revenue contribution analysis
- Customer segmentation and KPI calculations
- Data quality validation and join-inflation checks

## 💡 Business Questions Explored

1. How does sales revenue change over time?
2. Which product categories and sellers generate the highest item revenue?
3. How many customers make repeat purchases?
4. How long do customers wait for their orders?
5. What proportion of delivered orders arrive after the estimated date?
6. How are review scores distributed?
7. Are late deliveries associated with lower average review scores?
8. Which payment methods contribute the most recorded payment value?
9. How concentrated is revenue among the leading sellers?
10. Which categories may warrant further investigation based on sales and associated review scores?

## 📈 Key Findings

The project includes SQL queries designed to answer the business questions above. The specific numerical findings should be added after reviewing the query outputs.

Recommended findings to document:

- **Sales performance:** Monthly revenue trends and the strongest sales periods.
- **Product performance:** Leading product categories and their revenue contribution.
- **Customer behavior:** The proportion of one-time and repeat customers.
- **Delivery performance:** The late-delivery rate and states requiring further investigation.
- **Customer satisfaction:** The distribution of review scores and differences between on-time and late deliveries.

Each finding should include a supporting metric and a brief explanation of its business significance.

## 🚀 Business Recommendations

Potential actions to evaluate using the actual results include:

- Investigate operational issues in regions with higher late-delivery rates.
- Examine low-rated category-associated reviews to identify potential customer-experience issues.
- Explore retention strategies based on observed repeat-purchase patterns.
- Support high-performing categories while monitoring seller revenue concentration.
- Review freight-to-item-value ratios when evaluating shipping efficiency.

These recommendations should be prioritized according to the evidence produced by the analysis.

## 📁 Repository Structure

```text
ecommerce-sales-customer-analytics/
│
├── sql/
│   ├── 01_database_validation.sql
│   ├── 02_data_exploration_quality.sql
│   ├── 03_sales_analysis.sql
│   ├── 04_joins_product_analysis.sql
│   ├── 05_customer_delivery_review_analysis.sql
│   ├── 06_advanced_sql_analysis.sql
│   └── 07_business_insights.sql
│
├── screenshots/
│   ├── P1_*.png
│   ├── P2_*.png
│   ├── P3_*.png
│   ├── P4_*.png
│   ├── P5_*.png
│   ├── P6_*.png
│   └── P7_*.png
│
├── README.md
└── .gitignore
```

The SQL scripts contain the analysis queries, while the screenshots provide evidence of the query outputs.

## ▶️ How to Run the Project

1. Download the dataset from the [Kaggle dataset page](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).
2. Import the required CSV files into DB Browser for SQLite.
3. Confirm that the imported tables use the names expected by the SQL scripts.
4. Open the scripts in the `sql/` directory.
5. Execute the queries in sequence, beginning with database validation.
6. Review the results and compare them with the saved screenshots.

## ⚠️ Analytical Considerations

- Item revenue is calculated using product prices and does not represent profit.
- Freight value is analyzed separately from item revenue.
- Customer records and unique customers are different measures.
- Review scores belong to orders; when linked to multiple items, a review may be associated with multiple product categories.
- Historical patterns describe the available dataset and do not guarantee future performance.
- Data-quality limitations and missing timestamps can affect individual metrics.

## 👨‍💻 Author

SURAJ YADAV

Aspiring Data Analyst | SQL | Python | Excel | Power BI

GitHub: https://github.com/Suraj00008
---

*This project was developed as a hands-on SQL analytics portfolio project to practice relational database querying, data analysis, and business insight generation.*
