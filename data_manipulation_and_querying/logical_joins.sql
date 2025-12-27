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
  JOIN clique_bait.page_hierarchy AS ph
    ON e.page_id = ph.page_id
  WHERE product_id IS NOT NULL
  GROUP BY e.visit_id, ph.product_id, ph.page_name, ph.product_category
),
purchase_events AS (
  SELECT 
    DISTINCT visit_id
  FROM clique_bait.events
  WHERE event_type = 3
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
    product_name, 
    product_category, 
    SUM(page_view) AS views,
    SUM(cart_add) AS cart_adds, 
    SUM(CASE WHEN cart_add = 1 AND purchase = 0 THEN 1 ELSE 0 END) AS abandoned,
    SUM(CASE WHEN cart_add = 1 AND purchase = 1 THEN 1 ELSE 0 END) AS purchases
  FROM combined_table
  GROUP BY product_id, product_name, product_category)

SELECT *
FROM product_info
ORDER BY product_id;


-- How many `interest_id` values exist in the `fresh_segments.interest_metrics`
-- table but not in the `fresh_segments.interest_map` table? What about the other way around?
SELECT 
  COUNT(DISTINCT map.id) AS map_id_count,
  COUNT(DISTINCT metrics.interest_id) AS metrics_id_count,
  SUM(CASE WHEN map.id is NULL THEN 1 END) AS not_in_metric,
  SUM(CASE WHEN metrics.interest_id is NULL THEN 1 END) AS not_in_map
FROM fresh_segments.interest_map map
FULL OUTER JOIN fresh_segments.interest_metrics metrics
  ON metrics.interest_id = map.id;


-- danny's dinner
-- Create basic data tables that Danny and his team can use to quickly derive insights
-- without needing to join the underlying tables using SQL. Fill Member column as 'N' if the purchase was made
-- before becoming a member and 'Y' if the after is amde after joining the membership.--/
SELECT customer_id,
       order_date,
       product_name,
       price,
       IF(order_date >= join_date, 'Y', 'N') AS member
FROM members
RIGHT JOIN sales USING (customer_id)
INNER JOIN menu USING (product_id)
ORDER BY customer_id,
         order_date;


-- Create basic data tables that Danny and his team can use to quickly derive insights without needing to join
-- the underlying tables using SQL. Fill Member column as 'N' if the purchase was made before becoming a member
-- and 'Y' if the after is amde after joining the membership.
SELECT customer_id,
       order_date,
       product_name,
       price,
       IF(order_date >= join_date, 'Y', 'N') AS member
FROM members
RIGHT JOIN sales USING (customer_id)
INNER JOIN menu USING (product_id)
ORDER BY customer_id,
         order_date;


-- How many customers are allocated to each region?
  WITH total_unique_customers AS (
      SELECT 
          COUNT(DISTINCT customer_id) AS total_unique_customers
      FROM 
          data_bank.customer_nodes
  )
  SELECT 
      reg.region_name, 
      COUNT(DISTINCT cn.customer_id) AS unique_customers,
      COUNT(cn.customer_id) AS customers,
      ROUND(COUNT(DISTINCT cn.customer_id) * 100.0 / total.total_unique_customers, 2) AS unique_customers_percentage
  FROM 
      data_bank.customer_nodes AS cn
  INNER JOIN 
      data_bank.regions AS reg
  ON 
      cn.region_id = reg.region_id
  CROSS JOIN 
      total_unique_customers AS total
  GROUP BY 
      reg.region_name, total.total_unique_customers;
    

/*
FULL OUTER JOIN allows you to see all regions, including those without customers,
as well as customers with non-existent region_ids, and when combined with COUNT and GROUP BY,
enables aggregation across all regions and customers even if some data is missing.
*/
SELECT
    reg.region_id,
    reg.region_name,
    COUNT(cn.customer_id) AS total_customers
FROM customer_nodes cn
FULL OUTER JOIN regions reg
ON cn.region_id = reg.region_id
GROUP BY reg.region_id, reg.region_name
ORDER BY reg.region_id;
