SELECT q.quest_nm "Quest Name", count(*) AMount
FROM game g
join quest q 
on g.quest_rk = q.quest_rk 
where game_dttm between '2022-01-01 00:00:00' and '2023-01-31 23:59:59'
group by q.quest_nm
order by q.quest_nm 