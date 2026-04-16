-- 576_inspect_fb_entity_audit.sql
-- Účel:
-- 1) zobrazit strukturu tabulky ops.fb_entity_audit
-- 2) zobrazit všechny aktuální řádky pro FB audit
-- Spouštět v DBeaveru

-- 1) Struktura tabulky
select
    c.ordinal_position,
    c.column_name,
    c.data_type,
    c.is_nullable
from information_schema.columns c
where c.table_schema = 'ops'
  and c.table_name = 'fb_entity_audit'
order by c.ordinal_position;

-- 2) Aktuální obsah tabulky
select *
from ops.fb_entity_audit;