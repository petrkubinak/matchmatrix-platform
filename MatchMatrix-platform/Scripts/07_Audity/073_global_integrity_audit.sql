-- /sql/checks/global_integrity_audit.sql
-- MatchMatrix: Global integrity audit (teams, team_aliases, leagues, league_teams, matches)

-- =========================
-- 0) Quick DB sanity
-- =========================
SELECT 'teams' AS table_name, COUNT(*) AS rows FROM teams
UNION ALL SELECT 'team_aliases', COUNT(*) FROM team_aliases
UNION ALL SELECT 'leagues', COUNT(*) FROM leagues
UNION ALL SELECT 'league_teams', COUNT(*) FROM league_teams
UNION ALL SELECT 'matches', COUNT(*) FROM matches
ORDER BY table_name;

-- =========================
-- 1) league_teams PK sanity (duplicity by (league_id, team_id))
-- =========================
SELECT
  lt.league_id,
  l.name AS league_name,
  lt.team_id,
  t.name AS team_name,
  COUNT(*) AS cnt
FROM league_teams lt
JOIN leagues l ON l.id = lt.league_id
JOIN teams t ON t.id = lt.team_id
GROUP BY lt.league_id, l.name, lt.team_id, t.name
HAVING COUNT(*) > 1
ORDER BY cnt DESC, l.name, t.name;

-- =========================
-- 2) Orphan league_teams (FK problems) - should be 0
-- =========================
-- 2a) league_teams with missing team
SELECT lt.*
FROM league_teams lt
LEFT JOIN teams t ON t.id = lt.team_id
WHERE t.id IS NULL;

-- 2b) league_teams with missing league
SELECT lt.*
FROM league_teams lt
LEFT JOIN leagues l ON l.id = lt.league_id
WHERE l.id IS NULL;

-- =========================
-- 3) Matches FK sanity (home/away team existence)
-- =========================
-- 3a) matches with missing home team
SELECT m.*
FROM matches m
LEFT JOIN teams th ON th.id = m.home_team_id
WHERE th.id IS NULL
LIMIT 200;

-- 3b) matches with missing away team
SELECT m.*
FROM matches m
LEFT JOIN teams ta ON ta.id = m.away_team_id
WHERE ta.id IS NULL
LIMIT 200;

-- 3c) suspicious: home == away (usually error)
SELECT m.*
FROM matches m
WHERE m.home_team_id = m.away_team_id
LIMIT 200;

-- =========================
-- 4) team_aliases integrity
-- =========================
-- 4a) Orphan aliases (alias points to non-existing team) - should be 0
SELECT a.*
FROM team_aliases a
LEFT JOIN teams t ON t.id = a.team_id
WHERE t.id IS NULL
LIMIT 200;

-- 4b) Null/empty aliases (bad data)
SELECT a.*
FROM team_aliases a
WHERE a.alias IS NULL OR btrim(a.alias) = ''
LIMIT 200;

-- 4c) Leading/trailing whitespace aliases (data hygiene)
SELECT a.*
FROM team_aliases a
WHERE a.alias <> btrim(a.alias)
LIMIT 200;

-- 4d) Duplicate aliases for same team (case-insensitive) - redundant rows
SELECT
  a.team_id,
  t.name AS canonical,
  lower(btrim(a.alias)) AS alias_norm,
  COUNT(*) AS cnt,
  string_agg(DISTINCT COALESCE(a.source,'<NULL>'), ', ' ORDER BY COALESCE(a.source,'<NULL>')) AS sources
FROM team_aliases a
JOIN teams t ON t.id = a.team_id
GROUP BY a.team_id, t.name, lower(btrim(a.alias))
HAVING COUNT(*) > 1
ORDER BY cnt DESC, t.name, alias_norm;

-- =========================
-- 5) Alias collision risk (same alias -> multiple teams)
-- =========================
-- 5a) GLOBAL collisions (case-insensitive) - high risk for ingestion
SELECT
  lower(btrim(a.alias)) AS alias_norm,
  COUNT(DISTINCT a.team_id) AS teams_cnt,
  string_agg(DISTINCT t.name, ' | ' ORDER BY t.name) AS team_names,
  string_agg(DISTINCT COALESCE(a.source,'<NULL>'), ', ' ORDER BY COALESCE(a.source,'<NULL>')) AS sources
FROM team_aliases a
JOIN teams t ON t.id = a.team_id
GROUP BY lower(btrim(a.alias))
HAVING COUNT(DISTINCT a.team_id) > 1
ORDER BY teams_cnt DESC, alias_norm;

-- 5b) Collisions inside the same league (even worse)
WITH alias_team AS (
  SELECT lower(btrim(a.alias)) AS alias_norm, a.team_id
  FROM team_aliases a
),
team_league AS (
  SELECT DISTINCT lt.league_id, lt.team_id
  FROM league_teams lt
)
SELECT
  l.id AS league_id,
  l.name AS league_name,
  at.alias_norm,
  COUNT(DISTINCT at.team_id) AS teams_cnt,
  string_agg(DISTINCT t.name, ' | ' ORDER BY t.name) AS team_names
FROM alias_team at
JOIN team_league tl ON tl.team_id = at.team_id
JOIN leagues l ON l.id = tl.league_id
JOIN teams t ON t.id = at.team_id
GROUP BY l.id, l.name, at.alias_norm
HAVING COUNT(DISTINCT at.team_id) > 1
ORDER BY teams_cnt DESC, l.name, at.alias_norm;

-- =========================
-- 6) "Canonical name appears as alias of another team" (confusing but not always wrong)
-- =========================
SELECT
  t_canon.id AS canonical_team_id,
  t_canon.name AS canonical_name,
  a.team_id AS alias_points_to_team_id,
  t_other.name AS alias_points_to_team,
  a.alias,
  a.source
FROM teams t_canon
JOIN team_aliases a ON lower(btrim(a.alias)) = lower(btrim(t_canon.name))
JOIN teams t_other ON t_other.id = a.team_id
WHERE a.team_id <> t_canon.id
ORDER BY canonical_name
LIMIT 500;

-- =========================
-- 7) Teams without any league membership (may be ok, but useful to audit)
-- =========================
SELECT t.id, t.name
FROM teams t
LEFT JOIN league_teams lt ON lt.team_id = t.id
WHERE lt.team_id IS NULL
ORDER BY t.name
LIMIT 500;

-- =========================
-- 8) Teams without aliases (not an error; shows coverage)
-- =========================
SELECT t.id, t.name
FROM teams t
LEFT JOIN team_aliases a ON a.team_id = t.id
WHERE a.team_id IS NULL
ORDER BY t.name
LIMIT 500;

-- =========================
-- 9) Matches teams that are not in league_teams for the same league (if matches has league_id)
-- =========================
-- Only run this section if matches has league_id column.
-- If not, ignore.
-- (Uncomment if applicable)
-- SELECT m.*
-- FROM matches m
-- LEFT JOIN league_teams lth ON lth.league_id = m.league_id AND lth.team_id = m.home_team_id
-- LEFT JOIN league_teams lta ON lta.league_id = m.league_id AND lta.team_id = m.away_team_id
-- WHERE (lth.team_id IS NULL OR lta.team_id IS NULL)
-- LIMIT 200;