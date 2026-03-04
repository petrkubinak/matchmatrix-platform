WITH theodds_teams AS (
  SELECT DISTINCT trim(e->>'home_team') AS team_name
  FROM api_raw_payloads p
  CROSS JOIN LATERAL jsonb_array_elements(p.payload) e
  WHERE p.source='theodds'
    AND p.endpoint LIKE '/sports/%/odds'
    AND jsonb_typeof(p.payload)='array'
    AND e ? 'home_team'

  UNION

  SELECT DISTINCT trim(e->>'away_team') AS team_name
  FROM api_raw_payloads p
  CROSS JOIN LATERAL jsonb_array_elements(p.payload) e
  WHERE p.source='theodds'
    AND p.endpoint LIKE '/sports/%/odds'
    AND jsonb_typeof(p.payload)='array'
    AND e ? 'away_team'
),
normed AS (
  SELECT
    team_name,
    trim(regexp_replace(
      regexp_replace(lower(team_name), '\s+(fc|afc|cf|sc|ac)$', '', 'g'),
      '[^a-z0-9\s]', '',
      'g'
    )) AS team_key
  FROM theodds_teams
  WHERE team_name IS NOT NULL AND team_name <> ''
),
matched AS (
  SELECT
    n.team_name,
    t.id AS team_id
  FROM normed n
  JOIN teams t
    ON trim(regexp_replace(
         regexp_replace(lower(t.name), '\s+(fc|afc|cf|sc|ac)$', '', 'g'),
         '[^a-z0-9\s]', '',
         'g'
       )) = n.team_key

  UNION

  SELECT
    n.team_name,
    ta.team_id
  FROM normed n
  JOIN team_aliases ta
    ON trim(regexp_replace(
         regexp_replace(lower(ta.alias), '\s+(fc|afc|cf|sc|ac)$', '', 'g'),
         '[^a-z0-9\s]', '',
         'g'
       )) = n.team_key
)
INSERT INTO team_aliases(team_id, alias, source)
SELECT m.team_id, m.team_name, 'theodds'
FROM matched m
ON CONFLICT (alias, source) DO NOTHING;
