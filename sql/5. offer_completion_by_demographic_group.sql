----------------
-- 1. Offer completion rate by gender
--------------


WITH gender_offer_activity AS (
    SELECT
        COALESCE(c.gender, 'Unknown') AS gender,

        COUNT(*) FILTER (
            WHERE e.event = 'offer received'
        ) AS received_count,

        COUNT(*) FILTER (
            WHERE e.event = 'offer completed'
        ) AS completed_count

    FROM events e
    JOIN customers c
        ON e.customer_id = c.customer_id

    GROUP BY COALESCE(c.gender, 'Unknown')
)

SELECT
	gender,
	received_count,
	completed_count,

	ROUND(
	 100.0 * completed_count / NULLIF(received_count, 0),
        2
    ) AS completion_rate_pct

FROM gender_offer_activity
ORDER BY completion_rate_pct DESC;


------------------
-- 2. Offer completion rate by age group
------------------

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
),

age_offer_activity AS (
    SELECT
        cag.age_group,

        COUNT(*) FILTER (
            WHERE e.event = 'offer received'
        ) AS received_count,

        COUNT(*) FILTER (
            WHERE e.event = 'offer completed'
        ) AS completed_count

    FROM events e
    JOIN customer_age_groups cag
        ON e.customer_id = cag.customer_id

    GROUP BY cag.age_group
)

SELECT
    age_group,
    received_count,
    completed_count,

    ROUND(
        100.0 * completed_count / NULLIF(received_count, 0),
        2
    ) AS completion_rate_pct

FROM age_offer_activity
ORDER BY completion_rate_pct DESC;

-----------
-- 3. Offer completion rate by income group
------------
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
),

income_offer_activity AS (
    SELECT
        cig.income_group,

        COUNT(*) FILTER (
            WHERE e.event = 'offer received'
        ) AS received_count,

        COUNT(*) FILTER (
            WHERE e.event = 'offer completed'
        ) AS completed_count

    FROM events e
    JOIN customer_income_groups cig
        ON e.customer_id = cig.customer_id

    GROUP BY cig.income_group
)

SELECT
    income_group,
    received_count,
    completed_count,

    ROUND(
        100.0 * completed_count / NULLIF(received_count, 0),
        2
    ) AS completion_rate_pct

FROM income_offer_activity
ORDER BY completion_rate_pct DESC;

