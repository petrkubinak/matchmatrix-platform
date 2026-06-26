/*
MATCHMATRIX SQL 111_R
SPORT COMPLETION DASHBOARD SOURCE AUDIT V1

CO TO JE:
- Audit zdrojů pro nový panel Sport Completion Dashboard.

K ČEMU TO JE:
- Ověříme, jaké view a tabulky už máme připravené.
- Nebudeme vytvářet duplicity.

KDE TO UVIDÍME:
- DBeaver.

JAK SE TO VYUŽIJE:
- Na základě výsledku vytvoříme panel V17.11.03.
*/

SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema = 'ops'
AND (
       table_name ILIKE '%sport_completion%'
    OR table_name ILIKE '%completion%'
    OR table_name ILIKE '%dashboard%'
    OR table_name ILIKE '%summary%'
)
ORDER BY table_name;