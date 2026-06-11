/*
MATCHMATRIX SQL 17_9_J
TEAM INSERT GUARD VIEW V2
*/

CREATE OR REPLACE VIEW ops.v_team_insert_guard_v1 AS

WITH existing_provider AS (
    SELECT
        t.id::bigint AS team_id,
        t.name::text AS name,
        lower(trim(t.name))::text AS normalized_name,
        t.sport_id::integer AS sport_id,
        t.ext_source::text AS ext_source,
        t.ext_team_id::text AS ext_team_id,
        'EXISTING_PROVIDER_ID'::text AS guard_type,
        'USE_EXISTING_TEAM'::text AS action
    FROM public.teams t
),

existing_name AS (
    SELECT
        t.id::bigint AS team_id,
        t.name::text AS name,
        lower(trim(t.name))::text AS normalized_name,
        t.sport_id::integer AS sport_id,
        t.ext_source::text AS ext_source,
        t.ext_team_id::text AS ext_team_id,
        'EXISTING_NAME_SPORT'::text AS guard_type,
        'REVIEW_BEFORE_INSERT'::text AS action
    FROM public.teams t
),

hold_names AS (
    SELECT
        NULL::bigint AS team_id,
        h.normalized_name::text AS name,
        h.normalized_name::text AS normalized_name,
        h.sport_id::integer AS sport_id,
        h.provider::text AS ext_source,
        NULL::text AS ext_team_id,
        'HOLD_NAME'::text AS guard_type,
        'MANUAL_REVIEW_REQUIRED'::text AS action
    FROM ops.team_same_name_review_hold h
)

SELECT * FROM existing_provider
UNION ALL
SELECT * FROM existing_name
UNION ALL
SELECT * FROM hold_names;