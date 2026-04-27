-- 736_audit_generic_multisport_usage.sql
-- =========================================================
-- Zjistí, které sporty/provider už reálně používají
-- nový generický staging model:
--   - staging.stg_api_payloads
--   - staging.stg_provider_leagues
--   - staging.stg_provider_teams
--   - staging.stg_provider_fixtures
--   - staging.stg_provider_odds
-- =========================================================

WITH payloads AS (
    SELECT
        provider,
        sport_code,
        COUNT(*) AS payload_rows,
        COUNT(*) FILTER (WHERE entity_type = 'leagues')  AS payload_leagues,
        COUNT(*) FILTER (WHERE entity_type = 'teams')    AS payload_teams,
        COUNT(*) FILTER (WHERE entity_type = 'fixtures') AS payload_fixtures,
        COUNT(*) FILTER (WHERE entity_type = 'odds')     AS payload_odds,
        COUNT(*) FILTER (WHERE parse_status = 'pending')   AS payload_pending,
        COUNT(*) FILTER (WHERE parse_status = 'processed') AS payload_processed,
        COUNT(*) FILTER (WHERE parse_status = 'error')     AS payload_error,
        MAX(fetched_at) AS last_payload_at
    FROM staging.stg_api_payloads
    GROUP BY provider, sport_code
),
leagues AS (
    SELECT
        provider,
        sport_code,
        COUNT(*) AS leagues_rows,
        MAX(created_at) AS last_leagues_at
    FROM staging.stg_provider_leagues
    GROUP BY provider, sport_code
),
teams AS (
    SELECT
        provider,
        sport_code,
        COUNT(*) AS teams_rows,
        MAX(created_at) AS last_teams_at
    FROM staging.stg_provider_teams
    GROUP BY provider, sport_code
),
fixtures AS (
    SELECT
        provider,
        sport_code,
        COUNT(*) AS fixtures_rows,
        MAX(created_at) AS last_fixtures_at
    FROM staging.stg_provider_fixtures
    GROUP BY provider, sport_code
),
odds AS (
    SELECT
        provider,
        sport_code,
        COUNT(*) AS odds_rows,
        MAX(created_at) AS last_odds_at
    FROM staging.stg_provider_odds
    GROUP BY provider, sport_code
),
all_keys AS (
    SELECT provider, sport_code FROM payloads
    UNION
    SELECT provider, sport_code FROM leagues
    UNION
    SELECT provider, sport_code FROM teams
    UNION
    SELECT provider, sport_code FROM fixtures
    UNION
    SELECT provider, sport_code FROM odds
)
SELECT
    k.provider,
    k.sport_code,

    COALESCE(p.payload_rows, 0)        AS payload_rows,
    COALESCE(p.payload_leagues, 0)     AS payload_leagues,
    COALESCE(p.payload_teams, 0)       AS payload_teams,
    COALESCE(p.payload_fixtures, 0)    AS payload_fixtures,
    COALESCE(p.payload_odds, 0)        AS payload_odds,
    COALESCE(p.payload_pending, 0)     AS payload_pending,
    COALESCE(p.payload_processed, 0)   AS payload_processed,
    COALESCE(p.payload_error, 0)       AS payload_error,

    COALESCE(l.leagues_rows, 0)        AS stg_leagues_rows,
    COALESCE(t.teams_rows, 0)          AS stg_teams_rows,
    COALESCE(f.fixtures_rows, 0)       AS stg_fixtures_rows,
    COALESCE(o.odds_rows, 0)           AS stg_odds_rows,

    CASE WHEN COALESCE(p.payload_rows, 0) > 0 THEN 'YES' ELSE 'NO' END AS uses_stg_api_payloads,
    CASE WHEN COALESCE(l.leagues_rows, 0) > 0 THEN 'YES' ELSE 'NO' END AS uses_stg_provider_leagues,
    CASE WHEN COALESCE(t.teams_rows, 0) > 0 THEN 'YES' ELSE 'NO' END AS uses_stg_provider_teams,
    CASE WHEN COALESCE(f.fixtures_rows, 0) > 0 THEN 'YES' ELSE 'NO' END AS uses_stg_provider_fixtures,
    CASE WHEN COALESCE(o.odds_rows, 0) > 0 THEN 'YES' ELSE 'NO' END AS uses_stg_provider_odds,

    CASE
        WHEN COALESCE(p.payload_rows, 0) > 0
         AND (
              COALESCE(l.leagues_rows, 0) > 0
           OR COALESCE(t.teams_rows, 0) > 0
           OR COALESCE(f.fixtures_rows, 0) > 0
           OR COALESCE(o.odds_rows, 0) > 0
         )
        THEN 'ACTIVE_NEW_MODEL'
        WHEN COALESCE(p.payload_rows, 0) > 0
        THEN 'RAW_ONLY_NEW_MODEL'
        ELSE 'NO_NEW_MODEL_ACTIVITY'
    END AS generic_model_status,

    GREATEST(
        COALESCE(p.last_payload_at, '-infinity'::timestamptz),
        COALESCE(l.last_leagues_at, '-infinity'::timestamptz),
        COALESCE(t.last_teams_at, '-infinity'::timestamptz),
        COALESCE(f.last_fixtures_at, '-infinity'::timestamptz),
        COALESCE(o.last_odds_at, '-infinity'::timestamptz)
    ) AS last_activity_at

FROM all_keys k
LEFT JOIN payloads p
       ON p.provider = k.provider
      AND p.sport_code = k.sport_code
LEFT JOIN leagues l
       ON l.provider = k.provider
      AND l.sport_code = k.sport_code
LEFT JOIN teams t
       ON t.provider = k.provider
      AND t.sport_code = k.sport_code
LEFT JOIN fixtures f
       ON f.provider = k.provider
      AND f.sport_code = k.sport_code
LEFT JOIN odds o
       ON o.provider = k.provider
      AND o.sport_code = k.sport_code

ORDER BY
    generic_model_status DESC,
    last_activity_at DESC,
    k.provider,
    k.sport_code;