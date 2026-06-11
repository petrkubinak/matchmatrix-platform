/*
MATCHMATRIX SQL 17_9_H
TEAM SAME NAME REVIEW HOLD V1

CO TO JE:
- Evidence týmů se stejným názvem, stejným providerem, ale jiným ext_team_id.

K ČEMU TO JE:
- Tyto týmy se nesmí automaticky sloučit.
- Může jít o různé kluby, mládež, ženy, B tým nebo jinou soutěž.

KDE TO UVIDÍME:
- OPS / DATA QUALITY / TEAM DUPLICATE PREVENTION.

JAK SE TO VYUŽIJE:
- Vyjmeme je z automatického merge procesu.
- Později je ručně ověříme podle země, ligy, sezóny a provider detailu.
*/

CREATE TABLE IF NOT EXISTS ops.team_same_name_review_hold (
    id bigserial PRIMARY KEY,
    normalized_name text NOT NULL,
    sport_id integer NOT NULL,
    provider text NOT NULL,
    provider_team_ids text NOT NULL,
    review_status text NOT NULL DEFAULT 'HOLD_MANUAL_REVIEW',
    review_note text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

INSERT INTO ops.team_same_name_review_hold (
    normalized_name,
    sport_id,
    provider,
    provider_team_ids,
    review_note
)
SELECT
    normalized_name,
    sport_id,
    providers AS provider,
    provider_team_ids,
    'Stejný název + stejný provider + více ext_team_id. Neslučovat automaticky.'
FROM ops.v_team_canonical_identity_audit_v1
WHERE identity_status = 'SUSPECT_SAME_PROVIDER_MULTIPLE_IDS'
ON CONFLICT DO NOTHING;

CREATE OR REPLACE VIEW ops.v_team_same_name_review_hold_v1 AS
SELECT
    h.id,
    h.normalized_name,
    h.sport_id,
    h.provider,
    h.provider_team_ids,
    h.review_status,
    h.review_note,
    h.created_at,
    h.updated_at
FROM ops.team_same_name_review_hold h
ORDER BY h.normalized_name;