INSERT INTO matches (league_id, home_team_id, away_team_id, kickoff)
SELECT
  l.id,
  h.id,
  a.id,
  '2026-02-17 20:00'
FROM leagues l
JOIN teams h ON h.name = 'Chelsea'
JOIN teams a ON a.name = 'Liverpool'
WHERE l.name = 'Premier League'
RETURNING id;
