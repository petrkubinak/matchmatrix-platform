/*
MATCHMATRIX SQL 107_L
Create dependency resolver view V1

CO TO JE:
- Resolver view pro orchestration dependency graph.
- Spojuje worker registry + dependency graph.

K ČEMU TO JE:
- Aby scheduler viděl:
  parent worker,
  child worker,
  pořadí vrstev,
  runtime readiness,
  dependency readiness.

- Aby panel mohl zobrazovat orchestration chain.

NA CO TO BUDE:
- dependency-aware scheduler
- orchestration DAG
- future auto planner
- execution ordering
- autonomous orchestration

KDE TO POUŽIJEME:
- ops.v_dependency_resolver_v1
- future scheduler daemon
- panel orchestration tab
- C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V17_2.py
*/

CREATE OR REPLACE VIEW ops.v_dependency_resolver_v1 AS
SELECT
    d.dependency_code,

    d.parent_worker_code,
    pw.worker_name AS parent_worker_name,
    pw.layer_code AS parent_layer,
    pw.worker_status AS parent_worker_status,
    pw.is_enabled AS parent_enabled,
    pw.is_production_safe AS parent_production_safe,

    d.child_worker_code,
    cw.worker_name AS child_worker_name,
    cw.layer_code AS child_layer,
    cw.worker_status AS child_worker_status,
    cw.is_enabled AS child_enabled,
    cw.is_production_safe AS child_production_safe,

    d.dependency_type,

    d.layer_order,
    d.child_layer_order,

    d.is_required,
    d.is_enabled,

    CASE
        WHEN pw.worker_status IN ('runtime_tested', 'production_ready')
         AND cw.worker_status IN ('runtime_tested', 'production_ready')
         AND pw.is_enabled = true
         AND cw.is_enabled = true
         AND pw.is_production_safe = true
         AND cw.is_production_safe = true
        THEN true
        ELSE false
    END AS dependency_runtime_ready,

    CASE
        WHEN d.is_enabled = false
        THEN 'DEPENDENCY_DISABLED'

        WHEN pw.worker_status NOT IN ('runtime_tested', 'production_ready')
        THEN 'PARENT_NOT_RUNTIME_READY'

        WHEN cw.worker_status NOT IN ('runtime_tested', 'production_ready')
        THEN 'CHILD_NOT_RUNTIME_READY'

        WHEN pw.is_enabled = false
        THEN 'PARENT_DISABLED'

        WHEN cw.is_enabled = false
        THEN 'CHILD_DISABLED'

        WHEN pw.is_production_safe = false
        THEN 'PARENT_NOT_PRODUCTION_SAFE'

        WHEN cw.is_production_safe = false
        THEN 'CHILD_NOT_PRODUCTION_SAFE'

        ELSE 'DEPENDENCY_READY'
    END AS dependency_state

FROM ops.worker_dependency_graph d

LEFT JOIN ops.worker_registry pw
    ON pw.worker_code = d.parent_worker_code

LEFT JOIN ops.worker_registry cw
    ON cw.worker_code = d.child_worker_code;