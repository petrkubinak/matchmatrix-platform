INSERT INTO ops.provider_entity_coverage (
    provider,
    sport_code,
    entity,
    coverage_status,
    is_enabled,
    provider_priority,
    merge_priority,
    fetch_priority,
    quality_rating,
    availability_scope,
    free_plan_supported,
    paid_plan_supported,
    expected_depth,
    is_primary_source,
    is_fallback_source,
    is_merge_source,
    source_endpoint,
    target_table,
    worker_script,
    notes,
    limitations,
    next_action,
    created_at,
    updated_at
)
VALUES (
    'official_site',
    'FB',
    'articles',
    'runtime_tested',
    true,
    30,
    30,
    30,
    'medium',
    'partial',
    true,
    false,
    'basic',
    true,
    false,
    true,
    'official league/team news pages',
    'public.articles',
    'workers/media/pull_official_site_media_articles_v1.py',
    'Runtime ověřeno v media_source_health_audit: Bundesliga, LaLiga, Premier League, UEFA OK; FIFA/Serie A/Ligue 1 částečně nebo problém.',
    'Generic scraper není dostatečný pro všechny weby. UEFA/FIFA/Serie A/Ligue 1 mohou potřebovat vlastní parser.',
    'Vytvořit PC2 command pro spuštění media workeru mimo run_unified_ingest_v1.py.',
    now(),
    now()
)
ON CONFLICT DO NOTHING;

SELECT
    provider,
    sport_code,
    entity,
    coverage_status,
    quality_rating,
    availability_scope,
    expected_depth,
    worker_script,
    next_action
FROM ops.provider_entity_coverage
WHERE provider = 'official_site'
  AND sport_code = 'FB'
  AND entity = 'articles';