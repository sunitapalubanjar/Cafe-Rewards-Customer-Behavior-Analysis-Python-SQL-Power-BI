-- 1. Offer Performance Analysis

-- a. Total offers received vs completed

SELECT event,
		COUNT(*) AS total_count
FROM events
WHERE event IN ('offer received', 'offer completed')
GROUP BY event;

-- b. Completion Rate  by Offer Type

WITH received AS (
    SELECT offer_id, COUNT(*) AS received_count
    FROM events
    WHERE event = 'offer received'
    GROUP BY offer_id
),
completed AS (
    SELECT offer_id, COUNT(*) AS completed_count
    FROM events
    WHERE event = 'offer completed'
    GROUP BY offer_id
)

SELECT 
    o.offer_type,
    SUM(r.received_count) AS total_received,
    SUM(COALESCE(c.completed_count, 0)) AS total_completed,
    ROUND(
        SUM(COALESCE(c.completed_count, 0)) * 1.0 / SUM(r.received_count),
        2
    ) AS completion_rate
FROM received r
JOIN offers o ON r.offer_id = o.offer_id
LEFT JOIN completed c ON r.offer_id = c.offer_id
GROUP BY o.offer_type
ORDER BY completion_rate DESC;

-- Discount and BOGO offers showed measurable completion rates of 58% and 51% respectively, 
-- while informational offers had a completion rate of 0%. This is expected because informational 
-- offers are not designed to be redeemed or completed, but rather to influence future customer purchases.

