-- Product Funnel Analysis from clique_bait
WITH product_page_events AS (
    SELECT
        e.visit_id,
        ph.product_id,
        ph.page_name AS product_name,
        ph.product_category,
        SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS page_view,
        SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS cart_add
    FROM clique_bait.events AS e
    INNER JOIN clique_bait.page_hierarchy AS ph
        ON e.page_id = ph.page_id
    WHERE ph.product_id IS NOT NULL
    GROUP BY e.visit_id, ph.product_id, ph.page_name, ph.product_category
),

purchase_events AS (
    SELECT DISTINCT e.visit_id
    FROM clique_bait.events AS e
    WHERE e.event_type = 3
),

combined_table AS (
    SELECT
        ppe.visit_id,
        ppe.product_id,
        ppe.product_name,
        ppe.product_category,
        ppe.page_view,
        ppe.cart_add,
        CASE WHEN pe.visit_id IS NOT NULL THEN 1 ELSE 0 END AS purchase
    FROM product_page_events AS ppe
    LEFT JOIN purchase_events AS pe
        ON ppe.visit_id = pe.visit_id
),

product_info AS (
    SELECT
        c.product_name,
        c.product_category,
        SUM(c.page_view) AS page_views,
        SUM(c.cart_add) AS cart_adds,
        SUM(
            CASE WHEN c.cart_add = 1 AND c.purchase = 0 THEN 1 ELSE 0 END
        ) AS abandoned,
        SUM(
            CASE WHEN c.cart_add = 1 AND c.purchase = 1 THEN 1 ELSE 0 END
        ) AS purchases
    FROM combined_table AS c
    GROUP BY c.product_id, c.product_name, c.product_category
)

SELECT *
FROM product_info
ORDER BY product_id;


-- Danny's Diner: Create basic data table for customer purchases
SELECT
    sales.customer_id,
    sales.order_date,
    menu.product_name,
    sales.price,
    CASE
        WHEN
            members.join_date IS NOT NULL
            AND sales.order_date >= members.join_date THEN 'Y'
        ELSE 'N'
    END AS member
FROM sales
LEFT JOIN members
    ON sales.customer_id = members.customer_id
LEFT JOIN menu
    ON sales.product_id = menu.product_id
ORDER BY sales.customer_id, sales.order_date;


-- Customer allocation by region
WITH total_unique_customers AS (
    SELECT COUNT(DISTINCT customer_id) AS total_unique_customers
    FROM data_bank.customer_nodes
)

SELECT
    reg.region_name,
    COUNT(DISTINCT cn.customer_id) AS unique_customers,
    COUNT(cn.customer_id) AS customers,
    ROUND(
        COUNT(DISTINCT cn.customer_id) * 100.0 / tuc.total_unique_customers,
        2
    ) AS unique_customers_percentage
FROM data_bank.customer_nodes AS cn
INNER JOIN data_bank.regions AS reg
    ON cn.region_id = reg.region_id
CROSS JOIN total_unique_customers AS tuc
GROUP BY reg.region_name, tuc.total_unique_customers;


-- Full outer join to show all regions and customers
SELECT
    reg.region_id,
    reg.region_name,
    COUNT(cn.customer_id) AS total_customers
FROM data_bank.customer_nodes AS cn
FULL OUTER JOIN data_bank.regions AS reg
    ON cn.region_id = reg.region_id
GROUP BY reg.region_id, reg.region_name
ORDER BY reg.region_id;
