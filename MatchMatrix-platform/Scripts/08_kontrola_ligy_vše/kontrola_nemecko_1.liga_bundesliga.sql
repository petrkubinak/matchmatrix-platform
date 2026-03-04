-- 1) kolik týmů historicky
SELECT COUNT(DISTINCT team_id) AS distinct_teams
FROM league_teams
WHERE league_id = 27;

-- 2) alias coverage
SELECT t.id, t.name AS canonical, COUNT(a.id) AS alias_count
FROM league_teams lt
JOIN teams t ON t.id = lt.team_id
LEFT JOIN team_aliases a ON a.team_id = t.id
WHERE lt.league_id = 27
GROUP BY t.id, t.name
ORDER BY alias_count ASC, t.name;

-- 3) rychlá detekce “B týmů / rezerv / divných suffixů”
SELECT t.id, t.name
FROM league_teams lt
JOIN teams t ON t.id = lt.team_id
WHERE lt.league_id = 27
  AND (
    t.name ~* '(\bII\b|\b2\b|U19|U21|Amateure|Reserves)'
    OR t.name ILIKE '% ii'
    OR t.name ILIKE '% 2'
  )
ORDER BY t.name;


-- 4) rychlá detekce “duplicity uvnitř Bundesligy”
WITH bl AS (
  SELECT t.id, t.name
  FROM league_teams lt
  JOIN teams t ON t.id = lt.team_id
  WHERE lt.league_id = 27
),
norm AS (
  SELECT
    id,
    name,
    -- zjednodušený “normalizovaný klíč” pro hledání shod
    lower(
      regexp_replace(
        regexp_replace(
          regexp_replace(name, '[\.\-’'']', '', 'g'),
          '\s+', ' ', 'g'
        ),
        '\b(fc|sv|tsv|vfb|vfl|sc|tsg|spvgg|borussia|eintracht|bayer|bayern|1|04)\b',
        '',
        'g'
      )
    ) AS key
  FROM bl
),
pairs AS (
  SELECT
    a.id AS id1, a.name AS name1,
    b.id AS id2, b.name AS name2,
    a.key
  FROM norm a
  JOIN norm b
    ON a.key = b.key
   AND a.id < b.id
  WHERE length(btrim(a.key)) >= 4
)
SELECT *
FROM pairs
ORDER BY key, name1, name2;


-- 5) rychlá detekce “týmy s nízkým alias coverage v Bundeslize”
SELECT
  t.id,
  t.name AS canonical,
  COUNT(a.id) AS alias_count
FROM league_teams lt
JOIN teams t ON t.id = lt.team_id
LEFT JOIN team_aliases a ON a.team_id = t.id
WHERE lt.league_id = 27
GROUP BY t.id, t.name
HAVING COUNT(a.id) <= 1
ORDER BY t.name;


-- 6) rychlá detekce “Výpis, jaké aliasy již mají”
WITH low AS (
  SELECT t.id
  FROM league_teams lt
  JOIN teams t ON t.id = lt.team_id
  LEFT JOIN team_aliases a ON a.team_id = t.id
  WHERE lt.league_id = 27
  GROUP BY t.id
  HAVING COUNT(a.id) <= 1
)
SELECT
  t.id AS team_id,
  t.name AS canonical,
  a.alias,
  a.source
FROM low
JOIN teams t ON t.id = low.id
LEFT JOIN team_aliases a ON a.team_id = t.id
ORDER BY t.name, a.alias;


-- 7) rychlá detekce “rezervy / II / U21” v membership"
SELECT t.id, t.name
FROM league_teams lt
JOIN teams t ON t.id = lt.team_id
WHERE lt.league_id = 27
  AND (
    t.name ~* '(\bII\b|\b2\b|U19|U21|Amateure|Reserves)'
    OR t.name ILIKE '% ii'
    OR t.name ILIKE '% 2'
  )
ORDER BY t.name;

-- 8) rykontrola Aliases
SELECT t.name, COUNT(a.id)
FROM league_teams lt
JOIN teams t ON t.id = lt.team_id
LEFT JOIN team_aliases a ON a.team_id = t.id
WHERE lt.league_id = 27
GROUP BY t.name
ORDER BY t.name;