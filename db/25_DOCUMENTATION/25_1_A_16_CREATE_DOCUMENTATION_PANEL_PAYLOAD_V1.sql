/*
===============================================================================
MATCHMATRIX STANDARDNÍ HLAVIČKA
===============================================================================

CO:
Vytváří jednotný datový kontrakt dokumentační vrstvy pro Python OPS panel.

K ČEMU:
- sjednocuje hlavní stav, KPI karty a historii do jednoho pohledu,
- poskytuje panelu stabilní technická pole,
- poskytuje zároveň kompletní JSONB payload,
- omezuje počet SQL dotazů prováděných panelem,
- zachovává oddělení databázové logiky od prezentační vrstvy,
- databázová data nemění.

KDE:
db/25_DOCUMENTATION/25_1_A_16_CREATE_DOCUMENTATION_PANEL_PAYLOAD_V1.sql

JAK:
Spustit celý skript v DBeaveru nad databází matchmatrix.

NÁVAZNOST:
- A15 vytváří dashboard, KPI karty a historický pohled.
- A16 vytváří jednotný kontrakt pro Python panel.
- Následující krok připojí kontrakt do hlavního Control Panelu.
===============================================================================
*/

BEGIN;


/*
-------------------------------------------------------------------------------
1. JEDNOTNÝ PANEL PAYLOAD
-------------------------------------------------------------------------------
Pohled vrací právě jeden řádek.

Obsahuje:
- základní technická pole pro rychlé použití,
- summary_payload,
- kpi_cards_payload,
- recent_history_payload,
- complete_payload.
*/

CREATE OR REPLACE VIEW ops.v_documentation_panel_payload_v1 AS
WITH dashboard AS
(
    SELECT
        d.*
    FROM ops.v_documentation_status_dashboard_v1 AS d
),
cards AS
(
    SELECT
        COALESCE(
            jsonb_agg(
                jsonb_build_object(
                    'card_order', c.card_order,
                    'kpi_code', c.kpi_code,
                    'kpi_name_cs', c.kpi_name_cs,
                    'kpi_value', c.kpi_value,
                    'kpi_unit', c.kpi_unit,
                    'kpi_status', c.kpi_status,
                    'kpi_note_cs', c.kpi_note_cs,
                    'snapshot_at', c.snapshot_at
                )
                ORDER BY c.card_order
            ),
            '[]'::jsonb
        ) AS kpi_cards_payload
    FROM ops.v_documentation_status_kpi_cards_v1 AS c
),
recent_history_source AS
(
    SELECT
        h.status_snapshot_pk,
        h.snapshot_at,
        h.health,
        h.previous_health,
        h.health_changed,
        h.health_score,
        h.final_status,

        h.documents_count,
        h.current_versions_count,
        h.sections_count,
        h.relations_count,

        h.checks_total,
        h.checks_passed,
        h.checks_success_percent,

        h.in_sync_count,
        h.synchronization_percent,

        h.sync_actions,
        h.sync_blockers,

        h.verification_warnings,
        h.verification_blockers,

        h.blockers_count,
        h.warnings_count,

        h.source_git_commit,
        h.source_git_dirty,
        h.created_at

    FROM ops.v_documentation_status_recent_history_v1 AS h
    ORDER BY
        h.snapshot_at DESC,
        h.status_snapshot_pk DESC
    LIMIT 30
),
history AS
(
    SELECT
        COALESCE(
            jsonb_agg(
                jsonb_build_object(
                    'status_snapshot_pk', h.status_snapshot_pk,
                    'snapshot_at', h.snapshot_at,
                    'health', h.health,
                    'previous_health', h.previous_health,
                    'health_changed', h.health_changed,
                    'health_score', h.health_score,
                    'final_status', h.final_status,

                    'documents_count', h.documents_count,
                    'current_versions_count', h.current_versions_count,
                    'sections_count', h.sections_count,
                    'relations_count', h.relations_count,

                    'checks_total', h.checks_total,
                    'checks_passed', h.checks_passed,
                    'checks_success_percent', h.checks_success_percent,

                    'in_sync_count', h.in_sync_count,
                    'synchronization_percent', h.synchronization_percent,

                    'sync_actions', h.sync_actions,
                    'sync_blockers', h.sync_blockers,

                    'verification_warnings', h.verification_warnings,
                    'verification_blockers', h.verification_blockers,

                    'blockers_count', h.blockers_count,
                    'warnings_count', h.warnings_count,

                    'source_git_commit', h.source_git_commit,
                    'source_git_dirty', h.source_git_dirty,
                    'created_at', h.created_at
                )
                ORDER BY
                    h.snapshot_at DESC,
                    h.status_snapshot_pk DESC
            ),
            '[]'::jsonb
        ) AS recent_history_payload
    FROM recent_history_source AS h
),
assembled AS
(
    SELECT
        d.status_snapshot_pk,
        d.snapshot_at,

        d.documentation_health,
        d.dashboard_status,
        d.final_status,
        d.operator_action_cz,

        d.documents_count,
        d.current_versions_count,
        d.sections_count,
        d.relations_count,

        d.checks_total,
        d.checks_passed,
        d.checks_success_percent,

        d.in_sync_count,
        d.synchronization_percent,

        d.sync_actions,
        d.total_blockers,
        d.total_warnings,

        d.source_git_commit,
        d.source_git_branch,
        d.source_git_dirty,

        d.snapshot_age_minutes,

        jsonb_build_object(
            'status_snapshot_pk', d.status_snapshot_pk,
            'snapshot_at', d.snapshot_at,

            'documentation_health', d.documentation_health,
            'dashboard_status', d.dashboard_status,
            'final_status', d.final_status,
            'operator_action_cz', d.operator_action_cz,

            'manifest_status', d.manifest_status,
            'verification_status', d.verification_status,
            'sync_status', d.sync_status,
            'control_cycle_status', d.control_cycle_status,

            'documents_count', d.documents_count,
            'current_versions_count', d.current_versions_count,
            'sections_count', d.sections_count,
            'relations_count', d.relations_count,
            'status_history_count', d.status_history_count,
            'import_runs_count', d.import_runs_count,

            'checks_total', d.checks_total,
            'checks_passed', d.checks_passed,
            'checks_success_percent', d.checks_success_percent,

            'in_sync_count', d.in_sync_count,
            'synchronization_percent', d.synchronization_percent,

            'sync_actions', d.sync_actions,
            'sync_blockers', d.sync_blockers,

            'verification_warnings', d.verification_warnings,
            'verification_blockers', d.verification_blockers,

            'unregistered_sources', d.unregistered_sources,
            'database_only_documents', d.database_only_documents,

            'manifest_candidates', d.manifest_candidates,
            'manifest_ready', d.manifest_ready,
            'manifest_blockers', d.manifest_blockers,
            'manifest_warnings', d.manifest_warnings,

            'control_stages', d.control_stages,
            'control_stages_successful',
                d.control_stages_successful,

            'total_blockers', d.total_blockers,
            'total_warnings', d.total_warnings,

            'source_git_commit', d.source_git_commit,
            'source_git_branch', d.source_git_branch,
            'source_git_dirty', d.source_git_dirty,

            'snapshot_age_minutes', d.snapshot_age_minutes
        ) AS summary_payload,

        c.kpi_cards_payload,
        h.recent_history_payload

    FROM dashboard AS d
    CROSS JOIN cards AS c
    CROSS JOIN history AS h
)
SELECT
    a.status_snapshot_pk,
    a.snapshot_at,

    a.documentation_health,
    a.dashboard_status,
    a.final_status,
    a.operator_action_cz,

    a.documents_count,
    a.current_versions_count,
    a.sections_count,
    a.relations_count,

    a.checks_total,
    a.checks_passed,
    a.checks_success_percent,

    a.in_sync_count,
    a.synchronization_percent,

    a.sync_actions,
    a.total_blockers,
    a.total_warnings,

    a.source_git_commit,
    a.source_git_branch,
    a.source_git_dirty,

    a.snapshot_age_minutes,

    jsonb_array_length(
        a.kpi_cards_payload
    ) AS kpi_cards_count,

    jsonb_array_length(
        a.recent_history_payload
    ) AS history_rows_count,

    a.summary_payload,
    a.kpi_cards_payload,
    a.recent_history_payload,

    jsonb_build_object(
        'contract_version', '1.0',
        'generated_at', now(),

        'summary', a.summary_payload,
        'kpi_cards', a.kpi_cards_payload,
        'recent_history', a.recent_history_payload
    ) AS complete_payload,

    now() AS payload_generated_at

FROM assembled AS a;


COMMENT ON VIEW ops.v_documentation_panel_payload_v1 IS
'Jednotný JSONB datový kontrakt dokumentační vrstvy pro MatchMatrix Python OPS panel.';


COMMIT;


/*
===============================================================================
2. OVĚŘENÍ ZÁKLADNÍCH POLÍ
===============================================================================
*/

SELECT
    status_snapshot_pk,
    snapshot_at,

    documentation_health,
    dashboard_status,
    final_status,

    documents_count,
    current_versions_count,

    checks_success_percent,
    synchronization_percent,

    sync_actions,
    total_blockers,
    total_warnings,

    source_git_dirty,

    kpi_cards_count,
    history_rows_count,

    operator_action_cz
FROM ops.v_documentation_panel_payload_v1;


/*
===============================================================================
3. OVĚŘENÍ JSON KONTRAKTU
===============================================================================
*/

SELECT
    complete_payload ->> 'contract_version'
        AS contract_version,

    complete_payload
        -> 'summary'
        ->> 'documentation_health'
        AS documentation_health,

    complete_payload
        -> 'summary'
        ->> 'dashboard_status'
        AS dashboard_status,

    jsonb_array_length(
        complete_payload -> 'kpi_cards'
    ) AS kpi_cards_count,

    jsonb_array_length(
        complete_payload -> 'recent_history'
    ) AS history_rows_count
FROM ops.v_documentation_panel_payload_v1;


/*
===============================================================================
4. UKÁZKA KPI KARET Z JSON PAYLOADU
===============================================================================
*/

SELECT
    card ->> 'kpi_code' AS kpi_code,
    card ->> 'kpi_name_cs' AS kpi_name_cs,
    card ->> 'kpi_value' AS kpi_value,
    card ->> 'kpi_unit' AS kpi_unit,
    card ->> 'kpi_status' AS kpi_status
FROM ops.v_documentation_panel_payload_v1 AS payload
CROSS JOIN LATERAL jsonb_array_elements(
    payload.complete_payload -> 'kpi_cards'
) AS card;


/*
===============================================================================
5. FINÁLNÍ STAV
===============================================================================
*/

SELECT
    'DOCUMENTATION_PANEL_PAYLOAD_READY'
        AS final_status;