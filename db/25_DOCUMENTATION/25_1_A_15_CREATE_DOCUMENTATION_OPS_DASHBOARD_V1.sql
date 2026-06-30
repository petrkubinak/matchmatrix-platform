/*
===============================================================================
MATCHMATRIX STANDARDNÍ HLAVIČKA
===============================================================================

CO:
Vytváří panelovou SQL vrstvu nad stavovými snapshoty dokumentačního systému
MatchMatrix.

K ČEMU:
- poskytuje jeden souhrnný stav dokumentační vrstvy,
- poskytuje samostatné KPI karty pro OPS panel,
- poskytuje časovou historii pro tabulku nebo graf,
- převádí technické hodnoty na provozní stavy GOOD / WARNING / CRITICAL,
- doporučuje operátorovi další krok,
- neprovádí žádné změny dat.

KDE:
db/25_DOCUMENTATION/25_1_A_15_CREATE_DOCUMENTATION_OPS_DASHBOARD_V1.sql

JAK:
Spustit celý skript v DBeaveru nad databází matchmatrix.

NÁVAZNOST:
- A10 vytváří JSON status snapshot.
- A13 ukládá snapshot do documentation.status_snapshots.
- A15 zpřístupňuje poslední stav a historii pro OPS panel.
===============================================================================
*/

BEGIN;


/*
-------------------------------------------------------------------------------
1. HLAVNÍ DASHBOARD DOKUMENTAČNÍ VRSTVY
-------------------------------------------------------------------------------
Jeden řádek představuje poslední známý stav dokumentačního systému.
*/

CREATE OR REPLACE VIEW ops.v_documentation_status_dashboard_v1 AS
WITH latest AS
(
    SELECT
        s.*
    FROM documentation.v_latest_status_snapshot_v1 AS s
),
metrics AS
(
    SELECT
        l.status_snapshot_pk,
        l.snapshot_at,

        l.health AS documentation_health,
        l.final_status,

        l.manifest_status,
        l.verification_status,
        l.sync_status,
        l.control_cycle_status,

        l.documents_count,
        l.current_versions_count,
        l.sections_count,
        l.relations_count,
        l.status_history_count,
        l.import_runs_count,

        l.checks_total,
        l.checks_passed,

        CASE
            WHEN l.checks_total = 0
            THEN 0::numeric

            ELSE round(
                l.checks_passed::numeric
                * 100::numeric
                / l.checks_total::numeric,
                2
            )
        END AS checks_success_percent,

        l.in_sync_count,

        CASE
            WHEN l.documents_count = 0
            THEN 0::numeric

            ELSE round(
                l.in_sync_count::numeric
                * 100::numeric
                / l.documents_count::numeric,
                2
            )
        END AS synchronization_percent,

        l.sync_actions,
        l.sync_blockers,

        l.verification_warnings,
        l.verification_blockers,

        l.unregistered_sources,
        l.database_only_documents,

        l.manifest_candidates,
        l.manifest_ready,
        l.manifest_blockers,
        l.manifest_warnings,

        l.control_stages,
        l.control_stages_successful,

        l.blockers_count,
        l.warnings_count,

        (
            l.sync_blockers
            + l.verification_blockers
            + l.manifest_blockers
            + l.blockers_count
        ) AS total_blockers,

        (
            l.verification_warnings
            + l.manifest_warnings
            + l.warnings_count
        ) AS total_warnings,

        l.source_git_commit,
        l.source_git_branch,
        l.source_git_dirty,

        round(
            extract(
                epoch
                FROM now() - l.snapshot_at
            )::numeric / 60::numeric,
            2
        ) AS snapshot_age_minutes,

        l.snapshot_hash_sha256,
        l.created_at,
        l.created_by
    FROM latest AS l
)
SELECT
    m.*,

    CASE
        WHEN m.documentation_health = 'READY'
         AND m.total_blockers = 0
         AND m.sync_actions = 0
         AND m.total_warnings = 0
         AND m.source_git_dirty = false
        THEN 'GOOD'

        WHEN m.documentation_health = 'BLOCKED'
          OR m.total_blockers > 0
        THEN 'CRITICAL'

        ELSE 'WARNING'
    END AS dashboard_status,

    CASE
        WHEN m.total_blockers > 0
        THEN
            'Dokumentační vrstva obsahuje blokátory. '
            || 'Otevři integritní a synchronizační audit.'

        WHEN m.sync_actions > 0
        THEN
            'Synchronizační plán vyžaduje akci. '
            || 'Zkontroluj dokumenty mimo stav IN_SYNC.'

        WHEN m.total_warnings > 0
        THEN
            'Dokumentační vrstva obsahuje varování. '
            || 'Zkontroluj poslední status snapshot.'

        WHEN m.source_git_dirty = true
        THEN
            'Git pracovní strom není čistý. '
            || 'Zkontroluj změny a dokonči commit.'

        WHEN m.snapshot_age_minutes > 1440
        THEN
            'Poslední dokumentační snapshot je starší než 24 hodin. '
            || 'Spusť dokumentační status pipeline.'

        ELSE
            'Bez nutné akce. Dokumentační vrstva je plně synchronizovaná.'
    END AS operator_action_cz

FROM metrics AS m;


COMMENT ON VIEW ops.v_documentation_status_dashboard_v1 IS
'Jednořádkový dashboard posledního stavu dokumentační vrstvy MatchMatrix.';


/*
-------------------------------------------------------------------------------
2. KPI KARTY PRO OPS PANEL
-------------------------------------------------------------------------------
Každý řádek představuje jednu samostatnou KPI kartu.
*/

CREATE OR REPLACE VIEW ops.v_documentation_status_kpi_cards_v1 AS

SELECT
    1 AS card_order,
    'DOCUMENTATION_HEALTH'::text AS kpi_code,
    'Dokumentace'::text AS kpi_name_cs,

    CASE
        WHEN d.documentation_health = 'READY'
        THEN 100::numeric

        WHEN d.documentation_health = 'WARNING'
        THEN 60::numeric

        ELSE 0::numeric
    END AS kpi_value,

    '%'::text AS kpi_unit,

    CASE
        WHEN d.documentation_health = 'READY'
        THEN 'GOOD'

        WHEN d.documentation_health = 'WARNING'
        THEN 'WARNING'

        ELSE 'CRITICAL'
    END AS kpi_status,

    (
        'Celkový health stav dokumentační vrstvy: '
        || d.documentation_health
    )::text AS kpi_note_cs,

    d.snapshot_at

FROM ops.v_documentation_status_dashboard_v1 AS d


UNION ALL


SELECT
    2,
    'DOCUMENTS',
    'Dokumenty',
    d.documents_count::numeric,
    'dokumentů',
    CASE
        WHEN d.documents_count > 0
        THEN 'GOOD'
        ELSE 'CRITICAL'
    END,
    (
        'Počet kanonických dokumentů evidovaných '
        || 'v dokumentační databázi.'
    ),
    d.snapshot_at

FROM ops.v_documentation_status_dashboard_v1 AS d


UNION ALL


SELECT
    3,
    'CURRENT_VERSIONS',
    'Aktuální verze',
    d.current_versions_count::numeric,
    'verzí',
    CASE
        WHEN d.current_versions_count = d.documents_count
        THEN 'GOOD'
        ELSE 'CRITICAL'
    END,
    (
        'Každý aktivní dokument musí mít právě '
        || 'jednu aktuální verzi.'
    ),
    d.snapshot_at

FROM ops.v_documentation_status_dashboard_v1 AS d


UNION ALL


SELECT
    4,
    'DOCUMENT_SECTIONS',
    'Sekce',
    d.sections_count::numeric,
    'sekcí',
    'INFO',
    'Počet strukturovaných kapitol a podkapitol.',
    d.snapshot_at

FROM ops.v_documentation_status_dashboard_v1 AS d


UNION ALL


SELECT
    5,
    'DOCUMENT_RELATIONS',
    'Vazby',
    d.relations_count::numeric,
    'vazeb',
    'INFO',
    'Počet řízených vazeb mezi dokumenty.',
    d.snapshot_at

FROM ops.v_documentation_status_dashboard_v1 AS d


UNION ALL


SELECT
    6,
    'CHECKS_SUCCESS',
    'Integrita',
    d.checks_success_percent,
    '%',
    CASE
        WHEN d.checks_success_percent = 100
         AND d.total_blockers = 0
        THEN 'GOOD'

        WHEN d.checks_success_percent >= 95
        THEN 'WARNING'

        ELSE 'CRITICAL'
    END,
    (
        d.checks_passed::text
        || ' z '
        || d.checks_total::text
        || ' kontrol prošlo.'
    ),
    d.snapshot_at

FROM ops.v_documentation_status_dashboard_v1 AS d


UNION ALL


SELECT
    7,
    'SYNCHRONIZATION',
    'Synchronizace',
    d.synchronization_percent,
    '%',
    CASE
        WHEN d.synchronization_percent = 100
         AND d.sync_actions = 0
         AND d.sync_blockers = 0
        THEN 'GOOD'

        WHEN d.sync_blockers > 0
        THEN 'CRITICAL'

        ELSE 'WARNING'
    END,
    (
        d.in_sync_count::text
        || ' z '
        || d.documents_count::text
        || ' dokumentů je IN_SYNC.'
    ),
    d.snapshot_at

FROM ops.v_documentation_status_dashboard_v1 AS d


UNION ALL


SELECT
    8,
    'SYNC_ACTIONS',
    'Akční fronta',
    d.sync_actions::numeric,
    'akcí',
    CASE
        WHEN d.sync_actions = 0
        THEN 'GOOD'

        WHEN d.sync_actions <= 3
        THEN 'WARNING'

        ELSE 'CRITICAL'
    END,
    'Počet akcí požadovaných synchronizačním plánem.',
    d.snapshot_at

FROM ops.v_documentation_status_dashboard_v1 AS d


UNION ALL


SELECT
    9,
    'DOCUMENTATION_BLOCKERS',
    'Blokátory',
    d.total_blockers::numeric,
    'blokátorů',
    CASE
        WHEN d.total_blockers = 0
        THEN 'GOOD'
        ELSE 'CRITICAL'
    END,
    'Celkový počet blokátorů dokumentační vrstvy.',
    d.snapshot_at

FROM ops.v_documentation_status_dashboard_v1 AS d


UNION ALL


SELECT
    10,
    'DOCUMENTATION_WARNINGS',
    'Varování',
    d.total_warnings::numeric,
    'varování',
    CASE
        WHEN d.total_warnings = 0
        THEN 'GOOD'
        ELSE 'WARNING'
    END,
    'Celkový počet aktivních varování dokumentační vrstvy.',
    d.snapshot_at

FROM ops.v_documentation_status_dashboard_v1 AS d


UNION ALL


SELECT
    11,
    'GIT_STATE',
    'Git stav',

    CASE
        WHEN d.source_git_dirty = false
        THEN 100::numeric
        ELSE 0::numeric
    END,

    '%',

    CASE
        WHEN d.source_git_dirty = false
        THEN 'GOOD'
        ELSE 'WARNING'
    END,

    CASE
        WHEN d.source_git_dirty = false
        THEN 'Git pracovní strom byl při snapshotu čistý.'
        ELSE 'Git pracovní strom obsahoval neuzavřené změny.'
    END,

    d.snapshot_at

FROM ops.v_documentation_status_dashboard_v1 AS d;


COMMENT ON VIEW ops.v_documentation_status_kpi_cards_v1 IS
'KPI karty dokumentační vrstvy připravené pro zobrazení v OPS panelu.';


/*
-------------------------------------------------------------------------------
3. POSLEDNÍ HISTORIE PRO TABULKU NEBO GRAF
-------------------------------------------------------------------------------
*/

CREATE OR REPLACE VIEW ops.v_documentation_status_recent_history_v1 AS
WITH history AS
(
    SELECT
        h.status_snapshot_pk,
        h.snapshot_at,
        h.health,
        h.final_status,

        h.documents_count,
        h.current_versions_count,
        h.sections_count,
        h.relations_count,

        h.checks_total,
        h.checks_passed,
        h.checks_success_percent,

        h.in_sync_count,

        CASE
            WHEN h.documents_count = 0
            THEN 0::numeric

            ELSE round(
                h.in_sync_count::numeric
                * 100::numeric
                / h.documents_count::numeric,
                2
            )
        END AS synchronization_percent,

        h.sync_actions,
        h.sync_blockers,

        h.verification_warnings,
        h.verification_blockers,

        h.blockers_count,
        h.warnings_count,

        h.source_git_commit,
        h.source_git_dirty,

        CASE
            WHEN h.health = 'READY'
            THEN 100

            WHEN h.health = 'WARNING'
            THEN 60

            ELSE 0
        END AS health_score,

        lag(h.health) OVER (
            ORDER BY
                h.snapshot_at,
                h.status_snapshot_pk
        ) AS previous_health,

        h.created_at

    FROM ops.v_documentation_status_history_v1 AS h
)
SELECT
    status_snapshot_pk,
    snapshot_at,
    health,
    previous_health,

    CASE
        WHEN previous_health IS NULL
        THEN false

        WHEN previous_health <> health
        THEN true

        ELSE false
    END AS health_changed,

    health_score,
    final_status,

    documents_count,
    current_versions_count,
    sections_count,
    relations_count,

    checks_total,
    checks_passed,
    checks_success_percent,

    in_sync_count,
    synchronization_percent,

    sync_actions,
    sync_blockers,

    verification_warnings,
    verification_blockers,

    blockers_count,
    warnings_count,

    source_git_commit,
    source_git_dirty,
    created_at

FROM history
ORDER BY
    snapshot_at DESC,
    status_snapshot_pk DESC
LIMIT 100;


COMMENT ON VIEW ops.v_documentation_status_recent_history_v1 IS
'Posledních 100 stavových snapshotů dokumentační vrstvy pro OPS tabulku nebo graf.';


COMMIT;


/*
===============================================================================
4. OVĚŘENÍ
===============================================================================
*/

SELECT
    documentation_health,
    dashboard_status,
    documents_count,
    current_versions_count,
    sections_count,
    relations_count,
    checks_success_percent,
    synchronization_percent,
    sync_actions,
    total_blockers,
    total_warnings,
    source_git_dirty,
    operator_action_cz
FROM ops.v_documentation_status_dashboard_v1;


SELECT
    card_order,
    kpi_code,
    kpi_name_cs,
    kpi_value,
    kpi_unit,
    kpi_status,
    kpi_note_cs
FROM ops.v_documentation_status_kpi_cards_v1
ORDER BY card_order;


SELECT
    status_snapshot_pk,
    snapshot_at,
    health,
    previous_health,
    health_changed,
    health_score,
    checks_success_percent,
    synchronization_percent,
    source_git_commit,
    source_git_dirty
FROM ops.v_documentation_status_recent_history_v1
ORDER BY
    snapshot_at DESC,
    status_snapshot_pk DESC
LIMIT 10;


SELECT
    'DOCUMENTATION_OPS_DASHBOARD_READY' AS final_status;