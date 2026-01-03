-- from clique_bait
-- Extract the page name from the page_url.
-- The page name is the part of the URL that comes after
-- the third '/' character.
SELECT
    visit_id,
    SUBSTRING(
        page_url,
        CHARINDEX('/', page_url, 9) + 1,
        LEN(page_url)
    ) AS page_name
FROM page_views;


-- danny's diner
-- What is the total amount each customer spent at the restaurant?
SELECT
    dd_sales.customer_id,
    CONCAT('$', SUM(dd_menu.price)) AS total_sales
FROM dannys_diner.menu AS dd_menu
INNER JOIN dannys_diner.sales AS dd_sales
    ON dd_menu.product_id = dd_sales.product_id
GROUP BY dd_sales.customer_id
ORDER BY dd_sales.customer_id;


-- data marts
-- Data Cleansing Steps
SELECT
    region,
    platform,
    segment,
    transactions,
    sales,
    TO_DATE(week_date, 'DD/MM/YY') AS week_date,
    DATE_PART('week', TO_DATE(week_date, 'DD/MM/YY')) AS week_number,
    DATE_PART('month', TO_DATE(week_date, 'DD/MM/YY')) AS month_number,
    DATE_PART('year', TO_DATE(week_date, 'DD/MM/YY')) AS calendar_year,
    CASE
        WHEN RIGHT(segment, 1) = '1' THEN 'Young Adults'
        WHEN RIGHT(segment, 1) = '2' THEN 'Middle Aged'
        WHEN RIGHT(segment, 1) IN ('3', '4') THEN 'Retirees'
        ELSE 'unknown'
    END AS age_band,
    CASE
        WHEN LEFT(segment, 1) = 'C' THEN 'Couples'
        WHEN LEFT(segment, 1) = 'F' THEN 'Families'
        ELSE 'unknown'
    END AS demographic,
    ROUND((sales::NUMERIC / transactions), 2) AS avg_transaction
FROM data_mart.weekly_sales;


-- From Postgres Exercises
-- Pad zip codes with leading zeroes
SELECT LPAD(zip_code::TEXT, 5, '0') AS padded_zip_code
FROM cd.members
ORDER BY padded_zip_code;


-- From Postgres Exercises
-- Perform a case-insensitive search
SELECT
    facility_id,
    name,
    region
FROM cd.facilities
WHERE UPPER(name) LIKE UPPER('tennis%');


-- Calculate total revenue from pizzas and additional toppings
WITH order_details AS (
    SELECT
        co.order_id,
        pn.pizza_id,
        LENGTH(co.extras)
        - LENGTH(REPLACE(co.extras, ',', ''))
        + 1 AS topping_count
    FROM customer_orders_temp AS co
    INNER JOIN pizza_names AS pn
        ON co.pizza_id = pn.pizza_id
    INNER JOIN runner_orders_temp AS ro
        ON co.order_id = ro.order_id
    WHERE co.cancellation IS NULL
),

revenue_calc AS (
    SELECT
        SUM(CASE WHEN pizza_id = 1 THEN 12 ELSE 10 END) AS pizza_revenue,
        SUM(topping_count) AS topping_revenue
    FROM order_details
)

SELECT CONCAT('$', pizza_revenue + topping_revenue) AS total_revenue
FROM revenue_calc;


-- Campaign analysis with visual representation
WITH campaign_events AS (
    SELECT
        ci.campaign_id,
        TRIM(ci.campaign_name) AS clean_campaign_name,
        COUNT(e.visit_id) AS total_events
    FROM clique_bait.campaign_identifier AS ci
    LEFT JOIN clique_bait.events AS e
        ON e.page_id IN (
            SELECT ph.page_id
            FROM clique_bait.page_hierarchy AS ph
            WHERE ph.product_id IN (1, 2, 3)
        )
    GROUP BY ci.campaign_id, ci.campaign_name
)

SELECT
    campaign_id,
    clean_campaign_name,
    STRPOS(clean_campaign_name, 'Shoes') AS shoes_position,
    REPEAT('*', total_events::INT) AS events_visual,
    REVERSE(clean_campaign_name) AS reversed_name
FROM campaign_events;
