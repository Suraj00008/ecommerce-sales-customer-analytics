-- Query 1 — Monthly revenue ranking

WITH monthly_sales AS (
    SELECT
        strftime('%Y-%m', o.order_purchase_timestamp) AS sales_month,
        ROUND(SUM(oi.price), 2) AS item_revenue
    FROM olist_orders_dataset o
    JOIN olist_order_items_dataset oi
        ON o.order_id = oi.order_id
    WHERE o.order_purchase_timestamp IS NOT NULL
    GROUP BY strftime('%Y-%m', o.order_purchase_timestamp)
)
SELECT
    sales_month,
    item_revenue,
    RANK() OVER (ORDER BY item_revenue DESC) AS revenue_rank
FROM monthly_sales
ORDER BY sales_month;

-- Query 2 — Monthly running total and three-month moving average

WITH monthly_sales AS (
    SELECT
        strftime('%Y-%m', o.order_purchase_timestamp) AS sales_month,
        SUM(oi.price) AS item_revenue
    FROM olist_orders_dataset o
    JOIN olist_order_items_dataset oi
        ON o.order_id = oi.order_id
    WHERE o.order_purchase_timestamp IS NOT NULL
    GROUP BY strftime('%Y-%m', o.order_purchase_timestamp)
)
SELECT
    sales_month,
    ROUND(item_revenue, 2) AS item_revenue,
    ROUND(
        SUM(item_revenue) OVER (
            ORDER BY sales_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ),
        2
    ) AS cumulative_revenue,
    ROUND(
        AVG(item_revenue) OVER (
            ORDER BY sales_month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS three_month_moving_average
FROM monthly_sales
ORDER BY sales_month;

-- Query 3 — Top 3 product categories by revenue

WITH category_sales AS (
    SELECT
        COALESCE(
            t.product_category_name_english,
            p.product_category_name,
            'unknown'
        ) AS category,
        SUM(oi.price) AS item_revenue
    FROM olist_order_items_dataset oi
    JOIN olist_products_dataset p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_name_translation t
        ON p.product_category_name = t.product_category_name
    GROUP BY category
),
ranked_categories AS (
    SELECT
        category,
        ROUND(item_revenue, 2) AS item_revenue,
        DENSE_RANK() OVER (
            ORDER BY item_revenue DESC
        ) AS revenue_rank
    FROM category_sales
)
SELECT
    category,
    item_revenue,
    revenue_rank
FROM ranked_categories
WHERE revenue_rank <= 3
ORDER BY revenue_rank, category;

-- Query 4 — Top 10 sellers by revenue with ranking

WITH seller_sales AS (
    SELECT
        s.seller_id,
        s.seller_state,
        COUNT(DISTINCT oi.order_id) AS total_orders,
        SUM(oi.price) AS item_revenue
    FROM olist_sellers_dataset s
    JOIN olist_order_items_dataset oi
        ON s.seller_id = oi.seller_id
    GROUP BY
        s.seller_id,
        s.seller_state
)
SELECT
    seller_id,
    seller_state,
    total_orders,
    ROUND(item_revenue, 2) AS item_revenue,
    DENSE_RANK() OVER (
        ORDER BY item_revenue DESC
    ) AS seller_rank
FROM seller_sales
ORDER BY item_revenue DESC
LIMIT 10;

-- Query 5 — Customer segmentation by order frequency

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
),
segmented_customers AS (
    SELECT
        customer_unique_id,
        total_orders,
        CASE
            WHEN total_orders = 1 THEN 'One-time customer'
            WHEN total_orders BETWEEN 2 AND 3 THEN 'Occasional customer'
            ELSE 'Frequent customer'
        END AS customer_segment
    FROM customer_orders
)
SELECT
    customer_segment,
    COUNT(*) AS customers,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM segmented_customers),
        2
    ) AS customer_percentage,
    ROUND(AVG(total_orders), 2) AS avg_orders_per_customer
FROM segmented_customers
GROUP BY customer_segment
ORDER BY avg_orders_per_customer DESC;

-- Query 6 — Time between customer purchases

WITH customer_purchase_dates AS (
    SELECT DISTINCT
        c.customer_unique_id,
        o.order_id,
        date(o.order_purchase_timestamp) AS purchase_date
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    WHERE o.order_purchase_timestamp IS NOT NULL
),
purchase_intervals AS (
    SELECT
        customer_unique_id,
        order_id,
        purchase_date,
        LAG(purchase_date) OVER (
            PARTITION BY customer_unique_id
            ORDER BY purchase_date, order_id
        ) AS previous_purchase_date
    FROM customer_purchase_dates
)
SELECT
    customer_unique_id,
    order_id,
    previous_purchase_date,
    purchase_date,
    CAST(
        julianday(purchase_date)
        - julianday(previous_purchase_date)
        AS INTEGER
    ) AS days_since_previous_purchase
FROM purchase_intervals
WHERE previous_purchase_date IS NOT NULL
ORDER BY days_since_previous_purchase DESC
LIMIT 20;

-- Query 7 — Payment method contribution

WITH payment_summary AS (
    SELECT
        payment_type,
        COUNT(*) AS payment_records,
        SUM(payment_value) AS total_payment_value
    FROM olist_order_payments_dataset
    WHERE payment_value IS NOT NULL
    GROUP BY payment_type
)
SELECT
    payment_type,
    payment_records,
    ROUND(total_payment_value, 2) AS total_payment_value,
    ROUND(
        100.0 * total_payment_value /
        (SELECT SUM(payment_value)
         FROM olist_order_payments_dataset
         WHERE payment_value IS NOT NULL),
        2
    ) AS payment_value_percentage,
    DENSE_RANK() OVER (
        ORDER BY total_payment_value DESC
    ) AS payment_method_rank
FROM payment_summary
ORDER BY total_payment_value DESC;

-- Query 8 — Order value segmentation

WITH order_values AS (
    SELECT
        order_id,
        SUM(price) AS item_value
    FROM olist_order_items_dataset
    GROUP BY order_id
),
segmented_orders AS (
    SELECT
        order_id,
        item_value,
        CASE
            WHEN item_value < 100 THEN 'Low value'
            WHEN item_value < 500 THEN 'Medium value'
            ELSE 'High value'
        END AS order_segment
    FROM order_values
)
SELECT
    order_segment,
    COUNT(*) AS orders,
    ROUND(AVG(item_value), 2) AS avg_item_value,
    ROUND(SUM(item_value), 2) AS total_item_revenue,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM segmented_orders),
        2
    ) AS order_percentage
FROM segmented_orders
GROUP BY order_segment
ORDER BY avg_item_value;

-- Query 9 — Customer lifetime item revenue

WITH customer_revenue AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.price) AS lifetime_item_revenue
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    JOIN olist_order_items_dataset oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
)
SELECT
    customer_unique_id,
    total_orders,
    ROUND(lifetime_item_revenue, 2) AS lifetime_item_revenue,
    ROUND(
        lifetime_item_revenue / total_orders,
        2
    ) AS avg_item_revenue_per_order,
    DENSE_RANK() OVER (
        ORDER BY lifetime_item_revenue DESC
    ) AS customer_revenue_rank
FROM customer_revenue
ORDER BY lifetime_item_revenue DESC
LIMIT 20;

-- Query 10 — Revenue contribution by seller

WITH seller_revenue AS (
    SELECT
        seller_id,
        SUM(price) AS item_revenue
    FROM olist_order_items_dataset
    GROUP BY seller_id
),
seller_contribution AS (
    SELECT
        seller_id,
        item_revenue,
        100.0 * item_revenue /
            SUM(item_revenue) OVER () AS revenue_percentage,
        SUM(item_revenue) OVER (
            ORDER BY item_revenue DESC, seller_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_revenue
    FROM seller_revenue
)
SELECT
    seller_id,
    ROUND(item_revenue, 2) AS item_revenue,
    ROUND(revenue_percentage, 2) AS revenue_percentage,
    ROUND(
        100.0 * cumulative_revenue /
        SUM(item_revenue) OVER (),
        2
    ) AS cumulative_revenue_percentage
FROM seller_contribution
ORDER BY item_revenue DESC
LIMIT 20;