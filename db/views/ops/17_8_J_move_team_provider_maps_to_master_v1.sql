/*
MATCHMATRIX SQL 17_8_J
MOVE TEAM PROVIDER MAPS TO MASTER V2

CO TO JE:
- Bezpečný UPDATE provider map z duplicitních týmů na master týmy.
- Přesouvá pouze řádky z ops.v_team_provider_map_merge_execution_plan_v1 se stavem READY_FOR_UPDATE.
- Verze V2 respektuje skutečnou strukturu public.team_provider_map bez sloupce id.

K ČEMU TO JE:
- Zachová provider vazby při čištění duplicit.
- Připraví duplicitní týmy na následný bezpečný delete.
- Sníží počet týmů, které mají jen provider mapu a žádná další data.

KDE TO UVIDÍME:
- public.team_provider_map
- OPS Panel -> ČIŠTĚNÍ DB
- OPS Panel -> TEAM DEDUP
- DBeaver kontrola provider map merge

JAK SE TO VYUŽIJE:
- Po přesunu provider map znovu přepočítáme 17_8_F.
- Duplicitní týmy, které po přesunu nemají žádné vazby, půjdou do READY_FOR_DELETE.
- Následně je odstraníme přes 17_8_G.
*/

BEGIN;

WITH move_plan AS (
    SELECT
        old_team_id,
        master_team_id,
        provider,
        provider_team_id
    FROM ops.v_team_provider_map_merge_execution_plan_v1
    WHERE execution_status = 'READY_FOR_UPDATE'
),
verified AS (
    SELECT
        mp.old_team_id,
        mp.master_team_id,
        mp.provider,
        mp.provider_team_id
    FROM move_plan mp
    JOIN public.team_provider_map tpm
        ON tpm.team_id = mp.old_team_id
       AND tpm.provider = mp.provider
       AND tpm.provider_team_id = mp.provider_team_id

    WHERE NOT EXISTS (
        SELECT 1
        FROM public.team_provider_map existing
        WHERE existing.team_id = mp.master_team_id
          AND existing.provider = mp.provider
    )
)

UPDATE public.team_provider_map tpm
SET
    team_id = v.master_team_id,
    updated_at = now()
FROM verified v
WHERE tpm.team_id = v.old_team_id
  AND tpm.provider = v.provider
  AND tpm.provider_team_id = v.provider_team_id;

COMMIT;