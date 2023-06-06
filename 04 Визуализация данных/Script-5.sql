--Запрос на выборку количества посещений сайта по дням/неделям/месяцам:
SELECT DATE_TRUNC('day', client.visit_dttm) AS date,
		COUNT(DISTINCT client.client_rk) AS visits_count
FROM msu_analytics.client
GROUP BY date
ORDER BY date

--Запрос на выборку количества зарегистрированных пользователей по дням/неделям/месяцам:
SELECT DATE_TRUNC('day', account.registration_dttm) AS date,
       COUNT(DISTINCT account.client_rk) AS registrations_count
FROM msu_analytics.account
GROUP BY date
ORDER BY date

--Запрос на выборку количества заявок на игру по дням/неделям/месяцам:
SELECT DATE_TRUNC('day', application.application_dttm) AS date,
       COUNT(DISTINCT application.account_rk) AS game_applications_count
FROM msu_analytics.application
GROUP BY date
ORDER BY date

--Запрос на выборку количества пользователей, которые начали играть, по дням/неделям/месяцам:
SELECT DATE_TRUNC('day', game.game_dttm) AS date,
       COUNT(DISTINCT client.client_rk) AS game_plays_count
FROM msu_analytics.game
join msu_analytics.application
on application.game_rk = game.game_rk
join msu_analytics.account
on account.account_rk = application.account_rk
join msu_analytics.client
on client.client_rk = account.account_rk 
GROUP BY date
ORDER BY date

-- Количество клиентов, закончившие игру за неделю / месяц
SELECT COUNT(DISTINCT client.client_rk) AS "Customers",
    date_trunc('day', visit_dttm) AS date
    
FROM msu_analytics.client
JOIN msu_analytics.account
ON account.client_rk = client.client_rk
JOIN msu_analytics.application
ON application.account_rk = account.account_rk
JOIN msu_analytics.game
ON game.game_rk = application.game_rk
WHERE game.game_flg = 1
GROUP BY date
ORDER BY date

-- Можно объединить результаты в одну таблицу, чтобы построить визуализацию воронки. 
-- //////////////
SELECT t.day, t.visits_count, t.registrations_count, t.game_applications_count, t.game_plays_count
FROM
(SELECT DATE_TRUNC('day', client.visit_dttm) AS day,
COUNT(DISTINCT client.client_rk) AS visits_count,
0 AS registrations_count,
0 AS game_applications_count,
0 AS game_plays_count
FROM msu_analytics.client
GROUP BY day
UNION
SELECT DATE_TRUNC('day', account.registration_dttm) AS day,
0 AS visits_count,
COUNT(DISTINCT account.client_rk) AS registrations_count,
0 AS game_applications_count,
0 AS game_plays_count
FROM msu_analytics.account
GROUP BY day
UNION
SELECT DATE_TRUNC('day', application.application_dttm) AS day,
0 AS visits_count,
0 AS registrations_count,
COUNT(DISTINCT application.account_rk) AS game_applications_count,
0 AS game_plays_count
FROM msu_analytics.application
GROUP BY day
UNION
SELECT DATE_TRUNC('day', game.game_dttm) AS day,
0 AS visits_count,
0 AS registrations_count,
0 AS game_applications_count,
COUNT(DISTINCT client.client_rk) AS game_plays_count
FROM msu_analytics.game
JOIN msu_analytics.application
ON application.game_rk = game.game_rk
JOIN msu_analytics.account
ON account.account_rk = application.account_rk
JOIN msu_analytics.client
ON client.client_rk = account.account_rk
GROUP BY day) t
ORDER BY day
-- //////////////


-- Результат выполнения этого запроса будет содержать столбцы с количеством посещений, 
-- регистраций, заявок на игру и игроков, которые начали играть, по дням/неделямВот несколько примеров запросов, 
-- которые можно использовать для построения воронки:

-- Запрос для получения количества уникальных пользователей, посетивших сайт за каждую неделю:
SELECT DATE_TRUNC('Week', visit_dttm) as week, COUNT(DISTINCT client_rk) as visits
FROM msu_analytics.client
GROUP BY week
order by week;

-- Запрос для получения количества зарегистрированных пользователей за каждую неделю:
SELECT DATE_TRUNC('Week', account.registration_dttm) as week, COUNT(DISTINCT account.client_rk) as registrations
FROM msu_analytics.account
GROUP BY week;

-- Запрос для получения количества заявок на игру за каждую неделю:
SELECT DATE_TRUNC('Week', application.application_dttm) as week, COUNT(DISTINCT application.account_rk) as game_applications
FROM msu_analytics.application
GROUP BY week;

-- Запрос для получения количества пользователей, которые фактически пришли на игру за каждую неделю:
SELECT DATE_TRUNC('Week', game.game_dttm) as week, COUNT(DISTINCT client.client_rk) as game_attendees
FROM msu_analytics.game
join msu_analytics.application
on game.game_rk = application.game_rk
join msu_analytics.account
on application.account_rk = account.client_rk
join msu_analytics.client
on application.application_rk = client.client_rk
where game.game_flg = 1
GROUP BY week;

-- Запрос для получения конверсии пользователей на каждом этапе воронки за каждую неделю:
WITH funnel AS (
select DATE_TRUNC('Week', registration_dttm) as week, COUNT(DISTINCT client_rk) as users_registered
from msu_analytics.account
GROUP by week
), applications AS (
select DATE_TRUNC('Week', application_dttm) as week, COUNT(DISTINCT account_rk) as applications_made
from msu_analytics.application
GROUP by week
), game_attendees AS (
select DATE_TRUNC('Week', game.game_dttm) as week, COUNT(DISTINCT client.client_rk) as game_attendees_count
from msu_analytics.game
join msu_analytics.application
on game.game_rk = application.game_rk
join msu_analytics.account
on application.account_rk = account.client_rk
join msu_analytics.client
on application.application_rk = client.client_rk
where game.game_flg = 1
GROUP by week
)
select funnel.week, users_registered, applications_made, game_attendees_count,
applications_made / CAST(users_registered AS float) as registration_to_application_rate,
game_attendees_count / CAST(applications_made AS float) as application_to_game_attendee_rate
from funnel
join applications
on funnel.week = applications.week
LEFT join game_attendees
on funnel.week = game_attendees.week
ORDER by funnel.week;

-- \\\\\\\\\\ month

WITH funnel AS (
select DATE_TRUNC('month', registration_dttm) as month, COUNT(DISTINCT client_rk) as users_registered
from msu_analytics.account
GROUP by month
), applications AS (
select DATE_TRUNC('month', application_dttm) as month, COUNT(DISTINCT account_rk) as applications_made
from msu_analytics.application
GROUP by month
), game_attendees AS (
select DATE_TRUNC('month', game.game_dttm) as month, COUNT(DISTINCT client.client_rk) as game_attendees_count
from msu_analytics.game
join msu_analytics.application
on game.game_rk = application.game_rk
join msu_analytics.account
on application.account_rk = account.client_rk
join msu_analytics.client
on application.application_rk = client.client_rk
where game.game_flg = 1
GROUP by month
)
select funnel.month, users_registered, applications_made, game_attendees_count,
applications_made / CAST(users_registered AS float) as registration_to_application_rate,
game_attendees_count / CAST(applications_made AS float) as application_to_game_attendee_rate
from funnel
join applications
on funnel.month = applications.month
LEFT join game_attendees
on funnel.month = game_attendees.month
ORDER by funnel.month;