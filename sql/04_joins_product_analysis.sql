-- Query 1 — Explore the order-item relationships

SELECT
    COUNT(*) AS total_item_rows,
    COUNT(DISTINCT order_id) AS distinct_orders,
    COUNT(DISTINCT product_id) AS distinct_products,
    COUNT(DISTINCT seller_id) AS distinct_sellers
FROM olist_order_items_dataset;

-- Query 2 — Compare INNER JOIN and LEFT JOIN

SELECT
    'INNER JOIN' AS join_type,
    COUNT(*) AS matched_item_rows
FROM olist_order_items_dataset AS i
INNER JOIN olist_products_dataset AS p
    ON i.product_id = p.product_id

UNION ALL

SELECT
    'LEFT JOIN',
    COUNT(*)
FROM olist_order_items_dataset AS i
LEFT JOIN olist_products_dataset AS p
    ON i.product_id = p.product_id;
	
-- Query 3 — Revenue by product category

SELECT
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'unknown'
    ) AS product_category,
    COUNT(*) AS item_rows,
    COUNT(DISTINCT i.order_id) AS orders,
    ROUND(SUM(i.price), 2) AS item_revenue,
    ROUND(SUM(i.freight_value), 2) AS freight_value
FROM olist_order_items_dataset AS i
JOIN olist_products_dataset AS p
    ON i.product_id = p.product_id
LEFT JOIN product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name
GROUP BY
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'unknown'
    )
ORDER BY item_revenue DESC;

-- Query 4 — Top 10 products by item revenue

SELECT
    i.product_id,
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'unknown'
    ) AS product_category,
    COUNT(*) AS items_sold,
    COUNT(DISTINCT i.order_id) AS orders,
    ROUND(SUM(i.price), 2) AS item_revenue
FROM olist_order_items_dataset AS i
JOIN olist_products_dataset AS p
    ON i.product_id = p.product_id
LEFT JOIN product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name
GROUP BY
    i.product_id,
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'unknown'
    )
ORDER BY item_revenue DESC
LIMIT 10;

-- Query 5 — Top 10 sellers by item revenue

SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(*) AS item_rows,
    COUNT(DISTINCT i.order_id) AS orders,
    COUNT(DISTINCT i.product_id) AS distinct_products,
    ROUND(SUM(i.price), 2) AS item_revenue,
    ROUND(SUM(i.freight_value), 2) AS freight_value
FROM olist_order_items_dataset AS i
JOIN olist_sellers_dataset AS s
    ON i.seller_id = s.seller_id
GROUP BY
    s.seller_id,
    s.seller_city,
    s.seller_state
ORDER BY item_revenue DESC
LIMIT 10;

-- Query 6 — Category sales by order status

SELECT
    o.order_status,
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'unknown'
    ) AS product_category,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(i.price), 2) AS item_revenue
FROM olist_orders_dataset AS o
JOIN olist_order_items_dataset AS i
    ON o.order_id = i.order_id
JOIN olist_products_dataset AS p
    ON i.product_id = p.product_id
LEFT JOIN product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name
GROUP BY
    o.order_status,
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'unknown'
    )
ORDER BY o.order_status, item_revenue DESC;

-- Query 7 — Average item price and freight by category

SELECT
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'unknown'
    ) AS product_category,
    COUNT(*) AS item_rows,
    ROUND(AVG(i.price), 2) AS average_item_price,
    ROUND(AVG(i.freight_value), 2) AS average_freight,
    ROUND(
        AVG(i.freight_value) / NULLIF(AVG(i.price), 0) * 100,
        2
    ) AS freight_as_percent_of_average_price
FROM olist_order_items_dataset AS i
JOIN olist_products_dataset AS p
    ON i.product_id = p.product_id
LEFT JOIN product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name
GROUP BY
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'unknown'
    )
ORDER BY average_item_price DESC;

-- Query 8 — Products without a category translation

SELECT
    p.product_category_name,
    COUNT(DISTINCT p.product_id) AS products
FROM olist_products_dataset AS p
LEFT JOIN product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND TRIM(p.product_category_name) <> ''
  AND t.product_category_name IS NULL
GROUP BY p.product_category_name
ORDER BY products DESC;

-- Query 9 — Check whether a join inflates item revenue

WITH base_totals AS (
    SELECT
        COUNT(*) AS item_rows,
        SUM(price) AS item_revenue
    FROM olist_order_items_dataset
),
joined_totals AS (
    SELECT
        COUNT(*) AS item_rows,
        SUM(i.price) AS item_revenue
    FROM olist_order_items_dataset AS i
    JOIN olist_products_dataset AS p
        ON i.product_id = p.product_id
    JOIN olist_sellers_dataset AS s
        ON i.seller_id = s.seller_id
)
SELECT
    b.item_rows AS original_item_rows,
    j.item_rows AS joined_item_rows,
    ROUND(b.item_revenue, 2) AS original_item_revenue,
    ROUND(j.item_revenue, 2) AS joined_item_revenue,
    ROUND(j.item_revenue - b.item_revenue, 2) AS revenue_difference
FROM base_totals AS b
CROSS JOIN joined_totals AS j;