-- Query 1 — Customer base overview

SELECT
    COUNT(*) AS customer_records,
    COUNT(DISTINCT customer_unique_id) AS unique_customers,
    COUNT(DISTINCT customer_state) AS states,
    COUNT(DISTINCT customer_city) AS cities
FROM olist_customers_dataset;

-- Query 2 — Top 10 states by customer count

SELECT
    customer_state,
    COUNT(DISTINCT customer_unique_id) AS unique_customers,
    COUNT(*) AS customer_records
FROM olist_customers_dataset
GROUP BY customer_state
ORDER BY unique_customers DESC
LIMIT 10;

-- Query 3 — Repeat customer analysis

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    CASE
        WHEN total_orders = 1 THEN 'One order'
        ELSE 'Repeat customer'
    END AS customer_type,
    COUNT(*) AS customers,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM customer_orders),
        2
    ) AS percentage
FROM customer_orders
GROUP BY customer_type
ORDER BY customers DESC;

-- Query 4 — Average delivery time

SELECT
    COUNT(*) AS delivered_orders,
    ROUND(
        AVG(
            julianday(order_delivered_customer_date)
            - julianday(order_purchase_timestamp)
        ),
        2
    ) AS avg_delivery_days,
    ROUND(
        MIN(
            julianday(order_delivered_customer_date)
            - julianday(order_purchase_timestamp)
        ),
        2
    ) AS min_delivery_days,
    ROUND(
        MAX(
            julianday(order_delivered_customer_date)
            - julianday(order_purchase_timestamp)
        ),
        2
    ) AS max_delivery_days
FROM olist_orders_dataset
WHERE order_status = 'delivered'
  AND order_purchase_timestamp IS NOT NULL
  AND order_delivered_customer_date IS NOT NULL;
  
 -- Query 5 — On-time versus late deliveries
 
 WITH delivery_status AS (
    SELECT
        order_id,
        CASE
            WHEN julianday(order_delivered_customer_date)
                 <= julianday(order_estimated_delivery_date)
                THEN 'On time or early'
            ELSE 'Late'
        END AS delivery_result
    FROM olist_orders_dataset
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
      AND order_estimated_delivery_date IS NOT NULL
)
SELECT
    delivery_result,
    COUNT(*) AS orders,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM delivery_status),
        2
    ) AS percentage
FROM delivery_status
GROUP BY delivery_result
ORDER BY orders DESC;

-- Query 6 — Average delivery time by state

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    ROUND(
        AVG(
            julianday(o.order_delivered_customer_date)
            - julianday(o.order_purchase_timestamp)
        ),
        2
    ) AS avg_delivery_days
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp IS NOT NULL
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
HAVING COUNT(DISTINCT o.order_id) >= 100
ORDER BY avg_delivery_days DESC;

-- Query 7 — Review score distribution

SELECT
    review_score,
    COUNT(*) AS review_records,
    ROUND(
        100.0 * COUNT(*) /
        (
            SELECT COUNT(*)
            FROM olist_order_reviews_dataset
            WHERE review_score IS NOT NULL
        ),
        2
    ) AS percentage
FROM olist_order_reviews_dataset
WHERE review_score IS NOT NULL
GROUP BY review_score
ORDER BY review_score DESC;

-- Query 8 — Delivery performance versus review score

WITH order_delivery AS (
    SELECT
        order_id,
        CASE
            WHEN julianday(order_delivered_customer_date)
                 <= julianday(order_estimated_delivery_date)
                THEN 'On time or early'
            ELSE 'Late'
        END AS delivery_result
    FROM olist_orders_dataset
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
      AND order_estimated_delivery_date IS NOT NULL
),
order_reviews_summary AS (
    SELECT
        order_id,
        AVG(review_score) AS avg_review_score
    FROM olist_order_reviews_dataset
    WHERE review_score IS NOT NULL
    GROUP BY order_id
)
SELECT
    d.delivery_result,
    COUNT(*) AS orders_with_reviews,
    ROUND(AVG(r.avg_review_score), 2) AS avg_review_score
FROM order_delivery d
JOIN order_reviews_summary r
    ON d.order_id = r.order_id
GROUP BY d.delivery_result
ORDER BY avg_review_score DESC;

-- Query 9 — Review scores by delivery duration

WITH order_metrics AS (
    SELECT
        o.order_id,
        julianday(o.order_delivered_customer_date)
        - julianday(o.order_purchase_timestamp) AS delivery_days,
        r.review_score
    FROM olist_orders_dataset o
    JOIN olist_order_reviews_dataset r
        ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp IS NOT NULL
      AND o.order_delivered_customer_date IS NOT NULL
      AND r.review_score IS NOT NULL
)
SELECT
    CASE
        WHEN delivery_days < 3 THEN 'Under 3 days'
        WHEN delivery_days < 7 THEN '3 to under 7 days'
        WHEN delivery_days < 14 THEN '7 to under 14 days'
        ELSE '14 days or more'
    END AS delivery_range,
    COUNT(*) AS orders_with_reviews,
    ROUND(AVG(review_score), 2) AS avg_review_score
FROM order_metrics
WHERE delivery_days >= 0
GROUP BY delivery_range
ORDER BY
    CASE delivery_range
        WHEN 'Under 3 days' THEN 1
        WHEN '3 to under 7 days' THEN 2
        WHEN '7 to under 14 days' THEN 3
        ELSE 4
    END;
	
-- Query 10 — Review response time

SELECT
    COUNT(*) AS reviews_with_timestamps,
    ROUND(
        AVG(
            julianday(review_answer_timestamp)
            - julianday(review_creation_date)
        ),
        2
    ) AS avg_response_days,
    SUM(
        CASE
            WHEN julianday(review_answer_timestamp)
                 < julianday(review_creation_date)
                THEN 1
            ELSE 0
        END
    ) AS negative_time_records
FROM olist_order_reviews_dataset
WHERE review_creation_date IS NOT NULL
  AND review_answer_timestamp IS NOT NULL;