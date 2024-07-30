# Analyzing Business Patterns and Seasonality

## Tasks


### 1. Analyzing Seasonality

![image](https://github.com/user-attachments/assets/b3a7b62d-42b4-4f96-aaba-12799c59f7f7)

<br>

#### Query:
```
-- STEP 1: group by months
SELECT
    YEAR(web_sess.created_at) year,
    MONTH(web_sess.created_at) month,
    COUNT(DISTINCT web_sess.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM
    website_sessions web_sess
    LEFT JOIN orders ON web_sess.website_session_id = orders.website_session_id
WHERE
    YEAR(web_sess.created_at) < '2013'
GROUP BY
    year,
    month;

-- STEP 2: group by weeks
SELECT
    MIN(DATE(web_sess.created_at)) week_start_date,
    COUNT(DISTINCT web_sess.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM
    website_sessions web_sess
    LEFT JOIN orders ON web_sess.website_session_id = orders.website_session_id
WHERE
    YEAR(web_sess.created_at) < '2013'
GROUP BY
    WEEK(web_sess.created_at);

```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/b92e5b9e-269e-4138-86b3-d7f26abe0839)
![image](https://github.com/user-attachments/assets/2bbf3336-e450-4eca-b9f1-ea68cc8401bc)

- Steady growth over time, but big hike for Cyber Monday and Black Friday
- To prepare, stock up more procducts around that date range for next eyar


<br>

#### Stakeholder Response:

![image](https://github.com/user-attachments/assets/c7419d6b-a22b-49bd-90c8-d46fae5e340f)



<br>
<br>

***

### 2. Analyzing Business Patterns

![image](https://github.com/user-attachments/assets/0f1aafb5-8c4f-4577-b009-0b0f2a17af34)

<br>

#### Query:
```
WITH daily_hourly_sessions AS (
    SELECT
        DATE(created_at) created_date,
        WEEKDAY(created_at) AS wkday,
        HOUR(created_at) hr,
        COUNT(DISTINCT website_session_id) sessions
    FROM
        website_sessions web_sess
    WHERE
        web_sess.created_at BETWEEN '2012-09-15'
        AND '2012-11-15'
    GROUP BY
        1,
        2,
        3
    ORDER BY
        hr
)
SELECT
    hr,
    AVG(
        CASE
            WHEN wkday = 0 THEN sessions
            ELSE null
        END
    ) AS 'Monday',
    AVG(
        CASE
            WHEN wkday = 1 THEN sessions
            ELSE null
        END
    ) AS 'Tuesday',
    AVG(
        CASE
            WHEN wkday = 2 THEN sessions
            ELSE null
        END
    ) AS 'Wednesday',
    AVG(
        CASE
            WHEN wkday = 3 THEN sessions
            ELSE null
        END
    ) AS 'Thursday',
    AVG(
        CASE
            WHEN wkday = 4 THEN sessions
            ELSE null
        END
    ) AS 'Friday',
    AVG(
        CASE
            WHEN wkday = 5 THEN sessions
            ELSE null
        END
    ) AS 'Saturday',
    AVG(
        CASE
            WHEN wkday = 6 THEN sessions
            ELSE null
        END
    ) AS 'Sunday'
FROM
    daily_hourly_sessions
GROUP BY
    1;




```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/1d2231de-bed2-4ded-a6fb-16bbde593101)


- Weekday traffic is busier during working hours of 9-5, so we should increase staff for support team during those hours

<br>

#### Stakeholder Response:

![image](https://github.com/user-attachments/assets/261301b4-5d86-470f-a1c5-278b48cb3a57)



<br>
<br>

***

