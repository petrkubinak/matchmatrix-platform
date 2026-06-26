/*
MATCHMATRIX SQL 17_9_K
TEAM INSERT GUARD SUMMARY V1

CO TO JE:
- Souhrn ochranné vrstvy proti novým duplicitám týmů.

K ČEMU TO JE:
- Ukáže, kolik záznamů hlídá provider guard, name guard a hold guard.

KDE TO UVIDÍME:
- OPS Panel V18 → DATA QUALITY / TEAM DUPLICATE PREVENTION.

JAK SE TO VYUŽIJE:
- Kontrola před spuštěním ingest workerů.
- Pokud je hold_guard_rows > 0, guard je aktivní a chrání ruční HOLD případy.
*/

CREATE OR REPLACE VIEW ops.v_team_insert_guard_summary_v1 AS
SELECT
    now() AS checked_at,

    COUNT(*) FILTER (
        WHERE guard_type = 'EXISTING_PROVIDER_ID'
    ) AS provider_guard_rows,

    COUNT(*) FILTER (
        WHERE guard_type = 'EXISTING_NAME_SPORT'
    ) AS name_guard_rows,

    COUNT(*) FILTER (
        WHERE guard_type = 'HOLD_NAME'
    ) AS hold_guard_rows,

    CASE
        WHEN COUNT(*) FILTER (
            WHERE guard_type = 'HOLD_NAME'
        ) > 0
        THEN 'ACTIVE'
        ELSE 'READY'
    END AS guard_status

FROM ops.v_team_insert_guard_v1;