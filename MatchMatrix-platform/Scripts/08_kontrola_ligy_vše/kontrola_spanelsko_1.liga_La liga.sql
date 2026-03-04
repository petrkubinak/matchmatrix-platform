SELECT COUNT(DISTINCT team_id) AS distinct_teams
FROM league_teams
WHERE league_id = 32;



SELECT t.id, t.name
FROM league_teams lt
JOIN teams t ON t.id = lt.team_id
WHERE lt.league_id = 32
  AND lower(t.name) LIKE '%sc%';



SELECT
  t.id,
  t.name AS canonical,
  COUNT(a.id) AS alias_count
FROM league_teams lt
JOIN teams t ON t.id = lt.team_id
LEFT JOIN team_aliases a ON a.team_id = t.id
WHERE lt.league_id = 32
GROUP BY t.id, t.name
ORDER BY alias_count ASC, t.name;



WITH cand AS (
  SELECT *
  FROM (VALUES
    (1146,  622, 'Alaves -> Deportivo Alavés'),
    (1152,   79, 'Ath Madrid -> Club Atlético de Madrid'),
    (1149,  625, 'Celta -> RC Celta de Vigo'),
    (1154,  610, 'Osasuna -> CA Osasuna'),
    (1151,  611, 'Espanol -> RCD Espanyol de Barcelona')
  ) v(old_id, new_id, note)
)
SELECT
  c.note,
  t1.id AS old_id, t1.name AS old_name, t1.ext_source AS old_src, t1.ext_team_id AS old_ext,
  t2.id AS new_id, t2.name AS new_name, t2.ext_source AS new_src, t2.ext_team_id AS new_ext
FROM cand c
JOIN teams t1 ON t1.id = c.old_id
JOIN teams t2 ON t2.id = c.new_id
ORDER BY c.note;



BEGIN;

-- 1) Alaves -> Deportivo Alavés
SELECT public.merge_team(
    1146,
    622,
    'LaLiga 32: Alaves short -> Deportivo Alavés official',
    'manual'
);

-- 2) Ath Madrid -> Club Atlético de Madrid
SELECT public.merge_team(
    1152,
    79,
    'LaLiga 32: Ath Madrid short -> Club Atlético de Madrid',
    'manual'
);

-- 3) Celta -> RC Celta de Vigo
SELECT public.merge_team(
    1149,
    625,
    'LaLiga 32: Celta short -> RC Celta de Vigo',
    'manual'
);

-- 4) Osasuna -> CA Osasuna
SELECT public.merge_team(
    1154,
    610,
    'LaLiga 32: Osasuna short -> CA Osasuna',
    'manual'
);

-- 5) Espanol -> RCD Espanyol de Barcelona
SELECT public.merge_team(
    1151,
    611,
    'LaLiga 32: Espanol short -> RCD Espanyol de Barcelona',
    'manual'
);

COMMIT;



"kontrola po merge"

SELECT COUNT(DISTINCT team_id)
FROM league_teams
WHERE league_id = 32;



SELECT t.name, COUNT(a.id) AS alias_count
FROM league_teams lt
JOIN teams t ON t.id = lt.team_id
LEFT JOIN team_aliases a ON a.team_id = t.id
WHERE lt.league_id = 32
GROUP BY t.name
ORDER BY t.name;