# 🛒 E-Commerce Sales & Customer Analytics Using SQL

A SQL portfolio project analyzing the **Olist Brazilian E-Commerce Public Dataset** to investigate sales performance, product categories, customer purchasing behavior, payment methods, delivery efficiency, and customer satisfaction using **SQL, SQLite, and DB Browser for SQLite**.

[View Repository](https://github.com/Suraj00008/ecommerce-sales-customer-analytics) · [Business Insights](INSIGHTS.md) · [SQL Scripts](sql/)

---

## 📌 Project Overview

E-commerce businesses generate large amounts of transactional data, but raw records alone do not explain how a business is performing. This project uses SQL to transform relational data into meaningful metrics and business insights.

I completed seven stages of analysis, progressing from database validation and data-quality checks to multi-table joins, advanced SQL techniques, KPI calculations, and business recommendations.

**Project highlights**

- Validated nine relational database tables containing approximately 2.5 million rows.
- Analyzed sales revenue, monthly trends, product categories, and seller performance.
- Investigated customer purchasing patterns, delivery performance, and review scores.
- Applied joins, subqueries, CTEs, window functions, ranking, and date calculations.
- Documented quantitative findings, limitations, and business recommendations.

## 📊 Key Findings

The following results are documented in the project's SQL analysis and `INSIGHTS.md`.

| Metric | Result |
|---|---:|
| Total orders in the dataset | 99,441 |
| Total order-item revenue | 13,591,643.70 |
| Average order value | 137.75 |
| Top product category by item revenue | `health_beauty` |
| Most frequently recorded payment method | Credit card |
| Average delivery duration | 12.56 days |
| Late-delivery rate | 8.11% |
| Average customer review score | 4.09 / 5 |

**How to interpret these metrics**

- **Item revenue:** Sum of product prices in the order-items table; it is not profit and excludes freight from this metric.
- **Average order value:** Average item-price revenue per order represented in the order-items table. Its denominator differs from the total number of orders if some orders have no corresponding items.
- **Top category:** `health_beauty` is the category label returned by the current analysis.
- **Most-used payment method:** Credit card is the most frequent payment type in the payment records.
- **Late-delivery rate:** Percentage of delivered orders with both actual and estimated delivery timestamps where the actual delivery date was later than the estimated date.

For methodology, further results, and analytical limitations, see [INSIGHTS.md](INSIGHTS.md).

## 🎯 Business Objectives

The project investigates the following business questions:

1. How does item revenue change over time?
2. Which product categories and sellers generate the highest item revenue?
3. How common are repeat purchases among customers?
4. How long does delivery take on average?
5. What proportion of delivered orders arrive later than estimated?
6. How are customer review scores distributed?
7. Are delivery delays associated with lower review scores?
8. Which payment methods are most frequently used and contribute the most payment value?
9. How concentrated is item revenue among sellers?
10. Which product categories or delivery patterns may warrant further investigation?

## 🗂️ Dataset

**Source:** [Olist Brazilian E-Commerce Public Dataset — Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

The dataset contains anonymized transactional and operational information from a Brazilian e-commerce marketplace.

### Database tables

| Table | Purpose | Rows |
|---|---|---:|
| `olist_orders_dataset` | Order status and timestamps | 99,441 |
| `olist_customers_dataset` | Customer identifiers and locations | 99,441 |
| `olist_order_items_dataset` | Products, sellers, prices, and freight | 112,650 |
| `olist_order_payments_dataset` | Payment types and payment values | 103,886 |
| `olist_order_reviews_dataset` | Customer review scores and comments | 99,224 |
| `olist_products_dataset` | Product categories and attributes | 32,951 |
| `olist_sellers_dataset` | Seller identifiers and locations | 3,095 |
| `olist_geolocation_dataset` | Geographic coordinates and location data | 1,000,163 |
| `product_category_name_translation` | Category-name translations | 71 |

*Row counts reflect the imported tables validated during the project.*

## 🛠️ Tools and Technologies

- **SQL:** Data querying, aggregation, joins, KPI calculations, and analysis
- **SQLite:** Relational database engine
- **DB Browser for SQLite:** Database inspection and SQL execution
- **Git and GitHub:** Version control and project documentation

## 🔍 Analysis Workflow

### Part 1 — Database Validation
- Inspected table structures and verified row counts.
- Checked identifiers and important data fields.
- Reviewed order statuses and missing values.

### Part 2 — Data Exploration and Quality
- Investigated missing values and duplicate identifiers.
- Checked relationships between tables and timestamp consistency.
- Examined payment values, review scores, and category-translation coverage.

### Part 3 — Sales Performance Analysis
- Analyzed order status and the available date range.
- Calculated item revenue, freight value, and average order value.
- Examined monthly revenue, month-over-month changes, and cumulative revenue.
- Compared item-price totals with recorded payment values.

### Part 4 — Product and Seller Analysis
- Joined product, order-item, and seller tables.
- Ranked categories, products, and sellers by item revenue.
- Examined untranslated categories and possible join-related duplication.

### Part 5 — Customer, Delivery, and Review Analysis
- Examined customer distribution across states.
- Investigated repeat purchasing patterns.
- Calculated delivery duration and late-delivery rates.
- Compared delivery outcomes with review scores.

### Part 6 — Advanced SQL Analysis
- Applied Common Table Expressions (CTEs) and subqueries.
- Used `RANK()`, `DENSE_RANK()`, `ROW_NUMBER()`, and `LAG()`.
- Calculated running totals and other window-based metrics.
- Examined customer segments, payment patterns, and seller revenue contribution.

### Part 7 — Business Insights and Recommendations
- Developed business-focused KPI summaries.
- Investigated cancellation rates, category performance, and delivery delays.
- Examined customer satisfaction and freight relative to item revenue.
- Converted analytical results into recommendations for further investigation.

## 💻 SQL Skills Demonstrated

| Skill | Application |
|---|---|
| Filtering and sorting | `WHERE`, `ORDER BY` |
| Aggregation | `GROUP BY`, `HAVING`, `SUM()`, `AVG()`, `COUNT()` |
| Conditional analysis | `CASE WHEN` |
| Relational analysis | `INNER JOIN`, `LEFT JOIN`, multi-table joins |
| Query organization | CTEs and subqueries |
| Data quality | NULL handling, duplicate checks, join validation |
| Advanced analytics | Window functions, ranking, `LAG()` |
| Time-based analysis | Date differences, monthly trends, growth calculations |
| Business reporting | Revenue analysis, delivery KPIs, customer metrics |

## 💡 Business Recommendations

Based on the areas investigated in this project, the analysis can support the following actions:

1. **Improve delivery reliability:** Investigate the sellers, locations, and operational processes associated with late deliveries.
2. **Improve customer experience:** Examine low review scores alongside delivery outcomes to identify potential service issues.
3. **Support product planning:** Use category-level revenue trends to inform inventory and promotional decisions, while considering costs before making profitability claims.
4. **Strengthen customer retention:** Use purchasing-frequency analysis to identify opportunities to encourage repeat purchases.
5. **Monitor seller concentration:** Track the contribution of leading sellers and assess operational dependence on a small group of suppliers.
6. **Review shipping efficiency:** Compare freight charges with item revenue while accounting for order size and other relevant factors.

These are analytical recommendations, not proof of causal relationships. The detailed findings and limitations are documented in [INSIGHTS.md](INSIGHTS.md).

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
├── INSIGHTS.md
├── README.md
└── .gitignore
```

The SQL scripts contain the queries for each stage. The screenshots provide supporting evidence of query execution and results.

## ▶️ How to Run the Project

1. Download the dataset from the [Kaggle source page](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).
2. Extract the relevant CSV files.
3. Open DB Browser for SQLite and create or open your project database.
4. Import the CSV files as tables, preserving the expected table names.
5. Open the scripts in the `sql/` directory.
6. Execute the scripts in numerical order, starting with database validation.
7. Review the query outputs and compare them with the saved screenshots.
8. Read [INSIGHTS.md](INSIGHTS.md) for the quantitative summary and recommendations.

**Note:** The source CSV files and local SQLite database do not need to be committed to GitHub for someone to review your SQL code. Users should import the dataset locally before running the queries.

## ⚠️ Analytical Considerations and Limitations

- Item-price revenue is not equivalent to profit because the dataset does not provide all costs and expenses.
- Freight is analyzed separately from item-price revenue.
- The total number of orders is not necessarily the denominator for every order-level metric.
- Customer records and unique customers represent different measures.
- Review scores are associated with orders. Joining a review to multiple order items can associate the same score with multiple categories.
- Missing timestamps can affect delivery calculations.
- The analysis is descriptive; observed associations do not establish causation or guarantee future outcomes.
- The dataset represents historical Brazilian marketplace activity and should not be interpreted as a complete picture of the current e-commerce market.

## 👨‍💻 About Me

**Suraj Yadav**  
Aspiring Data Analyst | SQL | Python | Excel | Power BI

I am building practical data analytics projects to strengthen my SQL, data exploration, business analysis, and reporting skills.

**GitHub:** [Suraj00008](https://github.com/Suraj00008)

---

*Project type: Data Analytics Portfolio Project*  
*Dataset: Olist Brazilian E-Commerce Public Dataset*  
*Tools: SQL · SQLite · DB Browser for SQLite*
