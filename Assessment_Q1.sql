-- Finding the customers with at least one funded savings plan AND one funded investment plan,
-- sorted by total deposits.

SELECT
    u.id AS owner_id,
    u.name,
    COUNT(DISTINCT sa.id) FILTER (WHERE pp.is_regular_savings = 1 AND sa.confirmed_amount > 0) AS savings_count,
    COUNT(DISTINCT pl.id) FILTER (WHERE pl.is_a_fund = 1 AND sa.confirmed_amount > 0) AS investment_count,
    SUM(sa.confirmed_amount / 100.0) AS total_deposits -- Convert kobo to Naira
FROM
    users_customuser u
JOIN
    savings_savingsaccount sa ON u.id = sa.owner_id
LEFT JOIN
    plans_plan pp ON sa.plan_id = pp.id AND pp.is_regular_savings = 1
LEFT JOIN
    plans_plan pl ON u.id = pl.owner_id AND pl.is_a_fund = 1
WHERE
    EXISTS (SELECT 1 FROM savings_savingsaccount s INNER JOIN plans_plan p ON s.plan_id = p.id WHERE s.owner_id = u.id AND p.is_regular_savings = 1 AND s.confirmed_amount > 0)
    AND EXISTS (SELECT 1 FROM plans_plan i WHERE i.owner_id = u.id AND i.is_a_fund = 1 AND EXISTS (SELECT 1 FROM savings_savingsaccount ss WHERE ss.plan_id = i.id AND ss.confirmed_amount > 0))
GROUP BY
    u.id, u.name
HAVING
    COUNT(DISTINCT CASE WHEN pp.is_regular_savings = 1 AND sa.confirmed_amount > 0 THEN sa.id END) >= 1
    AND COUNT(DISTINCT CASE WHEN pl.is_a_fund = 1 AND sa.confirmed_amount > 0 THEN pl.id END) >= 1
ORDER BY
    total_deposits DESC;