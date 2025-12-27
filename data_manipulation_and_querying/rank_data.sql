-- 3. What was the first item from the menu purchased by each customer?
-- order_date column is a date column does not include the purchase time details. 
-- Asssumption: Since the timestamp is missing, all items bought on the first day is considered as the first item(provided multiple items were purchased on the first day)
-- dense_rank() is used to rank all orders purchased on the same day 
WITH order_info_cte AS
  (SELECT customer_id,
          order_date,
          product_name,
          DENSE_RANK() OVER(PARTITION BY s.customer_id
                            ORDER BY s.order_date) AS item_rank
   FROM dannys_diner.sales AS s
   JOIN dannys_diner.menu AS m ON s.product_id = m.product_id)
SELECT customer_id,
       product_name
FROM order_info_cte
WHERE item_rank = 1
GROUP BY customer_id,
         product_name;


-- 5. Which item was the most popular for each customer?
-- Asssumption: Products with the highest purchase counts are all considered to be popular for each customer
WITH order_info AS
  (SELECT product_name,
          customer_id,
          COUNT(product_name) AS order_count,
          RANK() OVER(PARTITION BY customer_id
                      ORDER BY COUNT(product_name) DESC) AS rank_num
   FROM dannys_diner.menu
   INNER JOIN dannys_diner.sales ON menu.product_id = sales.product_id
   GROUP BY customer_id,
            product_name)
SELECT customer_id,
       product_name,
       order_count
FROM order_info
WHERE rank_num =1;


-- foodie foo
-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
SELECT plan_id,
       plan_name,
       COUNT(customer_id) AS customer_count,
       ROUND(100.0 * COUNT(customer_id) / COUNT(DISTINCT customer_id) OVER (), 2) AS percentage_breakdown
FROM (
    SELECT s.customer_id,
           p.plan_id,
           p.plan_name,
           ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.start_date DESC) AS rn
    FROM subscriptions s
    JOIN plans p USING (plan_id)
    WHERE s.start_date <= '2020-12-31'
) AS sub
WHERE rn = 1
GROUP BY plan_id, plan_name
ORDER BY plan_id;


-- Get the most active customers divided into quartiles based on their total number of orders
SELECT
    customer_id,
    COUNT(*) AS total_orders,
    NTILE(4) OVER (ORDER BY COUNT(*) DESC) AS activity_quartile
FROM sales
GROUP BY customer_id
ORDER BY activity_quartile;
