SELECT
    t.id AS ingest_target_id,
    t.canonical_league_id,
    l.name AS canonical_league_name,
    l.country,
    l.ext_source,
    l.ext_league_id,
    t.provider,
    t.provider_league_id,
    t.notes,
    t.run_group
FROM ops.ingest_targets t
LEFT JOIN public.leagues l
       ON l.id = t.canonical_league_id
WHERE t.sport_code = 'BK'
  AND t.enabled = TRUE
  AND (
       l.country ILIKE '%China%'
    OR l.name ILIKE '%China%'
    OR t.notes ILIKE '%China%'
    OR t.notes IN ('CBA', 'WCBA Women')
  )
ORDER BY l.country, l.name, t.canonical_league_id;