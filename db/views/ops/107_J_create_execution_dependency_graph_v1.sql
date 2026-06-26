/*
MATCHMATRIX SQL 107_J
Create execution dependency graph V1

CO TO JE:
- Základní dependency graph pro orchestration workery.
- Definuje pořadí vrstev a závislostí mezi worker typy.

K ČEMU TO JE:
- Aby scheduler věděl, že některé kroky mají běžet až po jiných.
- Aby se nespouštěly PEOPLE/MEDIA vrstvy dříve než CORE.
- Aby vznikl základ pro orchestration chain.

NA CO TO BUDE:
- autonomous scheduler
- dependency-aware RUN NEXT
- orchestration chain execution
- future DAG scheduler
- multi-layer harvest flow

KDE TO POUŽIJEME:
- ops.worker_dependency_graph
- future dependency resolver
- future automation daemon
- C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V17_2.py
*/

CREATE TABLE IF NOT EXISTS ops.worker_dependency_graph (
    id BIGSERIAL PRIMARY KEY,

    dependency_code TEXT NOT NULL,

    parent_worker_code TEXT NOT NULL,
    child_worker_code TEXT NOT NULL,

    dependency_type TEXT NOT NULL DEFAULT 'must_run_before',

    layer_order INTEGER NOT NULL DEFAULT 100,
    child_layer_order INTEGER NOT NULL DEFAULT 100,

    is_required BOOLEAN NOT NULL DEFAULT true,
    is_enabled BOOLEAN NOT NULL DEFAULT true,

    notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_worker_dependency_graph UNIQUE (
        parent_worker_code,
        child_worker_code,
        dependency_type
    ),

    CONSTRAINT chk_worker_dependency_type CHECK (
        dependency_type IN (
            'must_run_before',
            'recommended_before',
            'optional_before',
            'blocks_if_failed'
        )
    )
);

CREATE INDEX IF NOT EXISTS ix_worker_dependency_parent
ON ops.worker_dependency_graph (parent_worker_code);

CREATE INDEX IF NOT EXISTS ix_worker_dependency_child
ON ops.worker_dependency_graph (child_worker_code);

COMMENT ON TABLE ops.worker_dependency_graph IS
'Dependency graph for MatchMatrix worker orchestration and future DAG scheduler.';