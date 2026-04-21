-- 729_audit_hb_leagues_provider_coverage.sql
-- Cíl:
-- 1) potvrdit, co přesně api_handball pro leagues vrací do raw/staging
-- 2) ověřit, zda je coverage limit na provideru, nebo v parser/pull vrstvě

-- 1) poslední HB leagues payloady - základní přehled
SELECT
    p.id,
    p.provider,
    p.sport_code,
    p.entity_type,
    p.endpoint_name,
    p.external_id,
    p.season,
    p.parse_status,
    p.created_at
FROM staging.stg_api_payloads p
WHERE p.provider = 'api_handball'
  AND p.entity_type = 'leagues'
ORDER BY p.created_at DESC;

-- 2) kolik různých HB leagues payload runů máme
SELECT
    p.provider,
    p.sport_code,
    p.entity_type,
    p.endpoint_name,
    p.external_id,
    p.season,
    p.parse_status,
    COUNT(*) AS rows_cnt,
    MIN(p.created_at) AS first_seen,
    MAX(p.created_at) AS last_seen
FROM staging.stg_api_payloads p
WHERE p.provider = 'api_handball'
  AND p.entity_type = 'leagues'
GROUP BY
    p.provider,
    p.sport_code,
    p.entity_type,
    p.endpoint_name,
    p.external_id,
    p.season,
    p.parse_status
ORDER BY last_seen DESC;

-- 3) co je dnes v public.leagues z api_handball
SELECT
    l.id,
    l.name,
    l.country,
    l.ext_league_id,
    l.ext_source,
    l.created_at,
    l.updated_at
FROM public.leagues l
WHERE l.ext_source = 'api_handball'
ORDER BY l.ext_league_id;

-- 4) mapování provider -> canonical
SELECT
    lpm.league_id,
    l.name,
    lpm.provider,
    lpm.provider_league_id,
    lpm.created_at
FROM public.league_provider_map lpm
LEFT JOIN public.leagues l
    ON l.id = lpm.league_id
WHERE lpm.provider = 'api_handball'
ORDER BY lpm.provider_league_id;

-- 5) jestli v targetech / planneru máme přesně to samé
SELECT
    t.provider_league_id,
    t.season,
    t.run_group,
    t.enabled,
    t.tier,
    t.notes
FROM ops.ingest_targets t
WHERE t.provider = 'api_handball'
  AND t.sport_code = 'HB'
ORDER BY t.provider_league_id;

-- 6) souhrn: leagues vs targets vs planner rows
SELECT
    'public_leagues_api_handball' AS check_name,
    COUNT(*)::bigint AS row_count
FROM public.leagues
WHERE ext_source = 'api_handball'

UNION ALL

SELECT
    'league_provider_map_api_handball' AS check_name,
    COUNT(*)::bigint AS row_count
FROM public.league_provider_map
WHERE provider = 'api_handball'

UNION ALL

SELECT
    'ops_ingest_targets_HB_api_handball' AS check_name,
    COUNT(*)::bigint AS row_count
FROM ops.ingest_targets
WHERE provider = 'api_handball'
  AND sport_code = 'HB'

UNION ALL

SELECT
    'ops_ingest_planner_HB_leagues_api_handball' AS check_name,
    COUNT(*)::bigint AS row_count
FROM ops.ingest_planner
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND entity = 'leagues';

-- 7) kontrola, zda neexistují HB leagues někde bokem bez ext_source=api_handball
SELECT
    l.id,
    l.name,
    l.country,
    l.ext_source,
    l.ext_league_id,
    l.created_at
FROM public.leagues l
WHERE l.name IN ('Champions League', 'EHF European League', 'African Championship')
ORDER BY l.name, l.ext_source;