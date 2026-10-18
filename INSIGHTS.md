# Business Insights — E-Commerce Sales & Customer Analytics

## 1. Project Overview

This project analyzes the Olist Brazilian E-Commerce Public Dataset using SQL and SQLite to understand sales performance, customer purchasing behavior, product category performance, payment preferences, customer reviews, and delivery efficiency.

The goal is to convert raw e-commerce data into actionable business insights that can support data-driven decision-making.

## 2. Key Business Areas Analyzed

### 2.1 Sales Performance
- Analyzed order and order-item data to understand revenue patterns.
- Examined sales trends across different time periods.
- Identified high-performing and low-performing periods.
- Evaluated average order value and overall sales performance.

**Business implication:** Sales trends can help businesses plan promotions, inventory, and marketing activities around periods of higher demand.

### 2.2 Product Category Performance
- Compared product categories based on sales and order-item performance.
- Examined category-level revenue contribution.
- Identified categories that may require additional marketing or performance analysis.

**Business implication:** High-performing categories can be prioritized for inventory planning, while weaker categories can be investigated for pricing, visibility, and customer-demand issues.

### 2.3 Customer Analytics
- Analyzed customer order activity and purchasing behavior.
- Examined customer distribution across geographic locations.
- Explored customer purchasing patterns using order-level data.

**Business implication:** Customer segmentation can help businesses create targeted campaigns, improve customer engagement, and identify opportunities to encourage repeat purchases.

### 2.4 Payment Method Analysis
- Examined the distribution of payment methods.
- Compared payment usage and payment-value patterns.
- Investigated installment-payment behavior where applicable.

**Business implication:** Understanding payment preferences can help businesses improve checkout options and reduce friction during the purchasing process.

### 2.5 Delivery Performance
- Compared estimated delivery dates with actual delivery dates.
- Examined delivery duration and late-delivery patterns.
- Investigated delivery performance across relevant customer or order segments.

**Business implication:** Monitoring delivery delays can help businesses identify logistics bottlenecks, improve delivery estimates, and increase customer satisfaction.

### 2.6 Customer Review Analysis
- Examined review-score distributions.
- Compared customer ratings with delivery performance.
- Investigated relationships between customer feedback and order outcomes.

**Business implication:** Customer reviews can help businesses identify service-quality issues and prioritize improvements in fulfillment and customer support.

### 2.7 Seller and Geographic Analysis
- Explored seller distribution and performance-related patterns.
- Examined geographic differences in customer and order activity.
- Investigated how seller location and delivery outcomes may relate.

**Business implication:** Geographic analysis can support logistics planning, seller evaluation, and decisions about where operational improvements may be needed.

## 3. Quantitative Findings

Complete this section using the actual results produced by your SQL queries.

| Metric | Actual Result |
|---|---|
| Total orders analyzed | [99441] |
| Total order-item revenue | [13591643.7] |
| Average order value | [137.75] |
| Top-performing product category | [health_beauty] |
| Most-used payment method | [credit_card] |
| Average delivery duration | [12.56] |
| Late-delivery percentage | [8.11] |
| Average review score | [4.09] |

**Important:** Define each metric consistently. For example, item revenue should be calculated from order-item prices, and average order value should use a clearly defined order-level denominator.

## 4. Business Recommendations

1. **Improve sales planning:** Use historical sales patterns to support inventory and promotional planning.
2. **Optimize product categories:** Investigate category performance and allocate marketing resources based on demand and profitability data when cost information is available.
3. **Improve delivery reliability:** Monitor late deliveries and investigate the sellers, locations, or operational stages associated with delays.
4. **Enhance customer experience:** Review low customer ratings alongside delivery and order outcomes to identify areas for service improvement.
5. **Optimize checkout:** Use payment-method analysis to understand customer preferences and support a convenient payment experience.
6. **Use customer segmentation:** Analyze order frequency and customer activity to design relevant engagement and retention campaigns.
7. **Monitor performance regularly:** Refresh the analysis periodically and track key metrics over time.

## 5. SQL Skills Demonstrated

This project demonstrates practical use of:

- Data validation and exploratory analysis
- Filtering, sorting, grouping, and aggregation
- Joins across multiple relational tables
- Subqueries and Common Table Expressions (CTEs)
- Window functions and ranking
- Date and time analysis
- Conditional logic using `CASE WHEN`
- Business KPI calculations
- Translating query results into recommendations

## 6. Data Limitations

- The dataset represents a historical sample of Brazilian e-commerce activity, not the entire current e-commerce market.
- Order-item price is not equivalent to profit because costs, fees, and other expenses are not fully represented by that metric.
- Customer reviews are associated with orders; analyses linking reviews to individual products or categories require careful interpretation.
- Relationships between delivery outcomes and review scores do not establish causation.
- The analysis is descriptive and should not be treated as a causal or predictive model.

## 7. Conclusion

This project demonstrates how SQL can be used to transform relational e-commerce data into business-oriented analysis. By examining sales, products, customers, payments, delivery performance, and reviews, the project provides a foundation for evidence-based decisions in sales planning, logistics, and customer experience.

The final conclusions should be supported by the actual SQL outputs documented in the project.

---

*Tools: SQL, SQLite, DB Browser for SQLite*  
*Dataset: Olist Brazilian E-Commerce Public Dataset*  
*Project Type: Data Analytics Portfolio Project*
