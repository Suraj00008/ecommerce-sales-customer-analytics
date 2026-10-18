-- Query 1 — Dataset date range

SELECT
    MIN(order_purchase_timestamp) AS first_purchase,
    MAX(order_purchase_timestamp) AS last_purchase,
    COUNT(*) AS total_orders
FROM olist_orders_dataset;

-- Query 2 — Order volume by status

SELECT
    order_status,
    COUNT(*) AS total_orders,
    ROUND(
        100.0 * COUNT(*) / (SELECT COUNT(*) FROM olist_orders_dataset),
        2
    ) AS percentage_of_orders
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY total_orders DESC;

-- Query 3 — Overall item revenue and freight

SELECT
    COUNT(*) AS total_order_item_rows,
    COUNT(DISTINCT order_id) AS orders_with_items,
    ROUND(SUM(price), 2) AS total_item_revenue,
    ROUND(SUM(freight_value), 2) AS total_freight_value,
    ROUND(SUM(price + freight_value), 2) AS item_value_plus_freight,
    ROUND(AVG(price), 2) AS average_item_price
FROM olist_order_items_dataset;

-- Query 4 — Monthly sales and order volume

SELECT
    strftime('%Y-%m', o.order_purchase_timestamp) AS sales_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(i.order_id) AS order_item_rows,
    ROUND(SUM(i.price), 2) AS item_revenue,
    ROUND(SUM(i.freight_value), 2) AS freight_revenue
FROM olist_orders_dataset AS o
LEFT JOIN olist_order_items_dataset AS i
    ON o.order_id = i.order_id
GROUP BY strftime('%Y-%m', o.order_purchase_timestamp)
ORDER BY sales_month;

-- Query 5 — Average order value (AOV)

WITH order_totals AS (
    SELECT
        order_id,
        SUM(price) AS order_item_total
    FROM olist_order_items_dataset
    GROUP BY order_id
)
SELECT
    COUNT(*) AS orders_with_items,
    ROUND(SUM(order_item_total), 2) AS total_item_revenue,
    ROUND(AVG(order_item_total), 2) AS average_order_value,
    ROUND(MIN(order_item_total), 2) AS smallest_order_item_total,
    ROUND(MAX(order_item_total), 2) AS largest_order_item_total
FROM order_totals;

-- Query 6 — Top 10 months by item revenue

WITH monthly_sales AS (
    SELECT
        strftime('%Y-%m', o.order_purchase_timestamp) AS sales_month,
        SUM(i.price) AS item_revenue
    FROM olist_orders_dataset AS o
    JOIN olist_order_items_dataset AS i
        ON o.order_id = i.order_id
    GROUP BY strftime('%Y-%m', o.order_purchase_timestamp)
)
SELECT
    sales_month,
    ROUND(item_revenue, 2) AS item_revenue
FROM monthly_sales
ORDER BY item_revenue DESC
LIMIT 10;

-- Query 7 — Month-over-month sales growth

WITH monthly_sales AS (
    SELECT
        strftime('%Y-%m', o.order_purchase_timestamp) AS sales_month,
        SUM(i.price) AS item_revenue
    FROM olist_orders_dataset AS o
    JOIN olist_order_items_dataset AS i
        ON o.order_id = i.order_id
    GROUP BY strftime('%Y-%m', o.order_purchase_timestamp)
),
monthly_comparison AS (
    SELECT
        sales_month,
        item_revenue,
        LAG(item_revenue) OVER (ORDER BY sales_month) AS previous_month_revenue
    FROM monthly_sales
)
SELECT
    sales_month,
    ROUND(item_revenue, 2) AS item_revenue,
    ROUND(previous_month_revenue, 2) AS previous_month_revenue,
    ROUND(item_revenue - previous_month_revenue, 2) AS revenue_change,
    ROUND(
        100.0 * (item_revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS mom_growth_percentage
FROM monthly_comparison
ORDER BY sales_month;

-- Query 8 — Cumulative revenue over time

WITH monthly_sales AS (
    SELECT
        strftime('%Y-%m', o.order_purchase_timestamp) AS sales_month,
        SUM(i.price) AS item_revenue
    FROM olist_orders_dataset AS o
    JOIN olist_order_items_dataset AS i
        ON o.order_id = i.order_id
    GROUP BY strftime('%Y-%m', o.order_purchase_timestamp)
)
SELECT
    sales_month,
    ROUND(item_revenue, 2) AS monthly_item_revenue,
    ROUND(
        SUM(item_revenue) OVER (
            ORDER BY sales_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ),
        2
    ) AS cumulative_item_revenue
FROM monthly_sales
ORDER BY sales_month;

-- Query 9 — Delivered-order sales KPIs

WITH delivered_orders AS (
    SELECT order_id
    FROM olist_orders_dataset
    WHERE order_status = 'delivered'
),
order_totals AS (
    SELECT
        i.order_id,
        SUM(i.price) AS item_total,
        SUM(i.freight_value) AS freight_total
    FROM olist_order_items_dataset AS i
    JOIN delivered_orders AS d
        ON i.order_id = d.order_id
    GROUP BY i.order_id
)
SELECT
    COUNT(*) AS delivered_orders_with_items,
    ROUND(SUM(item_total), 2) AS delivered_item_revenue,
    ROUND(SUM(freight_total), 2) AS delivered_freight_value,
    ROUND(AVG(item_total), 2) AS delivered_average_order_value
FROM order_totals;

-- Query 10 — Compare order-item values with payment values

WITH item_totals AS (
    SELECT
        COUNT(DISTINCT order_id) AS orders_with_items,
        SUM(price) AS total_item_revenue,
        SUM(freight_value) AS total_freight
    FROM olist_order_items_dataset
),
payment_totals AS (
    SELECT
        COUNT(DISTINCT order_id) AS orders_with_payments,
        SUM(payment_value) AS total_payment_value
    FROM olist_order_payments_dataset
)
SELECT
    i.orders_with_items,
    p.orders_with_payments,
    ROUND(i.total_item_revenue, 2) AS total_item_revenue,
    ROUND(i.total_freight, 2) AS total_freight,
    ROUND(p.total_payment_value, 2) AS total_payment_value,
    ROUND(
        p.total_payment_value - (i.total_item_revenue + i.total_freight),
        2
    ) AS payment_minus_items_and_freight
FROM item_totals AS i
CROSS JOIN payment_totals AS p;