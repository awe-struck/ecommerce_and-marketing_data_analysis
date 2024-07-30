# Analyzing Channels

## Tasks


### 1. Analzying Channel Portfolios

![image](https://github.com/user-attachments/assets/d26776b5-d6bb-43c5-82e8-236d0e466fdf)

<br>

#### Query:
```
SELECT
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(
        DISTINCT CASE
            WHEN utm_source = 'gsearch' THEN website_session_id
            ELSE NULL
        END
    ) gsearch_sessions,
    COUNT(
        DISTINCT CASE
            WHEN utm_source = 'bsearch' THEN website_session_id
            ELSE NULL
        END
    ) bsearch_sessions
FROM
    website_sessions
WHERE
    created_at > '2012-08-22'
    AND created_at < '2012-11-29'
    AND utm_campaign = 'nonbrand'
GROUP BY
    WEEK(created_at);
```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/baa8e16c-b73c-42ef-916d-0146e0cc0616)


- Bsearch is roughly a thrid of gsearch yet large enough volume where we should pay attention to it.
- So we should look into improving it, and explore via segmentaion.

<br>

#### Stakeholder Response:

![image](https://github.com/user-attachments/assets/04adf6c3-026f-459d-8c5a-3ea8120ac78f)


<br>
<br>

***

### 2. Comparing Channel Characteristics 

![image](https://github.com/user-attachments/assets/a3940853-6e5c-43aa-b12f-c9cee234a513)


<br>

#### Query:
```

SELECT
    utm_source,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(
        DISTINCT CASE
            WHEN device_type = 'mobile' THEN website_session_id
            ELSE NULL
        END
    ) AS mobile_sessions,
    COUNT(
        DISTINCT CASE
            WHEN device_type = 'mobile' THEN website_session_id
            ELSE NULL
        END
    ) / COUNT(DISTINCT website_session_id) AS mobile_sessions_pct
FROM
    website_sessions
WHERE
    utm_campaign = 'nonbrand'
    AND utm_source IN ('gsearch', 'bsearch')
    AND created_at > '2012-08-22'
    AND created_at < '2012-11-30'
GROUP BY
    utm_source;

```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/63b6bda6-5768-418d-a642-edbac5f44a6f)


- Mobile session trffic is very differnt between the two sources: gsearch and bsearch.
- So, we can explore and segment to find insights


<br>

#### Stakeholder Response:
![image](https://github.com/user-attachments/assets/170bb554-2ac0-4452-a44f-aebc19398bf3)




<br>
<br>

***


### 3. Cross-Channel Bid Optimizaation


![image](https://github.com/user-attachments/assets/c8991230-df73-48ff-b0fc-ef16f0a8b719)

<br>

#### Query:
```
SELECT
    device_type,
    utm_source,
    COUNT(DISTINCT web_sess.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT web_sess.website_session_id) AS sess_to_ord_CVR
FROM
    website_sessions web_sess
    LEFT JOIN orders ON web_sess.website_session_id = orders.website_session_id
WHERE
    utm_campaign = 'nonbrand'
    AND web_sess.created_at > '2012-08-22'
    AND web_sess.created_at < '2012-09-18'
GROUP BY
    device_type,
    utm_source;

```

<br>

#### Result:
![image](https://github.com/user-attachments/assets/7cf82a1f-dbc0-491c-8a33-f6d8d7d1a2e4)

- gserach has a better conversion rate in desktop and mobile vs bsearch.
- Thus, we should bid down bsearch since it underperforms in sessions AND perfromance metrics

<br>

#### Stakeholder Response:

![image](https://github.com/user-attachments/assets/2babacb7-a40d-4883-8848-2d6aa0246561)


<br>
<br>

***

### 4. Analyzing Channel Portfolio Trends 

![image](https://github.com/user-attachments/assets/295ae71c-8f60-45bb-8338-756ef972b632)


<br>

#### Query:
```
SELECT
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(
        DISTINCT CASE
            WHEN device_type = 'mobile'
            AND utm_source = 'gsearch' THEN website_session_id
            ELSE NULL
        END
    ) AS mobile_g_sessions,
    COUNT(
        DISTINCT CASE
            WHEN device_type = 'mobile'
            AND utm_source = 'bsearch' THEN website_session_id
            ELSE NULL
        END
    ) AS mobile_b_sessions,
    COUNT(
        DISTINCT CASE
            WHEN device_type = 'mobile'
            AND utm_source = 'bsearch' THEN website_session_id
            ELSE NULL
        END
    ) / COUNT(
        DISTINCT CASE
            WHEN device_type = 'mobile'
            AND utm_source = 'gsearch' THEN website_session_id
            ELSE NULL
        END
    ) AS mobile_b_pct_of_g,
    COUNT(
        DISTINCT CASE
            WHEN device_type = 'desktop'
            AND utm_source = 'gsearch' THEN website_session_id
            ELSE NULL
        END
    ) AS dtop_g_sessions,
    COUNT(
        DISTINCT CASE
            WHEN device_type = 'desktop'
            AND utm_source = 'bsearch' THEN website_session_id
            ELSE NULL
        END
    ) AS dtop_b_sessions,
    COUNT(
        DISTINCT CASE
            WHEN device_type = 'desktop'
            AND utm_source = 'bsearch' THEN website_session_id
            ELSE NULL
        END
    ) / COUNT(
        DISTINCT CASE
            WHEN device_type = 'desktop'
            AND utm_source = 'gsearch' THEN website_session_id
            ELSE NULL
        END
    ) AS dtop_b_pct_of_g
FROM
    website_sessions
WHERE
    utm_campaign = 'nonbrand'
    AND created_at > '2012-11-04'
    AND created_at < '2012-12-22'
GROUP BY
    WEEK(created_at);


```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/611ae6ed-a0a6-4c56-9a64-63665440041c)

  
- b-serach dropped a bit after the bid, but due to seasonality (holidays). Particularily, after Black Friday and Cyber Monday.
- BOTH sessions are down, but bsearch down significantly more down.


<br>

#### Stakeholder Response:

![image](https://github.com/user-attachments/assets/56b70935-828e-4555-ba99-ee7a737b2e33)


<br>
<br>

***


### 5. Analyzing Channel Portfolio Trends 

![image](https://github.com/user-attachments/assets/258b8b6e-64ec-4216-a92c-a1bc0f591b00)



<br>

#### Query:
```
-- STEP 1: find htpp_referal for Organic traffic
SELECT
    DISTINCT utm_campaign,
    utm_source,
    http_referer
FROM
    website_sessions
WHERE
    created_at < '2012-12-23';

-- STEP 2: 
WITH channels_sessions AS (
    SELECT
        website_session_id,
        created_at,
        CASE
            WHEN utm_source IS NULL
            AND http_referer IN (
                'https://www.gsearch.com',
                'https://www.bsearch.com'
            ) THEN 'organic_session'
            WHEN utm_source IS NULL
            AND http_referer IS NULL THEN 'direct_session'
            WHEN utm_source IS NOT NULL
            AND utm_campaign = 'brand' THEN 'paid_brand'
            WHEN utm_source IS NOT NULL
            AND utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
        END AS channels,
        utm_campaign,
        utm_source,
        http_referer
    FROM
        website_sessions
    WHERE
        created_at < '2012-12-23'
)
SELECT
    YEAR(created_at) AS year,
    MONTH(created_at) AS month,
    COUNT(
        DISTINCT CASE
            WHEN channels = 'paid_nonbrand' THEN website_session_id
            ELSE NULL
        END
    ) AS nonbrand_sessions,
    COUNT(
        DISTINCT CASE
            WHEN channels = 'paid_brand' THEN website_session_id
            ELSE NULL
        END
    ) AS brand_sessions,
    COUNT(
        DISTINCT CASE
            WHEN channels = 'paid_brand' THEN website_session_id
            ELSE NULL
        END
    ) / COUNT(
        DISTINCT CASE
            WHEN channels = 'paid_nonbrand' THEN website_session_id
            ELSE NULL
        END
    ) AS brand_pct_nonbrand,
    COUNT(
        DISTINCT CASE
            WHEN channels = 'organic_session' THEN website_session_id
            ELSE NULL
        END
    ) AS organic_sessions,
    COUNT(
        DISTINCT CASE
            WHEN channels = 'organic_session' THEN website_session_id
            ELSE NULL
        END
    ) / COUNT(
        DISTINCT CASE
            WHEN channels = 'paid_nonbrand' THEN website_session_id
            ELSE NULL
        END
    ) AS organic_pct_of_nonbrand,
    COUNT(
        DISTINCT CASE
            WHEN channels = 'direct_session' THEN website_session_id
            ELSE NULL
        END
    ) AS direct_sessions,
    COUNT(
        DISTINCT CASE
            WHEN channels = 'direct_session' THEN website_session_id
            ELSE NULL
        END
    ) / COUNT(
        DISTINCT CASE
            WHEN channels = 'paid_nonbrand' THEN website_session_id
            ELSE NULL
        END
    ) AS direct_pct_of_nonbrand
FROM
    channels_sessions
GROUP BY
    year,
    month

```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/519fdc05-3587-4e6a-8695-d78180c7ae8c)


  
- Brand, direct and organic traffic volume has been growing


<br>

#### Stakeholder Response:

![image](https://github.com/user-attachments/assets/ea1864b8-b421-4df5-ba79-3da68e7ec98e)




<br>
<br>

***

