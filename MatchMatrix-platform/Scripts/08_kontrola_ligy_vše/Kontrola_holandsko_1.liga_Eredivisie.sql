-- 1) kolik týmů v membership (historicky)
SELECT COUNT(DISTINCT team_id) AS distinct_teams
FROM league_teams
WHERE league_id = 29;

-- 2) alias coverage
SELECT t.id, t.name AS canonical, COUNT(a.id) AS alias_count
FROM league_teams lt
JOIN teams t ON t.id = lt.team_id
LEFT JOIN team_aliases a ON a.team_id = t.id
WHERE lt.league_id = 29
GROUP BY t.id, t.name
ORDER BY alias_count ASC, t.name;

-- 3) Kontrola rezerv / “II / Jong / U21” (v NL hodně časté)
SELECT t.id, t.name
FROM league_teams lt
JOIN teams t ON t.id = lt.team_id
WHERE lt.league_id = 29
  AND (
    t.name ILIKE 'jong %'
    OR t.name ~* '(\bII\b|U19|U21|Reserves)'
    OR t.name ILIKE '% ii'
  )
ORDER BY t.name;

-- 4) Duplicate candidates "short vs official v rámci ligy"
WITH nl AS (
  SELECT t.id, t.name
  FROM league_teams lt
  JOIN teams t ON t.id = lt.team_id
  WHERE lt.league_id = 29
),
norm AS (
  SELECT
    id,
    name,
    lower(
      regexp_replace(
        regexp_replace(
          regexp_replace(name, '[\.\-’'']', '', 'g'),
          '\s+', ' ', 'g'
        ),
        '\b(fc|sc|sv|vv|bv|vitesse|ajax|psv|az|feyenoord|sparta|heracles|pec)\b',
        '',
        'g'
      )
    ) AS key
  FROM nl
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


-- 5) Merge "bezpečný review dotaz"
WITH cand(old_id, new_id, note) AS (
VALUES
  (1104, 95,  'Ajax short -> AFC Ajax'),
  (566, 1106, 'AZ short -> AZ Alkmaar'),
  (1103, 556, 'Twente short -> FC Twente 65'),
  (1108, 562, 'Utrecht short -> FC Utrecht'),
  (561, 1098, 'Feyenoord Rotterdam -> Feyenoord'),
  (1107, 563, 'Groningen short -> FC Groningen'),
  (1095, 572, 'For Sittard -> Fortuna Sittard'),
  (1099, 559, 'Heerenveen short -> SC Heerenveen'),
  (94, 1101,  'PSV short -> PSV Eindhoven'),
  (1097, 557, 'Excelsior short -> SBV Excelsior'),
  (1100, 571, 'Volendam short -> FC Volendam'),
  (1102, 567, 'Zwolle short -> PEC Zwolle'),
  (1096, 570, 'Nijmegen -> NEC'),
  (1109, 558, 'Heracles short -> Heracles Almelo')
)
SELECT
  c.note,
  t1.id AS old_id, t1.name AS old_name, t1.ext_source AS old_src, t1.ext_team_id AS old_ext,
  t2.id AS new_id, t2.name AS new_name, t2.ext_source AS new_src, t2.ext_team_id AS new_ext
FROM cand c
JOIN teams t1 ON t1.id = c.old_id
JOIN teams t2 ON t2.id = c.new_id
ORDER BY c.note;

-- 5) Kontrola po Merge 
SELECT COUNT(DISTINCT team_id)
FROM league_teams
WHERE league_id = 29;


-- 5) Kontrola alias coverage
SELECT t.name, COUNT(a.id)
FROM league_teams lt
JOIN teams t ON t.id = lt.team_id
LEFT JOIN team_aliases a ON a.team_id = t.id
WHERE lt.league_id = 29
GROUP BY t.name
ORDER BY t.name;
