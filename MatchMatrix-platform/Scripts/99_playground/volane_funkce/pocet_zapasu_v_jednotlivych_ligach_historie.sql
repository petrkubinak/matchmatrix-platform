select l.name, count(*)
from matches m
join leagues l on l.id = m.league_id
where m.ext_source='football_data_uk'
group by l.name
order by 2 desc;
