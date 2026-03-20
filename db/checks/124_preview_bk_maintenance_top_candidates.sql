SELECT
    id,
    sport_code,
    canonical_league_id,
    provider,
    provider_league_id,
    tier,
    notes,
    run_group
FROM ops.ingest_targets
WHERE sport_code = 'BK'
  AND enabled = TRUE
  AND notes IN (
      'NBA',
      'Euroleague',
      'ACB',
      'Lega A',
      'LKL',
      'ABA League',
      'BBL',
      'NBL',
      'Champions League',
      'EuroCup',
      'VTB United League'
  )
ORDER BY notes, canonical_league_id;