-- Building Conversion Funnels to undestand where we lose our gsearch vistors
-- Between the /lander-1 page and placing an order, where do we lose gserach vistors
-- build full conversion funnel from /lander-1 to /thank-you
-- where dates between '2012-08-05' AND '2012-09-05'
-- PREP WORK: look at pageview_urls to check path
-- '/lander-1', '/products','/the-original-mr-fuzzy', '/cart', '/shipping', '/billing', 'thank'
-- SELECT
--     DISTINCT pageview_url
-- FROM
--     website_pageviews
-- STEP 1: Find and flag each step (url of interest) in the Funnel
-- STEP 2: Condense previous table results into a user path for each session
DROP TEMPORARY TABLE IF EXISTS sessions_w_user_paths;

CREATE TEMPORARY TABLE sessions_w_user_paths
SELECT
    website_session_id,
    MAX(products_page) AS viewed_products_page,
    MAX(mrfuzzy_page) AS viewed_mrfuzzy_page,
    MAX(cart_page) AS viewed_cart_page,
    MAX(shipping_page) AS viewed_shipping_page,
    MAX(billing_page) AS viewed_billing_page,
    MAX(thankyou_page) AS viewed_thankyou_page
FROM
    (
        SELECT
            web_pv.website_session_id,
            web_pv.pageview_url,
            CASE
                WHEN web_pv.pageview_url = '/products' THEN 1
                ELSE 0
            END AS products_page,
            CASE
                WHEN web_pv.pageview_url = '/the-original-mr-fuzzy' THEN 1
                ELSE 0
            END AS mrfuzzy_page,
            CASE
                WHEN web_pv.pageview_url = '/cart' THEN 1
                ELSE 0
            END AS cart_page,
            CASE
                WHEN web_pv.pageview_url = '/shipping' THEN 1
                ELSE 0
            END AS shipping_page,
            CASE
                WHEN web_pv.pageview_url = '/billing' THEN 1
                ELSE 0
            END AS billing_page,
            CASE
                WHEN web_pv.pageview_url = '/thank-you-for-your-order' THEN 1
                ELSE 0
            END AS thankyou_page
        FROM
            website_pageviews web_pv
            INNER JOIN website_sessions web_sess ON web_pv.website_session_id = web_sess.website_session_id
        WHERE
            web_sess.utm_campaign = 'nonbrand'
            AND web_sess.utm_source = 'gsearch'
            AND web_sess.created_at > '2012-08-05'
            AND web_sess.created_at < '2012-09-05'
        ORDER BY
            web_sess.website_session_id
    ) AS pages_visited
GROUP BY
    website_session_id;

-- STEP 3: Count total sessions per step
SELECT
    COUNT(website_session_id) AS sessions,
    COUNT(
        CASE
            WHEN viewed_products_page = 1 THEN 1
            ELSE NULL
        END
    ) AS to_products,
    COUNT(
        CASE
            WHEN viewed_mrfuzzy_page = 1 THEN 1
            ELSE NULL
        END
    ) AS to_mrfruzzy,
    COUNT(
        CASE
            WHEN viewed_cart_page = 1 THEN 1
            ELSE NULL
        END
    ) AS to_cart,
    COUNT(
        CASE
            WHEN viewed_shipping_page = 1 THEN 1
            ELSE NULL
        END
    ) AS to_shipping,
    COUNT(
        CASE
            WHEN viewed_billing_page = 1 THEN 1
            ELSE NULL
        END
    ) AS to_billing,
    COUNT(
        CASE
            WHEN viewed_thankyou_page = 1 THEN 1
            ELSE NULL
        END
    ) AS to_thankyou
FROM
    sessions_w_user_paths;

-- STEP 4: CTR per step
SELECT
    COUNT(website_session_id) AS sessions,
    COUNT(
        CASE
            WHEN viewed_products_page = 1 THEN 1
            ELSE NULL
        END
    ) / COUNT(website_session_id) AS lander_CTR,
    COUNT(
        CASE
            WHEN viewed_mrfuzzy_page = 1 THEN 1
            ELSE NULL
        END
    ) / COUNT(
        CASE
            WHEN viewed_products_page = 1 THEN 1
            ELSE NULL
        END
    ) AS products_CTR,
    COUNT(
        CASE
            WHEN viewed_cart_page = 1 THEN 1
            ELSE NULL
        END
    ) / COUNT(
        CASE
            WHEN viewed_mrfuzzy_page = 1 THEN 1
            ELSE NULL
        END
    ) AS mrfruzzy_CTR,
    COUNT(
        CASE
            WHEN viewed_shipping_page = 1 THEN 1
            ELSE NULL
        END
    ) / COUNT(
        CASE
            WHEN viewed_cart_page = 1 THEN 1
            ELSE NULL
        END
    ) AS cart_CTR,
    COUNT(
        CASE
            WHEN viewed_billing_page = 1 THEN 1
            ELSE NULL
        END
    ) / COUNT(
        CASE
            WHEN viewed_shipping_page = 1 THEN 1
            ELSE NULL
        END
    ) AS shipping_CTR,
    COUNT(
        CASE
            WHEN viewed_thankyou_page = 1 THEN 1
            ELSE NULL
        END
    ) / COUNT(
        CASE
            WHEN viewed_billing_page = 1 THEN 1
            ELSE NULL
        END
    ) AS billing_CTR
FROM
    sessions_w_user_paths;

-- VERSION 2
-- Calculate steps
-- version 1 is just an exercise of joining tables togesther, heres a better way
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

-- STEP 1: FUNNEL
SELECT
    *
FROM
    user_funnel;

-- Step 2: CTR
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