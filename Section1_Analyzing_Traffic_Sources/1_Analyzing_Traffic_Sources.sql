-- | 1. Finding Top Traffic Sources |
-- Result:  
-- gsearch nonbrand is the top drving of traffic
-- Next Step: Most sessions are generated from gsearch, so investigate if it has conversions
SELECT
    web_sess.utm_source,
    web_sess.utm_campaign,
    web_sess.http_referer,
    COUNT(web_sess.website_session_id) AS num_sessions
FROM
    website_sessions AS web_sess
WHERE
    web_sess.created_at < '2012-04-12'
GROUP BY
    web_sess.utm_source,
    web_sess.utm_campaign,
    web_sess.http_referer
ORDER BY
    num_sessions DESC;

-- | 2. Top Traffic Source Conversion Rate |
-- RESULT
-- 2.88% CVR which is lower than 4% CVR, so we
-- may need to reduce bids,will monitor results over time
SELECT
    COUNT(DISTINCT web_sess.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT web_sess.website_session_id) AS session_to_order_conv_rt
FROM
    website_sessions AS web_sess
    LEFT JOIN orders ON web_sess.website_session_id = orders.website_session_id
WHERE
    web_sess.created_at < '2012-04-14'
    AND utm_campaign = 'nonbrand'
    AND utm_source = 'gsearch';

-- | 3. Trend Analysis of Top Traffic Source |
-- RESULT 
-- will conitue to  mointor volume levels
SELECT
    MIN(date(created_at)) as week_start,
    COUNT(website_session_id) as sessions
FROM
    website_sessions
WHERE
    created_at < '2012-05-10'
    AND utm_campaign = 'nonbrand'
    AND utm_source = 'gsearch'
GROUP BY
    YEAR(created_at),
    WEEK(created_at);

-- | 4. Bid Optimizaation for Paid Traffic by device type |
-- RESULT
-- dESKTOP is at 3.373% vs mobile at 0.96% conversion rate
-- incrase more bids on desktop vs mobile since mobile is doing welll
SELECT
    device_type,
    COUNT(web_sess.website_session_id) AS sessions,
    COUNT(orders.order_id) as orders,
    COUNT(orders.order_id) / COUNT(web_sess.website_session_id) AS sessions_to_orders_cv_rt
FROM
    website_sessions AS web_sess
    LEFT JOIN orders on web_sess.website_session_id = orders.website_session_id
WHERE
    utm_campaign = 'nonbrand'
    AND utm_source = 'gsearch'
    AND web_sess.created_at < '2012-05-11'
GROUP BY
    web_sess.device_type;

-- | 5. Bid Optimizaation for Paid Traffic |
-- RESULT: 
-- the desktop segment is looking strong thanks to cHanges
--  continue to monitor device-level volume of traffic and be aware of impact that bid levels have
-- conintue to monitor conversion perofmatec at devile level to optimize spend
SELECT
    WEEK(created_at) AS week,
    MIN(created_at) AS week_start_date,
    COUNT(
        CASE
            WHEN device_type = 'desktop' THEN website_session_id
            ELSE NULL
        END
    ) AS desktop_sessions,
    COUNT(
        CASE
            WHEN device_type = 'mobile' THEN website_session_id
            ELSE NULL
        END
    ) AS mobile_sessions
FROM
    website_sessions as web_sess
WHERE
    web_sess.utm_campaign = 'nonbrand'
    AND web_sess.utm_source = 'gsearch'
    AND created_at BETWEEN '2012-04-15'
    AND '2012-06-09'
GROUP BY
    week;