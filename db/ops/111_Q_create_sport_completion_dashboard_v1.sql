/*
MATCHMATRIX SQL 111_Q
CREATE SPORT COMPLETION DASHBOARD V1

CO TO JE:
- Jeden přehled dokončenosti po sportech.

K ČEMU TO JE:
- Aby panel ukázal, který sport má slabý CORE / PEOPLE / MEDIA / ODDS.
- Aby AI doporučení později vědělo, co zvedne projekt nejvíc.

KDE TO UVIDÍME:
- OPS panel V17.11.03
- sekce: DOKONČENOST SPORTŮ

JAK SE TO VYUŽIJE:
- doporučená akce nebude jen podle workeru,
  ale podle nejslabšího sportu a nejslabší vrstvy.
*/

CREATE OR REPLACE VIEW ops.v_sport_completion_dashboard_v1 AS
WITH sports AS (
    SELECT
        LOWER(sport_code) AS sport_code,
        sport_name,
        priority,
        mode,
        daily_request_budget
    FROM ops.sports_import_plan
    WHERE enabled = TRUE
),
completion AS (
    SELECT
        LOWER(sport_code) AS sport_code,
        entity_count,
        ready_cnt,
        near_ready_cnt,
        not_ready_cnt,
        core_ready_cnt,
        people_ready_cnt,
        people_near_ready_cnt,
        people_not_ready_cnt,
        sport_readiness,
        top_priority_rank
    FROM ops.v_sport_completion_summary
),
coverage AS (
    SELECT
        LOWER(sport_code) AS sport_code,

        SUM(CASE WHEN entity IN ('leagues','teams','fixtures','matches','standings')
                 THEN ready_count ELSE 0 END) AS core_ready,

        SUM(CASE WHEN entity IN ('leagues','teams','fixtures','matches','standings')
                 THEN ready_count + missing_count + paid_count ELSE 0 END) AS core_total,

        SUM(CASE WHEN entity IN ('players','coaches','player_stats','player_profiles','player_season_stats')
                 THEN ready_count ELSE 0 END) AS people_ready,

        SUM(CASE WHEN entity IN ('players','coaches','player_stats','player_profiles','player_season_stats')
                 THEN ready_count + missing_count + paid_count ELSE 0 END) AS people_total,

        SUM(CASE WHEN entity IN ('articles','news','videos','highlights','comments','media')
                 THEN ready_count ELSE 0 END) AS media_ready,

        SUM(CASE WHEN entity IN ('articles','news','videos','highlights','comments','media')
                 THEN ready_count + missing_count + paid_count ELSE 0 END) AS media_total,

        SUM(CASE WHEN entity IN ('odds','bookmakers','bets')
                 THEN ready_count ELSE 0 END) AS odds_ready,

        SUM(CASE WHEN entity IN ('odds','bookmakers','bets')
                 THEN ready_count + missing_count + paid_count ELSE 0 END) AS odds_total
    FROM ops.v_coverage_priority_dashboard_v1
    GROUP BY LOWER(sport_code)
),
budget AS (
    SELECT
        LOWER(sport_code) AS sport_code,
        requests_used,
        requests_limit,
        requests_remaining,
        used_pct,
        budget_status
    FROM ops.v_sport_daily_budget_monitor_v1
),
pending_core AS (
    SELECT
        LOWER(sport_code) AS sport_code,
        SUM(pending_count) AS core_pending
    FROM ops.v_smart_core_quota_queue_v1
    GROUP BY LOWER(sport_code)
)
SELECT
    s.sport_code,
    s.sport_name,
    s.mode,

    ROUND(
        CASE WHEN COALESCE(cov.core_total, 0) > 0
             THEN cov.core_ready::numeric / cov.core_total::numeric * 100
             ELSE COALESCE(c.core_ready_cnt, 0)::numeric
        END, 2
    ) AS core_pct,

    ROUND(
        CASE WHEN COALESCE(cov.people_total, 0) > 0
             THEN cov.people_ready::numeric / cov.people_total::numeric * 100
             ELSE COALESCE(c.people_ready_cnt, 0)::numeric
        END, 2
    ) AS people_pct,

    ROUND(
        CASE WHEN COALESCE(cov.media_total, 0) > 0
             THEN cov.media_ready::numeric / cov.media_total::numeric * 100
             ELSE 0
        END, 2
    ) AS media_pct,

    ROUND(
        CASE WHEN COALESCE(cov.odds_total, 0) > 0
             THEN cov.odds_ready::numeric / cov.odds_total::numeric * 100
             ELSE 0
        END, 2
    ) AS odds_pct,

    ROUND((
        COALESCE(
            CASE WHEN COALESCE(cov.core_total, 0) > 0
                 THEN cov.core_ready::numeric / cov.core_total::numeric * 100
                 ELSE COALESCE(c.core_ready_cnt, 0)::numeric
            END, 0
        )
        +
        COALESCE(
            CASE WHEN COALESCE(cov.people_total, 0) > 0
                 THEN cov.people_ready::numeric / cov.people_total::numeric * 100
                 ELSE COALESCE(c.people_ready_cnt, 0)::numeric
            END, 0
        )
        +
        COALESCE(
            CASE WHEN COALESCE(cov.media_total, 0) > 0
                 THEN cov.media_ready::numeric / cov.media_total::numeric * 100
                 ELSE 0
            END, 0
        )
        +
        COALESCE(
            CASE WHEN COALESCE(cov.odds_total, 0) > 0
                 THEN cov.odds_ready::numeric / cov.odds_total::numeric * 100
                 ELSE 0
            END, 0
        )
    ) / 4, 2) AS total_pct,

    COALESCE(pc.core_pending, 0) AS core_pending,
    COALESCE(b.requests_used, 0) AS requests_used,
    COALESCE(b.requests_limit, 0) AS requests_limit,
    COALESCE(b.requests_remaining, 0) AS requests_remaining,
    COALESCE(b.used_pct, 0) AS budget_used_pct,
    COALESCE(b.budget_status, 'UNKNOWN') AS budget_status,

    COALESCE(c.sport_readiness, 'UNKNOWN') AS sport_readiness,
    COALESCE(c.top_priority_rank, 999) AS top_priority_rank,

    CASE
        WHEN COALESCE(pc.core_pending, 0) > 0 THEN 'CORE_HARVEST'
        WHEN COALESCE(c.people_not_ready_cnt, 0) > 0 THEN 'PEOPLE_LAYER'
        WHEN COALESCE(cov.media_total, 0) > 0 AND COALESCE(cov.media_ready, 0) < COALESCE(cov.media_total, 0) THEN 'MEDIA_LAYER'
        WHEN COALESCE(cov.odds_total, 0) > 0 AND COALESCE(cov.odds_ready, 0) < COALESCE(cov.odds_total, 0) THEN 'ODDS_LAYER'
        ELSE 'MONITOR'
    END AS recommended_focus

FROM sports s
LEFT JOIN completion c ON c.sport_code = s.sport_code
LEFT JOIN coverage cov ON cov.sport_code = s.sport_code
LEFT JOIN budget b ON b.sport_code = s.sport_code
LEFT JOIN pending_core pc ON pc.sport_code = s.sport_code
ORDER BY
    total_pct ASC,
    s.priority DESC,
    s.sport_code;