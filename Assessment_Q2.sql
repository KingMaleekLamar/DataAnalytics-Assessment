-- Calculating the average number of transactions per customer per month and categorize them.

WITH MonthlyTransactions AS (
    SELECT
        owner_id,
        EXTRACT(YEAR FROM transaction_date) AS transaction_year,
        EXTRACT(MONTH FROM transaction_date) AS transaction_month,
        COUNT(*) AS monthly_transaction_count
    FROM
        savings_savingsaccount
    WHERE confirmed_amount > 0 -- Considering only inflow transactions
    GROUP BY
        owner_id,
        EXTRACT(YEAR FROM transaction_date),
        EXTRACT(MONTH FROM transaction_date)
),
CustomerMonthlyAverages AS (
    SELECT
        owner_id,
        AVG(monthly_transaction_count) AS avg_transactions_per_month,
        COUNT(DISTINCT CONCAT(transaction_year, '-', LPAD(transaction_month::TEXT, 2, '0'))) AS total_active_months
    FROM
        MonthlyTransactions
    GROUP BY
        owner_id
)
SELECT
    CASE
        WHEN cma.avg_transactions_per_month >= 10 THEN 'High Frequency'
        WHEN cma.avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS frequency_category,
    COUNT(DISTINCT u.id) AS customer_count,
    AVG(cma.avg_transactions_per_month) AS avg_transactions_per_month
FROM
    CustomerMonthlyAverages cma
JOIN
    users_customuser u ON cma.owner_id = u.id
GROUP BY
    frequency_category
ORDER BY
    CASE
        WHEN frequency_category = 'High Frequency' THEN 1
        WHEN frequency_category = 'Medium Frequency' THEN 2
        ELSE 3
    END;