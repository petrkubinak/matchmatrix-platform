/*
MATCHMATRIX SQL 111_R
SPORT COMPLETION DASHBOARD COLUMNS AUDIT V1

CO TO JE:
- Kontrola sloupců view ops.v_sport_completion_dashboard_v1.

K ČEMU TO JE:
- Abychom přesně věděli, jaké názvy sloupců použít v panelu V17.11.03.

KDE TO UVIDÍME:
- Výsledek v DBeaveru.

JAK SE TO VYUŽIJE:
- Podle těchto sloupců doplníme SPORT COMPLETION DASHBOARD do panelu.
*/

SELECT
    table_schema,
    table_name,
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'ops'
  AND table_name = 'v_sport_completion_dashboard_v1'
ORDER BY ordinal_position;