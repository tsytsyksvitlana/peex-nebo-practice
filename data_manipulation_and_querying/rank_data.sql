-- 3. First item from the menu purchased by each customer
WITH order_info_cte AS (
    SELECT
        s.customer_id,
        s.order_date,
        m.product_name,
        DENSE_RANK() OVER (
            PARTITION BY s.customer_id
            ORDER BY s.order_date
        ) AS item_rank
    FROM dannys_diner.sales AS s
    INNER JOIN dannys_diner.menu AS m
        ON s.product_id = m.product_id
)

SELECT
    oic.customer_id,
    oic.product_name
FROM order_info_cte AS oic
WHERE oic.item_rank = 1
GROUP BY
    oic.customer_id,
    oic.product_name;


-- 5. Most popular item for each customer
WITH order_info AS (
    SELECT
        s.customer_id,
        m.product_name,
        COUNT(m.product_name) AS order_count,
        RANK() OVER (
            PARTITION BY s.customer_id
            ORDER BY COUNT(m.product_name) DESC
        ) AS rank_num
    FROM dannys_diner.sales AS s
    INNER JOIN dannys_diner.menu AS m
        ON s.product_id = m.product_id
    GROUP BY s.customer_id, m.product_name
)

SELECT
    oi.customer_id,
    oi.product_name,
    oi.order_count
FROM order_info AS oi
WHERE oi.rank_num = 1;


-- 7. Customer count and percentage breakdown for plans as of 2020-12-31
WITH latest_subscriptions AS (
    SELECT
        s.customer_id,
        p.plan_id,
        p.plan_name,
        ROW_NUMBER() OVER (
            PARTITION BY s.customer_id
            ORDER BY s.start_date DESC
        ) AS rn
    FROM foodie_foo.subscriptions AS s
    INNER JOIN foodie_foo.plans AS p
        ON s.plan_id = p.plan_id
    WHERE s.start_date <= '2020-12-31'
)

SELECT
    ls.plan_id,
    ls.plan_name,
    COUNT(ls.customer_id) AS customer_count,
    ROUND(
        100.0 * COUNT(ls.customer_id)
        / COUNT(DISTINCT ls.customer_id) OVER (), 2
    ) AS percentage_breakdown
FROM latest_subscriptions AS ls
WHERE ls.rn = 1
GROUP BY ls.plan_id, ls.plan_name
ORDER BY ls.plan_id;


-- Most active customers divided into quartiles by total orders
SELECT
    s.customer_id,
    COUNT(*) AS total_orders,
    NTILE(4) OVER (ORDER BY COUNT(*) DESC) AS activity_quartile
FROM dannys_diner.sales AS s
GROUP BY s.customer_id
ORDER BY activity_quartile;
