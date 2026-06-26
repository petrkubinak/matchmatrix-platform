/*
MATCHMATRIX SQL 120_Q_T Context Engine Object Audit V1

CO TO JE:
- Audit všech DB objektů pro Context Resolver / Match Context Engine.

K ČEMU TO JE:
- Ověříme, že všechny funkce, view a tabulky z 120_Q_A až 120_Q_S opravdu existují.

KDE TO UVIDÍME:
- V DBeaveru jako přehled objektů v ops/public/staging.

JAK SE TO VYUŽIJE:
- Podle výsledku navážeme dalším krokem 120_Q_U.
*/

SELECT
    n.nspname AS schema_name,
    c.relname AS object_name,
    CASE c.relkind
        WHEN 'r' THEN 'TABLE'
        WHEN 'v' THEN 'VIEW'
        WHEN 'm' THEN 'MATERIALIZED_VIEW'
        WHEN 'S' THEN 'SEQUENCE'
        ELSE c.relkind::text
    END AS object_type
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname IN ('ops', 'public', 'staging')
  AND (
        c.relname ILIKE '%context%'
     OR c.relname ILIKE '%resolver%'
     OR c.relname ILIKE '%entity_registry%'
     OR c.relname ILIKE '%alias_registry%'
     OR c.relname ILIKE '%search%'
     OR c.relname ILIKE '%match_pair%'
  )
ORDER BY schema_name, object_type, object_name;


SELECT
    n.nspname AS schema_name,
    p.proname AS function_name,
    pg_get_function_arguments(p.oid) AS arguments,
    pg_get_function_result(p.oid) AS result_type
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname IN ('ops', 'public')
  AND (
        p.proname ILIKE '%context%'
     OR p.proname ILIKE '%resolver%'
     OR p.proname ILIKE '%search%'
     OR p.proname ILIKE '%match_pair%'
  )
ORDER BY schema_name, function_name;