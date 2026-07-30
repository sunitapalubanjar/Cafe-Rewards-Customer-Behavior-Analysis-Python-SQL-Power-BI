-- 1. Customer Distribution by gender
SELECT
	COALESCE(gender, 'Unknown') AS gender,
	COUNT(*) AS customer_count,

    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS customer_percentage

FROM customers
GROUP BY COALESCE(gender, 'Unknown')
ORDER BY customer_count DESC;



----------
-- 2 Customer distribution by age group
-----------------

WITH customer_age_groups AS (
    SELECT
        customer_id,

        CASE
            WHEN age IS NULL THEN 'Unknown'
            WHEN age < 30 THEN 'Under 30'
            WHEN age BETWEEN 30 AND 44 THEN '30–44'
            WHEN age BETWEEN 45 AND 59 THEN '45–59'
            ELSE '60+'
        END AS age_group

    FROM customers
)

SELECT
    age_group,
    COUNT(*) AS customer_count,

    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS customer_percentage

FROM customer_age_groups
GROUP BY age_group
ORDER BY customer_count DESC;

----------------
--3. Customer distribution by income group
----------------

WITH customer_income_groups AS (
    SELECT
        customer_id,

        CASE
            WHEN income IS NULL THEN 'Unknown'
            WHEN income < 50000 THEN 'Below $50,000'
            WHEN income < 75000 THEN '$50,000–$74,999'
            WHEN income < 100000 THEN '$75,000–$99,999'
            ELSE '$100,000+'
        END AS income_group

    FROM customers
)

SELECT
    income_group,
    COUNT(*) AS customer_count,

    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS customer_percentage

FROM customer_income_groups
GROUP BY income_group
ORDER BY customer_count DESC;

