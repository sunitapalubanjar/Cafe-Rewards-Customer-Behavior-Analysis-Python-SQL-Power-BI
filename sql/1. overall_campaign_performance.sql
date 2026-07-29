-- 1. How many offers were received, viewed, and completed?

SELECT
    event,
    COUNT(*) AS total_events
FROM events
WHERE event IN (
    'offer received',
    'offer viewed',
    'offer completed'
)
GROUP BY event
ORDER BY total_events DESC;


--2. What is the overall offer completion rate?

WITH offer_activity AS (
    SELECT
        COUNT(*) FILTER (
            WHERE event = 'offer received'
        ) AS total_received,

        COUNT(*) FILTER (
            WHERE event = 'offer completed'
        ) AS total_completed
    FROM events
)	

SELECT
    total_received,
    total_completed,
    ROUND(
        100.0 * total_completed / NULLIF(total_received, 0),
        2
    ) AS completion_rate_pct
FROM offer_activity;

-- 3. What is the overall offer viewing rate?

WITH offer_activity AS (
    SELECT
        COUNT(*) FILTER (
            WHERE event = 'offer received'
        ) AS total_received,

        COUNT(*) FILTER (
            WHERE event = 'offer viewed'
        ) AS total_viewed
    FROM events
)

SELECT
    total_received,
    total_viewed,
    ROUND(
        100.0 * total_viewed / NULLIF(total_received, 0),
        2
    ) AS viewing_rate_pct
FROM offer_activity;


-- 2. Which type of offer drives the highest customer engagement? (Completion Rate by Offer Type)
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


-- 4. Which offer type has the highest completion rate?

WITH offer_summary AS (
    SELECT
        o.offer_type,

        COUNT(*) FILTER (
            WHERE e.event = 'offer received'
        ) AS received_count,

        COUNT(*) FILTER (
            WHERE e.event = 'offer viewed'
        ) AS viewed_count,

        COUNT(*) FILTER (
            WHERE e.event = 'offer completed'
        ) AS completed_count

    FROM events e
    JOIN offers o
        ON e.offer_id = o.offer_id

    GROUP BY o.offer_type
)

SELECT
    offer_type,
    received_count,
    viewed_count,
    completed_count,

    ROUND(
        100.0 * viewed_count / NULLIF(received_count, 0),
        2
    ) AS viewing_rate_pct,

    ROUND(
        100.0 * completed_count / NULLIF(received_count, 0),
        2
    ) AS completion_rate_pct

FROM offer_summary
ORDER BY completion_rate_pct DESC NULLS LAST;

--5. Which specific offers perform best and worst? (Performance of Individual Offers)

WITH offer_summary AS (
    SELECT
        e.offer_id,
        o.offer_type,
        o.difficulty,
        o.reward,
        o.duration,

        COUNT(*) FILTER (
            WHERE e.event = 'offer received'
        ) AS received_count,

        COUNT(*) FILTER (
            WHERE e.event = 'offer viewed'
        ) AS viewed_count,

        COUNT(*) FILTER (
            WHERE e.event = 'offer completed'
        ) AS completed_count

    FROM events e
    JOIN offers o
        ON e.offer_id = o.offer_id

    GROUP BY
        e.offer_id,
        o.offer_type,
        o.difficulty,
        o.reward,
        o.duration
)

SELECT
    offer_id,
    offer_type,
    difficulty,
    reward,
    duration,
    received_count,
    viewed_count,
    completed_count,

    ROUND(
        100.0 * viewed_count / NULLIF(received_count, 0),
        2
    ) AS viewing_rate_pct,

    ROUND(
        100.0 * completed_count / NULLIF(received_count, 0),
        2
    ) AS completion_rate_pct

FROM offer_summary
ORDER BY completion_rate_pct DESC NULLS LAST;




-- Note:
-- Informational offers do not have an offer-completed event.
-- Their effectiveness should be measured through later transactions rather
-- than through completion rate.



