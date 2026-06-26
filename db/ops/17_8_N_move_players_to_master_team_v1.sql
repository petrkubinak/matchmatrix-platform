/*
MATCHMATRIX SQL 17_8_N
MOVE PLAYERS TO MASTER TEAM V1

CO TO JE:
- Bezpečný UPDATE hráčů z duplicitních týmů na master týmy.
- Přesouvá pouze hráče označené jako READY_FOR_PLAYER_MOVE.

K ČEMU TO JE:
- Zachová hráče při čištění duplicitních týmů.
- Uvolní poslední blokace v HOLD_DEPENDENCY.
- Připraví týmy pro finální DELETE.

KDE TO UVIDÍME:
- public.players
- OPS Panel -> TEAM DEDUP
- OPS Panel -> PEOPLE

JAK SE TO VYUŽIJE:
- Po přesunu hráčů přepočítáme 17_8_F.
- Většina HOLD_DEPENDENCY týmů zmizí.
- Poté znovu spustíme 17_8_G a odstraníme zbylé duplicity.
*/

BEGIN;

WITH move_plan AS (
    SELECT
        player_id,
        old_team_id,
        master_team_id
    FROM ops.v_team_hold_player_move_plan_v1
    WHERE move_status = 'READY_FOR_PLAYER_MOVE'
)

UPDATE public.players p
SET
    team_id = mp.master_team_id,
    updated_at = now()
FROM move_plan mp
WHERE p.id = mp.player_id
  AND p.team_id = mp.old_team_id;

COMMIT;