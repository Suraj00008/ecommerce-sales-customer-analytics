-- 1. List all nine tables

SELECT
    name AS table_name
FROM sqlite_master
WHERE type = 'table'
  AND name NOT LIKE 'sqlite_%'
ORDER BY name;

-- 2. Count records in all tables

SELECT 'orders' AS table_name, COUNT(*) AS total_rows
FROM olist_orders_dataset

UNION ALL

SELECT 'customers', COUNT(*)
FROM olist_customers_dataset

UNION ALL

SELECT 'order_items', COUNT(*)
FROM olist_order_items_dataset

UNION ALL

SELECT 'payments', COUNT(*)
FROM olist_order_payments_dataset

UNION ALL

SELECT 'reviews', COUNT(*)
FROM olist_order_reviews_dataset

UNION ALL

SELECT 'products', COUNT(*)
FROM olist_products_dataset

UNION ALL

SELECT 'sellers', COUNT(*)
FROM olist_sellers_dataset

UNION ALL

SELECT 'geolocation', COUNT(*)
FROM olist_geolocation_dataset

UNION ALL

SELECT 'category_translation', COUNT(*)
FROM product_category_name_translation;

-- 3. Inspect the orders table structure

PRAGMA table_info(olist_orders_dataset);

-- 4. Validate order counts and unique IDs

SELECT
    COUNT(*) AS total_orders,
    COUNT(DISTINCT order_id) AS unique_order_ids,
    COUNT(*) - COUNT(DISTINCT order_id)
        AS duplicate_order_id_excess
FROM olist_orders_dataset;

-- 5. Check missing values in essential order columns

SELECT
    COUNT(*) AS total_orders,

    SUM(
        CASE WHEN order_id IS NULL
             THEN 1 ELSE 0 END
    ) AS missing_order_ids,

    SUM(
        CASE WHEN customer_id IS NULL
             THEN 1 ELSE 0 END
    ) AS missing_customer_ids,

    SUM(
        CASE WHEN order_status IS NULL
             THEN 1 ELSE 0 END
    ) AS missing_order_statuses

FROM olist_orders_dataset; 

-- 6. Examine the order-status distribution

SELECT
    order_status,
    COUNT(*) AS total_orders
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY total_orders DESC;

-- 7. Preview the first 10 orders

SELECT *
FROM olist_orders_dataset
LIMIT 10;