SELECT quest_nm, count(quest_nm)  from quest q  
join game g 
on q.quest_rk = g.game_rk 
where g.game_dttm between '2022-01-01 00:00:00' and '2023-01-31 23:59:59'
group by q.quest_nm 


SELECT * from quest q  
order by q.quest_rk desc  
LIMIT 10

SELECT * from game g  
order by g.game_rk  desc  
LIMIT 10

SELECT game_dttm from game  
LIMIT 10