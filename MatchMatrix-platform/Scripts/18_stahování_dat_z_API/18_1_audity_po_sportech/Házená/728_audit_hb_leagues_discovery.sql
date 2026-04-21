-- 728_audit_hb_leagues_discovery.sql
-- Audit: kolik HB lig uz je v systemu a jestli mame stopy pro dalsi leagues discovery

-- 1) HB ligy v public.leagues
SELECT
    l.id,
    l.name,
    l.country,
    l.ext_source,
    l.ext_league_id,
    l.created_at,
    l.updated_at
FROM public.leagues l
WHERE l.ext_source = 'api_handball'
ORDER BY l.country NULLS LAST, l.name;

-- 2) HB mapovani v public.league_provider_map
SELECT
    lpm.league_id,
    l.name,
    lpm.provider,
    lpm.provider_league_id,
    lpm.created_at,
    lpm.updated_at
FROM public.league_provider_map lpm
LEFT JOIN public.leagues l
    ON l.id = lpm.league_id
WHERE lpm.provider = 'api_handball'
ORDER BY lpm.provider_league_id;

-- 3) HB leagues payloady ve staging.stg_api_payloads
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

-- 4) souhrn HB leagues payloadu podle external_id / season
SELECT
    p.external_id,
    p.season,
    p.endpoint_name,
    p.parse_status,
    COUNT(*) AS payload_count,
    MIN(p.created_at) AS first_seen,
    MAX(p.created_at) AS last_seen
FROM staging.stg_api_payloads p
WHERE p.provider = 'api_handball'
  AND p.entity_type = 'leagues'
GROUP BY p.external_id, p.season, p.endpoint_name, p.parse_status
ORDER BY last_seen DESC;

-- 5) kolik HB lig je v public.leagues vs kolik HB targetu je v ops.ingest_targets
SELECT
    'public.leagues.api_handball' AS check_name,
    COUNT(*)::bigint AS row_count
FROM public.leagues
WHERE ext_source = 'api_handball'

UNION ALL

SELECT
    'ops.ingest_targets.HB.api_handball' AS check_name,
    COUNT(*)::bigint AS row_count
FROM ops.ingest_targets
WHERE provider = 'api_handball'
  AND sport_code = 'HB';

-- 6) HB matches podle ext_league_id - ať vidíme, které ligy jsou opravdu používané
SELECT
    l.ext_league_id AS provider_league_id,
    l.name,
    m.season,
    COUNT(*) AS matches_rows,
    MAX(m.updated_at) AS last_update_ts
FROM public.matches m
LEFT JOIN public.leagues l
    ON l.id = m.league_id
WHERE m.ext_source = 'api_handball'
GROUP BY l.ext_league_id, l.name, m.season
ORDER BY matches_rows DESC, l.ext_league_id;