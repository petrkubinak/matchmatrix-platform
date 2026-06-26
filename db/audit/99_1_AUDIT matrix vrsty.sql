/*
1. Provider Coverage
 */
SELECT
    sport_code,
    entity,
    provider,
    coverage_status,
    free_plan_supported,
    paid_plan_supported,
    expected_depth,
    quality_rating,
    next_action
FROM ops.provider_entity_coverage
ORDER BY sport_code, entity, provider;

/*
2. Missing Matrix
 */
SELECT *
FROM ops.provider_missing_matrix
ORDER BY sport_code, entity_type;

/*
3. People Audit
 */
SELECT *
FROM ops.provider_people_audit
ORDER BY sport_code;


/*
4. Source Registry
 */
SELECT *
FROM ops.source_registry
ORDER BY source_type, source_name;


/*
5. Source Discovery Matrix
 */
SELECT *
FROM ops.source_discovery_matrix
ORDER BY sport_code;
