/*
MATCHMATRIX SQL 19_B

PLAYER DUPLICATE CANDIDATE DETAIL V1

CO TO JE:
- Detailní seznam hráčů z rizikových duplicate skupin.

K ČEMU TO JE:
- Ukáže konkrétní player_id, provider, team, birth_date a doporučení.
- Připraví ruční kontrolu před případným canonical merge.

KDE TO UVIDÍME:
- People Governance
- OPS Panel
- Player Duplicate Prevention

JAK SE TO VYUŽIJE:
- Nejdřív zkontrolujeme HIGH_HOLD.
- Potom MEDIUM duplicate kandidáty.
- Zatím nic nemažeme ani neslučujeme.

NAVAZUJE NA:
- 19_A_create_player_duplicate_prevention_audit_v1.sql

DALŠÍ KROK:
- 19_C_create_player_duplicate_merge_plan_v1.sql
*/

DROP VIEW IF EXISTS ops.v_player_duplicate_candidate_detail_v1;

CREATE OR REPLACE VIEW ops.v_player_duplicate_candidate_detail_v1 AS

WITH risky_groups AS (
    SELECT
        sport_id,
        normalized_name,
        duplicate_status,
        risk_level,
        recommended_action
    FROM ops.v_player_duplicate_prevention_audit_v1
    WHERE duplicate_status <> 'SINGLE_OK'
),

player_base AS (
    SELECT
        p.id AS player_id,
        p.sport_id,
        p.team_id,
        p.name AS player_name,
        p.first_name,
        p.last_name,
        p.birth_date,
        p.nationality,
        p.position,
        p.photo_url,
        p.ext_source,
        p.ext_player_id,

        lower(
            regexp_replace(
                trim(
                    COALESCE(
                        NULLIF(p.name, ''),
                        trim(COALESCE(p.first_name, '') || ' ' || COALESCE(p.last_name, ''))
                    )
                ),
                '\s+',
                ' ',
                'g'
            )
        ) AS normalized_name,

        ppm.provider,
        ppm.provider_player_id,
        ppm.provider_team_id,
        ppm.provider_team_name,
        ppm.provider_player_name,
        ppm.is_active AS provider_map_active

    FROM public.players p
    LEFT JOIN public.player_provider_map ppm
        ON ppm.player_id = p.id
)

SELECT
    rg.risk_level,
    rg.duplicate_status,
    rg.recommended_action,

    pb.sport_id,
    pb.normalized_name,

    pb.player_id,
    pb.player_name,
    pb.first_name,
    pb.last_name,
    pb.birth_date,
    pb.nationality,
    pb.position,
    pb.team_id,

    pb.provider,
    pb.provider_player_id,
    pb.provider_team_id,
    pb.provider_team_name,
    pb.provider_player_name,
    pb.provider_map_active,

    pb.photo_url,
    pb.ext_source,
    pb.ext_player_id,

    CASE
        WHEN rg.risk_level = 'HIGH_HOLD'
            THEN 'NEŘEŠIT AUTOMATICKY - stejné jméno, jiný birth_date.'

        WHEN rg.risk_level = 'MEDIUM'
            THEN 'Ruční kontrola stejného providera před merge.'

        WHEN rg.risk_level = 'HIGH'
            THEN 'Kandidát na cross-provider merge po kontrole.'

        ELSE
            'Ruční kontrola.'
    END AS review_note,

    now() AS refreshed_at

FROM risky_groups rg
JOIN player_base pb
    ON pb.sport_id = rg.sport_id
   AND pb.normalized_name = rg.normalized_name

ORDER BY
    CASE rg.risk_level
        WHEN 'HIGH_HOLD' THEN 1
        WHEN 'HIGH' THEN 2
        WHEN 'MEDIUM' THEN 3
        ELSE 4
    END,
    pb.normalized_name,
    pb.birth_date NULLS LAST,
    pb.provider,
    pb.player_id;