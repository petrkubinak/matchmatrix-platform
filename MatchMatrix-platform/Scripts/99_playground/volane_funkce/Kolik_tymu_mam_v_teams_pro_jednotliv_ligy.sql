-- sql/coverage_theodds_vs_teams.sql
-- Kolik týmů mám v teams pro jednotlivé ligy (přes matches)

SELECT l.theodds_key,
       l.name,
       COUNT(DISTINCT m.home_team_id) + COUNT(DISTINCT m.away_team_id) AS distinct_team_refs,
       COUNT(DISTINCT t.id) AS teams_present
FROM leagues l
LEFT JOIN matches m ON m.league_id = l.id
LEFT JOIN teams t ON t.id IN (m.home_team_id, m.away_team_id)
WHERE l.theodds_key IS NOT NULL
GROUP BY l.theodds_key, l.name
ORDER BY teams_present DESC;