/*
MATCHMATRIX SQL 111_R
AUDIT EXISTING AI RECOMMENDATION OBJECTS V1

CO TO JE:
- Kontrola, jestli už v OPS existují tabulky nebo view pro AI doporučení / AI akce.

K ČEMU TO JE:
- Abychom zbytečně nevytvořili duplicitní tabulku.
- Nejdřív ověříme aktuální stav databáze.

KDE TO UVIDÍME:
- Výsledek v DBeaveru.

JAK SE TO VYUŽIJE:
- Podle výsledku rozhodneme, jestli:
  1) rozšíříme existující objekt,
  2) vytvoříme nové view,
  3) nebo založíme novou tabulku pro 111_R.
*/

SELECT
    n.nspname AS schema_name,
    c.relname AS object_name,
    CASE c.relkind
        WHEN 'r' THEN 'TABLE'
        WHEN 'v' THEN 'VIEW'
        WHEN 'm' THEN 'MATERIALIZED VIEW'
        ELSE c.relkind::text
    END AS object_type
FROM pg_class c
JOIN pg_namespace n
    ON n.oid = c.relnamespace
WHERE n.nspname = 'ops'
  AND (
        c.relname ILIKE '%ai%'
     OR c.relname ILIKE '%recommend%'
     OR c.relname ILIKE '%action%'
     OR c.relname ILIKE '%queue%'
     OR c.relname ILIKE '%brain%'
     OR c.relname ILIKE '%autonomous%'
  )
ORDER BY
    object_type,
    object_name;