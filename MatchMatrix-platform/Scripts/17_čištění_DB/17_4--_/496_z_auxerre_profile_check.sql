
-- 496_z_auxerre_profile_check.sql
-- Cíl:
-- porovnat oba Auxerre team_id před mergem

SELECT
    t.id,
    t.name,
    t.ext_source,
    t.ext_team_id,
    COUNT(DISTINCT m.id) AS matches_count,
    COUNT(DISTINCT pss.id) AS player_season_stats_count
FROM public.teams t
LEFT JOIN public.matches m
  ON m.home_team_id = t.id OR m.away_team_id = t.id
LEFT JOIN public.player_season_statistics pss
  ON pss.team_id = t.id
WHERE t.id IN (1019, 12116)
GROUP BY
    t.id, t.name, t.ext_source, t.ext_team_id
ORDER BY matches_count DESC, player_season_stats_count DESC, t.id;