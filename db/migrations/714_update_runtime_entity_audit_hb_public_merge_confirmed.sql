-- 714_update_runtime_entity_audit_hb_public_merge_confirmed.sql
-- Cíl:
-- Dorovnat HB runtime audit po potvrzenem public smoke merge:
-- - leagues: provider_map + public_merge = true
-- - teams:   provider_map + public_merge = true
-- - fixtures: public_merge = true
--
-- Pozn.: downstream_confirmed zatim nechavame FALSE.

-- =========================================================
-- HB LEAGUES
-- =========================================================
UPDATE ops.runtime_entity_audit
SET
    current_state = 'CONFIRMED',
    state_reason = 'HB leagues jsou potvrzene od pull/raw/staging az po canonical public.leagues a public.league_provider_map pro core smoke scope.',
    provider_map_confirmed = TRUE,
    public_merge_confirmed = TRUE,
    downstream_confirmed = FALSE,
    last_check_at = NOW(),
    last_log_summary = 'HB leagues confirmed in staging + public.leagues + league_provider_map',
    db_evidence_summary = 'public.leagues: 24881/24882/24883 | public.league_provider_map: api_handball -> 131/145/183',
    next_action = 'Rozsirit stejny flow na dalsi HB teams/fixtures targety a navazat downstream vrstvy.',
    audit_note = 'HB leagues jsou potvrzene v canonical vrstve. Downstream layer zatim neni auditne potvrzena.',
    updated_at = NOW()
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND entity = 'leagues';

-- =========================================================
-- HB TEAMS
-- =========================================================
UPDATE ops.runtime_entity_audit
SET
    current_state = 'CONFIRMED',
    state_reason = 'HB teams jsou potvrzene od pull/raw/staging az po canonical public.teams a public.team_provider_map pro smoke scope 131/2024.',
    provider_map_confirmed = TRUE,
    public_merge_confirmed = TRUE,
    downstream_confirmed = FALSE,
    last_check_at = NOW(),
    last_log_summary = 'HB teams confirmed in staging + public.teams + team_provider_map for 131/2024',
    db_evidence_summary = 'public.teams api_handball=16 | public.team_provider_map api_handball=16 | league 131 / season 2024',
    next_action = 'Rozsirit canonical teams flow i pro dalsi HB leagues 145 a 183.',
    audit_note = 'HB teams jsou potvrzene v public vrstve pro smoke scope 131/2024. Dalsi targety se budou rozsirovat postupne.',
    updated_at = NOW()
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND entity = 'teams';

-- =========================================================
-- HB FIXTURES
-- =========================================================
UPDATE ops.runtime_entity_audit
SET
    current_state = 'CONFIRMED',
    state_reason = 'HB fixtures jsou potvrzene od pull/raw/staging az po public.matches merge pro smoke scope 131/2024.',
    provider_map_confirmed = FALSE,
    public_merge_confirmed = TRUE,
    downstream_confirmed = FALSE,
    last_check_at = NOW(),
    last_log_summary = 'HB fixtures confirmed in staging + public.matches for 131/2024',
    db_evidence_summary = 'staging.stg_provider_fixtures=132 | public.matches ext_source=api_handball=132 for league 24881 / season 2024',
    next_action = 'Rozsirit fixtures smoke merge i pro dalsi HB targety a potom resit downstream layers.',
    audit_note = 'HB fixtures jsou potvrzene v public.matches pro smoke scope 131/2024. Provider-map flag zustava FALSE, protoze fixtures samostatnou provider_map tabulku nemaji.',
    updated_at = NOW()
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND entity = 'fixtures';

-- =========================================================
-- KONTROLA
-- =========================================================
SELECT
    provider,
    sport_code,
    entity,
    current_state,
    staging_confirmed,
    provider_map_confirmed,
    public_merge_confirmed,
    downstream_confirmed,
    last_log_summary,
    db_evidence_summary,
    next_action,
    updated_at
FROM ops.runtime_entity_audit
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
ORDER BY entity;