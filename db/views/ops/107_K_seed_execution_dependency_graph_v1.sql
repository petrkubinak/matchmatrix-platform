/*
MATCHMATRIX SQL 107_K
Seed execution dependency graph V1

CO TO JE:
- Základní orchestration dependency chain pro MatchMatrix.
- Definuje pořadí hlavních worker vrstev.

K ČEMU TO JE:
- Aby scheduler znal správné pořadí execution flow.
- Aby se MEDIA nebo PEOPLE nespouštěly před CORE ingestem.
- Aby vznikl základ dependency-aware orchestration scheduleru.

NA CO TO BUDE:
- autonomous scheduler
- orchestration chain execution
- dependency-aware RUN NEXT
- future DAG scheduler
- auto dependency resolution

KDE TO POUŽIJEME:
- ops.worker_dependency_graph
- future scheduler daemon
- orchestration planner
- C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V17_2.py
*/

INSERT INTO ops.worker_dependency_graph (
    dependency_code,
    parent_worker_code,
    child_worker_code,
    dependency_type,
    layer_order,
    child_layer_order,
    is_required,
    is_enabled,
    notes
)
VALUES

(
    'CORE_TO_PEOPLE',
    'CORE_INGEST_V3',
    'PEOPLE_PIPELINE_V22',
    'must_run_before',
    100,
    200,
    true,
    true,
    'People pipeline depends on canonical core fixtures/leagues/teams.'
),

(
    'CORE_TO_MEDIA',
    'CORE_INGEST_V3',
    'MEDIA_PIPELINE_V1',
    'recommended_before',
    100,
    300,
    true,
    true,
    'Media matching quality improves after canonical core ingest.'
),

(
    'MEDIA_PIPELINE_TO_MERGE',
    'MEDIA_PIPELINE_V1',
    'MEDIA_MERGE_V1',
    'must_run_before',
    300,
    400,
    true,
    true,
    'Media merge requires completed media pipeline ingest.'
),

(
    'MEDIA_MERGE_TO_ENTITY_MATCH',
    'MEDIA_MERGE_V1',
    'MATCH_ARTICLE_ENTITIES_V1',
    'must_run_before',
    400,
    500,
    true,
    true,
    'Entity matching depends on merged public articles.'
),

(
    'MEDIA_ENTITY_TO_PLAYER_MATCH',
    'MATCH_ARTICLE_ENTITIES_V1',
    'MATCH_ARTICLE_PLAYERS_V1',
    'recommended_before',
    500,
    600,
    true,
    true,
    'Player matching benefits from completed entity matching.'
)

ON CONFLICT (
    parent_worker_code,
    child_worker_code,
    dependency_type
)
DO NOTHING;