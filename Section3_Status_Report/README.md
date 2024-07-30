# Mid Course Project - Status Report

## The Situation

Maven Fuzzy Factory has been live for ~8 months, and your CEO is due to present company 
performance metrics to the board next week. You’ll be the one tasked with preparing relevant 
metrics to show the company’s promising growth.

## The Objective

**Use SQL to:** 
Extract and analyze website traffic and performance data from the Maven Fuzzy Factory database to quantify the company’s growth, and to tell the story of how you have been able to generate that growth. 

As an Analyst, the first part of your job is extracting and analyzing the data, and the next part of your job is effectively communicating the story to your stakeholders.


## Tasks

![image](https://github.com/user-attachments/assets/8d7d34ba-0039-4120-9146-a65ca0f000aa)

### 1. Gsearch seems to be the biggest driver of our business. Could you pull monthly trends for gsearch sessions and orders so that we can showcase the growth there?

#### Query:
```
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

```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/dceffc84-e6fb-470e-93a7-54ff2901cf8b)

- Our company while new, has been steadly growing our customer base over the course of 9 months.
- Looking at our website traffic and order volume, the data shows an increase of both metrics month over month.
- We went from 1852 sessions to 8506 sessions which indicates growing awarness of our brand and engagment with our content/products. At the same time, our orders Conversion Rates remained steady, and slightly increased from 3.24% to 4.19%.
- While our nonbrand campaign has been the biggest drive of traffic, our brand campaign also shows growth promise as well.

<br>
<br>

***

### 2. Next, it would be great to see a similar monthly trend for Gsearch, but this time splitting out nonbrand and brand campaigns separately. I am wondering if brand is picking up at all. If so, this is a good story to tell


#### Query:
```
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

```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/6821a8f0-7c84-483a-ba71-e2c285111586)

- Interstingly enough, our branded traffic shows similar growth rates as our nonbranded traffic.
- Over the same span of 9 months, our branded traffic reamained steady and grew from 3% to 4% CVR

<br>
<br>

***


### 3. While we’re on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device type? I want to flex our analytical muscles a little and show the board we really know our traffic sources.

#### Query:
```
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
    ) AS desktop_orders,
    COUNT(
        CASE
            WHEN orders.order_id IS NOT NULL
            AND web_sess.device_type = 'mobile' THEN 1
            ELSE NULL
        END
    ) / COUNT(
        CASE
            WHEN web_sess.device_type = 'mobile' THEN 1
            ELSE NULL
        END
    ) AS mobile_CVR,

    COUNT(
        CASE
            WHEN orders.order_id IS NOT NULL
            AND web_sess.device_type = 'desktop' THEN 1
            ELSE NULL
        END
    ) /     COUNT(
        CASE
            WHEN web_sess.device_type = 'desktop' THEN 1
            ELSE NULL
        END
    ) AS desktop_CVR

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
```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/91cc115c-b153-457d-a867-97329fc6b006)

- Most of the orders and session traffic can be attributed to desktop users. It sarted with a solid CVR of.43% in March, and dropped in April to 3.51%. However, it continued to increase in the following months to reach 5% CVR in November.
- For our mobile devices group, it has lower traffic and performance metrics when compared to our desktop users. We will investigae th details further. Possible explanations could include accessiblilty, design and/or techinical differences betwen the two device types.

<br>
<br>

***

### 4.  I’m worried that one of our more pessimistic board members may be concerned about the large % of traffic from Gsearch. Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels?

#### Query:
```
-- Traffic Sources
SELECT
    DISTINCT utm_campaign,
    utm_source,
    http_referer
FROM
    website_sessions
WHERE
    created_at < '2012-11-27';

```
![image](https://github.com/user-attachments/assets/7e5b81c7-b590-4b6e-b789-3b8b2d6db3a9)
 
- When campaign, source and http_reffee are ALL NULL then direct traffic
- when campaign, and souce are null then SEO and organic traffic

#### Query:
```

-- Requestd Data
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
```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/75194e7c-d160-466c-9d35-f1492cc8d22d)

- Even though, Gsearch is our dominant traffic channel and is growing the fastest; our other channels have been growing too
- Our data shows an increase in all sources of session traffic, particullary seo and direct growth has been positive for our brand
- The growth of these two non-paid channels is essential as it shows our companies growth without the need to put money in it. 

<br>
<br>

***




### 5. I’d like to tell the story of our website performance improvements over the course of the first 8 months. Could you pull session to order conversion rates, by month?


#### Query:
```
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


```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/22bbc1ec-7c7b-41fb-a95d-fbe2562d4684)

-  In March, the Conversion Rate was 3.19% and decreased in the next month. But, that's where the downward dip ended. In the following months, the conversion rate started to increase steadily until it reached its current rate at 4.40% (in November)

<br>
<br>

***


### 6.  For the gsearch lander test, please estimate the revenue that test earned us (Hint: Look at the increase in CVR from the test (Jun 19 – Jul 28), and use nonbrand sessions and revenue since then to calculate incremental value)


#### Query:
```
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

```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/d2b21c78-2644-4a10-ba1d-301e47d683ef)
![image](https://github.com/user-attachments/assets/c7c385f3-e61e-446c-be58-16efa7252856)


- Calculated the Absolute Lift of the landing page A/B test:
- Absolute Lift = test_page - control_page = 0.0406 - 0.0318 = 0.0087 additional conversions

- 22972 sessions have occured since the test
- To calculate incremental orders:  22972 sessions * 0.0088 = 202 incremental orders seince 2012-07-29
- Which means roughly 50 extra orders/session for each month, since this testing implementation

<br>
<br>

***




### 7.  I’d like to tell the story of our website performance improvements over the course of the first 8 months. Could you pull session to order conversion rates, by month?


#### Query:
```
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

```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/169b43a1-f48e-45c6-b379-a478d5ec5d17)

- We improved our website performance by A/B a new version of a landing page. Through Conversion Funnel Analysis, Lander-1 page has shown a better click trough rate than the home page.

<br>
<br>

***



### 8. I’d love for you to quantify the impact of our billing test, as well. Please analyze the lift generated from the test (Sep 10 – Nov 10), in terms of revenue per billing page session, and then pull the number of billing page sessions for the past month to understand monthly impact.


#### Query:
```
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

--STEP 3: find most recenmt date of billing to see when it stops being implemetnsd
SELECT
    COUNT(website_session_id) AS billing_page_sessions -- 1193 sessions
FROM
    website_pageviews
WHERE
    pageview_url IN ('/billing', '/billing-2')
    AND created_at BETWEEN '2012-10-27'
    AND '2012-11-27';



```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/e6f04f6e-d60c-4105-bf3c-7bad2bbd3ee0)
![image](https://github.com/user-attachments/assets/765f38bc-1b8d-4c37-b857-c7daa3af29cb)


- We calcualte revenue per session, by doing the following:
-- /billing CVR: 22.826484
-- /billing-2 CVR: 31.339297
-- Lift = (/billing-2 CVR) - (/billing CVR) = 8.512813 revenue per session
  
-- So an increemntal increase of 8.512814 dollars/billing pageview from billing 2
-- The total value of billing page sessions 1193. This all results in 10, 142 dollar increase in value, calculated from
1193* 8.51 =  10,1452

<br>
<br>

***




