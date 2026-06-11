/*
MATCHMATRIX SQL 18_E
PLAYER INSERT GUARD V1

CO TO JE:
- Ochranná vrstva proti vytváření nových duplicitních hráčů.

K ČEMU TO JE:
- Worker před INSERTEM ověří:
  1) ext_source + ext_player_id
  2) normalized_name + birth_date + sport_id
  3) HOLD seznam nejasných identit

KDE TO UVIDÍME:
- OPS Panel V18 → PEOPLE / PLAYER IDENTITY GOVERNANCE.

JAK SE TO VYUŽIJE:
- Budoucí people ingest workery.
- Player merge engine.
- Provider onboarding.
*/

CREATE OR REPLACE VIEW ops.v_player_insert_guard_v1 AS

WITH existing_provider AS (
    SELECT
        p.id::bigint AS player_id,
        p.team_id::integer AS team_id,
        p.name::text AS name,
        lower(trim(p.name))::text AS normalized_name,
        p.birth_date::date AS birth_date,
        p.sport_id::integer AS sport_id,
        p.ext_source::text AS ext_source,
        p.ext_player_id::text AS ext_player_id,
        'EXISTING_PROVIDER_PLAYER_ID'::text AS guard_type,
        'USE_EXISTING_PLAYER'::text AS action
    FROM public.players p
    WHERE p.ext_source IS NOT NULL
      AND p.ext_player_id IS NOT NULL
),

existing_name_birth AS (
    SELECT
        p.id::bigint AS player_id,
        p.team_id::integer AS team_id,
        p.name::text AS name,
        lower(trim(p.name))::text AS normalized_name,
        p.birth_date::date AS birth_date,
        p.sport_id::integer AS sport_id,
        p.ext_source::text AS ext_source,
        p.ext_player_id::text AS ext_player_id,
        'EXISTING_NAME_BIRTH_SPORT'::text AS guard_type,
        'REVIEW_BEFORE_INSERT'::text AS action
    FROM public.players p
    WHERE p.name IS NOT NULL
      AND trim(p.name) <> ''
      AND p.birth_date IS NOT NULL
      AND p.sport_id IS NOT NULL
),

hold_identity AS (
    SELECT
        NULL::bigint AS player_id,
        h.team_id::integer AS team_id,
        h.normalized_name::text AS name,
        h.normalized_name::text AS normalized_name,
        NULL::date AS birth_date,
        h.sport_id::integer AS sport_id,
        h.providers::text AS ext_source,
        h.provider_player_ids::text AS ext_player_id,
        'HOLD_PLAYER_IDENTITY'::text AS guard_type,
        'MANUAL_REVIEW_REQUIRED'::text AS action
    FROM ops.player_identity_review_hold h
    WHERE h.review_status = 'HOLD_MANUAL_REVIEW'
)

SELECT * FROM existing_provider
UNION ALL
SELECT * FROM existing_name_birth
UNION ALL
SELECT * FROM hold_identity;