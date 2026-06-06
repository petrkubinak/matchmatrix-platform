/*
MATCHMATRIX SQL 117_M
PEOPLE MASTER READINESS V1

CO TO JE:
- Master audit připravenosti PEOPLE vrstvy podle sportů.

K ČEMU TO JE:
- Neřeší jen počet hráčů.
- Vyhodnocuje hráče, trenéry, profily, season stats, match stats, formu a provider mapy.

KDE TO UVIDÍME:
- OPS Panel -> PEOPLE.
- OPS Panel -> HARVEST.
- Budoucí Admin Web -> People Readiness.

JAK SE TO VYUŽIJE:
- Ukáže, který sport má PEOPLE vrstvu hotovou.
- Ukáže, kde chybí trenéři, statistiky, profily nebo provider.
- Pomůže rozhodnout další harvest/backfill krok.
*/

CREATE OR REPLACE VIEW ops.v_people_master_readiness_v1 AS
WITH sports AS (
    SELECT
        id AS sport_id,
        code AS sport_code,
        name AS sport_name
    FROM public.sports
    WHERE is_active = true
),
players_by_sport AS (
    SELECT
        p.sport_id,
        COUNT(*) AS players_count,
        COUNT(*) FILTER (WHERE p.photo_url IS NOT NULL AND trim(p.photo_url) <> '') AS players_with_photo,
        COUNT(*) FILTER (WHERE p.birth_date IS NOT NULL) AS players_with_birth_date,
        COUNT(*) FILTER (WHERE p.nationality IS NOT NULL AND trim(p.nationality) <> '') AS players_with_nationality
    FROM public.players p
    GROUP BY p.sport_id
),
coaches_by_sport AS (
    SELECT
        c.sport_id,
        COUNT(*) AS coaches_count,
        COUNT(*) FILTER (WHERE c.photo_url IS NOT NULL AND trim(c.photo_url) <> '') AS coaches_with_photo
    FROM public.coaches c
    GROUP BY c.sport_id
),
player_maps_by_sport AS (
    SELECT
        p.sport_id,
        COUNT(*) AS player_provider_maps
    FROM public.player_provider_map ppm
    JOIN public.players p
      ON p.id = ppm.player_id
    WHERE COALESCE(ppm.is_active, true) = true
    GROUP BY p.sport_id
),
coach_maps_by_sport AS (
    SELECT
        c.sport_id,
        COUNT(*) AS coach_provider_maps
    FROM public.coach_provider_map cpm
    JOIN public.coaches c
      ON c.id = cpm.coach_id
    WHERE COALESCE(cpm.is_active, true) = true
    GROUP BY c.sport_id
),
season_stats_by_sport AS (
    SELECT
        pss.sport_id,
        COUNT(*) AS player_season_stats_rows,
        COUNT(DISTINCT pss.player_id) AS players_with_season_stats
    FROM public.player_season_statistics pss
    GROUP BY pss.sport_id
),
match_stats_by_sport AS (
    SELECT
        p.sport_id,
        COUNT(*) AS player_match_stats_rows,
        COUNT(DISTINCT pms.player_id) AS players_with_match_stats
    FROM public.player_match_statistics pms
    JOIN public.players p
      ON p.id = pms.player_id
    GROUP BY p.sport_id
),
form_by_sport AS (
    SELECT
        pf.sport_id,
        COUNT(*) AS player_form_rows,
        COUNT(DISTINCT pf.player_id) AS players_with_form
    FROM public.player_form pf
    GROUP BY pf.sport_id
),
provider_matrix AS (
    SELECT
        sport_code,
        COUNT(*) AS people_providers,
        COUNT(*) FILTER (WHERE players_supported = true) AS providers_players_supported,
        COUNT(*) FILTER (WHERE coaches_supported = true) AS providers_coaches_supported,
        COUNT(*) FILTER (WHERE profiles_supported = true) AS providers_profiles_supported,
        COUNT(*) FILTER (WHERE season_stats_supported = true) AS providers_season_stats_supported,
        COUNT(*) FILTER (WHERE match_stats_supported = true) AS providers_match_stats_supported,
        COUNT(*) FILTER (WHERE provider_status ILIKE '%READY%' OR provider_status ILIKE '%CONFIRMED%') AS providers_ready
    FROM ops.people_master_provider_matrix
    GROUP BY sport_code
),
provider_audit AS (
    SELECT
        sport_code,
        COUNT(*) AS audited_people_endpoints,
        COUNT(*) FILTER (WHERE endpoint_exists = true) AS endpoints_exist,
        COUNT(*) FILTER (WHERE endpoint_returns_data = true) AS endpoints_return_data,
        COUNT(*) FILTER (WHERE requires_pro = true) AS endpoints_requires_pro,
        COUNT(*) FILTER (WHERE alternative_provider_needed = true) AS endpoints_need_alternative
    FROM ops.provider_people_audit
    GROUP BY sport_code
),
base AS (
    SELECT
        s.sport_code,
        s.sport_name,

        COALESCE(p.players_count, 0) AS players_count,
        COALESCE(p.players_with_photo, 0) AS players_with_photo,
        COALESCE(p.players_with_birth_date, 0) AS players_with_birth_date,
        COALESCE(p.players_with_nationality, 0) AS players_with_nationality,

        COALESCE(c.coaches_count, 0) AS coaches_count,
        COALESCE(c.coaches_with_photo, 0) AS coaches_with_photo,

        COALESCE(pm.player_provider_maps, 0) AS player_provider_maps,
        COALESCE(cm.coach_provider_maps, 0) AS coach_provider_maps,

        COALESCE(ss.player_season_stats_rows, 0) AS player_season_stats_rows,
        COALESCE(ss.players_with_season_stats, 0) AS players_with_season_stats,

        COALESCE(ms.player_match_stats_rows, 0) AS player_match_stats_rows,
        COALESCE(ms.players_with_match_stats, 0) AS players_with_match_stats,

        COALESCE(f.player_form_rows, 0) AS player_form_rows,
        COALESCE(f.players_with_form, 0) AS players_with_form,

        COALESCE(mx.people_providers, 0) AS people_providers,
        COALESCE(mx.providers_players_supported, 0) AS providers_players_supported,
        COALESCE(mx.providers_coaches_supported, 0) AS providers_coaches_supported,
        COALESCE(mx.providers_profiles_supported, 0) AS providers_profiles_supported,
        COALESCE(mx.providers_season_stats_supported, 0) AS providers_season_stats_supported,
        COALESCE(mx.providers_match_stats_supported, 0) AS providers_match_stats_supported,
        COALESCE(mx.providers_ready, 0) AS providers_ready,

        COALESCE(pa.audited_people_endpoints, 0) AS audited_people_endpoints,
        COALESCE(pa.endpoints_exist, 0) AS endpoints_exist,
        COALESCE(pa.endpoints_return_data, 0) AS endpoints_return_data,
        COALESCE(pa.endpoints_requires_pro, 0) AS endpoints_requires_pro,
        COALESCE(pa.endpoints_need_alternative, 0) AS endpoints_need_alternative

    FROM sports s
    LEFT JOIN players_by_sport p ON p.sport_id = s.sport_id
    LEFT JOIN coaches_by_sport c ON c.sport_id = s.sport_id
    LEFT JOIN player_maps_by_sport pm ON pm.sport_id = s.sport_id
    LEFT JOIN coach_maps_by_sport cm ON cm.sport_id = s.sport_id
    LEFT JOIN season_stats_by_sport ss ON ss.sport_id = s.sport_id
    LEFT JOIN match_stats_by_sport ms ON ms.sport_id = s.sport_id
    LEFT JOIN form_by_sport f ON f.sport_id = s.sport_id
    LEFT JOIN provider_matrix mx ON mx.sport_code = s.sport_code
    LEFT JOIN provider_audit pa ON pa.sport_code = s.sport_code
)
SELECT
    sport_code,
    sport_name,

    players_count,
    coaches_count,
    player_provider_maps,
    coach_provider_maps,

    player_season_stats_rows,
    player_match_stats_rows,
    player_form_rows,

    people_providers,
    providers_ready,
    audited_people_endpoints,
    endpoints_return_data,
    endpoints_requires_pro,
    endpoints_need_alternative,

    ROUND(
        CASE WHEN players_count > 0
        THEN (player_provider_maps::numeric / players_count::numeric) * 100
        ELSE 0 END,
        2
    ) AS player_map_coverage_pct,

    ROUND(
        CASE WHEN players_count > 0
        THEN (players_with_season_stats::numeric / players_count::numeric) * 100
        ELSE 0 END,
        2
    ) AS season_stats_coverage_pct,

    ROUND(
        CASE WHEN players_count > 0
        THEN (players_with_match_stats::numeric / players_count::numeric) * 100
        ELSE 0 END,
        2
    ) AS match_stats_coverage_pct,

    ROUND(
        CASE WHEN players_count > 0
        THEN (players_with_form::numeric / players_count::numeric) * 100
        ELSE 0 END,
        2
    ) AS form_coverage_pct,

    LEAST(
        100,
        (
            CASE WHEN players_count > 0 THEN 20 ELSE 0 END
            +
            CASE WHEN player_provider_maps >= players_count AND players_count > 0 THEN 20
                 WHEN player_provider_maps > 0 THEN 10
                 ELSE 0 END
            +
            CASE WHEN coaches_count > 0 THEN 10 ELSE 0 END
            +
            CASE WHEN player_season_stats_rows > 0 THEN 15 ELSE 0 END
            +
            CASE WHEN player_match_stats_rows > 0 THEN 15 ELSE 0 END
            +
            CASE WHEN player_form_rows > 0 THEN 10 ELSE 0 END
            +
            CASE WHEN people_providers > 0 THEN 10 ELSE 0 END
        )
    ) AS people_master_score,

    CASE
        WHEN players_count = 0 THEN 'DATA_GAP'
        WHEN people_providers = 0 THEN 'PROVIDER_GAP'
        WHEN player_provider_maps = 0 THEN 'MAP_GAP'
        WHEN player_season_stats_rows = 0 AND player_match_stats_rows = 0 THEN 'STATS_GAP'
        WHEN LEAST(
            100,
            (
                CASE WHEN players_count > 0 THEN 20 ELSE 0 END
                +
                CASE WHEN player_provider_maps >= players_count AND players_count > 0 THEN 20
                     WHEN player_provider_maps > 0 THEN 10
                     ELSE 0 END
                +
                CASE WHEN coaches_count > 0 THEN 10 ELSE 0 END
                +
                CASE WHEN player_season_stats_rows > 0 THEN 15 ELSE 0 END
                +
                CASE WHEN player_match_stats_rows > 0 THEN 15 ELSE 0 END
                +
                CASE WHEN player_form_rows > 0 THEN 10 ELSE 0 END
                +
                CASE WHEN people_providers > 0 THEN 10 ELSE 0 END
            )
        ) >= 80 THEN 'READY'
        WHEN LEAST(
            100,
            (
                CASE WHEN players_count > 0 THEN 20 ELSE 0 END
                +
                CASE WHEN player_provider_maps >= players_count AND players_count > 0 THEN 20
                     WHEN player_provider_maps > 0 THEN 10
                     ELSE 0 END
                +
                CASE WHEN coaches_count > 0 THEN 10 ELSE 0 END
                +
                CASE WHEN player_season_stats_rows > 0 THEN 15 ELSE 0 END
                +
                CASE WHEN player_match_stats_rows > 0 THEN 15 ELSE 0 END
                +
                CASE WHEN player_form_rows > 0 THEN 10 ELSE 0 END
                +
                CASE WHEN people_providers > 0 THEN 10 ELSE 0 END
            )
        ) >= 50 THEN 'PARTIAL'
        ELSE 'NOT_READY'
    END AS people_master_status,

    CASE
        WHEN players_count = 0
            THEN 'Najít nebo napojit provider pro hráče tohoto sportu.'
        WHEN people_providers = 0
            THEN 'Doplnit people providera do ops.people_master_provider_matrix.'
        WHEN player_provider_maps = 0
            THEN 'Doplnit player_provider_map pro propojení hráčů s providerem.'
        WHEN player_season_stats_rows = 0 AND player_match_stats_rows = 0
            THEN 'Doplnit season stats nebo match stats pro hráče.'
        WHEN endpoints_requires_pro > 0
            THEN 'Část PEOPLE vrstvy čeká na PRO provider plán.'
        ELSE 'PEOPLE vrstva je použitelná, pokračovat enrichmentem profilů a statistik.'
    END AS recommendation_cz,

    now() AS generated_at

FROM base
ORDER BY
    people_master_score DESC,
    sport_code;