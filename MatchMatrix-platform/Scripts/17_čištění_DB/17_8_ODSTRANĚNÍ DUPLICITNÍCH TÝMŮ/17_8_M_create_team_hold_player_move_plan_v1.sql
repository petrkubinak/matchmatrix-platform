/*
MATCHMATRIX SQL 17_8_M
TEAM HOLD PLAYER MOVE PLAN V1

CO TO JE:
- Plán bezpečného přesunu hráčů z duplicitních týmů na master týmy.
- Nic zatím neupravuje v databázi.

K ČEMU TO JE:
- Připraví 46 hráčů k přesunu z old_team_id na master_team_id.
- Ověří, že stejný hráč už na master týmu neexistuje.
- Umožní bezpečný UPDATE v dalším kroku 17_8_N.

KDE TO UVIDÍME:
- OPS Panel -> ČIŠTĚNÍ DB
- OPS Panel -> TEAM DEDUP
- DBeaver audit hráčů navázaných na duplicitní týmy

JAK SE TO VYUŽIJE:
- 17_8_N přesune public.players.team_id na master_team_id.
- Poté znovu přepočítáme 17_8_F.
- Týmy bez dalších vazeb půjdou do bezpečného DELETE přes 17_8_G.
*/

CREATE OR REPLACE VIEW ops.v_team_hold_player_move_plan_v1 AS
SELECT
    h.team_name,
    h.old_team_id,
    h.master_team_id,

    p.id AS player_id,
    p.name AS player_name,
    p.ext_source,
    p.ext_player_id,
    p.sport_id,

    CASE
        WHEN mp.id IS NULL THEN 'READY_FOR_PLAYER_MOVE'
        ELSE 'HOLD_PLAYER_ALREADY_EXISTS_ON_MASTER'
    END AS move_status,

    CASE
        WHEN mp.id IS NULL
            THEN 'Hráče lze bezpečně přesunout na master tým.'
        ELSE 'Hráč už existuje na master týmu. Vyžaduje ruční kontrolu.'
    END AS recommendation_cz,

    now() AS generated_at

FROM ops.v_team_hold_dependency_detail_audit_v1 h

JOIN public.players p
    ON p.id = h.dependency_id::bigint

LEFT JOIN public.players mp
    ON mp.team_id = h.master_team_id
   AND mp.ext_source = p.ext_source
   AND mp.ext_player_id = p.ext_player_id

WHERE h.dependency_type = 'PLAYER'

ORDER BY
    h.team_name,
    p.name;