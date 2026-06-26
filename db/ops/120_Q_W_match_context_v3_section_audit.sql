/*
MATCHMATRIX SQL 120_Q_W Match Context V3 Section Audit

CO TO JE:
- Audit přesného výstupu fn_match_context_engine_v3 podle sekcí.

K ČEMU TO JE:
- Zjistíme, jestli duplicita vzniká v LAST_5_MATCHES nebo při UNION skládání sekcí.

KDE TO UVIDÍME:
- V DBeaveru.

JAK SE TO VYUŽIJE:
- Podle výsledku opravíme V3 funkci.
*/

SELECT
    section_name,
    item_order,
    item_value,
    COUNT(*) AS row_count
FROM ops.fn_match_context_engine_v3(
    'Barcelona',
    'Real Madrid',
    1
)
GROUP BY
    section_name,
    item_order,
    item_value
HAVING COUNT(*) > 1
ORDER BY
    section_name,
    item_order;