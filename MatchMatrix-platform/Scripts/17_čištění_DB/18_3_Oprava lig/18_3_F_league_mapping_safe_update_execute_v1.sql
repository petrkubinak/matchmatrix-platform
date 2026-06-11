/*
MATCHMATRIX SQL 18_3_F League Mapping Safe Update Execute V1

CO TO JE:
- Bezpečná oprava league_id u zápasů s provider league mapping konfliktem.

K ČEMU TO JE:
- Přepíše current_league_id na master_league_id u 562 ověřených zápasů.

KDE TO UVIDÍME:
- public.matches bude mít sjednocené ligy podle master providera.

JAK SE TO VYUŽIJE:
- Opraví League Mapping konflikty v Match Duplicate Governance.
*/

BEGIN;

CREATE TABLE IF NOT EXISTS ops.league_mapping_safe_update_run_log (
    id bigserial PRIMARY KEY,
    updated_at timestamptz NOT NULL DEFAULT now(),
    match_id bigint NOT NULL,
    old_league_id bigint,
    old_league_name text,
    new_league_id bigint,
    new_league_name text,
    ext_source text,
    ext_match_id text,
    home_team text,
    away_team text,
    match_date date,
    run_note text NOT NULL
);

INSERT INTO ops.league_mapping_safe_update_run_log (
    match_id,
    old_league_id,
    old_league_name,
    new_league_id,
    new_league_name,
    ext_source,
    ext_match_id,
    home_team,
    away_team,
    match_date,
    run_note
)
SELECT
    match_id,
    current_league_id,
    current_league_name,
    master_league_id,
    master_league_name,
    ext_source,
    ext_match_id,
    home_team,
    away_team,
    match_date,
    '18_3_F_SAFE_LEAGUE_MAPPING_UPDATE'
FROM ops.v_league_mapping_fix_dependency_audit_v1
WHERE dependency_status = 'SAFE_LEAGUE_UPDATE_READY';

UPDATE public.matches m
SET
    league_id = p.master_league_id,
    updated_at = now()
FROM ops.v_league_mapping_fix_dependency_audit_v1 p
WHERE m.id = p.match_id
  AND p.dependency_status = 'SAFE_LEAGUE_UPDATE_READY';

SELECT COUNT(*) AS updated_logged_rows
FROM ops.league_mapping_safe_update_run_log
WHERE run_note = '18_3_F_SAFE_LEAGUE_MAPPING_UPDATE';

COMMIT;