
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
- For a company that just started, we s

<br>
<br>

***




### 3.


#### Query:
```

```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/6821a8f0-7c84-483a-ba71-e2c285111586)

- <insights>
- <insights>

<br>
<br>

***

### 4.


#### Query:
```

```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/6821a8f0-7c84-483a-ba71-e2c285111586)

- <insights>
- <insights>

<br>
<br>

***




### 5.


#### Query:
```

```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/6821a8f0-7c84-483a-ba71-e2c285111586)

- <insights>
- <insights>

<br>
<br>

***






### 6.


#### Query:
```

```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/6821a8f0-7c84-483a-ba71-e2c285111586)

- <insights>
- <insights>

<br>
<br>

***




### 7.


#### Query:
```

```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/6821a8f0-7c84-483a-ba71-e2c285111586)

- <insights>
- <insights>

<br>
<br>

***



### 8.


#### Query:
```

```

<br>

#### Result:

![image](https://github.com/user-attachments/assets/6821a8f0-7c84-483a-ba71-e2c285111586)

- <insights>
- <insights>

<br>
<br>

***




