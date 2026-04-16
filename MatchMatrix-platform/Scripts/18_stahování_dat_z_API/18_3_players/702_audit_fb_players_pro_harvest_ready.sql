-- =====================================================================
-- MatchMatrix
-- FILE: 702_audit_fb_players_pro_harvest_ready.sql
-- PATH: C:\MatchMatrix-platform\db\audit\702_audit_fb_players_pro_harvest_ready.sql
--
-- Cíl:
-- PRO HARVEST READY audit pro FB players
--
-- Ukáže:
-- 1) planner scope league + season
-- 2) raw payload coverage
-- 3) players_import coverage
-- 4) public players coverage
-- 5) priority seznam pro první PRO lavinu
--
-- Poznámka:
-- tento audit NEHODNOTÍ free účet jako chybu
-- cílem je připravit harvest plán pro placený účet
-- =====================================================================

-- -----------------------------------------------------
-- 0) FB PLAYERS PLANNER SUMMARY
-- -----------------------------------------------------
SELECT
    provider,
    sport_code,
    entity,
    COUNT(*) AS planner_rows,
    COUNT(*) FILTER (WHERE status = 'pending') AS pending_rows,
    COUNT(*) FILTER (WHERE status = 'running') AS running_rows,
    COUNT(*) FILTER (WHERE status = 'done') AS done_rows,
    COUNT(*) FILTER (WHERE status = 'error') AS error_rows
FROM ops.ingest_planner
WHERE provider = 'api_football'
  AND entity = 'players'
GROUP BY provider, sport_code, entity
ORDER BY provider, sport_code, entity;

-- -----------------------------------------------------
-- 1) PLANNER SCOPE BY LEAGUE + SEASON
-- -----------------------------------------------------
SELECT
    p.id AS planner_id,
    p.provider,
    p.sport_code,
    p.entity,
    p.provider_league_id,
    l.name AS league_name,
    p.season,
    p.run_group,
    p.priority,
    p.status,
    p.attempts,
    p.next_run,
    p.updated_at
FROM ops.ingest_planner p
LEFT JOIN public.league_provider_map lpm
       ON lpm.provider = p.provider
      AND lpm.provider_league_id::text = p.provider_league_id::text
LEFT JOIN public.leagues l
       ON l.id = lpm.league_id
WHERE p.provider = 'api_football'
  AND p.entity = 'players'
ORDER BY
    CASE WHEN p.season = '2024' THEN 0 ELSE 1 END,
    p.priority,
    p.provider_league_id,
    p.season;

-- -----------------------------------------------------
-- 2) RAW PAYLOAD COVERAGE BY LEAGUE + SEASON
-- staging.stg_api_payloads
-- -----------------------------------------------------
SELECT
    sap.provider,
    sap.external_id AS provider_league_id,
    l.name AS league_name,
    sap.season,
    COUNT(*) AS raw_payload_rows,
    MIN(sap.id) AS first_payload_id,
    MAX(sap.id) AS last_payload_id
FROM staging.stg_api_payloads sap
LEFT JOIN public.league_provider_map lpm
       ON lpm.provider = sap.provider
      AND lpm.provider_league_id::text = sap.external_id::text
LEFT JOIN public.leagues l
       ON l.id = lpm.league_id
WHERE sap.provider = 'api_football'
  AND sap.entity_type = 'players'
  AND sap.endpoint_name = 'players'
GROUP BY
    sap.provider,
    sap.external_id,
    l.name,
    sap.season
ORDER BY
    sap.season DESC NULLS LAST,
    raw_payload_rows DESC,
    provider_league_id;

-- -----------------------------------------------------
-- 3) PLAYERS_IMPORT COVERAGE BY LEAGUE + SEASON
-- -----------------------------------------------------
SELECT
    pi.provider_code AS provider,
    pi.provider_league_id,
    COALESCE(pi.league_name, l.name) AS league_name,
    pi.season,
    COUNT(*) AS players_import_rows,
    COUNT(DISTINCT pi.provider_player_id) AS distinct_provider_players,
    COUNT(DISTINCT COALESCE(pi.provider_team_id, pi.team_provider_id)) AS distinct_provider_teams
FROM staging.players_import pi
LEFT JOIN public.league_provider_map lpm
       ON lpm.provider = pi.provider_code
      AND lpm.provider_league_id::text = pi.provider_league_id::text
LEFT JOIN public.leagues l
       ON l.id = lpm.league_id
WHERE pi.provider_code = 'api_football'
GROUP BY
    pi.provider_code,
    pi.provider_league_id,
    COALESCE(pi.league_name, l.name),
    pi.season
ORDER BY
    pi.season DESC NULLS LAST,
    distinct_provider_players DESC,
    provider_league_id;

-- -----------------------------------------------------
-- 4) STG_PROVIDER_PLAYERS COVERAGE BY LEAGUE + SEASON
-- -----------------------------------------------------
SELECT
    spp.provider,
    spp.external_league_id AS provider_league_id,
    COALESCE(spp.league_name, l.name) AS league_name,
    spp.season,
    COUNT(*) AS staging_player_rows,
    COUNT(DISTINCT spp.external_player_id) AS distinct_players,
    COUNT(DISTINCT spp.external_team_id) AS distinct_teams
FROM staging.stg_provider_players spp
LEFT JOIN public.league_provider_map lpm
       ON lpm.provider = spp.provider
      AND lpm.provider_league_id::text = spp.external_league_id::text
LEFT JOIN public.leagues l
       ON l.id = lpm.league_id
WHERE spp.provider = 'api_football'
GROUP BY
    spp.provider,
    spp.external_league_id,
    COALESCE(spp.league_name, l.name),
    spp.season
ORDER BY
    spp.season DESC NULLS LAST,
    distinct_players DESC,
    provider_league_id;

-- -----------------------------------------------------
-- 5) PUBLIC PLAYERS COVERAGE BY LEAGUE + SEASON
-- přes staging.stg_provider_players -> player_provider_map -> public.players
-- -----------------------------------------------------
WITH spp AS (
    SELECT DISTINCT
        provider,
        external_player_id,
        external_league_id,
        season,
        league_name
    FROM staging.stg_provider_players
    WHERE provider = 'api_football'
),
mapped AS (
    SELECT
        spp.external_league_id AS provider_league_id,
        spp.season,
        COALESCE(spp.league_name, l.name) AS league_name,
        ppm.player_id
    FROM spp
    LEFT JOIN public.player_provider_map ppm
           ON ppm.provider = spp.provider
          AND ppm.provider_player_id::text = spp.external_player_id::text
    LEFT JOIN public.league_provider_map lpm
           ON lpm.provider = spp.provider
          AND lpm.provider_league_id::text = spp.external_league_id::text
    LEFT JOIN public.leagues l
           ON l.id = lpm.league_id
)
SELECT
    provider_league_id,
    league_name,
    season,
    COUNT(*) FILTER (WHERE player_id IS NOT NULL) AS mapped_public_players,
    COUNT(DISTINCT player_id) FILTER (WHERE player_id IS NOT NULL) AS distinct_public_players
FROM mapped
GROUP BY
    provider_league_id,
    league_name,
    season
ORDER BY
    season DESC NULLS LAST,
    distinct_public_players DESC,
    provider_league_id;

-- -----------------------------------------------------
-- 6) END-TO-END COVERAGE MATRIX
-- planner + raw + import + staging + public
-- -----------------------------------------------------
WITH planner_scope AS (
    SELECT DISTINCT
        p.provider,
        p.provider_league_id::text AS provider_league_id,
        p.season::text AS season,
        p.run_group,
        p.priority,
        p.status
    FROM ops.ingest_planner p
    WHERE p.provider = 'api_football'
      AND p.entity = 'players'
),
raw_cov AS (
    SELECT
        sap.external_id::text AS provider_league_id,
        sap.season::text AS season,
        COUNT(*) AS raw_payload_rows
    FROM staging.stg_api_payloads sap
    WHERE sap.provider = 'api_football'
      AND sap.entity_type = 'players'
      AND sap.endpoint_name = 'players'
    GROUP BY sap.external_id, sap.season
),
import_cov AS (
    SELECT
        pi.provider_league_id::text AS provider_league_id,
        pi.season::text AS season,
        COUNT(DISTINCT pi.provider_player_id) AS import_players
    FROM staging.players_import pi
    WHERE pi.provider_code = 'api_football'
    GROUP BY pi.provider_league_id, pi.season
),
staging_cov AS (
    SELECT
        spp.external_league_id::text AS provider_league_id,
        spp.season::text AS season,
        COUNT(DISTINCT spp.external_player_id) AS staging_players
    FROM staging.stg_provider_players spp
    WHERE spp.provider = 'api_football'
    GROUP BY spp.external_league_id, spp.season
),
public_cov AS (
    SELECT
        spp.external_league_id::text AS provider_league_id,
        spp.season::text AS season,
        COUNT(DISTINCT ppm.player_id) AS public_players
    FROM staging.stg_provider_players spp
    LEFT JOIN public.player_provider_map ppm
           ON ppm.provider = spp.provider
          AND ppm.provider_player_id::text = spp.external_player_id::text
    WHERE spp.provider = 'api_football'
    GROUP BY spp.external_league_id, spp.season
)
SELECT
    ps.provider_league_id,
    l.name AS league_name,
    ps.season,
    ps.run_group,
    ps.priority,
    ps.status AS planner_status,
    COALESCE(rc.raw_payload_rows, 0) AS raw_payload_rows,
    COALESCE(ic.import_players, 0) AS import_players,
    COALESCE(sc.staging_players, 0) AS staging_players,
    COALESCE(pc.public_players, 0) AS public_players,
    CASE
        WHEN COALESCE(pc.public_players, 0) >= 300 THEN 'STRONG'
        WHEN COALESCE(pc.public_players, 0) >= 100 THEN 'USABLE'
        WHEN COALESCE(pc.public_players, 0) > 0 THEN 'STARTED'
        WHEN COALESCE(rc.raw_payload_rows, 0) > 0 THEN 'FETCH_ONLY'
        ELSE 'NOT_STARTED'
    END AS harvest_status
FROM planner_scope ps
LEFT JOIN raw_cov rc
       ON rc.provider_league_id = ps.provider_league_id
      AND rc.season = ps.season
LEFT JOIN import_cov ic
       ON ic.provider_league_id = ps.provider_league_id
      AND ic.season = ps.season
LEFT JOIN staging_cov sc
       ON sc.provider_league_id = ps.provider_league_id
      AND sc.season = ps.season
LEFT JOIN public_cov pc
       ON pc.provider_league_id = ps.provider_league_id
      AND pc.season = ps.season
LEFT JOIN public.league_provider_map lpm
       ON lpm.provider = 'api_football'
      AND lpm.provider_league_id::text = ps.provider_league_id
LEFT JOIN public.leagues l
       ON l.id = lpm.league_id
ORDER BY
    CASE
        WHEN ps.season = '2024' THEN 0
        WHEN ps.season = '2023' THEN 1
        WHEN ps.season = '2022' THEN 2
        ELSE 9
    END,
    ps.priority,
    COALESCE(pc.public_players, 0) DESC,
    ps.provider_league_id;

-- -----------------------------------------------------
-- 7) FIRST PRO LAVINA - PRIORITY LIST
-- co pustit jako první po upgradu
-- logika:
-- - 2024 první
-- - pending/error před done
-- - nízká public coverage první
-- -----------------------------------------------------
WITH coverage AS (
    SELECT
        p.id AS planner_id,
        p.provider_league_id::text AS provider_league_id,
        p.season::text AS season,
        p.run_group,
        p.priority,
        p.status,
        COALESCE((
            SELECT COUNT(DISTINCT spp.external_player_id)
            FROM staging.stg_provider_players spp
            WHERE spp.provider = 'api_football'
              AND spp.external_league_id::text = p.provider_league_id::text
              AND spp.season::text = p.season::text
        ), 0) AS staging_players
    FROM ops.ingest_planner p
    WHERE p.provider = 'api_football'
      AND p.entity = 'players'
)
SELECT
    c.planner_id,
    c.provider_league_id,
    l.name AS league_name,
    c.season,
    c.run_group,
    c.priority,
    c.status,
    c.staging_players,
    CASE
        WHEN c.season = '2024' AND c.staging_players = 0 THEN 'WAVE_1_TOP'
        WHEN c.season = '2024' AND c.staging_players < 100 THEN 'WAVE_1_FILL'
        WHEN c.season = '2023' AND c.staging_players = 0 THEN 'WAVE_2_TOP'
        WHEN c.season = '2023' AND c.staging_players < 100 THEN 'WAVE_2_FILL'
        WHEN c.season = '2022' AND c.staging_players = 0 THEN 'WAVE_3_TOP'
        ELSE 'LATER'
    END AS pro_wave_bucket
FROM coverage c
LEFT JOIN public.league_provider_map lpm
       ON lpm.provider = 'api_football'
      AND lpm.provider_league_id::text = c.provider_league_id
LEFT JOIN public.leagues l
       ON l.id = lpm.league_id
ORDER BY
    CASE
        WHEN c.season = '2024' THEN 0
        WHEN c.season = '2023' THEN 1
        WHEN c.season = '2022' THEN 2
        ELSE 9
    END,
    CASE
        WHEN c.status IN ('pending', 'error') THEN 0
        WHEN c.status = 'done' THEN 1
        ELSE 2
    END,
    c.staging_players ASC,
    c.priority,
    c.provider_league_id;

-- -----------------------------------------------------
-- 8) RUN GROUP READY SUMMARY
-- -----------------------------------------------------
WITH grouped AS (
    SELECT
        p.run_group,
        COUNT(*) AS planner_rows,
        COUNT(*) FILTER (WHERE p.status = 'pending') AS pending_rows,
        COUNT(*) FILTER (WHERE p.status = 'done') AS done_rows,
        COUNT(*) FILTER (WHERE p.status = 'error') AS error_rows
    FROM ops.ingest_planner p
    WHERE p.provider = 'api_football'
      AND p.entity = 'players'
    GROUP BY p.run_group
)
SELECT
    run_group,
    planner_rows,
    pending_rows,
    done_rows,
    error_rows
FROM grouped
ORDER BY planner_rows DESC, run_group;

-- -----------------------------------------------------
-- 9) FINAL PRO READY KPI
-- -----------------------------------------------------
WITH planner_scope AS (
    SELECT DISTINCT
        provider_league_id::text AS provider_league_id,
        season::text AS season
    FROM ops.ingest_planner
    WHERE provider = 'api_football'
      AND entity = 'players'
),
started AS (
    SELECT DISTINCT
        external_id::text AS provider_league_id,
        season::text AS season
    FROM staging.stg_api_payloads
    WHERE provider = 'api_football'
      AND entity_type = 'players'
      AND endpoint_name = 'players'
),
staged AS (
    SELECT DISTINCT
        external_league_id::text AS provider_league_id,
        season::text AS season
    FROM staging.stg_provider_players
    WHERE provider = 'api_football'
)
SELECT
    COUNT(*) AS planner_targets_total,
    COUNT(*) FILTER (
        WHERE (ps.provider_league_id, ps.season) IN (
            SELECT provider_league_id, season FROM started
        )
    ) AS targets_with_raw_fetch,
    COUNT(*) FILTER (
        WHERE (ps.provider_league_id, ps.season) IN (
            SELECT provider_league_id, season FROM staged
        )
    ) AS targets_with_staging_players,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE (ps.provider_league_id, ps.season) IN (
                SELECT provider_league_id, season FROM started
            )
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS pct_started,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE (ps.provider_league_id, ps.season) IN (
                SELECT provider_league_id, season FROM staged
            )
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS pct_staged
FROM planner_scope ps;