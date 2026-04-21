-- 704_fix_hb_target_131_canonical_league.sql
-- Cíl:
-- Opravit HB ingest target pro provider_league_id=131,
-- aby misto stare canonical league 13001 (EHF)
-- pouzival novou explicitni HB ligu 24881 (Champions League).

UPDATE ops.ingest_targets
SET
    canonical_league_id = 24881,
    notes = 'HB smoke test: Champions League (api_handball league_id=131) | canonical league fixed to public.leagues.id=24881 | fixtures date window enabled (±30 days)',
    updated_at = NOW()
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND provider_league_id = '131'
  AND season = '2024';

-- kontrola
SELECT
    id,
    sport_code,
    canonical_league_id,
    provider,
    provider_league_id,
    season,
    enabled,
    tier,
    run_group,
    notes
FROM ops.ingest_targets
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
ORDER BY tier, provider_league_id, season;