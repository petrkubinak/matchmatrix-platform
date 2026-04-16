-- 471_seed_canonical_league_and_team_mapping_auto.sql
-- Cíl:
-- 1) zapsat potvrzené mapování top lig do canonical_league_map
-- 2) zapsat automatické team mapování tam, kde je přesná shoda názvu
-- 3) NIC nemažeme, jen seedujeme mapovací vrstvu

-- =========================================================
-- 1) SEED TOP LIG: football_data => canonical, api_football => provider
-- =========================================================
INSERT INTO public.canonical_league_map (
    canonical_league_id,
    provider,
    provider_league_id,
    status,
    note
)
VALUES
    (5,  'api_football', 20871, 'confirmed', 'Championship: football_data canonical, api_football mapped'),
    (6,  'api_football', 20855, 'confirmed', 'Premier League: football_data canonical, api_football mapped'),
    (26, 'api_football', 20852, 'confirmed', 'Ligue 1: football_data canonical, api_football mapped'),
    (27, 'api_football', 20856, 'confirmed', 'Bundesliga: football_data canonical, api_football mapped'),
    (28, 'api_football', 20857, 'confirmed', 'Serie A: football_data canonical, api_football mapped'),
    (29, 'api_football', 20849, 'confirmed', 'Eredivisie: football_data canonical, api_football mapped'),
    (30, 'api_football', 20858, 'confirmed', 'Primeira Liga: football_data canonical, api_football mapped')
ON CONFLICT (canonical_league_id, provider, provider_league_id) DO NOTHING;


-- =========================================================
-- 2) AUTO TEAM MATCHING – exact name match uvnitř spárovaných lig
-- =========================================================
WITH mapped_leagues AS (
    SELECT
        clm.canonical_league_id,
        clm.provider_league_id AS api_league_id
    FROM public.canonical_league_map clm
    WHERE clm.provider = 'api_football'
      AND clm.canonical_league_id IN (5, 6, 26, 27, 28, 29, 30)
),
fd_teams AS (
    SELECT DISTINCT
        ml.canonical_league_id,
        t.id AS canonical_team_id,
        lower(trim(t.name)) AS team_name_key,
        t.name AS canonical_team_name
    FROM mapped_leagues ml
    JOIN public.matches m
      ON m.league_id = ml.canonical_league_id
    JOIN public.teams t
      ON t.id IN (m.home_team_id, m.away_team_id)
),
api_teams AS (
    SELECT DISTINCT
        ml.canonical_league_id,
        t.id AS api_team_id,
        lower(trim(t.name)) AS team_name_key,
        t.name AS api_team_name
    FROM mapped_leagues ml
    JOIN public.matches m
      ON m.league_id = ml.api_league_id
    JOIN public.teams t
      ON t.id IN (m.home_team_id, m.away_team_id)
),
auto_pairs AS (
    SELECT
        fd.canonical_league_id,
        fd.canonical_team_id,
        fd.canonical_team_name,
        api.api_team_id,
        api.api_team_name
    FROM fd_teams fd
    JOIN api_teams api
      ON fd.canonical_league_id = api.canonical_league_id
     AND fd.team_name_key = api.team_name_key
)
INSERT INTO public.canonical_team_map (
    canonical_team_id,
    provider,
    provider_team_id,
    status,
    note
)
SELECT
    ap.canonical_team_id,
    'api_football' AS provider,
    ap.api_team_id AS provider_team_id,
    'auto' AS status,
    CONCAT(
        'Auto exact-name match in mapped league | canonical=',
        ap.canonical_team_name,
        ' | provider=',
        ap.api_team_name
    ) AS note
FROM auto_pairs ap
ON CONFLICT (canonical_team_id, provider, provider_team_id) DO NOTHING;


-- =========================================================
-- 3) KONTROLA – kolik lig bylo seednuto
-- =========================================================
SELECT
    provider,
    COUNT(*) AS rows_count
FROM public.canonical_league_map
GROUP BY provider
ORDER BY provider;


-- =========================================================
-- 4) KONTROLA – kolik team map bylo seednuto
-- =========================================================
SELECT
    provider,
    status,
    COUNT(*) AS rows_count
FROM public.canonical_team_map
GROUP BY provider, status
ORDER BY provider, status;


-- =========================================================
-- 5) PREVIEW – jaké auto team mapy vznikly
-- =========================================================
SELECT
    ctm.canonical_team_id,
    t1.name AS canonical_team_name,
    ctm.provider,
    ctm.provider_team_id,
    t2.name AS provider_team_name,
    ctm.status,
    ctm.note
FROM public.canonical_team_map ctm
LEFT JOIN public.teams t1
       ON t1.id = ctm.canonical_team_id
LEFT JOIN public.teams t2
       ON t2.id = ctm.provider_team_id
WHERE ctm.provider = 'api_football'
ORDER BY t1.name, t2.name;