/*
MATCHMATRIX SQL 19_3_C
PC2 Command Center KPI Pack V1

CO TO JE:
- KPI balíček pro horní část PC2 Command Center.

K ČEMU TO JE:
- Aby panel V18 měl připravené jednoduché přehledové hodnoty.

KDE TO UVIDÍME:
- OPS Panel V18
- PC2 Command Center

JAK SE TO VYUŽIJE:
- Horní KPI bloky: READY, CORE, PEOPLE, MEDIA, PROVIDERS, PHOTOS.
*/

CREATE OR REPLACE VIEW ops.v_pc2_command_center_kpi_pack_v1 AS
SELECT
    'PC2_READY_SCORE' AS kpi_code,
    'PC2 připravenost' AS kpi_name_cs,
    ROUND(
        (
            (
                COUNT(*) FILTER (WHERE next_harvest_layer <> 'CORE')::numeric
                / NULLIF(COUNT(*),0)
            ) * 100
        ),
        2
    ) AS kpi_value,
    '%' AS kpi_unit,
    'Kolik sportů už není blokováno CORE vrstvou.' AS kpi_note_cs
FROM ops.v_pc2_command_center_dashboard_v1

UNION ALL

SELECT
    'CORE_SPORTS',
    'CORE priorita',
    COUNT(*) FILTER (WHERE next_harvest_layer = 'CORE')::numeric,
    'sporty',
    'Sporty, které musí nejdříve doplnit základní data.'
FROM ops.v_pc2_command_center_dashboard_v1

UNION ALL

SELECT
    'PEOPLE_SPORTS',
    'PEOPLE priorita',
    COUNT(*) FILTER (WHERE next_harvest_layer = 'PEOPLE')::numeric,
    'sporty',
    'Sporty, které mají CORE a čekají na People vrstvu.'
FROM ops.v_pc2_command_center_dashboard_v1

UNION ALL

SELECT
    'MEDIA_SPORTS',
    'MEDIA priorita',
    COUNT(*) FILTER (WHERE next_harvest_layer = 'MEDIA')::numeric,
    'sporty',
    'Sporty, které mají CORE + PEOPLE a čekají na Media vrstvu.'
FROM ops.v_pc2_command_center_dashboard_v1

UNION ALL

SELECT
    'PROVIDER_GAPS',
    'Provider gapy',
    SUM(provider_gap_total)::numeric,
    'gapů',
    'Celkový počet provider/datových mezer v PC2 roadmapě.'
FROM ops.v_pc2_command_center_dashboard_v1

UNION ALL

SELECT
    'PHOTO_LICENSE_REVIEW',
    'Photo licence',
    SUM(photo_license_review_count)::numeric,
    'kontrol',
    'Počet photo/logo/stadium zdrojů čekajících na kontrolu licence.'
FROM ops.v_pc2_command_center_dashboard_v1

UNION ALL

SELECT
    'PHOTO_WAIT_FOR_PAID',
    'Photo paid',
    SUM(photo_wait_for_paid_count)::numeric,
    'zdrojů',
    'Photo/logo zdroje čekající na placený plán.'
FROM ops.v_pc2_command_center_dashboard_v1;


CREATE OR REPLACE VIEW ops.v_pc2_command_center_kpi_cards_v1 AS
SELECT
    kpi_code,
    kpi_name_cs,
    kpi_value,
    kpi_unit,
    kpi_note_cs,

    CASE
        WHEN kpi_code = 'PC2_READY_SCORE' AND kpi_value >= 80 THEN 'GOOD'
        WHEN kpi_code = 'PC2_READY_SCORE' AND kpi_value >= 50 THEN 'WARNING'
        WHEN kpi_code = 'PC2_READY_SCORE' THEN 'CRITICAL'

        WHEN kpi_code = 'CORE_SPORTS' AND kpi_value = 0 THEN 'GOOD'
        WHEN kpi_code = 'CORE_SPORTS' AND kpi_value <= 2 THEN 'WARNING'
        WHEN kpi_code = 'CORE_SPORTS' THEN 'CRITICAL'

        WHEN kpi_code = 'PHOTO_WAIT_FOR_PAID' AND kpi_value = 0 THEN 'GOOD'
        WHEN kpi_code = 'PHOTO_WAIT_FOR_PAID' AND kpi_value <= 4 THEN 'WARNING'
        WHEN kpi_code = 'PHOTO_WAIT_FOR_PAID' THEN 'CRITICAL'

        ELSE 'INFO'
    END AS kpi_status

FROM ops.v_pc2_command_center_kpi_pack_v1
ORDER BY
    CASE kpi_code
        WHEN 'PC2_READY_SCORE' THEN 1
        WHEN 'CORE_SPORTS' THEN 2
        WHEN 'PEOPLE_SPORTS' THEN 3
        WHEN 'MEDIA_SPORTS' THEN 4
        WHEN 'PROVIDER_GAPS' THEN 5
        WHEN 'PHOTO_LICENSE_REVIEW' THEN 6
        WHEN 'PHOTO_WAIT_FOR_PAID' THEN 7
        ELSE 99
    END;


SELECT
    kpi_code,
    kpi_name_cs,
    kpi_value,
    kpi_unit,
    kpi_status
FROM ops.v_pc2_command_center_kpi_cards_v1;