# Analyzing Website Performance

## Tasks

### 1. Analyzing Top Web Page Content

![image](https://github.com/user-attachments/assets/7a2ed0bf-3cff-4092-a63f-51acd64e0911)

#### Steps:
- Group by webpage url
- Find session volume

<br>

#### Query:
```
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

```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/db07c962-bec0-4f8c-b316-5978af3b8502)

- the home page has the most session volume
- With this knowledge, we could either:
- Segement and explore the top webpages further
- Check if the top webpags are also top landing pages


<br>

#### Stakeholder Response:

![image](https://github.com/user-attachments/assets/7e942e27-b7c2-4855-96a9-2663a767c8db)

<br>
<br>

***

### 2. Finding Top Landing Pages 

![image](https://github.com/user-attachments/assets/c8fe52db-e1b0-47ae-bbd5-c22bea8bb5ab)

#### Steps:
- Group by sessions, then find the minimum or smallest pageview id which represents the first webpage per session

<br>

#### Query:
```
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

```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/e8621938-5b05-4d2d-851a-d71726cd8e99)

- Top webpage is also the top landing page which isthe /home page

<br>

#### Stakeholder Response:

![image](https://github.com/user-attachments/assets/c33c67ec-0dd8-48e7-a3aa-14c963c377ff)

<br>
<br>

***

### 3. Calculate Bounce Rate for Top Landing Pages|

![image](https://github.com/user-attachments/assets/27c9879d-e340-4178-830e-714fbecec31c)


#### Steps:
- find landing page id
- find sessions with landing pages URL (filtered for home page)
- get the number of pageviews per session then filter for only 1 pageview
- get the sessions, bournces and bounce rates

<br>

#### Query:
```
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
```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/0e9dfba1-eccc-4f15-8288-2bc61ec433d6)

- High bounce rate of 59%, so /home page needs to be investigated
- Segment and research /home page further
- Can also create new /home and A/B test it

<br>

#### Stakeholder Response:

![image](https://github.com/user-attachments/assets/8aa7fa99-7402-4a7d-8d54-6b939a1e8749)


<br>
<br>

***

### 4. Analyzing Landing Page A/B Tests 

![image](https://github.com/user-attachments/assets/114a0cd2-a33c-4323-9e00-1c2f3000d68d)


#### Steps:
- find the earliest occurnce of /lander-1 page
- find landing page id for each session fitler with session_id > 11683
- find session ids for each landing page of home or lander-1
- count the pageviews for each lanindg page
- calculate CVR
<br>

#### Query:
```

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



```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/94f7a091-bca0-453d-aed6-258538e65665)

- the /lander-1 page has 6% lower bounce rate to /home page at 53% vs 58% respecitvely
- so use the /lander-1 page moving forward


<br>

#### Stakeholder Response:

![image](https://github.com/user-attachments/assets/fc1c713c-ab66-47c0-ab95-b2b0a9fc2f26)


<br>
<br>

***


###  5. Trend Analysis Landing Page 

![image](https://github.com/user-attachments/assets/3c032ce9-14d9-4128-9708-97e87db3fecb)

#### Steps:
- Find landing pages, with count(page view)
- Find Landing page url
- Trend analysis

<br>

#### Query:
```
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

```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/f953b613-a5f5-48ab-a782-d2afe651e652)

- Once /home page was phased out, /lander-1 was the only page left with a substantial decline in overall bounce rate

<br>

#### Stakeholder Response:

![image](https://github.com/user-attachments/assets/6bbaf539-1a29-453b-9eca-51ee612ecf23)

<br>
<br>

***

### 6. Bulding Conversion Funnels

![image](https://github.com/user-attachments/assets/0c6a124c-2237-4707-9c48-8db75350319f)


#### Steps:

<br>

#### Query:
```
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


```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/ef2f84be-ffa2-4d80-80fe-62bc8495735a)
![image](https://github.com/user-attachments/assets/8611f2f1-7aef-4f95-9e65-9d2c78d65e3d)

- Looking at the landing page, mrfuzzy product apge and the billing page as they have the **lowest** CTRs
- redesign and pages, then A/B test them
- Or segment and explore, each of these pages to dig for insights

<br>

#### Stakeholder Response:

![image](https://github.com/user-attachments/assets/6683791f-c559-46ec-9f8e-7c9781102a0b)

<br>
<br>

***

### 7. Analyzing Conversion Funnel Tests

![image](https://github.com/user-attachments/assets/ddc0362f-400a-4d25-a6f7-f7fc45fcb4d2)


#### Steps:
- find last instance of /billing-2 page
- count sessions in each step of funnel
- get conversion rate of dates

<br>

#### Query:
```

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

```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/314704ba-9681-4663-a509-65ca0be3c26a)

- the /billing-2 page has performed much better than /billing page So we will use this page moving forward


<br>

#### Stakeholder Response:

![image](https://github.com/user-attachments/assets/94d2e260-131b-468f-9e3a-7178a71a8d06)



<br>
<br>

***



