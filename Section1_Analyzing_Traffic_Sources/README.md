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


### <Next Question Number>

<Question image>

#### Steps:
-<>

<br>

#### Query:
```

```

<br>

#### Result:

<query results Image>

- <insights>
- <insights>


<br>

#### Stakeholder Response:

<response Iimage>


<br>
<br>

***
