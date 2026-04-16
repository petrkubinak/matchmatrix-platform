-- =====================================================================
-- MatchMatrix
-- FILE: 703_build_fb_players_pro_priority_buckets.sql
-- PATH: C:\MatchMatrix-platform\db\ops\703_build_fb_players_pro_priority_buckets.sql
--
-- Cíl:
-- vytvořit PRO priority buckety pro FB players harvest
--
-- Bucket logika:
-- WAVE_0_RETEST  = error/running/done bez coverage
-- WAVE_1_TOP     = top ligy s nejvyšší prioritou
-- WAVE_2_CORE    = evropský core backlog
-- WAVE_3_EXPANSION = širší expansion / nižší soutěže / play-off
-- DONE_KEEP      = už rozběhnuté a použitelné targety
-- =====================================================================

BEGIN;

-- -----------------------------------------------------
-- 1) TABLE
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS ops.fb_players_pro_priority_buckets (
    id bigserial PRIMARY KEY,
    planner_id bigint NOT NULL,
    provider text NOT NULL,
    sport_code text NOT NULL,
    entity text NOT NULL,
    provider_league_id text NOT NULL,
    league_name text NULL,
    season text NOT NULL,
    run_group text NULL,
    priority integer NULL,
    planner_status text NULL,
    staging_players integer NOT NULL DEFAULT 0,
    bucket_code text NOT NULL,
    bucket_order integer NOT NULL,
    note text NULL,
    created_at timestamptz NOT NULL DEFAULT NOW(),
    updated_at timestamptz NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_fb_players_pro_priority_buckets_planner
    ON ops.fb_players_pro_priority_buckets (planner_id);

-- -----------------------------------------------------
-- 2) REFRESH CONTENT
-- -----------------------------------------------------
TRUNCATE TABLE ops.fb_players_pro_priority_buckets;

WITH coverage AS (
    SELECT
        p.id AS planner_id,
        p.provider,
        p.sport_code,
        p.entity,
        p.provider_league_id::text AS provider_league_id,
        COALESCE(l.name, p.provider_league_id::text) AS league_name,
        p.season::text AS season,
        p.run_group,
        p.priority,
        p.status AS planner_status,
        COALESCE((
            SELECT COUNT(DISTINCT spp.external_player_id)
            FROM staging.stg_provider_players spp
            WHERE spp.provider = p.provider
              AND spp.external_league_id::text = p.provider_league_id::text
              AND spp.season::text = p.season::text
        ), 0) AS staging_players
    FROM ops.ingest_planner p
    LEFT JOIN public.league_provider_map lpm
           ON lpm.provider = p.provider
          AND lpm.provider_league_id::text = p.provider_league_id::text
    LEFT JOIN public.leagues l
           ON l.id = lpm.league_id
    WHERE p.provider = 'api_football'
      AND p.sport_code = 'FB'
      AND p.entity = 'players'
),
bucketed AS (
    SELECT
        c.*,
        CASE
            -- -------------------------------------------
            -- WAVE 0 = re-test problematických targetů
            -- -------------------------------------------
            WHEN c.planner_status IN ('error', 'running')
                 THEN 'WAVE_0_RETEST'

            WHEN c.planner_status = 'done'
                 AND c.staging_players = 0
                 THEN 'WAVE_0_RETEST'

            -- -------------------------------------------
            -- hotové a reálně použitelné targety
            -- -------------------------------------------
            WHEN c.planner_status = 'done'
                 AND c.staging_players >= 40
                 THEN 'DONE_KEEP'

            -- -------------------------------------------
            -- WAVE 1 = top ligy
            -- -------------------------------------------
            WHEN c.provider_league_id IN ('39', '78', '140', '79', '89', '62')
                 THEN 'WAVE_1_TOP'

            -- -------------------------------------------
            -- WAVE 2 = evropský core
            -- -------------------------------------------
            WHEN c.provider_league_id IN (
                '103','104','106','107','113','114','144','145','164','165',
                '203','204','207','208','218','219','244','245','261','286',
                '287','310','311','315','345','346','361','362','365','373',
                '374','382','383','664','865'
            )
                 THEN 'WAVE_2_CORE'

            -- -------------------------------------------
            -- WAVE 3 = expansion / lower / playoff
            -- -------------------------------------------
            ELSE 'WAVE_3_EXPANSION'
        END AS bucket_code
    FROM coverage c
)
INSERT INTO ops.fb_players_pro_priority_buckets (
    planner_id,
    provider,
    sport_code,
    entity,
    provider_league_id,
    league_name,
    season,
    run_group,
    priority,
    planner_status,
    staging_players,
    bucket_code,
    bucket_order,
    note
)
SELECT
    b.planner_id,
    b.provider,
    b.sport_code,
    b.entity,
    b.provider_league_id,
    b.league_name,
    b.season,
    b.run_group,
    b.priority,
    b.planner_status,
    b.staging_players,
    b.bucket_code,
    CASE b.bucket_code
        WHEN 'WAVE_0_RETEST' THEN 0
        WHEN 'WAVE_1_TOP' THEN 1
        WHEN 'WAVE_2_CORE' THEN 2
        WHEN 'WAVE_3_EXPANSION' THEN 3
        WHEN 'DONE_KEEP' THEN 9
        ELSE 99
    END AS bucket_order,
    CASE
        WHEN b.bucket_code = 'WAVE_0_RETEST' AND b.planner_status = 'error'
            THEN 'retry after PRO upgrade - previous error'
        WHEN b.bucket_code = 'WAVE_0_RETEST' AND b.planner_status = 'running'
            THEN 'cleanup/verify stuck running target'
        WHEN b.bucket_code = 'WAVE_0_RETEST' AND b.planner_status = 'done' AND b.staging_players = 0
            THEN 'done but zero coverage - must re-test'
        WHEN b.bucket_code = 'WAVE_1_TOP'
            THEN 'highest business priority core leagues'
        WHEN b.bucket_code = 'WAVE_2_CORE'
            THEN 'core European breadth wave'
        WHEN b.bucket_code = 'WAVE_3_EXPANSION'
            THEN 'expansion / lower leagues / playoffs'
        WHEN b.bucket_code = 'DONE_KEEP'
            THEN 'already harvested - keep as validated baseline'
        ELSE NULL
    END AS note
FROM bucketed b;

-- -----------------------------------------------------
-- 3) UPDATED_AT NORMALIZATION
-- -----------------------------------------------------
UPDATE ops.fb_players_pro_priority_buckets
SET updated_at = NOW();

COMMIT;

-- -----------------------------------------------------
-- 4) REVIEW
-- -----------------------------------------------------
SELECT
    bucket_code,
    COUNT(*) AS rows_count
FROM ops.fb_players_pro_priority_buckets
GROUP BY bucket_code
ORDER BY
    CASE bucket_code
        WHEN 'WAVE_0_RETEST' THEN 0
        WHEN 'WAVE_1_TOP' THEN 1
        WHEN 'WAVE_2_CORE' THEN 2
        WHEN 'WAVE_3_EXPANSION' THEN 3
        WHEN 'DONE_KEEP' THEN 9
        ELSE 99
    END;

SELECT
    bucket_code,
    planner_id,
    provider_league_id,
    league_name,
    season,
    run_group,
    priority,
    planner_status,
    staging_players,
    note
FROM ops.fb_players_pro_priority_buckets
ORDER BY bucket_order, season DESC, priority, provider_league_id;