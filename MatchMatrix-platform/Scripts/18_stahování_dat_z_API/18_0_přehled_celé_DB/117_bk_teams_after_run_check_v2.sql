-- 117_bk_teams_after_run_check_v2.sql
-- Schema-safe kontrola pro BK teams po runu

DROP TABLE IF EXISTS temp_bk_teams_check_results;
CREATE TEMP TABLE temp_bk_teams_check_results (
    section    text,
    check_name text,
    value_text text
);

-- ============================================================
-- 1) Přehled sloupců
-- ============================================================
INSERT INTO temp_bk_teams_check_results (section, check_name, value_text)
SELECT
    'columns',
    table_schema || '.' || table_name,
    string_agg(column_name, ', ' ORDER BY ordinal_position)
FROM information_schema.columns
WHERE (table_schema, table_name) IN (
    ('public',  'api_raw_payloads'),
    ('staging', 'stg_api_payloads'),
    ('staging', 'stg_provider_teams'),
    ('public',  'team_provider_map'),
    ('public',  'teams')
)
GROUP BY table_schema, table_name
ORDER BY table_schema, table_name;

-- ============================================================
-- 2) Dynamické county
-- ============================================================
DO $$
DECLARE
    sql_text text;
    cnt bigint;

    has_api_raw_source boolean;
    has_api_raw_endpoint boolean;

    has_stg_api_provider boolean;
    has_stg_api_sport_code boolean;
    has_stg_api_entity_type boolean;
    has_stg_api_endpoint_name boolean;

    has_stg_teams_provider boolean;
    has_stg_teams_sport_code boolean;
    has_stg_teams_external_team_id boolean;
    has_stg_teams_team_name boolean;

    has_tpm_provider boolean;
BEGIN
    -- public.api_raw_payloads
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='public' AND table_name='api_raw_payloads' AND column_name='source'
    ) INTO has_api_raw_source;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='public' AND table_name='api_raw_payloads' AND column_name='endpoint'
    ) INTO has_api_raw_endpoint;

    sql_text := 'SELECT COUNT(*) FROM public.api_raw_payloads WHERE 1=0';

    IF has_api_raw_source THEN
        sql_text := sql_text || ' OR lower(coalesce(source::text, '''')) like ''%basket%'' OR lower(coalesce(source::text, '''')) like ''%sport%''';
    END IF;

    IF has_api_raw_endpoint THEN
        sql_text := sql_text || ' OR lower(coalesce(endpoint::text, '''')) like ''%teams%''';
    END IF;

    EXECUTE sql_text INTO cnt;
    INSERT INTO temp_bk_teams_check_results VALUES ('counts', 'api_raw_payloads_bk_teams', cnt::text);

    -- staging.stg_api_payloads
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='staging' AND table_name='stg_api_payloads' AND column_name='provider'
    ) INTO has_stg_api_provider;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='staging' AND table_name='stg_api_payloads' AND column_name='sport_code'
    ) INTO has_stg_api_sport_code;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='staging' AND table_name='stg_api_payloads' AND column_name='entity_type'
    ) INTO has_stg_api_entity_type;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='staging' AND table_name='stg_api_payloads' AND column_name='endpoint_name'
    ) INTO has_stg_api_endpoint_name;

    sql_text := 'SELECT COUNT(*) FROM staging.stg_api_payloads WHERE 1=0';

    IF has_stg_api_provider THEN
        sql_text := sql_text || ' OR lower(coalesce(provider::text, '''')) like ''%sport%''';
    END IF;

    IF has_stg_api_sport_code THEN
        sql_text := sql_text || ' OR lower(coalesce(sport_code::text, '''')) in (''bk'', ''basketball'')';
    END IF;

    IF has_stg_api_entity_type THEN
        sql_text := sql_text || ' OR lower(coalesce(entity_type::text, '''')) like ''%team%''';
    END IF;

    IF has_stg_api_endpoint_name THEN
        sql_text := sql_text || ' OR lower(coalesce(endpoint_name::text, '''')) like ''%team%''';
    END IF;

    EXECUTE sql_text INTO cnt;
    INSERT INTO temp_bk_teams_check_results VALUES ('counts', 'stg_api_payloads_bk_teams', cnt::text);

    -- staging.stg_provider_teams
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='staging' AND table_name='stg_provider_teams' AND column_name='provider'
    ) INTO has_stg_teams_provider;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='staging' AND table_name='stg_provider_teams' AND column_name='sport_code'
    ) INTO has_stg_teams_sport_code;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='staging' AND table_name='stg_provider_teams' AND column_name='external_team_id'
    ) INTO has_stg_teams_external_team_id;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='staging' AND table_name='stg_provider_teams' AND column_name='team_name'
    ) INTO has_stg_teams_team_name;

    sql_text := 'SELECT COUNT(*) FROM staging.stg_provider_teams WHERE 1=0';

    IF has_stg_teams_provider THEN
        sql_text := sql_text || ' OR lower(coalesce(provider::text, '''')) like ''%sport%''';
    END IF;

    IF has_stg_teams_sport_code THEN
        sql_text := sql_text || ' OR lower(coalesce(sport_code::text, '''')) in (''bk'', ''basketball'')';
    END IF;

    EXECUTE sql_text INTO cnt;
    INSERT INTO temp_bk_teams_check_results VALUES ('counts', 'stg_provider_teams_bk', cnt::text);

    -- public.team_provider_map
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='public' AND table_name='team_provider_map' AND column_name='provider'
    ) INTO has_tpm_provider;

    sql_text := 'SELECT COUNT(*) FROM public.team_provider_map WHERE 1=0';

    IF has_tpm_provider THEN
        sql_text := sql_text || ' OR lower(coalesce(provider::text, '''')) like ''%basket%'' OR lower(coalesce(provider::text, '''')) like ''%sport%''';
    END IF;

    EXECUTE sql_text INTO cnt;
    INSERT INTO temp_bk_teams_check_results VALUES ('counts', 'team_provider_map_bk', cnt::text);

    -- public.teams total
    SELECT COUNT(*) INTO cnt FROM public.teams;
    INSERT INTO temp_bk_teams_check_results VALUES ('counts', 'public_teams_total', cnt::text);
END $$;

-- ============================================================
-- 3) Výstupy
-- ============================================================
SELECT *
FROM temp_bk_teams_check_results
ORDER BY section, check_name;

-- ============================================================
-- 4) Preview BK rows ze stg_provider_teams
-- ============================================================
SELECT to_jsonb(t)
FROM (
    SELECT *
    FROM staging.stg_provider_teams
    WHERE
        (EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema='staging'
              AND table_name='stg_provider_teams'
              AND column_name='provider'
        ) AND lower(coalesce(provider::text, '')) like '%sport%')
        OR
        (EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema='staging'
              AND table_name='stg_provider_teams'
              AND column_name='sport_code'
        ) AND lower(coalesce(sport_code::text, '')) in ('bk', 'basketball'))
    ORDER BY created_at DESC NULLS LAST, id DESC
    LIMIT 20
) t;