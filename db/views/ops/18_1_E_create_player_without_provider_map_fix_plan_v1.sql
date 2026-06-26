/*
MATCHMATRIX SQL 18_1_E

PLAYER WITHOUT PROVIDER MAP FIX PLAN V1

CO TO JE:
- Audit a plán opravy hráčů, kteří existují v public.players,
  ale nemají záznam v:
      public.player_provider_map
      public.player_external_identity

K ČEMU TO JE:
- Najde orphan hráče bez provider identity.
- Připraví data pro automatické doplnění map.

KDE TO UVIDÍME:
- OPS Panel V18
- People Layer
- Provider Governance

JAK SE TO VYUŽIJE:
- Doplňování player_provider_map.
- Doplňování player_external_identity.
- Kontrola integrity People Layer.
*/

CREATE OR REPLACE VIEW ops.v_player_without_provider_map_fix_plan_v1 AS

WITH players_without_map AS (

    SELECT
        p.id AS player_id,
        p.team_id,
        p.name,
        p.first_name,
        p.last_name,
        p.birth_date,
        p.nationality,
        p.position,
        p.ext_source,
        p.ext_player_id,
        p.sport_id,
        p.created_at,
        p.updated_at

    FROM public.players p

    LEFT JOIN public.player_provider_map ppm
           ON ppm.player_id = p.id

    LEFT JOIN public.player_external_identity pei
           ON pei.player_id = p.id

    WHERE ppm.player_id IS NULL
      AND pei.player_id IS NULL
)

SELECT

    player_id,
    team_id,
    name,
    first_name,
    last_name,
    birth_date,
    nationality,
    position,
    ext_source,
    ext_player_id,
    sport_id,
    created_at,
    updated_at,

    CASE
        WHEN ext_source IS NOT NULL
         AND ext_player_id IS NOT NULL
        THEN 'AUTO_CREATE_PROVIDER_MAP'

        ELSE 'MANUAL_REVIEW_REQUIRED'
    END AS proposed_action,

    CASE
        WHEN ext_source IS NOT NULL
         AND ext_player_id IS NOT NULL
        THEN 'Hráč má provider identitu přímo v public.players. Lze vytvořit provider map automaticky.'

        ELSE 'Chybí ext_source nebo ext_player_id. Nutná ruční kontrola.'
    END AS action_note

FROM players_without_map

ORDER BY player_id;