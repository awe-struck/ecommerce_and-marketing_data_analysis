# User Analysis

## Tasks


### 1. Identify Repeat Visit & Purchase Behaviour

![image](https://github.com/user-attachments/assets/d60671e0-238b-40a7-af0d-73f9f3b8764e)

<br>

#### Query:
```
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



```

<br>

#### Result:


![image](https://github.com/user-attachments/assets/031c2dd2-3d5c-4418-a3e8-d53efa83da80)

- We get a fair bit of repeat visitors, will dig in deeper for insights

<br>

#### Stakeholder Response:

![image](https://github.com/user-attachments/assets/7f7d0934-ae70-422a-8d62-028455ec502a)

<br>
<br>

***

### 2. Analyzing Time to Repeat

![image](https://github.com/user-attachments/assets/b8611952-c829-4f9d-9782-ace7cc1639d9)


<br>

#### Query:
```

```

<br>

#### Result:

<query results Image>

- For same time period, find minimum, maximum and avergae time
-- between first and second sessions for customer who come back


<br>

#### Stakeholder Response:

![image](https://github.com/user-attachments/assets/981647b6-cf43-44dd-9582-55a18ee09187)


<br>
<br>

***

### 3. Analyzing Repeat Channel Behaviour 

<Question image>

#### Steps:
-<>

<br>

#### Query:
```
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

```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/beaa4273-886d-4d3e-ae8b-c1caa794abd4)


- <insights>
- <insights>


<br>

#### Stakeholder Response:

<response Iimage>


<br>
<br>

***


### 4.

<Question image>

#### Steps:
-<>

<br>

#### Query:
```
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
```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/bd9850a6-9c1b-4f84-8bf8-4d0852a5599e)


- <insights>
- <insights>


<br>

#### Stakeholder Response:

<response Iimage>


<br>
<br>

***
