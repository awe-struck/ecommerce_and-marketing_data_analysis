# Analyzing Traffic Sources and Bid Optimization

## Tasks

### 1. Finding Top Traffic Sources

![image](https://github.com/user-attachments/assets/da6fe6c1-64a7-4c01-91a6-bb2973261577)

#### Steps:
- Group by different traffic sources. Then count sessions.

<br>

#### Query:
```
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
```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/bfe43875-41b8-42c9-ac95-6e393843284e)

- A majority of the sessions(3613) come from gsearch nonbrand campaign traffic. Report this insight to Cindy, and await further instructions. Otherwise, we could check the performance metrics of these sessions groups.
- Or segment and drill in deeper into this group to find additional insights.

<br>

#### Stakeholder Response:

![image](https://github.com/user-attachments/assets/b3c1472f-00fa-45a2-aa13-731ce1025c2d)

<br>
<br>

***

### 2. Top Traffic Source Conversion Rate

![image](https://github.com/user-attachments/assets/d7f332ce-26c7-44c4-b6c6-97f607986951)

#### Steps:
- Segment for gsearch nonbrand group
- Calculate the Conversion Rate (CVR)
- Compare the CVR to the 4% benchmark
- If its lower than 4%, reduce bid budget
- If its higher than 4%, increase bid bdudget

<br>

#### Query:
```
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
```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/d6f2d8e1-0876-4f1e-924c-852318548c5b)

- the CVR is 2.88%, which is **less than** the 4% threshold
- Thus, the recommendation is to reduce the bid budget of this group

<br>

#### Stakeholder Response:

![image](https://github.com/user-attachments/assets/41544988-c255-4dcc-aa94-063ce243791b)

<br>
<br>

***

### 3. Trend Analysis of Top Traffic Source

![image](https://github.com/user-attachments/assets/0d29482a-321d-4366-b5c7-263311e11657)

#### Steps:
- Monitor results of our bid optimization for the gsearch nonbrand group
- Group data based on week-by-week dates and monitor session results

<br>

#### Query:
```
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

```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/c78675da-dc34-4282-ad61-3359d5df9d99)


- Since bidding down on 2012-04-15, there was a downward trend in session volume
- Meaning that gsearch nonbrand is fairly sensitive to bid changes
- Will further segmment this group to explore data,
- and monitor results overtime to evaluate solutions to increase session traffic

<br>

#### Stakeholder Response:

![image](https://github.com/user-attachments/assets/81255452-5976-4aa4-9de9-675330faf37c)

<br>
<br>

***

### 4. Bid Optimizaation for Paid Traffic by device type

![image](https://github.com/user-attachments/assets/b510ac6f-57df-4acd-9521-9d7c0d81c27f)

#### Steps:
- Segment the gsearch nonbrand group into device type groups
- Analyze the following metrics: sessions, orders and session to order conversion rates

<br>

#### Query:
```
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

```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/40a5f529-6279-4435-ad28-6a11e3f2bf10)


- Desktop sessions have been performing better than mobile sessions with 3.73% vs 0.96% session-to-order Conversion Rate
- One possible recommendation is to do bid optimitiaztion, and to reallocate the budget to the higher performing device type
- So we can bid down on mobile sessions and bid up on desktop sessions. Then monitor the changes over time


<br>

#### Stakeholder Response:

![image](https://github.com/user-attachments/assets/0502dc3e-3ff7-4ebf-ab80-e580e7ef326f)

<br>
<br>

***

###  5. Bid Optimizaation for Paid Traffic 

![image](https://github.com/user-attachments/assets/cbb75a01-3e9c-4b5f-bca8-cf2b9eaf45af)

#### Steps:
- Perfrom trend analysis for desktop and mobile sessions, and monitor the session volume

<br>

#### Query:
```
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
```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/73bf5d42-161f-4e98-b2f8-a2e4658a369d)

- Since the 2012-05-19 change, the mobile sessions has been slightly down VS a strong increase in desktop sessions
- Will continue to monitor the results of this device type bid change over time

<br>

#### Stakeholder Response:

![image](https://github.com/user-attachments/assets/a1fd112b-be65-4c02-b861-55a640a6855a)

<br>
<br>

***

