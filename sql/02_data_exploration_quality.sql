-- Query 1 — Missing values in key tables

SELECT
    'orders' AS table_name,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS missing_key,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer,
    SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) AS missing_status
FROM olist_orders_dataset

UNION ALL

SELECT
    'customers',
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN customer_unique_id IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN customer_zip_code_prefix IS NULL THEN 1 ELSE 0 END)
FROM olist_customers_dataset

UNION ALL

SELECT
    'order_items',
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END)
FROM olist_order_items_dataset

UNION ALL

SELECT
    'payments',
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN payment_type IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN payment_value IS NULL THEN 1 ELSE 0 END)
FROM olist_order_payments_dataset

UNION ALL

SELECT
    'reviews',
    SUM(CASE WHEN review_id IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END)
FROM olist_order_reviews_dataset

UNION ALL

SELECT
    'products',
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN product_weight_g IS NULL THEN 1 ELSE 0 END)
FROM olist_products_dataset

UNION ALL

SELECT
    'sellers',
    SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN seller_city IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN seller_state IS NULL THEN 1 ELSE 0 END)
FROM olist_sellers_dataset;

-- Query 2 — Check duplicate identifiers

SELECT
    'orders.order_id' AS identifier,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_ids,
    COUNT(*) - COUNT(DISTINCT order_id) AS duplicate_excess
FROM olist_orders_dataset

UNION ALL

SELECT
    'customers.customer_id',
    COUNT(*),
    COUNT(DISTINCT customer_id),
    COUNT(*) - COUNT(DISTINCT customer_id)
FROM olist_customers_dataset

UNION ALL

SELECT
    'products.product_id',
    COUNT(*),
    COUNT(DISTINCT product_id),
    COUNT(*) - COUNT(DISTINCT product_id)
FROM olist_products_dataset

UNION ALL

SELECT
    'sellers.seller_id',
    COUNT(*),
    COUNT(DISTINCT seller_id),
    COUNT(*) - COUNT(DISTINCT seller_id)
FROM olist_sellers_dataset;

-- Query 3 — Inspect order statuses

SELECT
    order_status,
    COUNT(*) AS total_orders
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY total_orders DESC;

-- Query 4 — Check timestamp consistency

SELECT
    COUNT(*) AS total_orders,

    SUM(CASE
        WHEN order_purchase_timestamp IS NULL
        THEN 1 ELSE 0
    END) AS missing_purchase_time,

    SUM(CASE
        WHEN order_approved_at IS NOT NULL
         AND order_approved_at < order_purchase_timestamp
        THEN 1 ELSE 0
    END) AS approval_before_purchase,

    SUM(CASE
        WHEN order_delivered_customer_date IS NOT NULL
         AND order_delivered_customer_date < order_purchase_timestamp
        THEN 1 ELSE 0
    END) AS delivery_before_purchase,

    SUM(CASE
        WHEN order_estimated_delivery_date IS NOT NULL
         AND order_estimated_delivery_date < order_purchase_timestamp
        THEN 1 ELSE 0
    END) AS estimate_before_purchase

FROM olist_orders_dataset;

-- Query 5 — Find orders without a matching customer

SELECT
    COUNT(*) AS orders_without_customer
FROM olist_orders_dataset AS o
LEFT JOIN olist_customers_dataset AS c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Query 6 — Check order items against orders, products, and sellers

SELECT
    SUM(CASE WHEN o.order_id IS NULL THEN 1 ELSE 0 END)
        AS items_without_order,

    SUM(CASE WHEN p.product_id IS NULL THEN 1 ELSE 0 END)
        AS items_without_product,

    SUM(CASE WHEN s.seller_id IS NULL THEN 1 ELSE 0 END)
        AS items_without_seller

FROM olist_order_items_dataset AS i
LEFT JOIN olist_orders_dataset AS o
    ON i.order_id = o.order_id
LEFT JOIN olist_products_dataset AS p
    ON i.product_id = p.product_id
LEFT JOIN olist_sellers_dataset AS s
    ON i.seller_id = s.seller_id;
	
-- Query 7 — Check payments and reviews against orders

SELECT
    'payments_without_order' AS check_name,
    COUNT(*) AS unmatched_rows
FROM olist_order_payments_dataset AS p
LEFT JOIN olist_orders_dataset AS o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT
    'reviews_without_order',
    COUNT(*)
FROM olist_order_reviews_dataset AS r
LEFT JOIN olist_orders_dataset AS o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Query 8 — Check product-category translation coverage

SELECT
    COUNT(*) AS total_products,

    SUM(CASE
        WHEN p.product_category_name IS NULL
          OR TRIM(p.product_category_name) = ''
        THEN 1 ELSE 0
    END) AS missing_category,

    SUM(CASE
        WHEN p.product_category_name IS NOT NULL
         AND TRIM(p.product_category_name) <> ''
         AND t.product_category_name IS NULL
        THEN 1 ELSE 0
    END) AS category_without_translation

FROM olist_products_dataset AS p
LEFT JOIN product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name;
	
-- Query 9 — Validate review scores

SELECT
    COUNT(*) AS total_review_rows,

    SUM(CASE
        WHEN review_score IS NULL
        THEN 1 ELSE 0
    END) AS missing_scores,

    SUM(CASE
        WHEN review_score < 1 OR review_score > 5
        THEN 1 ELSE 0
    END) AS out_of_range_scores

FROM olist_order_reviews_dataset;

-- Query 10 — Check payment values

SELECT
    COUNT(*) AS total_payment_rows,

    SUM(CASE
        WHEN payment_value IS NULL
        THEN 1 ELSE 0
    END) AS missing_payment_values,

    SUM(CASE
        WHEN payment_value < 0
        THEN 1 ELSE 0
    END) AS negative_payment_values,

    SUM(CASE
        WHEN payment_value = 0
        THEN 1 ELSE 0
    END) AS zero_payment_values

FROM olist_order_payments_dataset;