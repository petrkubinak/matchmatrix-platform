/*
===============================================================================
MATCHMATRIX 20_3_C – PEOPLE READINESS BY SPORT BEFORE HARVEST
===============================================================================

CO TO JE:
Audit připravenosti PEOPLE vrstvy po sportech.

K ČEMU TO JE:
Před velkým harvestem potřebujeme vědět, kde už máme hráče,
provider mapy a externí identity.

KDE TO UVIDÍME:
DBeaver
OPS Dashboard
People Pipeline
Harvest Readiness

JAK SE TO VYUŽIJE:
Určíme, které sporty jsou:
READY / PARTIAL / DATA_GAP

VÝSTUP:
- počet hráčů
- počet provider map
- počet external identity
- People status

NAVAZUJE NA:
20_3_B_core_readiness_by_sport_before_harvest.sql

DALŠÍ KROK:
20_3_D_media_readiness_by_sport_before_harvest.sql

SOUBOR:
20_3_C_people_readiness_by_sport_before_harvest.sql

KAM ULOŽIT:
C:\MatchMatrix-platform\db\ops\20_3\

JAK SPUSTIT:
DBeaver → spustit celý SQL skript.
===============================================================================
*/

WITH
player_counts AS (
    SELECT
        sport_id,
        COUNT(*) AS players_count
    FROM public.players
    GROUP BY sport_id
),
provider_map_counts AS (
    SELECT
        p.sport_id,
        COUNT(ppm.*) AS provider_map_count
    FROM public.player_provider_map ppm
    JOIN public.players p
      ON p.id = ppm.player_id
    GROUP BY p.sport_id
),
external_identity_counts AS (
    SELECT
        p.sport_id,
        COUNT(pei.*) AS external_identity_count
    FROM public.player_external_identity pei
    JOIN public.players p
      ON p.id = pei.player_id
    GROUP BY p.sport_id
)
SELECT
    s.code AS sport_code,
    s.name AS sport_name,

    COALESCE(pc.players_count, 0) AS players_count,
    COALESCE(pmc.provider_map_count, 0) AS provider_map_count,
    COALESCE(eic.external_identity_count, 0) AS external_identity_count,

    CASE
        WHEN COALESCE(pc.players_count, 0) >= 500
         AND COALESCE(pmc.provider_map_count, 0) >= 500
            THEN 'READY'

        WHEN COALESCE(pc.players_count, 0) > 0
          OR COALESCE(pmc.provider_map_count, 0) > 0
          OR COALESCE(eic.external_identity_count, 0) > 0
            THEN 'PARTIAL'

        ELSE 'DATA_GAP'
    END AS people_status

FROM public.sports s
LEFT JOIN player_counts pc
       ON pc.sport_id = s.id
LEFT JOIN provider_map_counts pmc
       ON pmc.sport_id = s.id
LEFT JOIN external_identity_counts eic
       ON eic.sport_id = s.id
ORDER BY
    players_count DESC,
    provider_map_count DESC;