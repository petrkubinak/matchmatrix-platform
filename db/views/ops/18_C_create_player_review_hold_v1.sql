/*
MATCHMATRIX SQL 18_C
PLAYER REVIEW HOLD V1

CO TO JE:
- HOLD seznam hráčů, které nesmíme automaticky sloučit.

K ČEMU TO JE:
- Chrání hráče se stejným jménem, ale nejasnou identitou.
- Typicky chybí birth_date nebo mají stejné jméno ve stejném provideru.

KDE TO UVIDÍME:
- OPS Panel V18 → PEOPLE / PLAYER IDENTITY GOVERNANCE.

JAK SE TO VYUŽIJE:
- Automatický merge hráčů tyto skupiny přeskočí.
- Později je ověříme podle týmu, země, provider detailu a statistik.
*/

CREATE TABLE IF NOT EXISTS ops.player_identity_review_hold (
    id bigserial PRIMARY KEY,
    normalized_name text NOT NULL,
    sport_id integer,
    team_id integer,
    providers text,
    provider_player_ids text,
    birth_dates text,
    identity_status text NOT NULL,
    risk_level text NOT NULL,
    review_status text NOT NULL DEFAULT 'HOLD_MANUAL_REVIEW',
    review_note text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

INSERT INTO ops.player_identity_review_hold (
    normalized_name,
    sport_id,
    team_id,
    providers,
    provider_player_ids,
    birth_dates,
    identity_status,
    risk_level,
    review_note
)
SELECT
    normalized_name,
    sport_id,
    team_id,
    providers,
    provider_player_ids,
    birth_dates,
    identity_status,
    risk_level,
    recommended_action
FROM ops.v_player_canonical_identity_audit_v1
WHERE identity_status IN (
    'SAFE_DIFFERENT_BIRTH_DATE',
    'SUSPECT_MISSING_BIRTH_DATE',
    'SUSPECT_NO_BIRTH_DATE'
)
ON CONFLICT DO NOTHING;

CREATE OR REPLACE VIEW ops.v_player_identity_review_hold_v1 AS
SELECT
    id,
    normalized_name,
    sport_id,
    team_id,
    providers,
    provider_player_ids,
    birth_dates,
    identity_status,
    risk_level,
    review_status,
    review_note,
    created_at,
    updated_at
FROM ops.player_identity_review_hold
ORDER BY
    CASE risk_level
        WHEN 'CRITICAL' THEN 1
        WHEN 'HIGH' THEN 2
        WHEN 'MEDIUM' THEN 3
        WHEN 'LOW' THEN 4
        ELSE 5
    END,
    normalized_name;