/*
MATCHMATRIX SQL 19_3_K
PC2 Execution Readiness Audit V1

CO TO JE:
- Audit skutečné spustitelnosti PC2 fronty.

K ČEMU TO JE:
- PC2 panel už umí spustit příkaz.
- Teď musíme u každé akce vědět, jestli má:
  1) planner job,
  2) ingest target,
  3) správný provider,
  4) podporovanou entitu,
  5) navrženou opravu.

KDE TO UVIDÍME:
- OPS Panel V18
- PC2 Command Center
- PC2 Execution Readiness

JAK SE TO VYUŽIJE:
- Spustit → ověřit → zapsat → opravit → vrátit nový job do fronty.
*/

CREATE OR REPLACE VIEW ops.v_pc2_execution_readiness_audit_v1 AS
WITH q AS (
    SELECT
        id AS command_id,
        sport_code,
        sport_name,
        target_layer,
        run_group,
        command_title,
        command_text,
        run_status,
        last_result
    FROM ops.pc2_run_command_queue
    WHERE run_group = '19_3_PC2_DEPENDENCY_QUEUE'
),
planner AS (
    SELECT
        run_group,
        sport_code,
        entity,
        COUNT(*) AS planner_jobs,
        COUNT(*) FILTER (WHERE status = 'pending') AS pending_jobs,
        COUNT(*) FILTER (WHERE status IN ('done','success')) AS done_jobs,
        COUNT(*) FILTER (WHERE status IN ('error','failed')) AS failed_jobs,
        COUNT(*) FILTER (WHERE provider_league_id IS NULL OR provider_league_id = '') AS missing_league_jobs,
        MAX(provider) AS sample_provider,
        MAX(entity) AS sample_entity
    FROM ops.ingest_planner
    WHERE run_group LIKE 'PC2_%'
    GROUP BY
        run_group,
        sport_code,
        entity
),
targets AS (
    SELECT
        sport_code,
        provider,
        COUNT(*) AS enabled_targets,
        COUNT(*) FILTER (
            WHERE provider_league_id IS NOT NULL
              AND provider_league_id <> ''
        ) AS targets_with_league
    FROM ops.ingest_targets
    WHERE enabled = true
    GROUP BY
        sport_code,
        provider
),
base AS (
    SELECT
        q.command_id,
        q.sport_code,
        q.sport_name,
        q.target_layer,
        q.command_title,
        q.command_text,
        q.run_status,
        q.last_result,

        COALESCE(p.sample_provider, 'UNKNOWN') AS provider,
        COALESCE(p.sample_entity,
            CASE
                WHEN q.target_layer = 'CORE' THEN 'fixtures'
                WHEN q.target_layer = 'PEOPLE' THEN 'players'
                WHEN q.target_layer = 'MEDIA' THEN 'media'
                WHEN q.target_layer = 'ODDS' THEN 'odds'
                ELSE 'unknown'
            END
        ) AS entity,

        COALESCE(p.planner_jobs, 0) AS planner_jobs,
        COALESCE(p.pending_jobs, 0) AS pending_jobs,
        COALESCE(p.done_jobs, 0) AS done_jobs,
        COALESCE(p.failed_jobs, 0) AS failed_jobs,
        COALESCE(p.missing_league_jobs, 0) AS missing_league_jobs,

        COALESCE(t.enabled_targets, 0) AS enabled_targets,
        COALESCE(t.targets_with_league, 0) AS targets_with_league

    FROM q
    LEFT JOIN planner p
        ON p.run_group =
            CASE
                WHEN q.target_layer = 'CORE' THEN 'PC2_CORE_' || q.sport_code
                WHEN q.target_layer = 'PEOPLE' THEN 'PC2_PEOPLE_' || q.sport_code
                WHEN q.target_layer = 'MEDIA' THEN 'PC2_MEDIA_' || q.sport_code
                WHEN q.target_layer = 'ODDS' THEN 'PC2_ODDS_' || q.sport_code
                ELSE q.run_group
            END
       AND p.sport_code = q.sport_code
    LEFT JOIN targets t
        ON t.sport_code = q.sport_code
       AND (
            p.sample_provider IS NULL
            OR t.provider = p.sample_provider
       )
)
SELECT
    command_id,
    sport_code,
    sport_name,
    target_layer,
    provider,
    entity,

    planner_jobs,
    pending_jobs,
    done_jobs,
    failed_jobs,
    missing_league_jobs,

    enabled_targets,
    targets_with_league,

    run_status,

    CASE
        WHEN planner_jobs = 0
            THEN 'PLANNER_JOB_MISSING'

        WHEN target_layer = 'CORE'
         AND targets_with_league = 0
            THEN 'TARGET_MISSING'

        WHEN target_layer = 'CORE'
         AND missing_league_jobs > 0
            THEN 'LEAGUE_ID_MISSING'

        WHEN provider = 'api_american_football'
         AND entity = 'players'
            THEN 'ROUTING_ERROR_PLAYERS_NOT_GENERIC'

        WHEN provider IN ('api_basketball','api_hockey','api_volleyball','api_baseball','api_cricket')
         AND entity = 'players'
            THEN 'VERIFY_PEOPLE_WORKER'

        WHEN pending_jobs > 0
            THEN 'READY_TO_RUN'

        WHEN failed_jobs > 0
            THEN 'FAILED_NEEDS_RETRY_OR_FIX'

        WHEN done_jobs > 0
            THEN 'DONE_OR_PARTIAL_DONE'

        ELSE 'REVIEW'
    END AS execution_readiness_status,

    CASE
        WHEN planner_jobs = 0
            THEN 'Doplnit job do ops.ingest_planner podle PC2 fronty.'

        WHEN target_layer = 'CORE'
         AND targets_with_league = 0
            THEN 'Doplnit ops.ingest_targets s provider_league_id pro daný sport/provider.'

        WHEN target_layer = 'CORE'
         AND missing_league_jobs > 0
            THEN 'Zrušit placeholder joby bez provider_league_id a vygenerovat joby z ops.ingest_targets.'

        WHEN provider = 'api_american_football'
         AND entity = 'players'
            THEN 'Přesměrovat AFB players na samostatný people worker nebo správný provider, ne GenericApiSportProvider.'

        WHEN provider IN ('api_basketball','api_hockey','api_volleyball','api_baseball','api_cricket')
         AND entity = 'players'
            THEN 'Ověřit, zda provider podporuje players přes unified ingest, nebo vytvořit custom people worker.'

        WHEN pending_jobs > 0
            THEN 'Spustit z panelu nebo nechat v PC2 frontě.'

        WHEN failed_jobs > 0
            THEN 'Zkontrolovat last_result/log, opravit parametr/provider a vrátit job na pending.'

        WHEN done_jobs > 0
            THEN 'Ověřit data v raw/staging/public a posunout sport do další vrstvy.'

        ELSE 'Ruční kontrola.'
    END AS next_fix_action,

    command_title,
    command_text,
    last_result

FROM base
ORDER BY
    CASE
        WHEN target_layer = 'CORE' THEN 1
        WHEN target_layer = 'PEOPLE' THEN 2
        WHEN target_layer = 'MEDIA' THEN 3
        WHEN target_layer = 'ODDS' THEN 4
        ELSE 9
    END,
    sport_code;


SELECT
    execution_readiness_status,
    COUNT(*) AS command_count
FROM ops.v_pc2_execution_readiness_audit_v1
GROUP BY execution_readiness_status
ORDER BY execution_readiness_status;


SELECT
    command_id,
    sport_code,
    target_layer,
    provider,
    entity,
    planner_jobs,
    pending_jobs,
    failed_jobs,
    execution_readiness_status,
    next_fix_action
FROM ops.v_pc2_execution_readiness_audit_v1
ORDER BY command_id;