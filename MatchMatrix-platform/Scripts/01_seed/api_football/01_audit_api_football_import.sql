-- ligy z api_football
SELECT id, name, country, ext_source, ext_league_id
FROM leagues
WHERE ext_source = 'api_football'
ORDER BY id;

-- týmy z api_football
SELECT COUNT(*) AS teams_cnt
FROM teams
WHERE ext_source = 'api_football';

SELECT id, name, ext_team_id
FROM teams
WHERE ext_source = 'api_football'
ORDER BY id
LIMIT 50;