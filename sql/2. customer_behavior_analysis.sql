-- 1. Show the offer funnel by offer type

WITH funnel AS (
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
    ) AS received_to_viewed_pct,

    ROUND(
        100.0 * completed_count / NULLIF(viewed_count, 0),
        2
    ) AS viewed_to_completed_pct,

    ROUND(
        100.0 * completed_count / NULLIF(received_count, 0),
        2
    ) AS received_to_completed_pct

FROM funnel
ORDER BY received_to_completed_pct DESC NULLS LAST;

