/*
MATCHMATRIX SQL 18_2_H Match Safe Delete Execute V1

CO TO JE:
- Bezpečné odstranění duplicitních zápasů podle ověřeného plánu.

K ČEMU TO JE:
- Odstraní pouze duplicate_match_id, které mají SAFE_DELETE.

KDE TO UVIDÍME:
- public.matches bude očištěna o bezpečné provider duplicity.

JAK SE TO VYUŽIJE:
- Context Engine přestane vracet duplicitní zápasy.
- Team Power, Ticket Engine a web budou pracovat s čistší databází.
*/

BEGIN;

CREATE TABLE IF NOT EXISTS ops.match_safe_delete_run_log (
    id bigserial PRIMARY KEY,
    deleted_at timestamptz NOT NULL DEFAULT now(),
    duplicate_match_id bigint NOT NULL,
    master_match_id bigint NOT NULL,
    duplicate_ext_source text,
    duplicate_ext_match_id text,
    kickoff timestamp without time zone,
    home_team text,
    away_team text,
    execution_action text NOT NULL,
    run_note text
);

INSERT INTO ops.match_safe_delete_run_log (
    duplicate_match_id,
    master_match_id,
    duplicate_ext_source,
    duplicate_ext_match_id,
    kickoff,
    home_team,
    away_team,
    execution_action,
    run_note
)
SELECT
    duplicate_match_id,
    master_match_id,
    duplicate_ext_source,
    duplicate_ext_match_id,
    kickoff,
    home_team,
    away_team,
    execution_action,
    '18_2_H_SAFE_DELETE_PROVIDER_DUPLICATES'
FROM ops.v_match_safe_delete_execution_plan_v1;

DELETE FROM public.matches m
USING ops.v_match_safe_delete_execution_plan_v1 p
WHERE m.id = p.duplicate_match_id;

SELECT COUNT(*) AS deleted_logged_rows
FROM ops.match_safe_delete_run_log
WHERE run_note = '18_2_H_SAFE_DELETE_PROVIDER_DUPLICATES';

COMMIT;