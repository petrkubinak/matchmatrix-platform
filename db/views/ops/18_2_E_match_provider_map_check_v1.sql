/*
MATCHMATRIX SQL 18_2_E Match Provider Map Check V1

CO TO JE:
- Kontrola, jestli v DB existuje provider map tabulka pro zápasy.

K ČEMU TO JE:
- Před smazáním duplicit musíme ověřit, zda duplicate_match_id není navázané v match_provider_map.

KDE TO UVIDÍME:
- V DBeaveru jako seznam tabulek/sloupců, které obsahují match provider vazby.

JAK SE TO VYUŽIJE:
- Pokud žádná match provider map tabulka neexistuje, můžeme přejít na safe delete plan.
*/

SELECT
    table_schema,
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema IN ('public', 'ops', 'staging')
  AND (
        column_name ILIKE '%match%provider%'
     OR column_name ILIKE '%provider%match%'
     OR column_name ILIKE '%ext_match%'
     OR column_name ILIKE '%fixture%'
  )
ORDER BY
    table_schema,
    table_name,
    ordinal_position;