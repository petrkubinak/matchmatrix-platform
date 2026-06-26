/*
CO TO JE:
Oprava view ops.v_people_pipeline_summary_v1.

K ČEMU TO JE:
Správně vyhodnotí stav PEOPLE vrstvy pro všechny sporty.

KDE TO UVIDÍME:
Control Panel V17
PEOPLE záložka
Dashboardy OPS

JAK SE TO VYUŽIJE:
READY/PARTIAL/DATA_GAP bude odpovídat skutečnému stavu databáze.
Coverage nikdy nepřekročí 100 %.
FB bude po opravě označen jako READY.
Scheduler a OPS budou mít správný přehled o dokončenosti PEOPLE vrstvy
*/

CREATE OR REPLACE VIEW ops.v_people_pipeline_summary_v1 AS
WITH sports_base AS (
    SELECT
        sports.code AS sport_code,
        sports.name AS sport_name,
        sports.sort_order
    FROM public.sports
    WHERE sports.is_active = true
),
people AS (
    SELECT
        a.sport_code,
        COUNT(DISTINCT a.provider) AS providers,
        SUM(a.raw_payloads) AS raw_payloads,
        SUM(a.raw_pending) AS raw_pending,
        SUM(a.raw_parsed) AS raw_parsed,
        SUM(a.raw_error) AS raw_error,
        SUM(a.staging_players) AS staging_players,
        SUM(a.staging_distinct_players) AS staging_distinct_players,
        SUM(a.public_players) AS public_players,
        SUM(a.provider_maps) AS provider_maps
    FROM ops.v_people_pipeline_audit_v1 a
    GROUP BY a.sport_code
)
SELECT
    s.sport_code,
    s.sport_name,
    COALESCE(p.providers, 0::bigint) AS providers,
    COALESCE(p.raw_payloads, 0::numeric) AS raw_payloads,
    COALESCE(p.raw_pending, 0::numeric) AS raw_pending,
    COALESCE(p.raw_parsed, 0::numeric) AS raw_parsed,
    COALESCE(p.raw_error, 0::numeric) AS raw_error,
    COALESCE(p.staging_players, 0::numeric) AS staging_players,
    COALESCE(p.staging_distinct_players, 0::numeric) AS staging_distinct_players,
    COALESCE(p.public_players, 0::numeric) AS public_players,
    COALESCE(p.provider_maps, 0::numeric) AS provider_maps,

    CASE
        WHEN COALESCE(p.staging_distinct_players, 0::numeric) = 0::numeric THEN 0::numeric
        ELSE LEAST(
            ROUND(COALESCE(p.public_players, 0::numeric) / NULLIF(p.staging_distinct_players, 0::numeric) * 100::numeric, 2),
            100.00
        )
    END AS coverage_pct,

    CASE
        WHEN COALESCE(p.staging_distinct_players, 0::numeric) > 0::numeric
         AND COALESCE(p.public_players, 0::numeric) >= COALESCE(p.staging_distinct_players, 0::numeric)
         AND COALESCE(p.provider_maps, 0::numeric) >= COALESCE(p.staging_distinct_players, 0::numeric)
            THEN 'READY'::text

        WHEN COALESCE(p.public_players, 0::numeric) > 0::numeric
         AND COALESCE(p.public_players, 0::numeric) < COALESCE(p.staging_distinct_players, 0::numeric)
            THEN 'PARTIAL'::text

        WHEN COALESCE(p.staging_distinct_players, 0::numeric) > 0::numeric
         AND COALESCE(p.public_players, 0::numeric) = 0::numeric
            THEN 'READY_FOR_MERGE'::text

        WHEN COALESCE(p.raw_pending, 0::numeric) > 0::numeric
            THEN 'RAW_PENDING_PARSE'::text

        ELSE 'DATA_GAP'::text
    END AS sport_people_status,

    s.sort_order
FROM sports_base s
LEFT JOIN people p
    ON p.sport_code = s.sport_code
ORDER BY s.sort_order, s.sport_code;