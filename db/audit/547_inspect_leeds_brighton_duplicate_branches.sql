-- 547_inspect_leeds_brighton_duplicate_branches.sql
-- Cíl:
-- bezpečně zkontrolovat duplicate větve pro Leeds a Brighton
-- před případným safe merge

-- Kandidáti:
-- Leeds:    956  -> 61
-- Brighton: 11917 -> 64

-- =========================================================
-- 1) Základní profil týmů
-- =========================================================
SELECT
    t.id,
    t.name
FROM public.teams t
WHERE t.id IN (956, 61, 11917, 64)
ORDER BY t.id;

-- =========================================================
-- 2) Provider map
-- =========================================================
SELECT
    tpm.team_id,
    t.name AS team_name,
    tpm.provider,
    tpm.provider_team_id
FROM public.team_provider_map tpm
JOIN public.teams t
  ON t.id = tpm.team_id
WHERE tpm.team_id IN (956, 61, 11917, 64)
ORDER BY tpm.team_id, tpm.provider, tpm.provider_team_id;

-- =========================================================
-- 3) Aliasy
-- =========================================================
SELECT
    ta.team_id,
    t.name AS team_name,
    ta.alias,
    ta.source
FROM public.team_aliases ta
JOIN public.teams t
  ON t.id = ta.team_id
WHERE ta.team_id IN (956, 61, 11917, 64)
ORDER BY ta.team_id, ta.alias, ta.source;

-- =========================================================
-- 4) Použití v matches jako home
-- =========================================================
SELECT
    m.home_team_id AS team_id,
    t.name AS team_name,
    COUNT(*) AS home_matches
FROM public.matches m
JOIN public.teams t
  ON t.id = m.home_team_id
WHERE m.home_team_id IN (956, 61, 11917, 64)
GROUP BY m.home_team_id, t.name
ORDER BY m.home_team_id;

-- =========================================================
-- 5) Použití v matches jako away
-- =========================================================
SELECT
    m.away_team_id AS team_id,
    t.name AS team_name,
    COUNT(*) AS away_matches
FROM public.matches m
JOIN public.teams t
  ON t.id = m.away_team_id
WHERE m.away_team_id IN (956, 61, 11917, 64)
GROUP BY m.away_team_id, t.name
ORDER BY m.away_team_id;

-- =========================================================
-- 6) Použití v league_teams
-- =========================================================
SELECT
    lt.team_id,
    t.name AS team_name,
    COUNT(*) AS league_team_rows
FROM public.league_teams lt
JOIN public.teams t
  ON t.id = lt.team_id
WHERE lt.team_id IN (956, 61, 11917, 64)
GROUP BY lt.team_id, t.name
ORDER BY lt.team_id;

-- =========================================================
-- 7) Použití v odds
-- přes match navázané na tým
-- =========================================================
SELECT
    x.team_id,
    t.name AS team_name,
    COUNT(*) AS odds_rows
FROM (
    SELECT m.home_team_id AS team_id, o.id
    FROM public.odds o
    JOIN public.matches m
      ON m.id = o.match_id
    WHERE m.home_team_id IN (956, 61, 11917, 64)

    UNION ALL

    SELECT m.away_team_id AS team_id, o.id
    FROM public.odds o
    JOIN public.matches m
      ON m.id = o.match_id
    WHERE m.away_team_id IN (956, 61, 11917, 64)
) x
JOIN public.teams t
  ON t.id = x.team_id
GROUP BY x.team_id, t.name
ORDER BY x.team_id;

-- =========================================================
-- 8) Rychlý návrh merge směru
-- =========================================================
SELECT
    'LEEDS' AS case_name,
    956 AS old_team_id,
    61  AS new_team_id
UNION ALL
SELECT
    'BRIGHTON' AS case_name,
    11917 AS old_team_id,
    64    AS new_team_id;