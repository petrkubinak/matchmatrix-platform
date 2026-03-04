-- 1) Týmy bez membership
SELECT t.id, t.name
FROM teams t
LEFT JOIN league_teams lt ON lt.team_id = t.id
WHERE lt.team_id IS NULL
ORDER BY t.name;

-- 2) Týmy bez aliasů
SELECT t.id, t.name
FROM teams t
LEFT JOIN team_aliases a ON a.team_id = t.id
WHERE a.team_id IS NULL
ORDER BY t.name;

-- 3) Matches s team_id, který neexistuje
SELECT COUNT(*)
FROM matches m
LEFT JOIN teams t1 ON t1.id = m.home_team_id
LEFT JOIN teams t2 ON t2.id = m.away_team_id
WHERE t1.id IS NULL OR t2.id IS NULL;

-- 4) Alias kolize (stejný alias pro víc team_id)
SELECT lower(btrim(alias)) AS alias_norm,
       COUNT(DISTINCT team_id) AS teams_cnt
FROM team_aliases
GROUP BY lower(btrim(alias))
HAVING COUNT(DISTINCT team_id) > 1
ORDER BY teams_cnt DESC;