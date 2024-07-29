-- | 1. Finding Top Website Content |
-- RESULT
-- check the performacne of the top pages
-- check if they are also landing pages too
SELECT
    pageview_url,
    COUNT(website_session_id) AS session_vol
FROM
    website_pageviews
WHERE
    created_at < '2012-06-09'
GROUP BY
    pageview_url
ORDER BY
    session_vol DESC;

-- | 2. Finding Top Landing Pages |
-- RESULT
-- only /home page s our landing page
-- next analyze lanidng page performae for homepage, then abtest it
WITH website_landing_pages AS (
    SELECT
        website_session_id,
        MIN(website_pageview_id) AS first_pv_id
    FROM
        website_pageviews
    WHERE
        created_at < '2012-06-12'
    GROUP BY
        website_session_id
)
SELECT
    web_pv.pageview_url landing_pages,
    COUNT(DISTINCT web_pv.website_session_id) sessions
FROM
    website_landing_pages web_lp
    INNER JOIN website_pageviews web_pv ON web_lp.first_pv_id = web_pv.website_pageview_id
GROUP BY
    landing_pages;

-- | 3. Calculate Bounce Rate for Top Landing Pages|
-- RESULT: 
-- 10714 sessions /home, but we ONLY have it for /home
-- evaulate perfomance
-- check if homepage is best as landingpage
WITH first_pv AS (
    SELECT
        website_session_id,
        MIN(website_pageview_id) AS min_pv_id
    FROM
        website_pageviews
    GROUP BY
        website_session_id
)
SELECT
    website_pageviews.pageview_url AS landing_pages,
    COUNT(first_pv.website_session_id) AS sessions_with_landing_page
FROM
    first_pv
    INNER JOIN website_pageviews ON first_pv.min_pv_id = website_pageviews.website_pageview_id
WHERE
    created_at < '2012-06-12'
GROUP BY
    landing_pages
ORDER BY
    sessions_with_landing_page DESC;

-- | 4. Finding Top Landing Pages |
-- RESULT:
-- 59% bounce rate, so we need to make a new landing page and a/b test it
-- STEP 1: find landing page id
DROP TABLE website_landing_pages;

CREATE TEMPORARY TABLE website_landing_pages
SELECT
    website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pv_id
FROM
    website_pageviews
    INNER JOIN website_sessions on website_pageviews.website_session_id = website_sessions.website_session_id
WHERE
    website_sessions.created_at < '2012-06-14'
GROUP BY
    website_pageviews.website_session_id;

-- STEP 2: find sessions with landing pages URL (filtered tgo home page)
DROP TEMPORARY TABLE home_landing_page_only;

CREATE TEMPORARY TABLE home_landing_page_only
SELECT
    website_landing_pages.website_session_id,
    website_pageviews.pageview_url AS landing_pages
FROM
    website_landing_pages
    INNER JOIN website_pageviews ON website_landing_pages.min_pv_id = website_pageviews.website_pageview_id
WHERE
    website_pageviews.pageview_url = '/home';

--  STEP 3: get the number of pageviews per session then filter for only 1 pagevie
DROP TEMPORARY TABLE IF EXISTS bounced_sessions_only;

CREATE TEMPORARY TABLE bounced_sessions_only
SELECT
    home_landing_page_only.website_session_id,
    COUNT(website_pageview_id) AS num_pageviews
FROM
    home_landing_page_only
    INNER JOIN website_pageviews ON home_landing_page_only.website_session_id = website_pageviews.website_session_id
GROUP BY
    home_landing_page_only.landing_pages,
    home_landing_page_only.website_session_id
HAVING
    num_pageviews = 1;

-- STEP 4: get the sessions, bournces and bounce rates
SELECT
    COUNT(home_landing_page_only.website_session_id) sessions,
    COUNT(bounced_sessions_only.website_session_id) bounces,
    COUNT(bounced_sessions_only.website_session_id) / COUNT(home_landing_page_only.website_session_id) AS bounce_rt
FROM
    home_landing_page_only
    LEFT JOIN bounced_sessions_only ON home_landing_page_only.website_session_id = bounced_sessions_only.website_session_id;

-- | 5. Analyzing Landing Page A/B Tests |
-- RESULT:  
--6% decresase in bounce rate SO LANDER IS A SUCCESS
-- WATCH AND OVESR OVER TIME
-- STEP 1: find the latest occurnce of /lander-1 page
-- session_id: 11683, pagevieww_id: 23504, 2012-06-19 00:35:54
SELECT
    pageview_url,
    website_session_id,
    website_pageview_id,
    MIN(created_at)
FROM
    website_pageviews
WHERE
    pageview_url = '/lander-1'
GROUP BY
    pageview_url,
    website_session_id,
    website_pageview_id
LIMIT
    2;

-- STEP 2: find landing page id for each session fitler with session_id > 11683
DROP TABLE website_landing_pages;

CREATE TEMPORARY TABLE website_landing_pages
SELECT
    website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM
    website_pageviews
    INNER JOIN website_sessions ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE
    utm_campaign = 'nonbrand'
    AND utm_source = 'gsearch'
    AND website_sessions.website_session_id > 11683
    AND website_sessions.created_at < '2012-07-28'
GROUP BY
    website_pageviews.website_session_id;

-- STEP 3: find session ids for each landing page of home or lander-1
DROP TEMPORARY TABLE IF EXISTS ab_test_pages;

CREATE TEMPORARY TABLE ab_test_pages
SELECT
    website_landing_pages.website_session_id,
    website_pageviews.pageview_url AS landing_pages
FROM
    website_landing_pages
    INNER JOIN website_pageviews ON website_landing_pages.min_pageview_id = website_pageviews.website_pageview_id
    AND created_at
WHERE
    website_pageviews.pageview_url IN ('/home', '/lander-1');

-- STEP 4: count the pageviews for each lanindg page
DROP TEMPORARY TABLE IF EXISTS bounced_sessions_ab;

CREATE TEMPORARY TABLE bounced_sessions_ab
SELECT
    landing_pages,
    ab_test_pages.website_session_id,
    COUNT(website_pageviews.website_pageview_id) AS num_pageviews
FROM
    ab_test_pages
    INNER JOIN website_pageviews ON ab_test_pages.website_session_id = website_pageviews.website_session_id
GROUP BY
    landing_pages,
    ab_test_pages.website_session_id
HAVING
    num_pageviews = 1
ORDER BY
    landing_pages;

--  STEP 5: CALCUATE CVR
SELECT
    ab_test_pages.landing_pages,
    COUNT(ab_test_pages.website_session_id) AS sessions,
    COUNT(bounced_sessions_ab.website_session_id) AS bounces,
    COUNT(bounced_sessions_ab.website_session_id) / COUNT(ab_test_pages.website_session_id) AS bounce_rt
FROM
    ab_test_pages
    LEFT JOIN bounced_sessions_ab ON ab_test_pages.website_session_id = bounced_sessions_ab.website_session_id -- solution 1; TRY DOING IT 
GROUP BY
    ab_test_pages.landing_pages;

-- | 6. Trend Analysis Landing Page |
-- STEP 1: Find landing pages, with count(page views), and 
DROP TEMPORARY TABLE sessions_w_min_pv_and_pv_count;

CREATE TEMPORARY TABLE sessions_w_min_pv_and_pv_count
SELECT
    wb_pv.website_session_id,
    MIN(wb_pv.website_pageview_id) AS min_pv_id,
    COUNT(wb_pv.website_pageview_id) AS num_pageviews
FROM
    website_pageviews AS wb_pv
    INNER JOIN website_sessions AS wb_ss ON wb_pv.website_session_id = wb_ss.website_session_id
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
    AND wb_ss.created_at >= '2012-06-01'
    AND wb_ss.created_at < '2012-08-31'
GROUP BY
    website_session_id;

-- STEP 2: Find Landing page url
DROP TEMPORARY TABLE sessions_w_counts_lander_and_created_at;

CREATE TEMPORARY TABLE sessions_w_counts_lander_and_created_at
SELECT
    sess_pv.website_session_id,
    sess_pv.min_pv_id,
    sess_pv.num_pageviews,
    wb_pv.pageview_url AS landing_pages,
    wb_pv.created_at AS sessions_created_at
FROM
    sessions_w_min_pv_and_pv_count AS sess_pv
    INNER JOIN website_pageviews wb_pv ON sess_pv.min_pv_id = wb_pv.website_pageview_id;

-- STEP 3: Trend analysis
SELECT
    MIN(DATE(sess_created_at.sessions_created_at)) AS week_start_date,
    COUNT(website_session_id) AS total_sessions,
    COUNT(
        CASE
            WHEN num_pageviews = 1 THEN 1
            ELSE NULL
        END
    ) AS bounced_sessions,
    COUNT(
        CASE
            WHEN num_pageviews = 1 THEN 1
            ELSE NULL
        END
    ) / COUNT(website_session_id) AS bounce_rate,
    COUNT(
        CASE
            WHEN landing_pages = '/home' THEN 1
            ELSE NULL
        END
    ) AS home_sessions,
    COUNT(
        CASE
            WHEN landing_pages = '/lander-1' THEN 1
            ELSE NULL
        END
    ) AS lander_sessions
FROM
    sessions_w_counts_lander_and_created_at AS sess_created_at
GROUP BY
    WEEK(sessions_created_at);

-- | 7. Bulding Conversion Funnels|
CREATE TEMPORARY TABLE user_funnel
SELECT
    COUNT(DISTINCT web_pv.website_session_id) AS sessions,
    COUNT(
        CASE
            WHEN web_pv.pageview_url = '/products' THEN 1
            ELSE NULL
        END
    ) AS to_products,
    COUNT(
        CASE
            WHEN web_pv.pageview_url = '/the-original-mr-fuzzy' THEN 1
            ELSE NULL
        END
    ) AS to_mrfuzzy,
    COUNT(
        CASE
            WHEN web_pv.pageview_url = '/cart' THEN 1
            ELSE NULL
        END
    ) AS to_cart,
    COUNT(
        CASE
            WHEN web_pv.pageview_url = '/shipping' THEN 1
            ELSE NULL
        END
    ) AS to_shipping,
    COUNT(
        CASE
            WHEN web_pv.pageview_url = '/billing' THEN 1
            ELSE NULL
        END
    ) AS to_billing,
    COUNT(
        CASE
            WHEN web_pv.pageview_url = '/thank-you-for-your-order' THEN 1
            ELSE NULL
        END
    ) AS to_thankyou
FROM
    website_pageviews web_pv
    INNER JOIN website_sessions web_sess ON web_pv.website_session_id = web_sess.website_session_id
WHERE
    web_sess.utm_campaign = 'nonbrand'
    AND web_sess.utm_source = 'gsearch'
    AND web_sess.created_at > '2012-08-05'
    AND web_sess.created_at < '2012-09-05';

-- STEP 1: Converinos Funnel Values
SELECT
    *
FROM
    user_funnel;

-- STEP 2: Converinos Funnel CTRs
SELECT
    to_products / sessions AS lander_CTR,
    to_mrfuzzy / to_products AS products_CTR,
    to_cart / to_mrfuzzy AS mrfuzzy_CTR,
    to_shipping / to_cart AS cart_CTR,
    to_billing / to_shipping AS shipping_CTR,
    to_thankyou / to_billing AS billing_CTR
FROM
    user_funnel;

-- ony 43% go into mrfuzzy page and only 43% go into the thank you page
-- so audit products and billing pages
-- | 8. Analyzing  Conversion Funnel TEsts|
-- STEP 1: find last instance of /billing-2 page
SELECT
    website_session_id,
    website_pageview_id,
    pageview_url,
    created_at
FROM
    website_pageviews
WHERE
    pageview_url = '/billing-2'
LIMIT
    2;

-- STEP 2: count sessions in each step of funnel
DROP TEMPORARY TABLE IF EXISTS sessions_w_orders;

CREATE TEMPORARY TABLE sessions_w_orders
SELECT
    web_pv.pageview_url,
    COUNT(web_pv.website_session_id) as sessions,
    COUNT(
        CASE
            WHEN orders.order_id IS NOT NULL THEN 1
            ELSE NULL
        END
    ) as orders
FROM
    website_pageviews AS web_pv
    INNER JOIN website_sessions web_sess ON web_pv.website_session_id = web_sess.website_session_id
    LEFT JOIN orders ON web_sess.website_session_id = orders.website_session_id
WHERE
    web_pv.pageview_url IN ('/billing', '/billing-2')
    AND web_pv.website_session_id > 25325
    AND web_pv.created_at < '2012-11-10'
GROUP BY
    web_pv.pageview_url;

-- STEP 3: GET CONVERSION RATES OF PAGES
SELECT
    *,
    orders / sessions
FROM
    sessions_w_orders;