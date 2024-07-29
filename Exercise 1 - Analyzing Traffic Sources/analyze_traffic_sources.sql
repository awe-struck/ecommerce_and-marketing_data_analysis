-- USE mavenfuzzyfactory;
-- Finding Top Traffic Sources
-- Gsearch nonbrad is the top drving of traffic
SELECT
    web_sess.utm_source,
    web_sess.utm_campaign,
    web_sess.http_referer,
    COUNT(web_sess.website_session_id) AS num_sessions
FROM
    website_sessions AS web_sess
    LEFT JOIN orders ON web_sess.website_session_id = orders.website_session_id
WHERE
    web_sess.created_at < '2012-04-12 00:00:00'
GROUP BY
    web_sess.utm_source,
    web_sess.utm_campaign,
    web_sess.http_referer
ORDER BY
    num_sessions DESC;

-- Based on previous analysis, find Conversions Rates (CVR) from sessions to order
-- if lower than 4% CVR, we may need to reduce bids, if highter we can incraes
-- CVR is 2.88%, so we may need t obid lower
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

-- Bid optmiaztion: 
-- MIN date_value to have start week
SELECT
    YEAR(created_at) AS year,
    WEEK(created_at) as month,
    MIN(date(created_at)) as week_start,
    COUNT(website_session_id) as sessions
FROM
    website_sessions
WHERE
    website_session_id between 100000
    and 115000
group BY
    year,
    month;

-- Pivoting data with count and case
-- mimic excel pivot tables with COUNT(CASE WHEN ...)
-- basically have the count be the aggregated columns
SELECT
    primary_product_id,
    order_id,
    items_purchased,
    COUNT(
        DISTINCT CASE
            WHEN items_purchased = 1 THEN order_id
            ELSE null
        END
    ) AS count_single_item_orders,
    COUNT(
        DISTINCT CASE
            WHEN items_purchased = 2 THEN order_id
            ELSE null
        END
    ) AS count_two_item_orders
FROM
    orders
WHERE
    order_id between 31000
    and 32000
GROUP BY
    primary_product_id,
    order_id,
    items_purchased;

-- Trended Time Analysis
-- CONTEXT: based on CVR analysis, the we bid down on gsearch nonbrand on 2012-04-15 to 2012-05-10
-- PUll gsearch nonbrand trended session volumbe by week, see if bid changes caused volume to drop or increasee
-- From the weeks after te change, it marked a sharp decrease in sessions. meaning a change in bid is faily sensitve
-- will ideeat more
SELECT
    WEEK(web_sess.created_at) AS week,
    MIN(DATE(web_sess.created_at)) AS week_start_date,
    COUNT(DISTINCT web_sess.website_session_id) AS sessions
FROM
    website_sessions AS web_sess
WHERE
    utm_campaign = 'nonbrand'
    AND utm_source = 'gsearch'
    AND web_sess.created_at < '2012-05-10'
GROUP BY
    week;

-- CONTEXT: mobile seems slower when using it. Please pull out the numbers for them
-- conversion analysis on mobile vs desktop
-- date may 11,2012
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

-- CONTEXT: after looking at device level CVR of desktop outperfoming mobile, we bid gsearch nonbrand desktop cmapgins up on 
-- 2012-05-19
-- FOR TRENIDNG W/GRANULAR SEGMENTS make a pivot talbe
-- wieht date, pivot column, pivot column
-- each pivot column contains COUNT(case when ..)
-- pull up weekly trends for both desktop and mobile
-- use earlietr dat of 2012-04-15
-- result: the desktop segment is looking strong thanks to canges
-- NEXT STEPS: continue to monitor device-level volume of traffic and be aware of impact that bid levels have
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

-- Analyzing Top Website Content
-- CONTEXT: June 09, 2012. Find most-viewed website pages, ranked by sessions volume?
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

--  analyze top entry/landing pages
-- CONTEXT: home, product and fuzzy pages how most of the traffic. What about the lanidng pages?
-- RESULT: 10714 sessions /home, but we ONLY have it for /home
-- NEXT STEP: 
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

- -- check perfomace of each landing page. Find sessions and bounced sessions
-- STEP 1: find the first website_pageview_id for revleant sessions
-- STEP 2: identify the landing page url for each session
-- STEP 3: count pageviews for each sesions to identlyf bounces
-- STEP 4: summeraize the totoals
-- Finding Landing Pages for each Session
CREATE TEMPORARY TABLE website_landing_pages AS (
    SELECT
        website_pageviews.website_session_id,
        MIN(website_pageviews.website_pageview_id) AS min_pageview_id
    FROM
        website_pageviews
        INNER JOIN website_sessions ON website_pageviews.website_session_id = website_sessions.website_session_id
        AND website_sessions.created_at BETWEEN '2014-01-01'
        AND '2014-02-01'
    GROUP BY
        website_pageviews.website_session_id
);

-- Identify landing page url per sesason
CREATE TEMPORARY TABLE sessions_with_landing_page AS (
    SELECT
        website_pageviews.website_session_id,
        website_pageviews.pageview_url AS landing_pages
    FROM
        website_landing_pages
        INNER JOIN website_pageviews ON website_landing_pages.min_pageview_id = website_pageviews.website_pageview_id
);

-- get number of page visits per sessions per landing zcv then isolate for sessions with one page view
CREATE TEMPORARY TABLE bounced_sessions_only
SELECT
    sessions_with_landing_page.website_session_id,
    sessions_with_landing_page.landing_pages,
    COUNT(website_pageviews.website_pageview_id) AS total_pages_visited
FROM
    sessions_with_landing_page
    INNER JOIN website_pageviews ON sessions_with_landing_page.website_session_id = website_pageviews.website_session_id
GROUP BY
    sessions_with_landing_page.website_session_id,
    sessions_with_landing_page.landing_pages
HAVING
    total_pages_visited = 1;

-- intial
SELECT
    sessions_with_landing_page.landing_pages,
    sessions_with_landing_page.website_session_id,
    bounced_sessions_only.website_session_id AS bouned_website_sessions_id
FROM
    sessions_with_landing_page
    LEFT JOIN bounced_sessions_only ON sessions_with_landing_page.website_session_id = bounced_sessions_only.website_session_id
ORDER BY
    sessions_with_landing_page.website_session_id;

--final 
SELECT
    sessions_with_landing_page.landing_pages,
    COUNT(sessions_with_landing_page.website_session_id) AS sessions,
    COUNT(bounced_sessions_only.website_session_id) AS bouned_website_sessions_id,
    COUNT(bounced_sessions_only.website_session_id) / COUNT(sessions_with_landing_page.website_session_id) AS bounce_rate
FROM
    sessions_with_landing_page
    LEFT JOIN bounced_sessions_only ON sessions_with_landing_page.website_session_id = bounced_sessions_only.website_session_id
GROUP BY
    sessions_with_landing_page.landing_pages
ORDER BY
    sessions;

-- TlDR:
-- what are the lading pages, how many sessions did it get? how many did they bounce
--Analzing bounce rates ofr landing pages
-- from june 14, 2012
-- Find sessions, bounce rate and bouced sessions from homepage
-- Find landing page for each section 
-- results 60% bounce rate so we will ab test
DROP TABLE website_landing_pages CREATE TEMPORARY TABLE website_landing_pages
SELECT
    website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pv_id
FROM
    website_pageviews
    INNER JOIN website_sessions on website_pageviews.website_session_id = website_sessions.website_session_id
    AND website_sessions.created_at < '2012-06-14'
GROUP BY
    website_pageviews.website_session_id;

-- sessions with landing pages (filtered tgo home page)
CREATE TEMPORARY TABLE home_landing_page_only
SELECT
    website_landing_pages.website_session_id,
    website_pageviews.pageview_url AS landing_pages
FROM
    website_landing_pages
    INNER JOIN website_pageviews ON website_landing_pages.min_pv_id = website_pageviews.website_pageview_id
WHERE
    website_pageviews.pageview_url = '/home';

-- get the number of pageviews per session then filter for only 1 pagevie
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

-- get the sessions, bournces and bounce rates
SELECT
    COUNT(home_landing_page_only.website_session_id) sessions,
    COUNT(bounced_sessions_only.website_session_id) bounces,
    COUNT(bounced_sessions_only.website_session_id) / COUNT(home_landing_page_only.website_session_id) AS bounce_rt
FROM
    home_landing_page_only
    LEFT JOIN bounced_sessions_only ON home_landing_page_only.website_session_id = bounced_sessions_only.website_session_id;

-- A/B test landing pabes
--bounce rates of two a/b tested lading bages of lander-1 VS home
-- context: july, 28, 2012 only look at when lander 1 was getting taffer
-- Find earlierst date with traffic for /lander-1: 
-- SESSIONS_id: 11683, pagevieww_id: 23504, 2012-06-19 00:35:54
-- this is for g search nonbrand tgraffic
-- RESULT:  6% decresase in bounce rate
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
    website_pageview_id;

-- find landing page id for each session
DROP TABLE website_landing_pages;

CREATE TEMPORARY TABLE website_landing_pages
SELECT
    website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM
    website_pageviews
    INNER JOIN website_sessions on website_pageviews.website_session_id = website_sessions.website_session_id
    AND utm_campaign = 'nonbrand'
    AND utm_source = 'gsearch'
    AND website_sessions.website_session_id > 11683
    AND website_sessions.created_at < '2012-07-28'
GROUP BY
    website_pageviews.website_session_id;

-- find session ids for each landing page of home or lander-1
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

-- count the pageviews for each lanindg page
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

-- CALCUATE CVR
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

-- Landing Page Trend Analysis
-- CONTEXT:
-- date: August 31, 2012 '2012-08-31'
-- Find volume of paid search, nonbrad traffic landing on /home and /lander-1,
-- trended weekly aince june 1. Confrim traffic is routed correctly
-- All check overall bounce rate too.
-- STEP 1: Find landing pages WHERE paid, nonbrand, AND created by between june 1 and < '2012-08-31'
-- STEP 2: filter for /home and /lander-1 urls
-- STEP 3: count pagevies for bounce rates
-- STEP 4: group by week then caluclate boune tate
-- STEP !: Find Lanindg Pages
-- REsults: 
-- PRE-STEPS: the challenge made a mistkae and did not account for bseach only gsearch
-- so we will only use gsearch
-- NEXT steps: slowly switched towrs /lander page and the bounce rate s have been slowly decreading. will monitor over time
SELECT
    DISTINCT utm_source
FROM
    website_sessions;

-- STEP 1: find landing pages
DROP TEMPORARY TABLE IF EXISTS website_landing_pages;

CREATE TEMPORARY TABLE website_landing_pages
SELECT
    website_sessions.created_at,
    website_sessions.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pv_id
FROM
    website_sessions
    INNER JOIN website_pageviews ON website_sessions.website_session_id = website_pageviews.website_session_id
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
    AND website_sessions.created_at >= '2012-06-01'
    AND website_sessions.created_at < '2012-08-31'
GROUP BY
    website_sessions.created_at,
    website_sessions.website_session_id;

-- STEP 2: finding landing page urls
DROP TEMPORARY TABLE IF EXISTS sessions_with_landing_page;

CREATE TEMPORARY TABLE sessions_with_landing_page
SELECT
    website_landing_pages.created_at,
    website_landing_pages.website_session_id,
    website_pageviews.pageview_url AS landing_pages
FROM
    website_landing_pages
    INNER JOIN website_pageviews ON website_landing_pages.min_pv_id = website_pageviews.website_pageview_id
WHERE
    website_pageviews.pageview_url IN ('/home', '/lander-1');

-- STEP 3: count pageviews then filter for pages with bounces
-- STEP 3: find bounces
CREATE TEMPORARY TABLE bounced_sessions_only
SELECT
    sessions_with_landing_page.created_at,
    sessions_with_landing_page.website_session_id,
    sessions_with_landing_page.landing_pages,
    COUNT(website_pageviews.website_pageview_id) AS num_pageviews
FROM
    sessions_with_landing_page
    INNER JOIN website_pageviews ON sessions_with_landing_page.website_session_id = website_pageviews.website_session_id
GROUP BY
    sessions_with_landing_page.created_at,
    sessions_with_landing_page.website_session_id,
    sessions_with_landing_page.landing_pages
HAVING
    num_pageviews = 1;

-- STEP 4: GROUP TOGHETERH  fro trend analysis then count
SELECT
    MIN(DATE(sessions_with_landing_page.created_at)) AS week_start_date,
    COUNT(
        CASE
            WHEN sessions_with_landing_page.landing_pages = '/home' THEN sessions_with_landing_page.website_session_id
            ELSE NULL
        END
    ) AS home_sessions,
    COUNT(
        CASE
            WHEN sessions_with_landing_page.landing_pages = '/lander-1' THEN sessions_with_landing_page.website_session_id
            ELSE NULL
        END
    ) AS lander_sessions,
    COUNT(bounced_sessions_only.website_session_id) / COUNT(sessions_with_landing_page.website_session_id) AS bounce_rt
FROM
    sessions_with_landing_page
    LEFT JOIN bounced_sessions_only ON sessions_with_landing_page.website_session_id = bounced_sessions_only.website_session_id
GROUP BY
    YEARWEEK(sessions_with_landing_page.created_at);

-- VERSION 2: Condesnsed version
-- STEP 1: Find landing pages
-- STEP 2: Find Landing page url
-- STEP 3: Count pageviews, filter for bounce rate
-- STEP 4: trend analysis
-- STEP 1: Find landing pages, with count(page views), and 
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
    WEEK(sessions_created_at) -- Analyzing and testing conversion funnels
    -- BUSINESS CONTEXT
    -- we want to build a cojversion funnel from /lander-2 to /cart
    -- we want to know how many people reach each step, and also dropoff rates
    -- for simplicity of the demo, we look at /lander-2 traffic only
    -- for simplicity of the demo, we look at cutomers who like mr. fuzzy only
    -- STEPF 1: select all pageviews for relevant sessions 
    -- For each session id and its pageurls, flag the urls of interest (steps in the funnel) using case 1 else 0
    -- STEP 2: identify each relevant pageview as the specifci funnel step (basically condesne results from first table)
    -- for each session_id, make the funnel path by using max(url_step) to show if it has been done
    -- STEP 3: create the sessions-level converion funnel view
    -- STEP 4: aggregate data to assess funnel performance
    -- TLDR: flag each step of interest with CASE 1/0, aggreate that table into condensed one with MAX(url_step)
    -- then count each condensed version for results
    -- Create the temporary table and insert data from the CTE
    CREATE TEMPORARY TABLE session_level_made_it_flags AS
SELECT
    website_session_id,
    MAX(products_page) AS product_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it
FROM
    (
        SELECT
            wb_ss.website_session_id,
            wb_pv.pageview_url,
            wb_pv.created_at AS pageview_created_at,
            CASE
                WHEN pageview_url = '/products' THEN 1
                ELSE 0
            END as products_page,
            CASE
                WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1
                ELSE 0
            END as mrfuzzy_page,
            CASE
                WHEN pageview_url = '/cart' THEN 1
                ELSE 0
            END as cart_page
        FROM
            website_sessions AS wb_ss
            INNER JOIN website_pageviews AS wb_pv ON wb_ss.website_session_id = wb_pv.website_session_id
        WHERE
            wb_ss.created_at BETWEEN '2014-01-01'
            AND '2014-02-01'
            AND wb_pv.pageview_url IN (
                '/lander-2',
                '/products',
                '/the-original-mr-fuzzy',
                '/cart'
            )
        ORDER BY
            wb_ss.website_session_id,
            wb_pv.created_at
    ) AS pageview_level
GROUP BY
    website_session_id;

-- count of sessions per funnel step
SELECT
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(
        DISTINCT CASE
            WHEN product_made_it = 1 THEN website_session_id
            ELSE NULL
        END
    ) AS to_products,
    COUNT(
        DISTINCT CASE
            WHEN mrfuzzy_made_it = 1 THEN website_session_id
            ELSE NULL
        END
    ) AS to_mrfuzzy,
    COUNT(
        DISTINCT CASE
            WHEN cart_made_it = 1 THEN website_session_id
            ELSE NULL
        END
    ) AS to_cart
FROM
    session_level_made_it_flags;

-- count of sessions per funnel step with ctr
SELECT
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(
        DISTINCT CASE
            WHEN product_made_it = 1 THEN website_session_id
            ELSE NULL
        END
    ) / COUNT(DISTINCT website_session_id) AS clicked_to_products,
    COUNT(
        DISTINCT CASE
            WHEN mrfuzzy_made_it = 1 THEN website_session_id
            ELSE NULL
        END
    ) / COUNT(
        DISTINCT CASE
            WHEN product_made_it = 1 THEN website_session_id
            ELSE NULL
        END
    ) AS clicked_to_mrfuzzy,
    COUNT(
        DISTINCT CASE
            WHEN cart_made_it = 1 THEN website_session_id
            ELSE NULL
        END
    ) / COUNT(
        DISTINCT CASE
            WHEN mrfuzzy_made_it = 1 THEN website_session_id
            ELSE NULL
        END
    ) AS clicked_to_cart
FROM
    session_level_made_it_flags --