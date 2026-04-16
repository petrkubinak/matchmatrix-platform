-- 711_verify_post_merge_fk_cleanup.sql

SELECT id, name
FROM public.teams
WHERE id IN (13202,14578,13228,13255,13110,13615)
ORDER BY name, id;

SELECT team_id, COUNT(*) AS cnt
FROM public.league_standings
WHERE team_id IN (13202,14578,13228,13255,13110,13615)
GROUP BY team_id
ORDER BY team_id;

SELECT *
FROM public.team_provider_map
WHERE team_id IN (13202,14578,13228,13255,13110,13615)
ORDER BY team_id, provider, provider_team_id;