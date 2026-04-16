-- =====================================================================
-- MatchMatrix
-- FILE: 706_audit_fb_players_wave1_coverage.sql
-- PATH: C:\MatchMatrix-platform\db\audit\706_audit_fb_players_wave1_coverage.sql
--
-- Cíl:
-- Audit coverage pro FB players po WAVE 1
--
-- WAVE 1 ligy:
-- 39  Premier League
-- 62  Ligue 2
-- 78  Bundesliga
-- 79  2. Bundesliga
-- 89  Eerste Divisie
-- 140 La Liga
--
-- Sezona:
-- 2022
-- =====================================================================

-- -----------------------------------------------------
-- 0) WAVE 1 definice
-- -----------------------------------------------------
WITH wave1 AS (
    SELECT '39'  AS provider_league_id, 'Premier League'  AS expected_name, '2022' AS season UNION ALL
    SELECT '62'  AS provider_league_id, 'Ligue 2'         AS expected_name, '2022' AS season UNION ALL
    SELECT '78'  AS provider_league_id, 'Bundesliga'      AS expected_name, '2022' AS season UNION ALL
    SELECT '79'  AS provider_league_id, '2. Bundesliga'   AS expected_name, '2022' AS season UNION ALL
    SELECT '89'  AS provider_league_id, 'Eerste Divisie'  AS expected_name, '2022' AS season UNION ALL
    SELECT '140' AS provider_league_id, 'La Liga'         AS expected_name, '2022' AS season
)

-- -----------------------------------------------------
-- 1) END-TO-END SUMMARY
-- -----------------------------------------------------
SELECT
    w.provider_league_id,
    w.expected_name,
    w.season,
    COALESCE(pi.players_import_rows, 0)      AS players_import_rows,
    COALESCE(pi.distinct_import_players, 0)  AS distinct_import_players,
    COALESCE(sp.staging_rows, 0)             AS staging_rows,
    COALESCE(sp.distinct_staging_players, 0) AS distinct_staging_players,
    COALESCE(pp.public_players, 0)           AS distinct_public_players
FROM wave1 w
LEFT JOIN (
    SELECT
        provider_league_id::text AS provider_league_id,
        season::text AS season,
        COUNT(*) AS players_import_rows,
        COUNT(DISTINCT provider_player_id) AS distinct_import_players
    FROM staging.players_import
    WHERE provider_code = 'api_football'
      AND provider_league_id::text IN ('39','62','78','79','89','140')
      AND season::text = '2022'
    GROUP BY provider_league_id, season
) pi
    ON pi.provider_league_id = w.provider_league_id
   AND pi.season = w.season
LEFT JOIN (
    SELECT
        external_league_id::text AS provider_league_id,
        season::text AS season,
        COUNT(*) AS staging_rows,
        COUNT(DISTINCT external_player_id) AS distinct_staging_players
    FROM staging.stg_provider_players
    WHERE provider = 'api_football'
      AND external_league_id::text IN ('39','62','78','79','89','140')
      AND season::text = '2022'
    GROUP BY external_league_id, season
) sp
    ON sp.provider_league_id = w.provider_league_id
   AND sp.season = w.season
LEFT JOIN (
    SELECT
        spp.external_league_id::text AS provider_league_id,
        spp.season::text AS season,
        COUNT(DISTINCT ppm.player_id) AS public_players
    FROM staging.stg_provider_players spp
    LEFT JOIN public.player_provider_map ppm
           ON ppm.provider = spp.provider
          AND ppm.provider_player_id::text = spp.external_player_id::text
    WHERE spp.provider = 'api_football'
      AND spp.external_league_id::text IN ('39','62','78','79','89','140')
      AND spp.season::text = '2022'
    GROUP BY spp.external_league_id, spp.season
) pp
    ON pp.provider_league_id = w.provider_league_id
   AND pp.season = w.season
ORDER BY w.provider_league_id;

-- -----------------------------------------------------
-- 2) TEAM COVERAGE PER WAVE 1 LEAGUE
-- kolik canonical hráčů má každý tým v lize
-- -----------------------------------------------------
WITH wave1 AS (
    SELECT '39'  AS provider_league_id, '2022' AS season UNION ALL
    SELECT '62', '2022' UNION ALL
    SELECT '78', '2022' UNION ALL
    SELECT '79', '2022' UNION ALL
    SELECT '89', '2022' UNION ALL
    SELECT '140','2022'
),
league_teams AS (
    SELECT DISTINCT
        spp.external_league_id::text AS provider_league_id,
        spp.season::text AS season,
        tpm.team_id,
        t.name AS team_name,
        spp.external_team_id::text AS provider_team_id
    FROM staging.stg_provider_players spp
    LEFT JOIN public.team_provider_map tpm
           ON tpm.provider = spp.provider
          AND tpm.provider_team_id::text = spp.external_team_id::text
    LEFT JOIN public.teams t
           ON t.id = tpm.team_id
    WHERE spp.provider = 'api_football'
      AND spp.external_league_id::text IN ('39','62','78','79','89','140')
      AND spp.season::text = '2022'
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
    lt.provider_league_id,
    l.name AS league_name,
    lt.season,
    lt.team_id,
    lt.team_name,
    lt.provider_team_id,
    COALESCE(tpc.players_count, 0) AS players_count,
    CASE
        WHEN COALESCE(tpc.players_count, 0) >= 15 THEN 'READY'
        WHEN COALESCE(tpc.players_count, 0) BETWEEN 8 AND 14 THEN 'PARTIAL'
        ELSE 'LOW'
    END AS coverage_status
FROM league_teams lt
LEFT JOIN team_player_counts tpc
       ON tpc.team_id = lt.team_id
LEFT JOIN public.league_provider_map lpm
       ON lpm.provider = 'api_football'
      AND lpm.provider_league_id::text = lt.provider_league_id
LEFT JOIN public.leagues l
       ON l.id = lpm.league_id
ORDER BY
    lt.provider_league_id,
    players_count DESC,
    lt.team_name;

-- -----------------------------------------------------
-- 3) LOW COVERAGE TEAMS IN WAVE 1
-- -----------------------------------------------------
WITH league_teams AS (
    SELECT DISTINCT
        spp.external_league_id::text AS provider_league_id,
        spp.season::text AS season,
        tpm.team_id,
        t.name AS team_name,
        spp.external_team_id::text AS provider_team_id
    FROM staging.stg_provider_players spp
    LEFT JOIN public.team_provider_map tpm
           ON tpm.provider = spp.provider
          AND tpm.provider_team_id::text = spp.external_team_id::text
    LEFT JOIN public.teams t
           ON t.id = tpm.team_id
    WHERE spp.provider = 'api_football'
      AND spp.external_league_id::text IN ('39','62','78','79','89','140')
      AND spp.season::text = '2022'
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
    lt.provider_league_id,
    l.name AS league_name,
    lt.team_id,
    lt.team_name,
    lt.provider_team_id,
    COALESCE(tpc.players_count, 0) AS players_count
FROM league_teams lt
LEFT JOIN team_player_counts tpc
       ON tpc.team_id = lt.team_id
LEFT JOIN public.league_provider_map lpm
       ON lpm.provider = 'api_football'
      AND lpm.provider_league_id::text = lt.provider_league_id
LEFT JOIN public.leagues l
       ON l.id = lpm.league_id
WHERE COALESCE(tpc.players_count, 0) < 15
ORDER BY
    lt.provider_league_id,
    players_count ASC,
    lt.team_name;

-- -----------------------------------------------------
-- 4) LEAGUE KPI SUMMARY
-- -----------------------------------------------------
WITH league_teams AS (
    SELECT DISTINCT
        spp.external_league_id::text AS provider_league_id,
        spp.season::text AS season,
        tpm.team_id
    FROM staging.stg_provider_players spp
    LEFT JOIN public.team_provider_map tpm
           ON tpm.provider = spp.provider
          AND tpm.provider_team_id::text = spp.external_team_id::text
    WHERE spp.provider = 'api_football'
      AND spp.external_league_id::text IN ('39','62','78','79','89','140')
      AND spp.season::text = '2022'
),
team_player_counts AS (
    SELECT
        p.team_id,
        COUNT(*) AS players_count
    FROM public.players p
    WHERE p.team_id IS NOT NULL
    GROUP BY p.team_id
),
eval AS (
    SELECT
        lt.provider_league_id,
        lt.season,
        lt.team_id,
        COALESCE(tpc.players_count, 0) AS players_count
    FROM league_teams lt
    LEFT JOIN team_player_counts tpc
           ON tpc.team_id = lt.team_id
)
SELECT
    e.provider_league_id,
    l.name AS league_name,
    e.season,
    COUNT(*) AS teams_total,
    COUNT(*) FILTER (WHERE players_count >= 15) AS ready_teams,
    COUNT(*) FILTER (WHERE players_count BETWEEN 8 AND 14) AS partial_teams,
    COUNT(*) FILTER (WHERE players_count < 8) AS low_teams,
    ROUND(AVG(players_count)::numeric, 2) AS avg_players_per_team,
    MIN(players_count) AS min_players_per_team,
    MAX(players_count) AS max_players_per_team
FROM eval e
LEFT JOIN public.league_provider_map lpm
       ON lpm.provider = 'api_football'
      AND lpm.provider_league_id::text = e.provider_league_id
LEFT JOIN public.leagues l
       ON l.id = lpm.league_id
GROUP BY
    e.provider_league_id,
    l.name,
    e.season
ORDER BY e.provider_league_id;

-- -----------------------------------------------------
-- 5) WAVE 1 PUBLIC PLAYERS DETAIL
-- -----------------------------------------------------
WITH wave1_players AS (
    SELECT DISTINCT
        spp.external_league_id::text AS provider_league_id,
        spp.season::text AS season,
        ppm.player_id
    FROM staging.stg_provider_players spp
    JOIN public.player_provider_map ppm
      ON ppm.provider = spp.provider
     AND ppm.provider_player_id::text = spp.external_player_id::text
    WHERE spp.provider = 'api_football'
      AND spp.external_league_id::text IN ('39','62','78','79','89','140')
      AND spp.season::text = '2022'
)
SELECT
    wp.provider_league_id,
    l.name AS league_name,
    wp.season,
    p.id AS player_id,
    p.name,
    p.team_id,
    t.name AS team_name,
    p.ext_source,
    p.ext_player_id
FROM wave1_players wp
JOIN public.players p
  ON p.id = wp.player_id
LEFT JOIN public.teams t
  ON t.id = p.team_id
LEFT JOIN public.league_provider_map lpm
       ON lpm.provider = 'api_football'
      AND lpm.provider_league_id::text = wp.provider_league_id
LEFT JOIN public.leagues l
       ON l.id = lpm.league_id
ORDER BY
    wp.provider_league_id,
    team_name NULLS LAST,
    p.name;

-- -----------------------------------------------------
-- 6) FINAL WAVE 1 KPI
-- -----------------------------------------------------
WITH league_teams AS (
    SELECT DISTINCT
        spp.external_league_id::text AS provider_league_id,
        spp.season::text AS season,
        tpm.team_id
    FROM staging.stg_provider_players spp
    LEFT JOIN public.team_provider_map tpm
           ON tpm.provider = spp.provider
          AND tpm.provider_team_id::text = spp.external_team_id::text
    WHERE spp.provider = 'api_football'
      AND spp.external_league_id::text IN ('39','62','78','79','89','140')
      AND spp.season::text = '2022'
),
team_player_counts AS (
    SELECT
        p.team_id,
        COUNT(*) AS players_count
    FROM public.players p
    WHERE p.team_id IS NOT NULL
    GROUP BY p.team_id
),
eval AS (
    SELECT
        lt.team_id,
        COALESCE(tpc.players_count, 0) AS players_count
    FROM league_teams lt
    LEFT JOIN team_player_counts tpc
           ON tpc.team_id = lt.team_id
)
SELECT
    COUNT(*) AS wave1_teams_total,
    COUNT(*) FILTER (WHERE players_count >= 15) AS ready_teams,
    COUNT(*) FILTER (WHERE players_count BETWEEN 8 AND 14) AS partial_teams,
    COUNT(*) FILTER (WHERE players_count < 8) AS low_teams,
    ROUND(AVG(players_count)::numeric, 2) AS avg_players_per_team,
    MIN(players_count) AS min_players_per_team,
    MAX(players_count) AS max_players_per_team
FROM eval;