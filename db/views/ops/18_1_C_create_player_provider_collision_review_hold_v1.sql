/*
MATCHMATRIX SQL 18_1_C
PLAYER PROVIDER COLLISION REVIEW HOLD V1

CO TO JE:
- HOLD seznam kolizí provider identity hráčů.

K ČEMU TO JE:
- Zabrání automatickému merge hráčů tam, kde stejný provider_player_id ukazuje na různé hráče.

KDE TO UVIDÍME:
- OPS Panel V18 → People Layer → Provider Governance.

JAK SE TO VYUŽIJE:
- Rozdělíme kolize na:
  1) možné špatné provider mapy
  2) možné reálné hráčské duplicity
*/

CREATE TABLE IF NOT EXISTS ops.player_provider_collision_review_hold (
    id bigserial PRIMARY KEY,
    provider text NOT NULL,
    external_player_id text NOT NULL,
    player_ids text NOT NULL,
    player_names text,
    birth_dates text,
    review_status text NOT NULL DEFAULT 'HOLD_MANUAL_REVIEW',
    suggested_action text,
    review_note text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

INSERT INTO ops.player_provider_collision_review_hold (
    provider,
    external_player_id,
    player_ids,
    player_names,
    birth_dates,
    suggested_action,
    review_note
)
SELECT
    provider,
    external_player_id,
    STRING_AGG(player_id::text, ', ' ORDER BY preferred_rank) AS player_ids,
    STRING_AGG(COALESCE(name, ''), ' | ' ORDER BY preferred_rank) AS player_names,
    STRING_AGG(COALESCE(birth_date::text, ''), ' | ' ORDER BY preferred_rank) AS birth_dates,

    CASE
        WHEN COUNT(DISTINCT birth_date) FILTER (WHERE birth_date IS NOT NULL) = 1
             AND COUNT(*) FILTER (WHERE birth_date IS NULL) = 0
            THEN 'POSSIBLE_PLAYER_MERGE'
        ELSE 'PROVIDER_MAP_REVIEW'
    END AS suggested_action,

    CASE
        WHEN COUNT(DISTINCT birth_date) FILTER (WHERE birth_date IS NOT NULL) = 1
             AND COUNT(*) FILTER (WHERE birth_date IS NULL) = 0
            THEN 'Stejné datum narození. Pravděpodobný merge kandidát, ale před opravou ověřit reference.'
        ELSE 'Různé datum narození nebo nejasná identita. Neslučovat hráče automaticky, ověřit provider mapu.'
    END AS review_note

FROM ops.v_player_provider_identity_collision_plan_v1
GROUP BY provider, external_player_id
ON CONFLICT DO NOTHING;

CREATE OR REPLACE VIEW ops.v_player_provider_collision_review_hold_v1 AS
SELECT
    id,
    provider,
    external_player_id,
    player_ids,
    player_names,
    birth_dates,
    review_status,
    suggested_action,
    review_note,
    created_at,
    updated_at
FROM ops.player_provider_collision_review_hold
ORDER BY
    suggested_action,
    provider,
    external_player_id;