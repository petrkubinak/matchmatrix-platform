/*
===============================================================================
MATCHMATRIX SQL 19_5_M
PEOPLE DETAIL LAYER AUDIT
===============================================================================

CO TO JE:
- Audit všech detailních PEOPLE vrstev.
- Neřeší jen hráče jako jméno v public.players, ale i profily, statistiky,
  fotky, trenéry, zranění a další informace.

K ČEMU TO JE:
- Aby MatchMatrix věděl, kolik informací o hráči reálně máme.
- Zjistíme, co je READY, co je PARTIAL a co úplně chybí.

KDE TO UVIDÍME:
- People dashboard
- Sport Completion
- PC2 Command Center
- budoucí detail hráče na webu

JAK SE TO VYUŽIJE:
- Podle výsledku naplánujeme další harvest:
  profiles, stats, photos, coaches, injuries, transfers.
===============================================================================
*/

SELECT
    sport_code,
    sport_name,
    people_provider,
    players_supported,
    coaches_supported,
    profiles_supported,
    season_stats_supported,
    match_stats_supported,
    rankings_supported,
    photos_supported,
    provider_status,
    priority_order,
    notes
FROM ops.people_master_provider_matrix
ORDER BY sport_code, priority_order;

SELECT
    sport_code,
    sport_name,
    entity_type,
    layer_code,
    current_status,
    priority_score,
    current_provider,
    recommended_provider,
    access_type,
    estimated_coverage_pct,
    blocker_reason,
    next_action,
    research_status,
    research_rank
FROM ops.provider_missing_matrix
WHERE layer_code ILIKE '%PEOPLE%'
   OR entity_type IN (
        'PLAYERS',
        'COACHES',
        'PROFILES',
        'PLAYER_PROFILES',
        'SEASON_STATS',
        'MATCH_STATS',
        'PLAYER_PHOTOS',
        'COACH_PHOTOS',
        'INJURIES',
        'TRANSFERS',
        'RANKINGS'
   )
ORDER BY priority_score DESC, sport_code, entity_type;

SELECT
    provider,
    sport_code,
    entity,
    coverage_status,
    quality_rating,
    availability_scope,
    expected_depth,
    free_plan_supported,
    paid_plan_supported,
    worker_script,
    limitations,
    next_action
FROM ops.provider_entity_coverage
WHERE entity ILIKE '%player%'
   OR entity ILIKE '%coach%'
   OR entity ILIKE '%profile%'
   OR entity ILIKE '%stat%'
   OR entity ILIKE '%photo%'
   OR entity ILIKE '%injur%'
   OR entity ILIKE '%transfer%'
ORDER BY sport_code, entity, provider;

SELECT
    provider,
    sport_code,
    entity,
    current_state,
    last_run_group,
    last_log_summary,
    db_evidence_summary,
    next_action
FROM ops.runtime_entity_audit
WHERE entity ILIKE '%player%'
   OR entity ILIKE '%coach%'
   OR entity ILIKE '%profile%'
   OR entity ILIKE '%stat%'
   OR entity ILIKE '%photo%'
   OR entity ILIKE '%injur%'
   OR entity ILIKE '%transfer%'
ORDER BY sport_code, entity, provider;