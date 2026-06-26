/*
===============================================================================
MATCHMATRIX SQL 117_C
HARVEST PEOPLE READINESS V1

CO TO JE:
- Auditní view připravenosti People vrstvy
  na hromadný harvest dat.

K ČEMU TO JE:
- Vyhodnocuje stav hráčské vrstvy.
- Kontroluje provider mapping.
- Kontroluje coverage hráčů.
- Identifikuje sporty s People DATA GAP.

KDE TO UVIDÍME:
- OPS Panel
- Mission Control
- Harvest Dashboard
- People Audit Dashboard
- Budoucí Admin Web

JAK SE TO VYUŽIJE:
- kontrola připravenosti harvestu
- audit hráčských dat
- plánování providerů
- prioritizace rozvoje People vrstvy

ZDROJ DAT:
- ops.v_people_pipeline_summary_v1

VÝSTUP:
- people_readiness_score
- people_readiness_status
- recommendation_cz
- audit People coverage

===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_harvest_people_readiness_v1 AS
SELECT
    sport_code,
    sport_name,
    providers,
    raw_payloads,
    raw_pending,
    raw_parsed,
    raw_error,
    staging_players,
    staging_distinct_players,
    public_players,
    provider_maps,
    coverage_pct,
    sport_people_status,
    sort_order,

    LEAST(
        100,
        (
            CASE WHEN sport_people_status = 'READY' THEN 35 ELSE 0 END
            +
            CASE WHEN COALESCE(public_players,0) > 0 THEN 20 ELSE 0 END
            +
            CASE
                WHEN COALESCE(provider_maps,0) >= COALESCE(public_players,0)
                 AND COALESCE(public_players,0) > 0
                THEN 15 ELSE 0
            END
            +
            CASE WHEN COALESCE(staging_players,0) > 0 THEN 10 ELSE 0 END
            +
            CASE WHEN COALESCE(raw_payloads,0) > 0 THEN 10 ELSE 0 END
            +
            CASE
                WHEN sport_code IN ('FB','HK','BK') AND sport_people_status = 'READY'
                THEN 10
                WHEN sport_people_status = 'READY'
                THEN 5
                ELSE 0
            END
        )
    ) AS people_readiness_score,

    CASE
        WHEN sport_people_status = 'READY'
          AND COALESCE(public_players,0) > 0
          AND COALESCE(provider_maps,0) >= COALESCE(public_players,0)
        THEN 'PEOPLE_BASE_READY'

        WHEN sport_people_status = 'DATA_GAP'
        THEN 'PEOPLE_DATA_GAP'

        ELSE 'PEOPLE_REVIEW'
    END AS people_readiness_status,

    CASE
        WHEN sport_people_status = 'DATA_GAP'
            THEN 'Najít nebo doplnit People providera pro tento sport.'

        WHEN COALESCE(public_players,0) = 0
            THEN 'Doplnit hráče do public.players.'

        WHEN COALESCE(provider_maps,0) < COALESCE(public_players,0)
            THEN 'Doplnit player_provider_map.'

        WHEN sport_code IN ('FB','HK','BK')
            THEN 'Základní People vrstva je připravena. Doplnit profily, trenéry, fotky a detailní statistiky.'

        ELSE 'Základní People vrstva je připravena. Později doplnit profily, fotky a detailní statistiky.'
    END AS recommendation_cz

FROM ops.v_people_pipeline_summary_v1;