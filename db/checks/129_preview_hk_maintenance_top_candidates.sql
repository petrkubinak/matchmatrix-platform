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
WHERE sport_code = 'HK'
  AND enabled = TRUE
  AND notes IN (
      'NHL',
      'KHL',
      'SHL',
      'DEL',
      'National League',
      'Champions League',
      'Extraliga',
      'Tipos Extraliga',
      'Hockey Allsvenskan',
      'Swiss League'
  )
ORDER BY notes, canonical_league_id;