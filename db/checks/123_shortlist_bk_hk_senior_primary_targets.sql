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
WHERE sport_code IN ('BK', 'HK')
  AND enabled = TRUE
  AND COALESCE(notes, '') <> ''
  AND notes NOT ILIKE '%Women%'
  AND notes NOT ILIKE '%U16%'
  AND notes NOT ILIKE '%U17%'
  AND notes NOT ILIKE '%U18%'
  AND notes NOT ILIKE '%U19%'
  AND notes NOT ILIKE '%U20%'
  AND notes NOT ILIKE '%U21%'
  AND notes NOT ILIKE '%Cup%'
  AND notes NOT ILIKE '%Games%'
  AND notes NOT ILIKE '%Tournament%'
  AND notes NOT ILIKE '%Friendly%'
  AND notes NOT ILIKE '%Championship%'
  AND notes NOT ILIKE '%Challenge%'
  AND notes NOT ILIKE '%World%'
  AND notes NOT ILIKE '%Olympic%'
  AND notes NOT ILIKE '%Universiade%'
ORDER BY sport_code, notes;