-- 714a_check_runtime_entity_audit_allowed_states.sql
-- Účel:
-- zjistit, jaké hodnoty current_state povoluje runtime_entity_audit

-- =========================================================
-- A) definice check constraintu
-- =========================================================
select
    c.conname as constraint_name,
    pg_get_constraintdef(c.oid) as constraint_definition
from pg_constraint c
join pg_class t
    on t.oid = c.conrelid
join pg_namespace n
    on n.oid = t.relnamespace
where n.nspname = 'ops'
  and t.relname = 'runtime_entity_audit'
  and c.conname = 'chk_runtime_entity_audit_state';

-- =========================================================
-- B) aktuálně používané stavy v tabulce
-- =========================================================
select
    current_state,
    count(*) as row_count
from ops.runtime_entity_audit
group by current_state
order by current_state;