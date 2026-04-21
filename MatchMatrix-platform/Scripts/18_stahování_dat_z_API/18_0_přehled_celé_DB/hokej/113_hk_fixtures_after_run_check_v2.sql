-- 113_hk_fixtures_after_run_check_v2.sql
-- Schema-safe kontrola pro HK fixtures po runu

DROP TABLE IF EXISTS temp_runtime_check_results;
CREATE TEMP TABLE temp_runtime_check_results (
    section      text,
    check_name   text,
    value_text   text
);

-- ============================================================
-- 1) Přehled sloupců v relevantních tabulkách
-- ============================================================
INSERT INTO temp_runtime_check_results (section, check_name, value_text)
SELECT
    'columns',
    table_schema || '.' || table_name,
    string_agg(column_name, ', ' ORDER BY ordinal_position)
FROM information_schema.columns
WHERE (table_schema, table_name) IN (
    ('staging', 'stg_api_payloads'),
    ('staging', 'stg_provider_fixtures'),
    ('public',  'matches')
)
GROUP BY table_schema, table_name
ORDER BY table_schema, table_name;

-- ============================================================
-- 2) Dynamické county podle existujících sloupců
-- ============================================================
DO $$
DECLARE
    has_stg_api_provider     boolean;
    has_stg_api_source       boolean;
    has_stg_api_endpoint     boolean;

    has_stg_fix_provider     boolean;
    has_stg_fix_sport        boolean;
    has_stg_fix_sport_code   boolean;

    has_matches_ext_source   boolean;
    has_matches_source       boolean;

    sql_text text;
    cnt bigint;
BEGIN
    -- staging.stg_api_payloads
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'staging' AND table_name = 'stg_api_payloads' AND column_name = 'provider'
    ) INTO has_stg_api_provider;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'staging' AND table_name = 'stg_api_payloads' AND column_name = 'source'
    ) INTO has_stg_api_source;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'staging' AND table_name = 'stg_api_payloads' AND column_name = 'endpoint'
    ) INTO has_stg_api_endpoint;

    sql_text := 'SELECT COUNT(*) FROM staging.stg_api_payloads WHERE 1=0';

    IF has_stg_api_provider THEN
        sql_text := sql_text || ' OR lower(coalesce(provider::text, '''')) like ''%hockey%''';
    END IF;

    IF has_stg_api_source THEN
        sql_text := sql_text || ' OR lower(coalesce(source::text, '''')) like ''%hockey%''';
    END IF;

    IF has_stg_api_endpoint THEN
        sql_text := sql_text || ' OR lower(coalesce(endpoint::text, '''')) like ''%games%'' OR lower(coalesce(endpoint::text, '''')) like ''%fixtures%''';
    END IF;

    EXECUTE sql_text INTO cnt;

    INSERT INTO temp_runtime_check_results VALUES (
        'counts',
        'stg_api_payloads_hk_fixtures',
        cnt::text
    );

    -- staging.stg_provider_fixtures
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'staging' AND table_name = 'stg_provider_fixtures' AND column_name = 'provider'
    ) INTO has_stg_fix_provider;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'staging' AND table_name = 'stg_provider_fixtures' AND column_name = 'sport'
    ) INTO has_stg_fix_sport;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'staging' AND table_name = 'stg_provider_fixtures' AND column_name = 'sport_code'
    ) INTO has_stg_fix_sport_code;

    sql_text := 'SELECT COUNT(*) FROM staging.stg_provider_fixtures WHERE 1=0';

    IF has_stg_fix_provider THEN
        sql_text := sql_text || ' OR lower(coalesce(provider::text, '''')) like ''%hockey%''';
    END IF;

    IF has_stg_fix_sport THEN
        sql_text := sql_text || ' OR lower(coalesce(sport::text, '''')) like ''%hockey%''';
    END IF;

    IF has_stg_fix_sport_code THEN
        sql_text := sql_text || ' OR lower(coalesce(sport_code::text, '''')) in (''hk'', ''hockey'')';
    END IF;

    EXECUTE sql_text INTO cnt;

    INSERT INTO temp_runtime_check_results VALUES (
        'counts',
        'stg_provider_fixtures_hk',
        cnt::text
    );

    -- public.matches
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'matches' AND column_name = 'ext_source'
    ) INTO has_matches_ext_source;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'matches' AND column_name = 'source'
    ) INTO has_matches_source;

    sql_text := 'SELECT COUNT(*) FROM public.matches WHERE 1=0';

    IF has_matches_ext_source THEN
        sql_text := sql_text || ' OR lower(coalesce(ext_source::text, '''')) like ''%hockey%''';
    END IF;

    IF has_matches_source THEN
        sql_text := sql_text || ' OR lower(coalesce(source::text, '''')) like ''%hockey%''';
    END IF;

    EXECUTE sql_text INTO cnt;

    INSERT INTO temp_runtime_check_results VALUES (
        'counts',
        'public_matches_hk',
        cnt::text
    );
END $$;

-- ============================================================
-- 3) Výstupy
-- ============================================================
SELECT *
FROM temp_runtime_check_results
ORDER BY section, check_name;

-- ============================================================
-- 4) Náhled dat z staging.stg_provider_fixtures
-- bezpečný univerzální preview přes JSON
-- ============================================================
SELECT to_jsonb(t)
FROM (
    SELECT *
    FROM staging.stg_provider_fixtures
    LIMIT 10
) t;