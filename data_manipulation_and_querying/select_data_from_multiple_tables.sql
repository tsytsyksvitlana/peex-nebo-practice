-- UNION ALL: Show all transitions from trial to paid plans,
-- including duplicates
SELECT
    customer_id,
    plan_id,
    start_date
FROM foodie_fi.subscriptions
WHERE plan_id = 0
UNION ALL
SELECT
    customer_id,
    plan_id,
    start_date
FROM foodie_fi.subscriptions
WHERE plan_id IN (1, 2, 3);


-- UNION: List all unique users who ever had trial or pro plans
SELECT customer_id
FROM foodie_fi.subscriptions
WHERE plan_id = 0
UNION
SELECT customer_id
FROM foodie_fi.subscriptions
WHERE plan_id IN (2, 3);


-- INTERSECT: Find users who had trial and later subscribed to a paid plan
SELECT customer_id
FROM foodie_fi.subscriptions
WHERE plan_id = 0
INTERSECT
SELECT customer_id
FROM foodie_fi.subscriptions
WHERE plan_id IN (1, 2, 3);


-- EXCEPT: Find users who had trial but never upgraded to a paid plan
SELECT customer_id
FROM foodie_fi.subscriptions
WHERE plan_id = 0
EXCEPT
SELECT customer_id
FROM foodie_fi.subscriptions
WHERE plan_id IN (1, 2, 3);
