-- Calculating Customer Lifetime Value (CLV) based on account tenure and transaction volume.

WITH CustomerTransactions AS (
    SELECT
        owner_id,
        COUNT(*) AS total_transactions
    FROM
        savings_savingsaccount
    WHERE confirmed_amount > 0 -- Considering only inflow transactions for transaction volume
    GROUP BY
        owner_id
)
SELECT
    u.id AS customer_id,
    u.name,
    EXTRACT(EPOCH FROM (CURRENT_DATE - u.date_joined)) / (60 * 60 * 24 * 30) AS tenure_months, -- Approximate months
    COALESCE(ct.total_transactions, 0) AS total_transactions,
    ROUND(
        (COALESCE(ct.total_transactions, 0) * 1.0 / (EXTRACT(EPOCH FROM (CURRENT_DATE - u.date_joined)) / (60 * 60 * 24 * 30))) * 12 * (COALESCE(SUM(sa.confirmed_amount), 0) / 100.0 * 0.001) / NULLIF(COUNT(DISTINCT EXTRACT(EPOCH FROM (CURRENT_DATE - u.date_joined)) / (60 * 60 * 24 * 30)), 0), 2
    ) AS estimated_clv
FROM
    users_customuser u
LEFT JOIN
    CustomerTransactions ct ON u.id = ct.owner_id
LEFT JOIN
    savings_savingsaccount sa ON u.id = sa.owner_id AND sa.confirmed_amount > 0
GROUP BY
    u.id, u.name, u.date_joined, ct.total_transactions
ORDER BY
    estimated_clv DESC NULLS LAST;