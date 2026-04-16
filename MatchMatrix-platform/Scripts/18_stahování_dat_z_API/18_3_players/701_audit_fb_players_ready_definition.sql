-- =====================================================================
-- MatchMatrix
-- FILE: 701_audit_fb_players_ready_definition.sql
-- PATH: C:\MatchMatrix-platform\db\audit\701_audit_fb_players_ready_definition.sql
--
-- Cíl:
-- Audit "PLAYERS READY" definice pro football / api_football
--
-- Kontroluje:
-- 1) public.players count
-- 2) public.player_provider_map count
-- 3) coverage hráčů na tým
-- 4) coverage hráčů na ligu
-- 5) týmy s nízkým coverage
-- 6) duplicity provider map
-- 7) duplicity players podle name + birth_date
--
-- Spouštění:
-- v DBeaveru jako běžný SQL script
-- =====================================================================

-- -----------------------------------------------------
-- 0) SUMMARY
-- -----------------------------------------------------
SELECT 'public.players' AS metric, COUNT(*)::bigint AS value
FROM public.players

UNION ALL
SELECT 'public.player_provider_map', COUNT(*)::bigint
FROM public.player_provider_map

UNION ALL
SELECT 'public.players ext_source=api_football', COUNT(*)::bigint
FROM public.players
WHERE ext_source = 'api_football'

UNION ALL
SELECT 'player_provider_map provider=api_football', COUNT(*)::bigint
FROM public.player_provider_map
WHERE provider = 'api_football';

-- -----------------------------------------------------
-- 1) PLAYERS PER TEAM
-- canonical team coverage
-- -----------------------------------------------------
WITH team_player_counts AS (
    SELECT
        p.team_id,
        COUNT(*) AS players_count
    FROM public.players p
    WHERE p.team_id IS NOT NULL
    GROUP BY p.team_id
)
SELECT
    t.id AS team_id,
    t.name AS team_name,
    COALESCE(tpc.players_count, 0) AS players_count
FROM public.teams t
LEFT JOIN team_player_counts tpc
    ON tpc.team_id = t.id
ORDER BY players_count DESC, t.name;

-- -----------------------------------------------------
-- 2) LOW COVERAGE TEAMS
-- hranice můžeš později upravit
-- READY threshold zatím 15+
-- -----------------------------------------------------
WITH team_player_counts AS (
    SELECT
        p.team_id,
        COUNT(*) AS players_count
    FROM public.players p
    WHERE p.team_id IS NOT NULL
    GROUP BY p.team_id
)
SELECT
    t.id AS team_id,
    t.name AS team_name,
    COALESCE(tpc.players_count, 0) AS players_count,
    CASE
        WHEN COALESCE(tpc.players_count, 0) >= 15 THEN 'READY'
        WHEN COALESCE(tpc.players_count, 0) BETWEEN 8 AND 14 THEN 'PARTIAL'
        ELSE 'LOW'
    END AS coverage_status
FROM public.teams t
LEFT JOIN team_player_counts tpc
    ON tpc.team_id = t.id
WHERE COALESCE(tpc.players_count, 0) < 15
ORDER BY players_count ASC, t.name;

-- -----------------------------------------------------
-- 3) PLAYERS PER LEAGUE
-- přes týmové vazby league_teams
-- -----------------------------------------------------
WITH team_player_counts AS (
    SELECT
        p.team_id,
        COUNT(*) AS players_count
    FROM public.players p
    WHERE p.team_id IS NOT NULL
    GROUP BY p.team_id
),
league_coverage AS (
    SELECT
        l.id AS league_id,
        l.name AS league_name,
        COUNT(DISTINCT lt.team_id) AS teams_in_league,
        COALESCE(SUM(COALESCE(tpc.players_count, 0)), 0) AS total_players_in_league
    FROM public.leagues l
    LEFT JOIN public.league_teams lt
        ON lt.league_id = l.id
    LEFT JOIN team_player_counts tpc
        ON tpc.team_id = lt.team_id
    GROUP BY l.id, l.name
)
SELECT
    league_id,
    league_name,
    teams_in_league,
    total_players_in_league,
    CASE
        WHEN teams_in_league = 0 THEN 0
        ELSE ROUND(total_players_in_league::numeric / teams_in_league, 2)
    END AS avg_players_per_team
FROM league_coverage
ORDER BY avg_players_per_team DESC NULLS LAST, league_name;

-- -----------------------------------------------------
-- 4) LEAGUES WITH LOW PLAYER COVERAGE
-- -----------------------------------------------------
WITH team_player_counts AS (
    SELECT
        p.team_id,
        COUNT(*) AS players_count
    FROM public.players p
    WHERE p.team_id IS NOT NULL
    GROUP BY p.team_id
),
league_coverage AS (
    SELECT
        l.id AS league_id,
        l.name AS league_name,
        COUNT(DISTINCT lt.team_id) AS teams_in_league,
        COALESCE(SUM(COALESCE(tpc.players_count, 0)), 0) AS total_players_in_league
    FROM public.leagues l
    LEFT JOIN public.league_teams lt
        ON lt.league_id = l.id
    LEFT JOIN team_player_counts tpc
        ON tpc.team_id = lt.team_id
    GROUP BY l.id, l.name
)
SELECT
    league_id,
    league_name,
    teams_in_league,
    total_players_in_league,
    CASE
        WHEN teams_in_league = 0 THEN 0
        ELSE ROUND(total_players_in_league::numeric / teams_in_league, 2)
    END AS avg_players_per_team,
    CASE
        WHEN teams_in_league = 0 THEN 'NO_TEAMS'
        WHEN (total_players_in_league::numeric / NULLIF(teams_in_league, 0)) >= 15 THEN 'READY'
        WHEN (total_players_in_league::numeric / NULLIF(teams_in_league, 0)) >= 8 THEN 'PARTIAL'
        ELSE 'LOW'
    END AS coverage_status
FROM league_coverage
WHERE
    teams_in_league = 0
    OR (total_players_in_league::numeric / NULLIF(teams_in_league, 0)) < 15
ORDER BY avg_players_per_team ASC NULLS FIRST, league_name;

-- -----------------------------------------------------
-- 5) PROVIDER MAP DUPLICITY
-- 1 provider_player_id nesmí vést na více canonical players
-- -----------------------------------------------------
SELECT
    ppm.provider,
    ppm.provider_player_id,
    COUNT(*) AS rows_count,
    COUNT(DISTINCT ppm.player_id) AS distinct_player_ids,
    STRING_AGG(DISTINCT ppm.player_id::text, ', ' ORDER BY ppm.player_id::text) AS player_ids
FROM public.player_provider_map ppm
WHERE ppm.provider = 'api_football'
GROUP BY
    ppm.provider,
    ppm.provider_player_id
HAVING COUNT(DISTINCT ppm.player_id) > 1
ORDER BY distinct_player_ids DESC, ppm.provider_player_id;

-- -----------------------------------------------------
-- 6) PLAYERS DUPLICITY BY NAME + BIRTH_DATE
-- kandidáti na canonical cleanup
-- -----------------------------------------------------
SELECT
    p.name,
    p.birth_date,
    COUNT(*) AS rows_count,
    STRING_AGG(p.id::text, ', ' ORDER BY p.id::text) AS player_ids
FROM public.players p
WHERE p.name IS NOT NULL
  AND p.birth_date IS NOT NULL
GROUP BY
    p.name,
    p.birth_date
HAVING COUNT(*) > 1
ORDER BY rows_count DESC, p.name, p.birth_date;

-- -----------------------------------------------------
-- 7) API_FOOTBALL PLAYERS WITHOUT PROVIDER MAP
-- hráči s ext_source=api_football, ale bez player_provider_map
-- -----------------------------------------------------
SELECT
    p.id AS player_id,
    p.name,
    p.birth_date,
    p.team_id,
    p.ext_source,
    p.ext_player_id
FROM public.players p
LEFT JOIN public.player_provider_map ppm
    ON ppm.player_id = p.id
   AND ppm.provider = 'api_football'
WHERE p.ext_source = 'api_football'
  AND ppm.id IS NULL
ORDER BY p.name, p.id;

-- -----------------------------------------------------
-- 8) PROVIDER MAP POINTING TO MISSING PLAYER
-- bezpečnostní kontrola
-- -----------------------------------------------------
SELECT
    ppm.id,
    ppm.provider,
    ppm.provider_player_id,
    ppm.player_id
FROM public.player_provider_map ppm
LEFT JOIN public.players p
    ON p.id = ppm.player_id
WHERE ppm.provider = 'api_football'
  AND p.id IS NULL
ORDER BY ppm.id;

-- -----------------------------------------------------
-- 9) TEAM COVERAGE ONLY FOR TEAMS MAPPED FROM api_football
-- přes team_provider_map
-- užitečné pro real READY audit provider-based
-- -----------------------------------------------------
WITH api_teams AS (
    SELECT
        tpm.team_id,
        t.name AS team_name,
        tpm.provider_team_id
    FROM public.team_provider_map tpm
    JOIN public.teams t
        ON t.id = tpm.team_id
    WHERE tpm.provider = 'api_football'
),
team_player_counts AS (
    SELECT
        p.team_id,
        COUNT(*) AS players_count
    FROM public.players p
    WHERE p.team_id IS NOT NULL
    GROUP BY p.team_id
)
SELECT
    at.team_id,
    at.team_name,
    at.provider_team_id,
    COALESCE(tpc.players_count, 0) AS players_count,
    CASE
        WHEN COALESCE(tpc.players_count, 0) >= 15 THEN 'READY'
        WHEN COALESCE(tpc.players_count, 0) BETWEEN 8 AND 14 THEN 'PARTIAL'
        ELSE 'LOW'
    END AS coverage_status
FROM api_teams at
LEFT JOIN team_player_counts tpc
    ON tpc.team_id = at.team_id
ORDER BY players_count ASC, at.team_name;

-- -----------------------------------------------------
-- 10) FINAL READY KPI
-- agregovaný pohled pro rychlé rozhodnutí
-- -----------------------------------------------------
WITH api_teams AS (
    SELECT DISTINCT team_id
    FROM public.team_provider_map
    WHERE provider = 'api_football'
),
team_player_counts AS (
    SELECT
        p.team_id,
        COUNT(*) AS players_count
    FROM public.players p
    WHERE p.team_id IS NOT NULL
    GROUP BY p.team_id
),
team_eval AS (
    SELECT
        at.team_id,
        COALESCE(tpc.players_count, 0) AS players_count
    FROM api_teams at
    LEFT JOIN team_player_counts tpc
        ON tpc.team_id = at.team_id
)
SELECT
    COUNT(*) AS api_football_teams_total,
    COUNT(*) FILTER (WHERE players_count >= 15) AS ready_teams,
    COUNT(*) FILTER (WHERE players_count BETWEEN 8 AND 14) AS partial_teams,
    COUNT(*) FILTER (WHERE players_count < 8) AS low_teams,
    ROUND(AVG(players_count)::numeric, 2) AS avg_players_per_team,
    MIN(players_count) AS min_players_per_team,
    MAX(players_count) AS max_players_per_team
FROM team_eval;