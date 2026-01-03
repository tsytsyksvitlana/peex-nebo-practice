-- Customer balance at the end of each month
SELECT
    customer_id,
    EXTRACT(MONTH FROM txn_date) AS txn_month,
    TO_CHAR(txn_date, 'Mon') AS month_name,
    SUM(
        CASE
            WHEN txn_type = 'deposit' THEN txn_amount
            WHEN txn_type = 'withdrawal' THEN -txn_amount
            WHEN txn_type = 'purchase' THEN -txn_amount
            ELSE 0
        END
    ) AS month_balance
FROM data_bank.customer_transactions
GROUP BY customer_id, month_name, month
ORDER BY customer_id ASC, month ASC;


-- 4. How many days on average are customers reallocated to a different node?
SELECT
    customer_id,
    node_id,
    start_date,
    end_date,
    end_date - start_date AS duration,
    LAG(node_id)
        OVER (PARTITION BY customer_id ORDER BY start_date)
    AS previous_node
FROM data_bank.customer_nodes
WHERE
    DATE_PART('year', end_date) != 9999
    AND customer_id = 1
ORDER BY start_date ASC;



-- Analytics-style combined query
SELECT
    u.user_id,
    TO_CHAR(u.start_date, 'YYYY-MM') AS signup_month,
    DATE_TRUNC('month', u.start_date) AS signup_month_start,
    (CURRENT_DATE - u.start_date::DATE) AS user_lifetime_days
FROM clique_bait.users AS u;


-- Billing date is the 5th of the month following the campaign start date
SELECT
    campaign_name,
    start_date,
    MAKE_DATE(
        EXTRACT(YEAR FROM start_date)::INT,
        EXTRACT(MONTH FROM start_date)::INT,
        5
    ) AS billing_date
FROM clique_bait.campaign_identifier;
