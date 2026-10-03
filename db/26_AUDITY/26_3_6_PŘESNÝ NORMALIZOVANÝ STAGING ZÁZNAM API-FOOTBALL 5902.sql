BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY;

SET LOCAL TIME ZONE 'UTC';


-- ============================================================================
-- VÝSTUP 1
-- PŘESNÝ NORMALIZOVANÝ STAGING ZÁZNAM API-FOOTBALL 5902
-- ============================================================================

SELECT
    to_jsonb(t) AS staging_team_record
FROM staging.stg_provider_teams t
WHERE t.provider = 'api_football'
  AND t.external_team_id::text = '5902'
ORDER BY t.id;


-- ============================================================================
-- VÝSTUP 2
-- PŘÍPADNÝ EXISTUJÍCÍ PUBLIC.TEAMS ŘÁDEK PODLE EXTERNÍHO ID
-- ============================================================================

SELECT
    to_jsonb(t) AS public_team_record
FROM public.teams t
WHERE t.ext_team_id::text = '5902'
   OR lower(COALESCE(t.name, '')) LIKE '%louvi%'
ORDER BY t.id;


-- ============================================================================
-- VÝSTUP 3
-- PŘÍPADNÉ MAPOVÁNÍ API-FOOTBALL 5902
-- ============================================================================

SELECT
    to_jsonb(p) AS provider_map_record,
    to_jsonb(t) AS linked_public_team
FROM public.team_provider_map p
LEFT JOIN public.teams t
    ON t.id = p.team_id
WHERE p.provider = 'api_football'
  AND p.provider_team_id::text = '5902'
ORDER BY p.team_id;


-- ============================================================================
-- VÝSTUP 4
-- ÚPLNÝ STAV HISTORICKÉHO KANONICKÉHO TÝMU 970
-- ============================================================================

SELECT
    to_jsonb(t) AS historical_team_record
FROM public.teams t
WHERE t.id = 970;


-- ============================================================================
-- VÝSTUP 5
-- VŠECHNY PROVIDEROVÉ IDENTITY TÝMU 970
-- ============================================================================

SELECT
    to_jsonb(p) AS provider_identity
FROM public.team_provider_map p
WHERE p.team_id = 970
ORDER BY
    p.provider,
    p.provider_team_id::text;


-- ============================================================================
-- VÝSTUP 6
-- ALIASY SPOJENÉ S RAAL / LA LOUVIERE
-- ============================================================================

SELECT
    to_jsonb(a) AS alias_record
FROM public.team_aliases a
WHERE lower(to_jsonb(a)::text) LIKE '%raal%'
   OR lower(to_jsonb(a)::text) LIKE '%louvi%'
ORDER BY to_jsonb(a)::text;


-- ============================================================================
-- VÝSTUP 7
-- ROZSAH SENIORSKÝCH API FIXTURES PRO TEAM ID 5902
-- ============================================================================

SELECT
    f.season,
    f.league_id,
    COUNT(*)::bigint AS fixture_rows,
    COUNT(DISTINCT f.fixture_id)::bigint AS distinct_fixtures,
    MIN(f.kickoff) AS first_kickoff,
    MAX(f.kickoff) AS last_kickoff
FROM staging.api_football_fixtures f
WHERE f.home_team_id = 5902
   OR f.away_team_id = 5902
GROUP BY
    f.season,
    f.league_id
ORDER BY
    f.season,
    f.league_id;


-- ============================================================================
-- VÝSTUP 8
-- KONTROLA SEZONY 2025 A JUPILER PRO LEAGUE API ID 144
-- ============================================================================

SELECT
    COUNT(*)::bigint AS fixture_rows,
    COUNT(DISTINCT f.fixture_id)::bigint AS distinct_fixtures,
    MIN(f.kickoff) AS first_kickoff,
    MAX(f.kickoff) AS last_kickoff
FROM staging.api_football_fixtures f
WHERE (f.home_team_id = 5902 OR f.away_team_id = 5902)
  AND f.season = 2025
  AND f.league_id = 144;


ROLLBACK;