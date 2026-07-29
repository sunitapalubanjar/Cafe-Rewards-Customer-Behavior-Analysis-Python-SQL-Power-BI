-- 1. How many customers viewed informational offers?

SELECT
    COUNT(DISTINCT e.customer_id) AS informational_offer_viewers
FROM events e
JOIN offers o
    ON e.offer_id = o.offer_id
WHERE e.event = 'offer viewed'
  AND o.offer_type = 'informational';

--2. How many transactions occurred after an informational offer was viewed?

-- A transaction is counted only when it occurred:
-- 1. After the offer was viewed
-- 2. Before the informational offer expired

-- Offer duration is stored in days and event time is stored in hours.

WITH informational_views AS (
    SELECT
        e.customer_id,
        e.offer_id,
        e.time AS view_time,
        e.time + (o.duration * 24) AS offer_expiry_time

    FROM events e
    JOIN offers o
        ON e.offer_id = o.offer_id

    WHERE e.event = 'offer viewed'
      AND o.offer_type = 'informational'
),

transactions AS (
    SELECT
        customer_id,
        time AS transaction_time,
        amount
    FROM events
    WHERE event = 'transaction'
)

SELECT
    COUNT(*) AS transactions_after_info_view,
    COUNT(DISTINCT iv.customer_id) AS purchasing_customers,
    ROUND(SUM(t.amount)) AS total_transaction_value

FROM informational_views iv
JOIN transactions t
    ON iv.customer_id = t.customer_id
   AND t.transaction_time > iv.view_time
   AND t.transaction_time <= iv.offer_expiry_time;

--Informational offers were followed by 11,588 transactions from 5,533 unique customers during their valid offer periods. 
--These transactions generated approximately $150,214 in total value, suggesting that informational 
--campaigns may contribute to customer purchasing activity despite not providing a direct financial reward. So possiblity of double counting.


-- 3. What percentage of informational-offer viewers made a purchase within the offer period?

WITH informational_views AS (
    SELECT
        e.customer_id,
        e.offer_id,
        e.time AS view_time,
        e.time + (o.duration * 24) AS offer_expiry_time

    FROM events e
    JOIN offers o
        ON e.offer_id = o.offer_id

    WHERE e.event = 'offer viewed'
      AND o.offer_type = 'informational'
),

converted_views AS (
    SELECT DISTINCT
        iv.customer_id,
        iv.offer_id,
        iv.view_time

    FROM informational_views iv
    JOIN events t
        ON iv.customer_id = t.customer_id
       AND t.event = 'transaction'
       AND t.time > iv.view_time
       AND t.time <= iv.offer_expiry_time
)

SELECT
    COUNT(DISTINCT iv.customer_id) AS total_viewers,
    COUNT(DISTINCT cv.customer_id) AS converted_customers,

    ROUND(
        100.0 * COUNT(DISTINCT cv.customer_id)
        / NULLIF(COUNT(DISTINCT iv.customer_id), 0),
        2
    ) AS customer_conversion_rate_pct

FROM informational_views iv
LEFT JOIN converted_views cv
    ON iv.customer_id = cv.customer_id;


------------------------
-- 4. How long does it take customers to make their first purchase after viewing an informational offer?
------------------------
WITH informational_views AS (
    SELECT
        e.customer_id,
        e.offer_id,
        e.time AS view_time,
        e.time + (o.duration * 24) AS offer_expiry_time

    FROM events e
    JOIN offers o
        ON e.offer_id = o.offer_id

    WHERE e.event = 'offer viewed'
      AND o.offer_type = 'informational'
),

first_purchase AS (
    SELECT
        iv.customer_id,
        iv.offer_id,
        iv.view_time,
        MIN(t.time) AS first_transaction_time

    FROM informational_views iv
    JOIN events t
        ON iv.customer_id = t.customer_id
       AND t.event = 'transaction'
       AND t.time > iv.view_time
       AND t.time <= iv.offer_expiry_time

    GROUP BY
        iv.customer_id,
        iv.offer_id,
        iv.view_time
),

purchase_time AS (
    SELECT
        customer_id,
        offer_id,
        first_transaction_time - view_time AS hours_to_purchase
    FROM first_purchase
)

SELECT
    ROUND(AVG(hours_to_purchase), 2) AS avg_hours_to_purchase,
    ROUND(AVG(hours_to_purchase) / 24.0, 2) AS avg_days_to_purchase,
    MIN(hours_to_purchase) AS minimum_hours,
    MAX(hours_to_purchase) AS maximum_hours
FROM purchase_time;