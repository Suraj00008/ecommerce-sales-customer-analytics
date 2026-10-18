-- Query 1 — Executive KPI summary

WITH order_values AS (
    SELECT
        order_id,
        SUM(price) AS item_revenue,
        SUM(freight_value) AS freight_revenue
    FROM olist_order_items_dataset
    GROUP BY order_id
),
customer_summary AS (
    SELECT
        COUNT(DISTINCT customer_unique_id) AS unique_customers
    FROM olist_customers_dataset
),
order_summary AS (
    SELECT
        COUNT(*) AS total_orders,
        SUM(CASE WHEN order_status = 'delivered'
                 THEN 1 ELSE 0 END) AS delivered_orders,
        SUM(CASE WHEN order_status = 'canceled'
                 THEN 1 ELSE 0 END) AS canceled_orders
    FROM olist_orders_dataset
)
SELECT
    os.total_orders,
    os.delivered_orders,
    os.canceled_orders,
    cs.unique_customers,
    (SELECT COUNT(*) FROM order_values) AS orders_with_items,
    ROUND((SELECT SUM(item_revenue) FROM order_values), 2)
        AS total_item_revenue,
    ROUND((SELECT SUM(freight_revenue) FROM order_values), 2)
        AS total_freight_value,
    ROUND(
        (SELECT SUM(item_revenue) FROM order_values) /
        NULLIF((SELECT COUNT(*) FROM order_values), 0),
        2
    ) AS avg_item_value_per_order
FROM order_summary os
CROSS JOIN customer_summary cs;

-- Query 2 — Monthly sales trend and growth

WITH monthly_sales AS (
    SELECT
        strftime('%Y-%m', o.order_purchase_timestamp) AS sales_month,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.price) AS item_revenue
    FROM olist_orders_dataset o
    JOIN olist_order_items_dataset oi
        ON o.order_id = oi.order_id
    WHERE o.order_purchase_timestamp IS NOT NULL
    GROUP BY strftime('%Y-%m', o.order_purchase_timestamp)
),
monthly_comparison AS (
    SELECT
        sales_month,
        total_orders,
        item_revenue,
        LAG(item_revenue) OVER (
            ORDER BY sales_month
        ) AS previous_month_revenue
    FROM monthly_sales
)
SELECT
    sales_month,
    total_orders,
    ROUND(item_revenue, 2) AS item_revenue,
    ROUND(previous_month_revenue, 2) AS previous_month_revenue,
    ROUND(
        100.0 * (item_revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS mom_growth_percentage
FROM monthly_comparison
ORDER BY sales_month;

-- Query 3 — Top categories and revenue contribution

WITH category_sales AS (
    SELECT
        COALESCE(
            t.product_category_name_english,
            p.product_category_name,
            'unknown'
        ) AS category,
        SUM(oi.price) AS item_revenue,
        COUNT(*) AS items_sold
    FROM olist_order_items_dataset oi
    JOIN olist_products_dataset p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_name_translation t
        ON p.product_category_name = t.product_category_name
    GROUP BY category
)
SELECT
    category,
    items_sold,
    ROUND(item_revenue, 2) AS item_revenue,
    ROUND(
        100.0 * item_revenue /
        NULLIF((SELECT SUM(item_revenue) FROM category_sales), 0),
        2
    ) AS revenue_percentage
FROM category_sales
ORDER BY item_revenue DESC
LIMIT 10;

-- Query 4 — Order cancellation rate

SELECT
    COUNT(*) AS total_orders,
    SUM(
        CASE WHEN order_status = 'canceled'
             THEN 1 ELSE 0 END
    ) AS canceled_orders,
    ROUND(
        100.0 * SUM(
            CASE WHEN order_status = 'canceled'
                 THEN 1 ELSE 0 END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS cancellation_percentage,
    SUM(
        CASE WHEN order_status = 'unavailable'
             THEN 1 ELSE 0 END
    ) AS unavailable_orders
FROM olist_orders_dataset;

--Query 5 — Delivery delays by state

WITH delivery_metrics AS (
    SELECT
        c.customer_state,
        o.order_id,
        CASE
            WHEN julianday(o.order_delivered_customer_date)
                 > julianday(o.order_estimated_delivery_date)
                THEN 1
            ELSE 0
        END AS is_late
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
)
SELECT
    customer_state,
    COUNT(*) AS delivered_orders,
    SUM(is_late) AS late_orders,
    ROUND(
        100.0 * SUM(is_late) / NULLIF(COUNT(*), 0),
        2
    ) AS late_delivery_percentage
FROM delivery_metrics
GROUP BY customer_state
HAVING COUNT(*) >= 100
ORDER BY late_delivery_percentage DESC;

-- Query 6 — Customer satisfaction by review score

SELECT
    CASE
        WHEN review_score <= 2 THEN 'Low rating (1-2)'
        WHEN review_score = 3 THEN 'Neutral rating (3)'
        WHEN review_score >= 4 THEN 'High rating (4-5)'
    END AS rating_group,
    COUNT(*) AS review_count,
    ROUND(
        100.0 * COUNT(*) /
        (
            SELECT COUNT(*)
            FROM olist_order_reviews_dataset
            WHERE review_score BETWEEN 1 AND 5
        ),
        2
    ) AS percentage
FROM olist_order_reviews_dataset
WHERE review_score BETWEEN 1 AND 5
GROUP BY rating_group
ORDER BY
    CASE rating_group
        WHEN 'Low rating (1-2)' THEN 1
        WHEN 'Neutral rating (3)' THEN 2
        ELSE 3
    END;
	
-- Query 7 — Categories with the lowest average ratings

WITH category_reviews AS (
    SELECT
        COALESCE(
            t.product_category_name_english,
            p.product_category_name,
            'unknown'
        ) AS category,
        r.review_score
    FROM olist_order_reviews_dataset r
    JOIN olist_orders_dataset o
        ON r.order_id = o.order_id
    JOIN olist_order_items_dataset oi
        ON o.order_id = oi.order_id
    JOIN olist_products_dataset p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_name_translation t
        ON p.product_category_name = t.product_category_name
    WHERE r.review_score IS NOT NULL
)
SELECT
    category,
    COUNT(*) AS item_review_records,
    ROUND(AVG(review_score), 2) AS avg_review_score
FROM category_reviews
GROUP BY category
HAVING COUNT(*) >= 50
ORDER BY avg_review_score ASC
LIMIT 10;

-- Query 8 — Freight cost as a share of item revenue

WITH category_costs AS (
    SELECT
        COALESCE(
            t.product_category_name_english,
            p.product_category_name,
            'unknown'
        ) AS category,
        SUM(oi.price) AS item_revenue,
        SUM(oi.freight_value) AS freight_value
    FROM olist_order_items_dataset oi
    JOIN olist_products_dataset p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_name_translation t
        ON p.product_category_name = t.product_category_name
    GROUP BY category
)
SELECT
    category,
    ROUND(item_revenue, 2) AS item_revenue,
    ROUND(freight_value, 2) AS freight_value,
    ROUND(
        100.0 * freight_value / NULLIF(item_revenue, 0),
        2
    ) AS freight_percentage_of_item_revenue
FROM category_costs
ORDER BY freight_percentage_of_item_revenue DESC
LIMIT 10;

-- Query 9 — Seller revenue concentration

WITH seller_revenue AS (
    SELECT
        seller_id,
        SUM(price) AS item_revenue
    FROM olist_order_items_dataset
    GROUP BY seller_id
),
ranked_sellers AS (
    SELECT
        seller_id,
        item_revenue,
        ROW_NUMBER() OVER (
            ORDER BY item_revenue DESC, seller_id
        ) AS seller_rank
    FROM seller_revenue
)
SELECT
    COUNT(*) AS sellers,
    ROUND(SUM(item_revenue), 2) AS total_item_revenue,
    ROUND(
        100.0 * SUM(
            CASE WHEN seller_rank <= 10
                 THEN item_revenue ELSE 0 END
        ) / NULLIF(SUM(item_revenue), 0),
        2
    ) AS top_10_sellers_revenue_percentage,
    ROUND(
        100.0 * SUM(
            CASE WHEN seller_rank <= 50
                 THEN item_revenue ELSE 0 END
        ) / NULLIF(SUM(item_revenue), 0),
        2
    ) AS top_50_sellers_revenue_percentage
FROM ranked_sellers;

-- Query 10 — Business action summary by sales category

WITH category_sales AS (
    SELECT
        COALESCE(
            t.product_category_name_english,
            p.product_category_name,
            'unknown'
        ) AS category,
        COUNT(*) AS items_sold,
        SUM(oi.price) AS item_revenue
    FROM olist_order_items_dataset oi
    JOIN olist_products_dataset p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_name_translation t
        ON p.product_category_name = t.product_category_name
    GROUP BY category
),
category_reviews AS (
    SELECT
        COALESCE(
            t.product_category_name_english,
            p.product_category_name,
            'unknown'
        ) AS category,
        COUNT(*) AS associated_review_records,
        AVG(r.review_score) AS avg_review_score
    FROM olist_order_reviews_dataset r
    JOIN olist_order_items_dataset oi
        ON r.order_id = oi.order_id
    JOIN olist_products_dataset p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_name_translation t
        ON p.product_category_name = t.product_category_name
    WHERE r.review_score IS NOT NULL
    GROUP BY category
)
SELECT
    s.category,
    s.items_sold,
    ROUND(s.item_revenue, 2) AS item_revenue,
    cr.associated_review_records,
    ROUND(cr.avg_review_score, 2) AS avg_review_score,
    CASE
        WHEN cr.avg_review_score < 3
            THEN 'Investigate customer dissatisfaction'
        WHEN s.item_revenue >= (
            SELECT AVG(item_revenue) FROM category_sales
        )
        AND cr.avg_review_score >= 4
            THEN 'Protect and grow strong category'
        WHEN cr.avg_review_score >= 4
            THEN 'Explore growth opportunities'
        ELSE 'Monitor sales and reviews'
    END AS suggested_action
FROM category_sales s
LEFT JOIN category_reviews cr
    ON s.category = cr.category
ORDER BY s.item_revenue DESC
LIMIT 20;
