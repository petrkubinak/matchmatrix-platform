/*
MATCHMATRIX SQL 111_R
CREATE SPORT COMPLETION DASHBOARD V2

CO TO JE:
- Nové view pro přesnější dashboard dokončenosti sportů.
- Sjednocuje sport_code z dlouhých názvů na interní kódy, např. football -> FB.

K ČEMU TO JE:
- Aby panel neukazoval zkreslený stav typu football 25 %, když auditní pravda je ve sport_code FB.
- Aby se dashboard opíral o ops.sport_completion_audit.

KDE TO UVIDÍME:
- V DBeaveru jako ops.v_sport_completion_dashboard_v2.
- Později v panelu V17.11.04.

JAK SE TO VYUŽIJE:
- Panel bude číst V2 místo V1.
- 111_S Autonomous OPS Brain použije stejné pořadí priorit pro rozhodování.
*/

CREATE OR REPLACE VIEW ops.v_sport_completion_dashboard_v2 AS
WITH normalized AS (
    SELECT
        CASE
            WHEN sport_code = 'football' THEN 'FB'
            WHEN sport_code = 'hockey' THEN 'HK'
            WHEN sport_code = 'basketball' THEN 'BK'
            WHEN sport_code = 'tennis' THEN 'TN'
            WHEN sport_code = 'volleyball' THEN 'VB'
            WHEN sport_code = 'handball' THEN 'HB'
            WHEN sport_code = 'baseball' THEN 'BSB'
            WHEN sport_code = 'rugby' THEN 'RGB'
            WHEN sport_code = 'cricket' THEN 'CK'
            WHEN sport_code = 'american_football' THEN 'AFB'
            WHEN sport_code = 'field_hockey' THEN 'FH'
            WHEN sport_code = 'mma' THEN 'MMA'
            WHEN sport_code = 'esports' THEN 'ESP'
            WHEN sport_code = 'darts' THEN 'DRT'
            ELSE sport_code
        END AS sport_code,
        entity,
        layer_type,
        current_status,
        production_readiness,
        provider_primary,
        db_layer_ready,
        planner_ready,
        queue_ready,
        public_ready,
        key_gap,
        next_step,
        evidence_note,
        priority_rank,
        updated_at
    FROM ops.sport_completion_audit
),
layer_scores AS (
    SELECT
        sport_code,

        ROUND(
            100.0 * COUNT(*) FILTER (
                WHERE layer_type = 'core'
                  AND production_readiness IN ('READY', 'NEAR_READY')
            ) / NULLIF(COUNT(*) FILTER (WHERE layer_type = 'core'), 0),
            2
        ) AS core_pct,

        ROUND(
            100.0 * COUNT(*) FILTER (
                WHERE layer_type = 'people'
                  AND production_readiness IN ('READY', 'NEAR_READY')
            ) / NULLIF(COUNT(*) FILTER (WHERE layer_type = 'people'), 0),
            2
        ) AS people_pct,

        ROUND(
            100.0 * COUNT(*) FILTER (
                WHERE layer_type = 'media'
                  AND production_readiness IN ('READY', 'NEAR_READY')
            ) / NULLIF(COUNT(*) FILTER (WHERE layer_type = 'media'), 0),
            2
        ) AS media_pct,

        ROUND(
            100.0 * COUNT(*) FILTER (
                WHERE layer_type IN ('odds', 'extension')
                  AND production_readiness IN ('READY', 'NEAR_READY')
            ) / NULLIF(COUNT(*) FILTER (WHERE layer_type IN ('odds', 'extension')), 0),
            2
        ) AS odds_pct,

        COUNT(*) FILTER (
            WHERE layer_type = 'core'
              AND current_status NOT IN ('DONE', 'CONFIRMED')
        ) AS core_pending,

        MIN(priority_rank) AS top_priority_rank,

        MAX(updated_at) AS updated_at
    FROM normalized
    GROUP BY sport_code
),
final_calc AS (
    SELECT
        sport_code,

        COALESCE(core_pct, 0) AS core_pct,
        COALESCE(people_pct, 0) AS people_pct,
        COALESCE(media_pct, 0) AS media_pct,
        COALESCE(odds_pct, 0) AS odds_pct,
        COALESCE(core_pending, 0) AS core_pending,
        COALESCE(top_priority_rank, 999) AS top_priority_rank,
        updated_at,

        ROUND(
            (
                COALESCE(core_pct, 0) * 0.40
              + COALESCE(people_pct, 0) * 0.25
              + COALESCE(media_pct, 0) * 0.20
              + COALESCE(odds_pct, 0) * 0.15
            ),
            2
        ) AS total_pct
    FROM layer_scores
)
SELECT
    f.sport_code,

    CASE f.sport_code
        WHEN 'FB' THEN 'Football'
        WHEN 'HK' THEN 'Hockey'
        WHEN 'BK' THEN 'Basketball'
        WHEN 'TN' THEN 'Tennis'
        WHEN 'VB' THEN 'Volleyball'
        WHEN 'HB' THEN 'Handball'
        WHEN 'BSB' THEN 'Baseball'
        WHEN 'RGB' THEN 'Rugby'
        WHEN 'CK' THEN 'Cricket'
        WHEN 'AFB' THEN 'American Football'
        WHEN 'FH' THEN 'Field Hockey'
        WHEN 'MMA' THEN 'MMA'
        WHEN 'ESP' THEN 'Esports'
        WHEN 'DRT' THEN 'Darts'
        ELSE f.sport_code
    END AS sport_name,

    'historical_backfill'::text AS mode,

    f.core_pct,
    f.people_pct,
    f.media_pct,
    f.odds_pct,
    f.total_pct,
    f.core_pending,

    COALESCE(b.requests_used, 0) AS requests_used,
    COALESCE(b.requests_limit, 0) AS requests_limit,
    COALESCE(b.requests_remaining, 0) AS requests_remaining,
    COALESCE(b.used_pct, 0) AS budget_used_pct,
    COALESCE(b.budget_status, 'UNKNOWN') AS budget_status,

    CASE
        WHEN f.total_pct >= 85 THEN 'SPORT_READY'
        WHEN f.total_pct >= 60 THEN 'SPORT_NEAR_READY'
        WHEN f.total_pct >= 30 THEN 'PARTIAL'
        ELSE 'DATA_GAP'
    END AS sport_readiness,

    f.top_priority_rank,

    CASE
        WHEN f.core_pct < 100 THEN 'CORE_HARVEST'
        WHEN f.people_pct < 100 THEN 'PEOPLE_LAYER'
        WHEN f.media_pct < 100 THEN 'MEDIA_LAYER'
        WHEN f.odds_pct < 100 THEN 'ODDS_LAYER'
        ELSE 'READY'
    END AS recommended_focus,

    f.updated_at
FROM final_calc f
LEFT JOIN ops.v_sport_daily_budget_monitor_v1 b
    ON b.sport_code = f.sport_code
ORDER BY
    f.top_priority_rank ASC,
    f.total_pct ASC,
    f.sport_code ASC;