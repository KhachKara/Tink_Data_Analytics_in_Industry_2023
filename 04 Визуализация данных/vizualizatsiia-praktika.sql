SELECT date_trunc('week', visit_dttm) AS week,
	date_trunc('month', visit_dttm) AS month,
    COUNT(*) AS visitors
FROM msu_analytics.client
GROUP BY week, month
ORDER BY week, month
                        
SELECT COUNT(*), date_trunc('week', registration_dttm) AS week,
	date_trunc('month', registration_dttm) AS month
FROM msu_analytics.account
WHERE registration_dttm >= '2022-01-01' AND registration_dttm < '2023-01-01'
GROUP BY week, month
ORDER BY week, month            

SELECT date_trunc('week', application_dttm) AS week,
	date_trunc('month', application_dttm) AS month,
	COUNT(DISTINCT account_rk) AS count
FROM msu_analytics.application
GROUP BY week, month
ORDER BY week, month

SELECT COUNT(DISTINCT client_rk) AS "Number of customers who visited the game",
    EXTRACT(WEEK FROM visit_dttm) AS "Week",
    EXTRACT(MONTH FROM visit_dttm) AS "Month"
FROM msu_analytics.client
GROUP BY "Week", "Month"
ORDER BY "Week", "Month"