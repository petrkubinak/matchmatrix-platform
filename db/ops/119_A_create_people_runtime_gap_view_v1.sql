/* ============================================================
MATCHMATRIX 119_A PEOPLE RUNTIME GAP VIEW V1

CO TO JE:
- View nad existujícími auditními tabulkami People vrstvy.
- Nevytváří novou auditní pravdu.
- Pouze spojuje runtime audit, provider people audit,
  people master provider matrix a worker registry.

K ČEMU TO JE:
- Ukáže, kde People vrstva skutečně stojí.
- Rozliší, jestli chybí provider, worker, parsing,
  public merge nebo downstream napojení.

KDE TO UVIDÍME:
- OPS Panel V18
- záložka PEOPLE
- později People Command Center

JAK SE TO VYUŽIJE:
- Výběr dalšího sportu/provideru.
- Plánování People backfillu.
- Příprava Media a Match Context vrstvy.
============================================================ */

CREATE OR REPLACE VIEW ops.v_people_runtime_gap_v1 AS
SELECT
    COALESCE(r.sport_code, p.sport_code, m.sport_code, w.sport_code) AS sport_code,
    COALESCE(r.provider, p.provider, m.people_provider, w.provider) AS provider,
    COALESCE(r.entity, p.entity, w.entity) AS entity,

    r.current_state,
    r.state_reason,

    r.panel_runner_exists,
    r.planner_target_exists,
    r.batch_target_exists,

    r.pull_confirmed,
    r.raw_confirmed,
    r.staging_confirmed,
    r.provider_map_confirmed,
    r.public_merge_confirmed,
    r.downstream_confirmed,

    p.endpoint_exists,
    p.endpoint_tested,
    p.endpoint_returns_data,
    p.usable_for_league,
    p.usable_for_team,
    p.usable_for_season,
    p.requires_pro,
    p.alternative_provider_needed,
    p.final_verdict AS provider_people_verdict,

    m.people_provider,
    m.players_supported,
    m.coaches_supported,
    m.profiles_supported,
    m.season_stats_supported,
    m.match_stats_supported,
    m.rankings_supported,
    m.photos_supported,
    m.provider_status AS people_matrix_status,

    w.pull_worker,
    w.parse_worker,
    w.merge_worker,
    w.runtime_ready,
    w.panel_ready,
    w.scheduler_ready,
    w.migration_state AS worker_migration_state,

    CASE
        WHEN COALESCE(p.endpoint_exists, false) = false
             AND COALESCE(m.players_supported, false) = false
            THEN 'PROVIDER_GAP'

        WHEN COALESCE(p.requires_pro, false) = true
            THEN 'SUBSCRIPTION_GAP'

        WHEN COALESCE(w.runtime_ready, false) = false
            THEN 'WORKER_GAP'

        WHEN COALESCE(r.pull_confirmed, false) = false
            THEN 'PULL_GAP'

        WHEN COALESCE(r.raw_confirmed, false) = false
            THEN 'RAW_GAP'

        WHEN COALESCE(r.staging_confirmed, false) = false
            THEN 'STAGING_GAP'

        WHEN COALESCE(r.public_merge_confirmed, false) = false
            THEN 'PUBLIC_MERGE_GAP'

        WHEN COALESCE(r.downstream_confirmed, false) = false
            THEN 'DOWNSTREAM_GAP'

        ELSE 'READY'
    END AS people_gap_status,

    COALESCE(
        r.next_action,
        p.next_step,
        m.notes,
        w.notes,
        'Prověřit People runtime ručně.'
    ) AS recommended_next_action,

    r.last_run_group,
    r.last_run_at,
    r.last_check_at,
    r.db_evidence_summary,
    r.last_log_summary

FROM ops.runtime_entity_audit r
FULL OUTER JOIN ops.provider_people_audit p
    ON p.provider = r.provider
   AND p.sport_code = r.sport_code
   AND p.entity = r.entity

FULL OUTER JOIN ops.people_master_provider_matrix m
    ON m.sport_code = COALESCE(r.sport_code, p.sport_code)
   AND m.people_provider = COALESCE(r.provider, p.provider)

FULL OUTER JOIN ops.unified_worker_registry w
    ON w.provider = COALESCE(r.provider, p.provider, m.people_provider)
   AND w.sport_code = COALESCE(r.sport_code, p.sport_code, m.sport_code)
   AND w.entity = COALESCE(r.entity, p.entity);