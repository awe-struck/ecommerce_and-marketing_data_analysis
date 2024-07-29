-- | 1. Product-Level Sales Analysis |
-- RESULT
-- monitor product sales over time
SELECT
    YEAR(web_sess.created_at) AS year,
    MONTH(web_sess.created_at) AS month,
    COUNT(DISTINCT orders.order_id) AS total_sales,
    SUM(orders.price_usd) AS total_revenue,
    SUM(orders.price_usd - orders.cogs_usd) AS total_margin
FROM
    website_sessions web_sess
    LEFT JOIN orders ON web_sess.website_session_id = orders.website_session_id
WHERE
    web_sess.created_at < '2013-01-04'
GROUP BY
    1,
    2;

-- | 2. Analyzing Product Launches |
-- resutls
-- EVERYTHING HAS steadly been improving
-- but still unsure if the new product lauch improved cmpany growth or if
-- the growth is just continuation of previous efforts. Monitro for now
SELECT
    YEAR(web_sess.created_at) AS year,
    MONTH(web_sess.created_at) AS month,
    COUNT(DISTINCT orders.order_id) orders,
    COUNT(DISTINCT web_sess.website_session_id) sessions,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT web_sess.website_session_id) AS CVR,
    SUM(price_usd) / COUNT(DISTINCT web_sess.website_session_id) AS revenue_per_session,
    COUNT(
        CASE
            WHEN orders.primary_product_id = 1 THEN 1
            ELSE NULL
        END
    ) product_1,
    COUNT(
        CASE
            WHEN orders.primary_product_id = 2 THEN 1
            ELSE NULL
        END
    ) AS product_2
FROM
    website_sessions web_sess
    LEFT JOIN orders ON web_sess.website_session_id = orders.website_session_id
WHERE
    web_sess.created_at > '2012-04-01'
    AND web_sess.created_at < '2013-04-05'
GROUP BY
    1,
    2;

--| 3. Analyzing Product-level WEbsite Pathing|
-- results: 
-- perecntr of sessions from /products to /mrfuzzy went down afoter /lovebear lauch, but overall CVR is up tho
-- look at conversion rates indicitdually
-- STEP 1:  for each session_id, find first viewed page and the next viewed page
DROP TEMPORARY TABLE IF EXISTS session_user_path;

CREATE TEMPORARY TABLE session_user_path
SELECT
    website_session_id,
    created_at,
    pageview_url AS first_page,
    LEAD(pageview_url) OVER(PARTITION BY website_session_id) AS next_page
FROM
    website_pageviews
WHERE
    website_pageviewS.created_at > '2012-10-06'
    AND website_pageviewS.created_at < '2013-04-06'
ORDER BY
    created_at;

-- STEP 2: find page sessions
SELECT
    CASE
        WHEN created_at BETWEEN '2012-10-06'
        AND '2013-01-06' THEN 'pre_product_launch'
        WHEN created_at BETWEEN '2013-01-06'
        AND '2013-04-06' THEN 'post-product_launch'
        ELSE NULL
    END time_period,
    COUNT(
        DISTINCT CASE
            WHEN first_page = '/products' THEN website_session_id
            ELSE NULL
        END
    ) AS product_sessions,
    COUNT(
        DISTINCT CASE
            WHEN first_page = '/products'
            AND next_page IS NOT NULL THEN website_session_id
            ELSE NULL
        END
    ) AS sessions_w_next_page,
    COUNT(
        DISTINCT CASE
            WHEN first_page = '/products'
            AND next_page IS NOT NULL THEN website_session_id
            ELSE NULL
        END
    ) / COUNT(
        DISTINCT CASE
            WHEN first_page = '/products' THEN website_session_id
            ELSE NULL
        END
    ) AS pct_to_next_page,
    COUNT(
        DISTINCT CASE
            WHEN first_page = '/products'
            AND next_page = '/the-original-mr-fuzzy' THEN website_session_id
            ELSE NULL
        END
    ) AS to_mrfuzzy_page,
    COUNT(
        DISTINCT CASE
            WHEN first_page = '/products'
            AND next_page = '/the-original-mr-fuzzy' THEN website_session_id
            ELSE NULL
        END
    ) / COUNT(
        DISTINCT CASE
            WHEN first_page = '/products' THEN website_session_id
            ELSE NULL
        END
    ) AS pct_to_mrfuzzy_page,
    COUNT(
        DISTINCT CASE
            WHEN first_page = '/products'
            AND next_page = '/the-forever-love-bear' THEN website_session_id
            ELSE NULL
        END
    ) AS to_lovebear_page,
    COUNT(
        DISTINCT CASE
            WHEN first_page = '/products'
            AND next_page = '/the-forever-love-bear' THEN website_session_id
            ELSE NULL
        END
    ) / COUNT(
        DISTINCT CASE
            WHEN first_page = '/products' THEN website_session_id
            ELSE NULL
        END
    ) AS pct_to_lovebear_page
FROM
    session_user_path
GROUP BY
    1;

-- | 4. Builidng Product-Level Conversion Funnels |
-- RESULT
-- overall, CTR has increased from seond product
-- STEP 1: find webpages that are included in this time period
SELECT
    DISTINCT pageview_url
FROM
    website_pageviews
WHERE
    created_at BETWEEN '2013-01-06'
    AND '2013-04-10 ';

-- STEP 2: for sessions, find and flag relevant webpages
DROP TEMPORARY TABLE IF EXISTS sessions_w_pages_flag;

CREATE TEMPORARY TABLE sessions_w_pages_flag
SELECT
    website_session_id,
    pageview_url,
    CASE
        WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1
        ELSE 0
    END AS flag_mrfuzzy_pages,
    CASE
        WHEN pageview_url = '/the-forever-love-bear' THEN 1
        ELSE 0
    END AS flag_lovebear_pages
FROM
    website_pageviews
WHERE
    created_at BETWEEN '2013-01-06'
    AND '2013-04-10 '
ORDER BY
    website_session_id;

-- STEP 3: filter website sessions with flags
DROP TEMPORARY TABLE IF EXISTS sessions_w_product_pages;

CREATE TEMPORARY TABLE sessions_w_product_pages
SELECT
    sessions_w_pages_flag.website_session_id,
    CASE
        WHEN sessions_w_pages_flag.pageview_url = '/the-original-mr-fuzzy'
        AND flag_mrfuzzy_pages = 1 THEN 'mrfuzzy_page'
        WHEN sessions_w_pages_flag.pageview_url = '/the-forever-love-bear'
        AND sessions_w_pages_flag.flag_lovebear_pages = 1 THEN 'lovebear_page'
    END AS product_pages,
    sessions_w_pages_flag.pageview_url
FROM
    sessions_w_pages_flag
    INNER JOIN website_pageviews ON sessions_w_pages_flag.website_session_id = website_pageviews.website_session_id
WHERE
    flag_lovebear_pages = 1
    OR flag_mrfuzzy_pages = 1;

-- STEP 4: create conversion funnel
DROP TEMPORARY TABLE IF EXISTS conversion_funnel;

CREATE TEMPORARY TABLE conversion_funnel
SELECT
    product_pages,
    COUNT(
        DISTINCT CASE
            WHEN sessions_w_pages_flag.pageview_url IN (
                '/the-original-mr-fuzzy',
                '/the-forever-love-bear'
            ) THEN sessions_w_pages_flag.website_session_id
            ELSE NULL
        END
    ) AS product_sessions,
    COUNT(
        DISTINCT CASE
            WHEN sessions_w_pages_flag.pageview_url = '/cart' THEN sessions_w_pages_flag.website_session_id
            ELSE NULL
        END
    ) AS to_cart_page,
    COUNT(
        DISTINCT CASE
            WHEN sessions_w_pages_flag.pageview_url = '/shipping' THEN sessions_w_pages_flag.website_session_id
            ELSE NULL
        END
    ) AS to_shipping_page,
    COUNT(
        DISTINCT CASE
            WHEN sessions_w_pages_flag.pageview_url = '/billing-2' THEN sessions_w_pages_flag.website_session_id
            ELSE NULL
        END
    ) AS to_billing_page,
    COUNT(
        DISTINCT CASE
            WHEN sessions_w_pages_flag.pageview_url = '/thank-you-for-your-order' THEN sessions_w_pages_flag.website_session_id
            ELSE NULL
        END
    ) AS to_thankyou_page
FROM
    sessions_w_product_pages
    INNER JOIN sessions_w_pages_flag ON sessions_w_product_pages.website_session_id = sessions_w_pages_flag.website_session_id
GROUP BY
    1;

-- STEP 5a: display funnel session values
SELECT
    *
FROM
    conversion_funnel;

-- STEP 5b: display funnel session CTRs
SELECT
    product_pages,
    to_cart_page / product_sessions AS product_page_ctr,
    to_shipping_page / to_cart_page AS cart_page_ctr,
    to_billing_page / to_shipping_page AS shipping_page_ctr,
    to_thankyou_page / to_billing_page AS billing_page_ctr
FROM
    conversion_funnel;

--| 5. Cross-Sale Analysis |
-- CTR did not go dwon, everything else slight ly went up. Monitro it
-- STEP 1: find relevant page /cart and next page
DROP TEMPORARY TABLE IF EXISTS flag_cart_pages;

CREATE TEMPORARY TABLE flag_cart_pages
SELECT
    website_session_id,
    created_at,
    pageview_url AS curr_page,
    LEAD(pageview_url) OVER(PARTITION BY website_session_id) AS next_page
FROM
    website_pageviews
WHERE
    created_at BETWEEN '2013-08-25'
    AND '2013-10-25'
ORDER BY
    created_at;

-- STEP 2: filter for only /cart pages 
DROP TEMPORARY TABLE only_sessions_w_cart;

CREATE TEMPORARY TABLE only_sessions_w_cart
SELECT
    *
FROM
    flag_cart_pages
WHERE
    curr_page = '/cart';

-- STEP 3: Get time periods
SELECT
    CASE
        WHEN only_sessions_w_cart.created_at BETWEEN '2013-08-25'
        AND '2013-09-25' THEN 'pre_cross_sell'
        WHEN only_sessions_w_cart.created_at BETWEEN '2013-09-25'
        AND '2013-10-25' THEN 'post_cross_sell'
    END AS time_period,
    COUNT(
        DISTINCT only_sessions_w_cart.website_session_id
    ) AS cart_sessions,
    COUNT(
        DISTINCT CASE
            WHEN next_page IS NOT NULL THEN only_sessions_w_cart.website_session_id
            ELSE NULL
        END
    ) AS clickthroughs,
    COUNT(
        DISTINCT CASE
            WHEN next_page IS NOT NULL THEN only_sessions_w_cart.website_session_id
            ELSE NULL
        END
    ) / COUNT(
        DISTINCT only_sessions_w_cart.website_session_id
    ) AS cart_CTR,
    SUM(orders.items_purchased) / COUNT(DISTINCT orders.order_id) AS products_per_order,
    AVG(price_usd) AOV,
    SUM(orders.price_usd) / COUNT(
        DISTINCT only_sessions_w_cart.website_session_id
    ) revenue_per_cart_session
FROM
    only_sessions_w_cart
    LEFT JOIN orders ON only_sessions_w_cart.website_session_id = orders.website_session_id
GROUP BY
    1;

-- | 6. Product Portfolio Expansion |
-- all metrics have improved, so maybe pump more money in or add another product
SELECT
    CASE
        WHEN website_sessions.created_at BETWEEN '2013-11-12'
        AND '2013-12-11' THEN 'pre_product_launch'
        WHEN website_sessions.created_at BETWEEN '2013-12-12'
        AND '2014-01-12' THEN 'post_product_launch'
    END AS time_period,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_CVR,
    AVG(price_usd) AOV,
    SUM(orders.items_purchased) / COUNT(DISTINCT orders.order_id) AS products_per_order,
    SUM(orders.price_usd) / COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session
FROM
    website_sessions
    LEFT JOIN orders ON website_sessions.website_session_id = orders.website_session_id
WHERE
    website_sessions.created_at BETWEEN '2013-11-12'
    AND '2014-01-12'
GROUP BY
    1;

-- | 7. Product Product Refund Rates| 
--MR FUZZY  went down after inital improvemetns in septemnet 2013, but as expected refund rates were bad in august and septemneter . New supplier is doing well so far
SELECT
    YEAR(order_items.created_at) year,
    MONTH(order_items.created_at) month,
    COUNT(
        DISTINCT CASE
            WHEN product_id = 1 THEN order_items.order_item_id
            ELSE NULL
        END
    ) AS p1_orders,
    COUNT(
        DISTINCT CASE
            WHEN product_id = '1' THEN order_item_refunds.order_item_refund_id
            ELSE NULL
        END
    ) / COUNT(
        DISTINCT CASE
            WHEN product_id = '1' THEN order_items.order_item_id
            ELSE NULL
        END
    ) AS p1_refund_rt,
    COUNT(
        DISTINCT CASE
            WHEN product_id = 2 THEN order_items.order_item_id
            ELSE NULL
        END
    ) AS p2_orders,
    COUNT(
        DISTINCT CASE
            WHEN product_id = '2' THEN order_item_refunds.order_item_refund_id
            ELSE NULL
        END
    ) / COUNT(
        DISTINCT CASE
            WHEN product_id = '2' THEN order_items.order_item_id
            ELSE NULL
        END
    ) AS p2_refund_rt,
    COUNT(
        DISTINCT CASE
            WHEN product_id = 3 THEN order_items.order_item_id
            ELSE NULL
        END
    ) AS p3_orders,
    COUNT(
        DISTINCT CASE
            WHEN product_id = '3' THEN order_item_refunds.order_item_refund_id
            ELSE NULL
        END
    ) / COUNT(
        DISTINCT CASE
            WHEN product_id = '3' THEN order_items.order_item_id
            ELSE NULL
        END
    ) AS p3_refund_rt,
    COUNT(
        DISTINCT CASE
            WHEN product_id = 4 THEN order_items.order_item_id
            ELSE NULL
        END
    ) AS p4_orders,
    COUNT(
        DISTINCT CASE
            WHEN product_id = '4' THEN order_item_refunds.order_item_refund_id
            ELSE NULL
        END
    ) / COUNT(
        DISTINCT CASE
            WHEN product_id = '4' THEN order_items.order_item_id
            ELSE NULL
        END
    ) AS p4_refund_rt
FROM
    order_items
    LEFT JOIN order_item_refunds ON order_items.order_item_id = order_item_refunds.order_item_id
GROUP BY
    YEAR(order_items.created_at),
    MONTH(order_items.created_at);