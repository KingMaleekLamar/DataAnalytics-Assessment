-- Finding all active accounts (savings or investments) with no inflow transactions in the last 1 year (365 days).

WITH LastTransaction AS (
    SELECT
        owner_id,
        MAX(transaction_date) AS last_transaction
    FROM
        savings_savingsaccount
    WHERE confirmed_amount > 0
    GROUP BY
        owner_id
)
SELECT
    COALESCE(p.id, sa.plan_id) AS plan_id,
    COALESCE(p.owner_id, sa.owner_id) AS owner_id,
    CASE
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund = 1 THEN 'Investment'
    END AS type,
    lt.last_transaction AS last_transaction_date,
    (CURRENT_DATE - lt.last_transaction) AS inactivity_days
FROM
    plans_plan p
LEFT JOIN
    LastTransaction lt ON p.owner_id = lt.owner_id
WHERE
    (p.is_regular_savings = 1 OR p.is_a_fund = 1)
    AND (lt.last_transaction IS NULL OR lt.last_transaction < CURRENT_DATE - INTERVAL '365 days')
    AND EXISTS (SELECT 1 FROM savings_savingsaccount s WHERE s.plan_id = p.id) -- Just to ensure it's an active account
UNION
SELECT
    sa.plan_id AS plan_id,
    sa.owner_id AS owner_id,
    'Savings' AS type,
    lt.last_transaction AS last_transaction_date,
    (CURRENT_DATE - lt.last_transaction) AS inactivity_days
FROM
    savings_savingsaccount sa
LEFT JOIN
    LastTransaction lt ON sa.owner_id = lt.owner_id
LEFT JOIN
    plans_plan p ON sa.plan_id = p.id
WHERE
    p.is_regular_savings = 1
    AND (lt.last_transaction IS NULL OR lt.last_transaction < CURRENT_DATE - INTERVAL '365 days');