-- C:\MatchMatrix-platform\db\ops\721_people_fallback_seed.sql

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
    updated_at,
    is_primary,
    priority
)
VALUES
('sportsdataio','BK','players','planned',true,2,2,50,'unknown','paid_only',false,true,'extended',false,true,true,NULL,'staging.stg_provider_players',NULL,'Fallback provider pro basketball players NBA/NCAA.','Nutno ověřit cenu, coverage a endpoint.','Smoke test players endpoint.',now(),now(),false,2),
('sportsdataio','BSB','players','planned',true,2,2,50,'unknown','paid_only',false,true,'extended',false,true,true,NULL,'staging.stg_provider_players',NULL,'Fallback provider pro baseball players MLB.','Nutno ověřit cenu, coverage a endpoint.','Smoke test players endpoint.',now(),now(),false,2),
('sportsdataio','HK','players','planned',true,2,2,50,'unknown','paid_only',false,true,'extended',false,true,true,NULL,'staging.stg_provider_players',NULL,'Fallback provider pro hockey players NHL.','Nutno ověřit cenu, coverage a endpoint.','Smoke test players endpoint.',now(),now(),false,2),
('sportmonks','CK','players','planned',true,2,2,50,'unknown','paid_only',false,true,'extended',false,true,true,NULL,'staging.stg_provider_players',NULL,'Fallback provider pro cricket players.','Nutno ověřit Sportmonks cricket coverage a endpoint.','Smoke test cricket players endpoint.',now(),now(),false,2),
('rapidapi_tennis','TN','players','planned',true,2,2,50,'unknown','paid_only',false,true,'extended',false,true,true,NULL,'staging.stg_provider_players',NULL,'Fallback provider pro tennis player profiles/rankings.','Tennis je special case, profiles/rankings nejsou klasické týmové soupisky.','Smoke test tennis players/profiles endpoint.',now(),now(),false,2),
('sportsdataio','MMA','players','planned',true,2,2,50,'unknown','paid_only',false,true,'extended',false,true,true,NULL,'staging.stg_provider_players',NULL,'Fallback provider pro MMA fighters.','Nutno ověřit UFC/MMA coverage a endpoint.','Smoke test fighters endpoint.',now(),now(),false,2)
ON CONFLICT DO NOTHING;

SELECT
    provider,
    sport_code,
    entity,
    coverage_status,
    quality_rating,
    is_primary,
    is_fallback_source,
    priority
FROM ops.provider_entity_coverage
WHERE entity = 'players'
ORDER BY sport_code, priority, provider;