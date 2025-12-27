-- from clique_bait
-- Extract the page name from the page_url.
-- The page name is the part of the URL that comes after the third '/' character.
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
SELECT customer_id,
       CONCAT('$', sum(price)) AS total_sales
FROM dannys_diner.menu
INNER JOIN dannys_diner.sales ON menu.product_id = sales.product_id
GROUP BY customer_id
ORDER BY customer_id;


-- data marts
-- Data Cleansing Steps
SELECT
  TO_DATE(week_date, 'DD/MM/YY') AS week_date,
  DATE_PART('week', TO_DATE(week_date, 'DD/MM/YY')) AS week_number,
  DATE_PART('month', TO_DATE(week_date, 'DD/MM/YY')) AS month_number,
  DATE_PART('year', TO_DATE(week_date, 'DD/MM/YY')) AS calendar_year,
  region, 
  platform, 
  segment,
  CASE 
    WHEN RIGHT(segment,1) = '1' THEN 'Young Adults'
    WHEN RIGHT(segment,1) = '2' THEN 'Middle Aged'
    WHEN RIGHT(segment,1) in ('3','4') THEN 'Retirees'
    ELSE 'unknown' END AS age_band,
  CASE 
    WHEN LEFT(segment,1) = 'C' THEN 'Couples'
    WHEN LEFT(segment,1) = 'F' THEN 'Families'
    ELSE 'unknown' END AS demographic,
  transactions,
  ROUND((sales::NUMERIC/transactions),2) AS avg_transaction,
  sales
FROM data_mart.weekly_sales


-- From Postgres Exercises
-- Pad zip codes with leading zeroes
SELECT LPAD(zip_code::TEXT, 5, '0') AS padded_zip_code
FROM cd.members
ORDER BY padded_zip_code;


-- From Postgres Exercises
-- Perform a case-insensitive search
SELECT *
FROM cd.facilities
WHERE UPPER(name) LIKE UPPER('tennis%');


-- Calculate total revenue from pizzas and additional toppings
WITH order_details AS (
    SELECT 
        co.order_id,
        pn.pizza_id,
        LENGTH(extras) - LENGTH(REPLACE(extras, ',', '')) + 1 AS topping_count
    FROM customer_orders_temp co
    INNER JOIN pizza_names pn USING (pizza_id)
    INNER JOIN runner_orders_temp ro USING (order_id)
    WHERE co.cancellation IS NULL
), revenue_calc AS (
    SELECT
        SUM(CASE WHEN pizza_id = 1 THEN 12 ELSE 10 END) AS pizza_revenue,
        SUM(topping_count) AS topping_revenue
    FROM order_details
)
SELECT CONCAT('$', pizza_revenue + topping_revenue) AS total_revenue
FROM revenue_calc;


/* This query takes the campaign name, removes any leading or trailing spaces,
finds the position of the word “Shoes” within the name,
creates a visual “star bar” representing the total number of events for that campaign,
and returns the reversed campaign name for demonstration purposes. */
WITH campaign_events AS (
    SELECT 
        ci.campaign_id,
        LTRIM(RTRIM(ci.campaign_name)) AS clean_campaign_name,
        COUNT(e.visit_id) AS total_events
    FROM clique_bait.campaign_identifier ci
    LEFT JOIN clique_bait.events e
        ON e.page_id IN (
            SELECT page_id 
            FROM clique_bait.page_hierarchy ph
            WHERE ph.product_id IN (1, 2, 3)
        )
    GROUP BY ci.campaign_id, ci.campaign_name
)
SELECT
    campaign_id,
    clean_campaign_name,
    STRPOS(clean_campaign_name, 'Shoes') AS shoes_position,      -- find substring position
    REPEAT('*', total_events::int) AS events_visual,             -- cast to int for REPEAT
    REVERSE(clean_campaign_name) AS reversed_name                -- reversed campaign name
FROM campaign_events;

