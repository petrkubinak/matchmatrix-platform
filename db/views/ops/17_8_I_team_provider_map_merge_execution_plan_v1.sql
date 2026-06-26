/*
MATCHMATRIX SQL 17_8_I
TEAM PROVIDER MAP MERGE EXECUTION PLAN V1

CO TO JE:
- Execution plán pro bezpečný přesun provider map z duplicitních týmů na master týmy.
- Nic zatím neupravuje v databázi.

K ČEMU TO JE:
- Připraví konkrétní provider mapy k přesunu.
- Vyloučí konfliktní případy.
- Umožní kontrolu před UPDATE.

KDE TO UVIDÍME:
- OPS Panel -> ČIŠTĚNÍ DB
- OPS Panel -> TEAM DEDUP
- DBeaver audit provider map merge

JAK SE TO VYUŽIJE:
- 17_8_J provede UPDATE public.team_provider_map.team_id.
- Po přesunu provider map půjde duplicitní tým znovu do bezpečného delete auditu.
*/

CREATE OR REPLACE VIEW ops.v_team_provider_map_merge_execution_plan_v1 AS
SELECT
    team_name,
    sport_id,

    old_team_id,
    master_team_id,

    provider,
    provider_team_id,

    'READY_FOR_UPDATE' AS execution_status,

    'Přesunout provider mapu z duplicate team_id na master_team_id.' AS recommendation_cz,

    now() AS generated_at

FROM ops.v_team_provider_map_merge_audit_v1
WHERE merge_status = 'READY_FOR_PROVIDER_MAP_MOVE'

ORDER BY
    team_name,
    provider,
    provider_team_id;