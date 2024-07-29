-- Need to prepare stats for baord meeting
-- need to show our grown over the first 8 months
-- crated< novemnter 27, 2012
USE mavenfuzzyfactory;

-- QUESTION 1: 
-- Based on previous analysis, gsearch brings in most of our business. 
-- Pull montly trends for gsearch sessions and orders, so we can showcase our growth
-- RESULT:
-- Traffic has been steadly climbing up over time with sessions being 1697->11314
-- Not only that, orders has been steadly climbing as well. Consitently going from
-- > sub 200 orders to hitting >sub 3000 - >sub 400 orders. Recently we hit > 1000 orders
SELECT
    YEAR(web_sess.created_at) AS year,
    MONTH(web_sess.created_at) AS month_start_date,
    COUNT(web_sess.website_session_id) AS sessions,
    COUNT(orders.order_id) AS sessions_w_orders,
    COUNT(orders.order_id) / COUNT(web_sess.website_session_id) AS conv_rate
FROM
    website_sessions AS web_sess
    LEFT JOIN orders ON web_sess.website_session_id = orders.website_session_id
WHERE
    web_sess.utm_campaign = 'nonbrand'
    AND web_sess.utm_source = 'gsearch'
    AND web_sess.created_at < '2012-11-27'
GROUP BY
    year,
    MONTH(web_sess.created_at);

-- QUESTION 2: 
-- Next, it would be great to see a similar monthly trend for Gsearch,
-- but this time splitting out nonbrand and brand campaings separately.
-- Wondering if brand campaign is doing well, if so it would help our narrative
-- VERSION 1:
SELECT
    YEAR(web_sess.created_at) AS year,
    MONTH(web_sess.created_at) AS month_start_date,
    web_sess.utm_campaign,
    COUNT(web_sess.website_session_id) AS sessions,
    COUNT(orders.order_id) AS sessions_w_orders,
    COUNT(orders.order_id) / COUNT(web_sess.website_session_id) AS conv_rate
FROM
    website_sessions AS web_sess
    LEFT JOIN orders ON web_sess.website_session_id = orders.website_session_id
WHERE
    web_sess.utm_campaign IN ('brand', 'nonbrand')
    AND web_sess.utm_source = 'gsearch'
    AND web_sess.created_at < '2012-11-27'
GROUP BY
    year,
    MONTH(web_sess.created_at),
    web_sess.utm_campaign
ORDER BY
    web_sess.utm_campaign,
    MONTH(web_sess.created_at);

-- VERSION 2:
SELECT
    YEAR(web_sess.created_at) AS year,
    MONTH(web_sess.created_at) AS month,
    COUNT(
        CASE
            WHEN web_sess.utm_campaign = 'nonbrand' THEN 1
            ELSE NULL
        END
    ) AS nonbrand_sessions,
    COUNT(
        CASE
            WHEN web_sess.utm_campaign = 'brand' THEN 1
            ELSE NULL
        END
    ) AS brand_sessions,
    COUNT(
        CASE
            WHEN orders.order_id IS NOT NULL
            AND web_sess.utm_campaign = 'nonbrand' THEN 1
            ELSE NULL
        END
    ) AS nonbrand_orders,
    COUNT(
        CASE
            WHEN orders.order_id IS NOT NULL
            AND web_sess.utm_campaign = 'brand' THEN 1
            ELSE NULL
        END
    ) AS brand_orders
FROM
    website_sessions AS web_sess
    LEFT JOIN orders ON web_sess.website_session_id = orders.website_session_id
WHERE
    web_sess.utm_campaign IN ('brand', 'nonbrand')
    AND web_sess.utm_source = 'gsearch'
    AND web_sess.created_at < '2012-11-27'
GROUP BY
    year,
    month;

-- QUESTION 3: 
-- While you' re analyzing Gsearch,
-- explore nonbrand and pull monthly sessions and orders by split device type
-- Show that you know and really understand your traffic souces
SELECT
    YEAR(web_sess.created_at) AS year,
    MONTH(web_sess.created_at) AS month,
    COUNT(
        CASE
            WHEN web_sess.device_type = 'mobile' THEN 1
            ELSE NULL
        END
    ) AS mobile_sessions,
    COUNT(
        CASE
            WHEN web_sess.device_type = 'desktop' THEN 1
            ELSE NULL
        END
    ) AS desktop_sessions,
    COUNT(
        CASE
            WHEN orders.order_id IS NOT NULL
            AND web_sess.device_type = 'mobile' THEN 1
            ELSE NULL
        END
    ) AS mobile_orders,
    COUNT(
        CASE
            WHEN orders.order_id IS NOT NULL
            AND web_sess.device_type = 'desktop' THEN 1
            ELSE NULL
        END
    ) AS desktop_orders
FROM
    website_sessions AS web_sess
    LEFT JOIN orders ON web_sess.website_session_id = orders.website_session_id
WHERE
    web_sess.utm_campaign = 'nonbrand'
    AND web_sess.utm_source = 'gsearch'
    AND web_sess.created_at < '2012-11-27'
GROUP BY
    year,
    month;

-- Qustion 4:
-- Concerns that pessimistic board members may be dubious about 
-- the large % of traffic coming from Gsearch.
-- Pull monthly trends for Gsearch, along with montly trends for our other channels
-- Basically, find out monthly trend data for all traffic souces
;

-- Traffic Sources
-- When campaign, source and http_reffee are ALL NULL then direct traffic
-- when campaign, and souce are null then SEO and organic traffic
-- otherwise paid traffi
-- RESULT : seo and direct has been iproving which is great becaue 
-- it is grwoing withoug us putting money in it
SELECT
    DISTINCT utm_campaign,
    utm_source,
    http_referer
FROM
    website_sessions
WHERE
    created_at < '2012-11-27';

-- DATA
SELECT
    YEAR(web_sess.created_at) year,
    MONTH(web_sess.created_at) month,
    COUNT(
        CASE
            WHEN web_sess.utm_campaign IS NULL
            AND web_sess.utm_source IS NULL
            AND web_sess.http_referer IS NULL THEN 1
            ELSE NULL
        END
    ) AS direct_traffic_sessions,
    COUNT(
        CASE
            WHEN web_sess.utm_campaign IS NULL
            AND web_sess.utm_source IS NULL
            AND web_sess.http_referer IS NOT NULL THEN 1
            ELSE NULL
        END
    ) AS organ_search_sessions,
    COUNT(
        CASE
            WHEN web_sess.utm_source = 'gsearch'
            AND web_sess.http_referer IS NOT NULL THEN 1
            ELSE NULL
        END
    ) AS gsearch_paid_sessions,
    COUNT(
        CASE
            WHEN web_sess.utm_source = 'bsearch'
            AND web_sess.http_referer IS NOT NULL THEN 1
            ELSE NULL
        END
    ) AS bsearch_paid_sessions
FROM
    website_sessions AS web_sess
    LEFT JOIN orders ON web_sess.website_session_id = orders.website_session_id
WHERE
    web_sess.created_at < '2012-11-27'
GROUP BY
    year,
    month;

--QUESTION 5: 
-- Tell the sotry of website performance over the course of the first 8 months. 
-- Pull session to order conversion rates, by month
SELECT
    YEAR(web_sess.created_at) AS year,
    MONTH(web_sess.created_at) AS month_start_date,
    COUNT(web_sess.website_session_id) AS sessions,
    COUNT(orders.order_id) AS sessions_w_orders,
    COUNT(orders.order_id) / COUNT(web_sess.website_session_id) AS conv_rate
FROM
    website_sessions AS web_sess
    LEFT JOIN orders ON web_sess.website_session_id = orders.website_session_id
WHERE
    web_sess.created_at < '2012-11-27'
GROUP BY
    year,
    MONTH(web_sess.created_at);

--QUESTION 6: 
-- For gsearch lander test, estimate the revenue that the test earned us
-- basically compare the conv rate of home vs lander
-- find lift: (conv rate: test A vs conv rate: test  B ) 
-- lift = (CVR test A  - CVR test control )/(CVR test control)
-- lift is how much the conv rate changes between two test or groups
-- (HINT: Look at the increase in CVR from test(Jun 19- jul 28),
-- and use nonbrand sessions and revenue since then to calculate incremental value)
-- RESULT: 1% differnce in conversion rate witth 3% vs 4%
-- STEP 1: 
-- Find earliest instance of /lander-1 getting traffic
-- website_session_id >= 11683
SELECT
    website_session_id,
    website_pageview_id,
    pageview_url,
    created_at
FROM
    website_pageviews
WHERE
    pageview_url = '/lander-1'
LIMIT
    5;

-- STEP 2:  find the landing page_ids and count pageviews per session
DROP TEMPORARY TABLE IF EXISTS sessions_w_min_pv;

CREATE TEMPORARY TABLE sessions_w_min_pv
SELECT
    web_pv.website_session_id,
    MIN(web_pv.website_pageview_id) AS min_pv_id
FROM
    website_pageviews AS web_pv
    INNER JOIN website_sessions AS web_sess ON web_pv.website_session_id = web_sess.website_session_id
    AND web_sess.utm_campaign = 'nonbrand'
    AND web_sess.utm_source = 'gsearch'
    AND web_sess.website_session_id >= 11683
    AND web_sess.created_at < '2012-07-28'
GROUP BY
    web_pv.website_session_id;

-- STEP 3:
-- find landing page urls and price_usd as revune
DROP TEMPORARY TABLE IF EXISTS sessions_w_revenue;

CREATE TEMPORARY TABLE sessions_w_revenue
SELECT
    sess_min_pv.website_session_id,
    sess_min_pv.min_pv_id,
    web_pv.pageview_url AS landing_pages,
    orders.order_id
FROM
    sessions_w_min_pv AS sess_min_pv
    INNER JOIN website_pageviews AS web_pv ON sess_min_pv.min_pv_id = web_pv.website_pageview_id
    LEFT JOIN orders ON sess_min_pv.website_session_id = orders.website_session_id
WHERE
    web_pv.pageview_url IN ('/home', '/lander-1');

-- STEP 4: count to calculate CVR
-- /home conv_rate: 0.0318
-- /lander-1: conv_rate: 0.0406
-- Incremental orders: 0.0406 - 0.0318 = 0.0087 additional conv
-- lift = (cVR_test - CVR_control )/CVR_control = 28% increease in conversions from test pge
SELECT
    landing_pages,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(order_id) AS sessions_w_orders,
    COUNT(order_id) / COUNT(website_session_id) AS conv_rate
FROM
    sessions_w_revenue AS sess_rev
GROUP BY
    landing_pages;

-- STEP 5: find the most recent date or session where /home stopped getting traffic
-- session id 17145, so all other sessions after this does not have traffic for /home
SELECT
    MAX(web_pv.website_session_id) AS most_recent_session
FROM
    website_pageviews AS web_pv
    INNER JOIN website_sessions AS web_sess ON web_pv.website_session_id = web_sess.website_session_id
WHERE
    web_pv.pageview_url = '/home'
    AND web_sess.utm_campaign = 'nonbrand'
    AND web_sess.utm_source = 'gsearch'
    AND web_sess.created_at < '2012-11-27';

-- STEP 6:
--    22972 sessions
--    22972 sessions * 0.0088 = 202 incremental orders seince 7/29
-- meaning roughly 50 extra orders per session
SELECT
    COUNT(website_session_id) AS sessions_since_test
FROM
    website_sessions
WHERE
    website_session_id > 17145
    AND utm_campaign = 'nonbrand'
    AND utm_source = 'gsearch'
    AND created_at < '2012-11-27';

--QUESTION 7: 
-- For the landing page test you analyzed previously, 
-- show a full conversion funnel from each of the two pages to orders.
-- You can use the same time period you analyzed last time (Jun 19 - Jul28)
-- STEP 1: 
-- find all the steps '/home', '/products' ,'/the-original-mr-fuzzy' , 
-- '/cart', '/shipping', '/billing' , '/thank-you-for-your-order'
SELECT
    DISTINCT pageview_url
FROM
    website_pageviews;

-- STEP 2: 
-- find landing_pages
DROP TEMPORARY TABLE IF EXISTS sessions_w_min_pv;

CREATE TEMPORARY TABLE sessions_w_min_pv
SELECT
    web_pv.website_session_id,
    MIN(web_pv.website_pageview_id) AS min_pv_id
FROM
    website_pageviews AS web_pv
    INNER JOIN website_sessions AS web_sess ON web_pv.website_session_id = web_sess.website_session_id -- STEP 3: filter sessions with landing page in home or /lander join with table with pageurls
    AND web_sess.utm_campaign = 'nonbrand'
    AND web_sess.utm_source = 'gsearch'
    AND web_sess.website_session_id >= 11683
    AND web_sess.created_at < '2012-07-28'
GROUP BY
    web_pv.website_session_id;

-- STEP 3: 
-- find landing page url
CREATE TEMPORARY TABLE sessions_w_landing_page_url
SELECT
    sess_min_pv.website_session_id,
    web_pv.pageview_url AS landing_pages
FROM
    sessions_w_min_pv AS sess_min_pv
    INNER JOIN website_pageviews web_pv ON sess_min_pv.min_pv_id = web_pv.website_pageview_id
WHERE
    web_pv.pageview_url IN ('/home', '/lander-1');

-- STEP 4: 
-- build converions funnel group by landing page
-- with all funnel step pageurls for each landing page
WITH conv_funnel AS (
    SELECT
        landing_pages,
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
        sessions_w_landing_page_url AS sess_lp_url
        INNER JOIN website_pageviews AS web_pv ON sess_lp_url.website_session_id = web_pv.website_session_id
    GROUP BY
        landing_pages
)
SELECT
    landing_pages,
    to_products / sessions AS landing_CTR,
    to_mrfuzzy / to_products AS mrfruzzy_CTR,
    to_cart / to_mrfuzzy AS cart_CTR,
    to_shipping / to_cart AS shipping_CTR,
    to_billing / to_shipping AS billing_CTR,
    to_thankyou / to_billing AS billing_CTR
FROM
    conv_funnel;

--QUESTION 8: 
-- Quantify the impact of our last billing test. 
-- Analyze lift generated from the test (Sep 10- Nov 10), 
-- in terms of revenue per billing page sessiosn,
-- and then pull the number of billing page sessions for the past month 
-- to undestand monlty impact
-- basically repeat the excat same steps as lander test
-- STEP 1: find the sessions with billing and billing-2 urls
DROP TEMPORARY table billing_pages_ab_test;

CREATE TEMPORARY TABLE billing_pages_ab_test
SELECT
    web_pv.website_session_id,
    web_pv.pageview_url AS billing_pages,
    price_usd
FROM
    website_pageviews AS web_pv
    INNER JOIN website_sessions AS web_sess ON web_pv.website_session_id = web_sess.website_session_id
    LEFT JOIN orders ON web_sess.website_session_id = orders.website_session_id
WHERE
    web_pv.pageview_url IN ('/billing', '/billing-2')
    AND web_sess.created_at > '2012-09-10'
    AND web_sess.created_at < '2012-11-10';

-- STEP 2: find conversion rates for the two page in terms of revenue per billing page session
SELECT
    billing_pages,
    count(DISTINCT website_session_id) AS sessions,
    sum(price_usd) / count(website_session_id) AS revenue_per_session
FROM
    billing_pages_ab_test
GROUP BY
    billing_pages;

-- revenue_per_session:
-- /billing: 22.826484
-- /billing-2: 31.339297
-- 8.512813 increase from billing-2
-- so an increemntal increase of 8.512814 dollars per billing page view from billing 2
--STEP 3: find most recenmt date of billing to see when it stops being implemetnsd
SELECT
    COUNT(website_session_id) AS billing_page_sessions -- 1193 sessions
FROM
    website_pageviews
WHERE
    pageview_url IN ('/billing', '/billing-2')
    AND created_at BETWEEN '2012-10-27'
    AND '2012-11-27';

-- total value of billing page test is 1193 sessions * 8.51 =  10, 142
-- so total value of billing test is 10,1452 extra dollars generated