-- | 1. Identify Repeat Visit & Purchase Behaviour |
-- FIND new users within this time frame ie.) years ACQUIRED in 2014
-- we are excluding users before 2014. Meaning returning users visiting will already be flagged
-- we want to filter them OUT, and focus on new users and if those new users return!
-- Again, we need to filter out all fllagged returning usrs who visited before 2014
;

-- The CASE NULL END user_session_count means, the NULL filters out all old users (not in date range)
-- COUNT(session) basically counts all sessions and repeated sesionas
-- udemy: 
-- just count all the sessions that a user has
-- use case else NULL to filter out the previous users before this testing poeriod
-- the window function is already loaded and applied, the case statement just selectively displats it
DROP TEMPORARY TABLE IF EXISTS user_session_count;

CREATE TEMPORARY TABLE user_session_count
SELECT
    user_id,
    CASE
        WHEN is_repeat_session = 0 THEN COUNT(website_session_id) OVER(PARTITION BY user_id)
        ELSE NULL
    END user_session_count,
    is_repeat_session
FROM
    website_sessions
WHERE
    created_at >= '2014-01-01'
    AND created_at < '2014-11-01'
ORDER BY
    user_id;

SELECT
    CASE
        WHEN t.user_session_count = 1 THEN t.user_session_count -1
        WHEN t.user_session_count = 2 THEN t.user_session_count -1
        WHEN t.user_session_count = 3 THEN t.user_session_count -1
        WHEN t.user_session_count = 4 THEN t.user_session_count -1
    END repeat_sessions,
    COUNT(user_session_count) unique_customers
FROM
    user_session_count t
WHERE
    t.user_session_count IS NOT NULL
GROUP BY
    1
ORDER BY
    repeat_sessions;

--Course solution:
-- first inner query fitlers out the previous users
-- seconde inner query that is LEFT joined gets the repeat sessions
-- LEFT JOIN with grab all new_user sessions and teh null repat_user sessiosn
CREATE TEMPORARY TABLE sessions_w_repeats
SELECT
    new_sessions.user_id,
    new_sessions.website_session_id AS new_session_id,
    repeat_sessions.website_session_id AS repeat_session_id
FROM
    (
        SELECT
            user_id,
            website_session_id
        FROM
            website_sessions
        WHERE
            created_at >= '2014-01-01'
            AND created_at < '2014-11-01'
            AND is_repeat_session = 0
    ) AS new_sessions
    LEFT JOIN (
        SELECT
            user_id,
            website_session_id
        FROM
            website_sessions
        WHERE
            created_at >= '2014-01-01'
            AND created_at < '2014-11-01'
            AND is_repeat_session = 1
    ) AS repeat_sessions ON new_sessions.user_id = repeat_sessions.user_id;

WITH session_type_per_user AS (
    SELECT
        user_id,
        COUNT(DISTINCT new_session_id) AS new_sessions,
        COUNT(DISTINCT repeat_session_id) AS repeat_sessions
    FROM
        sessions_w_repeats
    GROUP BY
        1
)
SELECT
    repeat_sessions,
    COUNT(DISTINCT user_id) AS users
FROM
    session_type_per_user
GROUP BY
    1;

-- | 2. Analyzing Time to Repeat |
-- For same time period, find minimum, maximum and avergae time
-- between first and second sessions for customer who come back
-- window method:
DROP TEMPORARY TABLE IF EXISTS session_cnt_per_user;

CREATE TEMPORARY TABLE session_cnt_per_user
SELECT
    user_id,
    website_session_id,
    created_at,
    CASE
        WHEN is_repeat_session = 0 THEN COUNT(website_session_id) OVER(PARTITION BY user_id)
        ELSE NULL
    END num_sessions
FROM
    website_sessions
WHERE
    created_at >= '2014-01-01'
    AND created_at < '2014-11-01'
ORDER BY
    user_id,
    created_at;

DROP TEMPORARY table only_two_sessions;

CREATE TEMPORARY table only_two_sessions
SELECT
    session_cnt_per_user.user_id,
    website_sessions.website_session_id,
    website_sessions.created_at as 'first_sess',
    LEAD(website_sessions.created_at) OVER(PARTITION BY session_cnt_per_user.user_id) AS 'second_sess'
FROM
    session_cnt_per_user
    INNER JOIN website_sessions ON session_cnt_per_user.user_id = website_sessions.user_id
WHERE
    num_sessions = 2
ORDER BY
    session_cnt_per_user.user_id,
    session_cnt_per_user.created_at;

WITH time_between_sessions AS (
    SELECT
        user_id,
        DATEDIFF(second_sess, first_sess) time_between_visit
    FROM
        only_two_sessions
    WHERE
        second_sess IS NOT NULL
)
SELECT
    MIN(time_between_visit) AS min_time_between_vists,
    MAX(time_between_visit) AS max_time_between_vists,
    AVG(time_between_visit) AS avg_time_between_vists
FROM
    time_between_sessions;

-- | 3. Analyzing Repeat Channel Behaviour |
SELECT
    CASE
        WHEN utm_source IS NULL
        AND http_referer IS NULL THEN 'direct_traffic'
        WHEN utm_source IS NULL
        AND http_referer IN (
            'https://www.gsearch.com',
            'https://www.bsearch.com'
        ) THEN 'organic_search'
        WHEN utm_campaign = 'brand' THEN 'paid_brand'
        WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
        WHEN utm_source = 'socialbook' THEN 'paid_social'
    END AS channel_group,
    COUNT(
        CASE
            WHEN is_repeat_session = 0 THEN Website_session_id
            ELSE NULL
        END
    ) AS non_repeat_session,
    COUNT(
        CASE
            WHEN is_repeat_session = 1 THEN Website_session_id
            ELSE NULL
        END
    ) AS repeat_session
FROM
    website_sessions
WHERE
    created_at >= '2014-01-01'
    AND created_at < '2014-11-01'
GROUP BY
    1;

-- | 4. Analyzing New and Repeat Conversion Rates |
SELECT
    CASE
        WHEN is_repeat_session = 0 THEN 0
        WHEN is_repeat_session = 1 THEN 1
    END is_repeat_session,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS sessions_to_orders_conv,
    SUM(price_usd) / COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session
FROM
    website_sessions
    LEFT JOIN orders ON website_sessions.website_session_id = orders.website_session_id
WHERE
    website_sessions.created_at >= '2014-01-01'
    AND website_sessions.created_at < '2014-11-08'
GROUP BY
    1;