-- 1 Does offer difficulty affect completion rate?

WITH difficulty_summary AS (
    SELECT
        o.difficulty,

        COUNT(*) FILTER (
            WHERE e.event = 'offer received'
        ) AS received_count,

        COUNT(*) FILTER (
            WHERE e.event = 'offer completed'
        ) AS completed_count

    FROM events e
    JOIN offers o
        ON e.offer_id = o.offer_id

    WHERE o.offer_type IN ('bogo', 'discount')
    GROUP BY o.difficulty
)

SELECT
    difficulty,
    received_count,
    completed_count,

    ROUND(
        100.0 * completed_count / NULLIF(received_count, 0),
        2
    ) AS completion_rate_pct

FROM difficulty_summary
ORDER BY difficulty;


-- 2 Does a larger reward lead to a higher completion rate?

WITH reward_summary AS (
    SELECT
        o.reward,

        COUNT(*) FILTER (
            WHERE e.event = 'offer received'
        ) AS received_count,

        COUNT(*) FILTER (
            WHERE e.event = 'offer completed'
        ) AS completed_count

    FROM events e
    JOIN offers o
        ON e.offer_id = o.offer_id

    WHERE o.offer_type IN ('bogo', 'discount')
    GROUP BY o.reward
)

SELECT
    reward,
    received_count,
    completed_count,

    ROUND(
        100.0 * completed_count / NULLIF(received_count, 0),
        2
    ) AS completion_rate_pct

FROM reward_summary
ORDER BY reward;


-- 3 Do longer offer durations have higher completion rates?

WITH duration_summary AS (
    SELECT
        o.duration,

        COUNT(*) FILTER (
            WHERE e.event = 'offer received'
        ) AS received_count,

        COUNT(*) FILTER (
            WHERE e.event = 'offer completed'
        ) AS completed_count

    FROM events e
    JOIN offers o
        ON e.offer_id = o.offer_id

    WHERE o.offer_type IN ('bogo', 'discount')
    GROUP BY o.duration
)

SELECT
    duration,
    received_count,
    completed_count,

    ROUND(
        100.0 * completed_count / NULLIF(received_count, 0),
        2
    ) AS completion_rate_pct

FROM duration_summary
ORDER BY duration;