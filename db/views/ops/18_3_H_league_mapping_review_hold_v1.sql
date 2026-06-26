/*
MATCHMATRIX SQL 18_3_H League Mapping Review Hold V1
*/

CREATE TABLE IF NOT EXISTS ops.league_mapping_review_hold (
    id bigserial PRIMARY KEY,
    created_at timestamptz NOT NULL DEFAULT now(),
    sport_id bigint,
    match_date date,
    team_low bigint,
    team_high bigint,
    league_mapping_status text,
    match_ids text,
    provider_refs text,
    league_refs text,
    match_names text,
    scores text,
    hold_reason text,
    hold_status text NOT NULL DEFAULT 'OPEN'
);

INSERT INTO ops.league_mapping_review_hold (
    sport_id,
    match_date,
    team_low,
    team_high,
    league_mapping_status,
    match_ids,
    provider_refs,
    league_refs,
    match_names,
    scores,
    hold_reason
)
SELECT
    sport_id,
    match_date,
    team_low,
    team_high,
    league_mapping_status,
    match_ids,
    provider_refs,
    league_refs,
    match_names,
    scores,
    CASE
        WHEN league_mapping_status = 'HOLD_SCORE_CONFLICT'
            THEN 'Chybí skóre u jednoho záznamu nebo je skóre rozdílné. Ruční kontrola.'
        WHEN league_mapping_status = 'LEAGUE_CANONICAL_CONFLICT'
            THEN 'Stejný provider, stejný zápas, různé ligy. Ruční kontrola ligové identity.'
        ELSE 'Ruční kontrola.'
    END AS hold_reason
FROM ops.v_league_mapping_governance_audit_v1
WHERE league_mapping_status IN (
    'HOLD_SCORE_CONFLICT',
    'LEAGUE_CANONICAL_CONFLICT'
)
ON CONFLICT DO NOTHING;