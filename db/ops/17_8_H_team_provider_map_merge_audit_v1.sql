/*
===============================================================================
MATCHMATRIX SQL 17_8_H
TEAM PROVIDER MAP MERGE AUDIT V1
===============================================================================

CO TO JE:
- Audit duplicitních týmů, které lze potenciálně sloučit přes provider mapy.
- Navazuje na 17_8_G po odstranění 361 mrtvých duplicit.

K ČEMU TO JE:
- Najde duplicitní týmy, kde duplicate tým obsahuje provider mapu.
- Ověří, zda master tým provider mapu nemá.
- Připraví kandidáty pro bezpečný přesun provider map na master tým.

KDE TO UVIDÍME:
- OPS Panel -> ČIŠTĚNÍ DB
- OPS Panel -> TEAM DEDUP
- DBeaver audit provider map merge

JAK SE TO VYUŽIJE:
- 17_8_I vytvoří execution plán.
- 17_8_J provede fyzický přesun provider map.
- Následně bude možné odstranit další duplicitní týmy.

BEZPEČNOST:
- Konfliktní provider ID se automaticky blokují.
- Pokud master již mapu má, jde do HOLD.
- Pokud duplicate obsahuje více map stejného providera, jde do HOLD.
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_team_provider_map_merge_audit_v1 AS

WITH candidates AS (

    SELECT
        team_name,
        sport_id,
        old_team_id,
        master_team_id
    FROM ops.v_team_safe_merge_plan_v1
    WHERE merge_status = 'SAFE_PROVIDER_MAP_MERGE'

),

duplicate_maps AS (

    SELECT
        c.team_name,
        c.sport_id,
        c.old_team_id,
        c.master_team_id,

        tpm.provider,
        tpm.provider_team_id,

        COUNT(*) OVER (
            PARTITION BY c.old_team_id, tpm.provider
        ) AS duplicate_provider_count

    FROM candidates c
    JOIN public.team_provider_map tpm
        ON tpm.team_id = c.old_team_id

),

master_maps AS (

    SELECT
        team_id,
        provider,
        provider_team_id
    FROM public.team_provider_map

)

SELECT
    d.team_name,
    d.sport_id,

    d.old_team_id,
    d.master_team_id,

    d.provider,
    d.provider_team_id,

    CASE
        WHEN EXISTS (
            SELECT 1
            FROM master_maps mm
            WHERE mm.team_id = d.master_team_id
              AND mm.provider = d.provider
        )
            THEN 'HOLD_MASTER_ALREADY_HAS_PROVIDER'

        WHEN d.duplicate_provider_count > 1
            THEN 'HOLD_DUPLICATE_PROVIDER_ROWS'

        ELSE 'READY_FOR_PROVIDER_MAP_MOVE'
    END AS merge_status,

    CASE
        WHEN EXISTS (
            SELECT 1
            FROM master_maps mm
            WHERE mm.team_id = d.master_team_id
              AND mm.provider = d.provider
        )
            THEN 'Master tým již obsahuje provider mapu.'

        WHEN d.duplicate_provider_count > 1
            THEN 'Duplicate tým obsahuje více provider map stejného providera.'

        ELSE 'Bezpečný kandidát pro přesun provider mapy.'
    END AS recommendation_cz,

    now() AS generated_at

FROM duplicate_maps d

ORDER BY
    merge_status,
    team_name,
    provider;