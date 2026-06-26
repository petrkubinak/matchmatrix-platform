/*
MATCHMATRIX SQL 17_9_E
FIND TEAM REFERENCE COLUMNS V1

CO TO JE:
- Audit všech sloupců v databázi, které pravděpodobně odkazují na public.teams.id.

K ČEMU TO JE:
- Než smažeme duplicitní týmy, musíme vědět, kde všude musíme přepsat missing_team_id na canonical_team_id.

KDE TO UVIDÍME:
- DBeaver výstup / OPS Data Quality.

JAK SE TO VYUŽIJE:
- Podle výsledku připravíme bezpečný merge update skript.
*/

CREATE OR REPLACE VIEW ops.v_team_reference_columns_v1 AS
SELECT
    table_schema,
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema IN ('public', 'staging', 'ops')
  AND (
        column_name = 'team_id'
     OR column_name = 'home_team_id'
     OR column_name = 'away_team_id'
     OR column_name = 'canonical_team_id'
     OR column_name = 'public_team_id'
     OR column_name = 'mapped_team_id'
     OR column_name = 'source_team_id'
     OR column_name = 'target_team_id'
     OR column_name LIKE '%team_id%'
  )
ORDER BY
    table_schema,
    table_name,
    column_name;