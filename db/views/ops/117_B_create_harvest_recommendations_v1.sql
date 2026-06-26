/*
===============================================================================
MATCHMATRIX SQL 117_B
HARVEST RECOMMENDATIONS V1

CO TO JE:
- Doporučovací view pro vyhodnocení připravenosti projektu
  na hromadný harvest dat.

K ČEMU TO JE:
- Identifikuje nejslabší oblasti projektu.
- Automaticky generuje doporučení.
- Prioritizuje další práci.

KDE TO UVIDÍME:
- OPS Panel
- Mission Control
- Harvest Dashboard
- Audit Snapshoty
- Budoucí Admin Web

JAK SE TO VYUŽIJE:
- řízení projektu
- roadmap management
- harvest readiness
- AI OPS doporučení
- prioritizace vývoje

ZDROJ DAT:
- ops.project_milestones

VÝSTUP:
- risk_level
- risk_color
- recommendation_cz
- priority doporučení

===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_harvest_recommendations_v1 AS
SELECT
    milestone_code,
    milestone_name,
    category,
    planned_date,
    status,
    progress_percent,

    CASE
        WHEN progress_percent < 30 THEN 'CRITICAL'
        WHEN progress_percent < 60 THEN 'HIGH'
        WHEN progress_percent < 85 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS risk_level,

    CASE
        WHEN progress_percent < 30 THEN 'RED'
        WHEN progress_percent < 60 THEN 'ORANGE'
        WHEN progress_percent < 85 THEN 'YELLOW'
        ELSE 'GREEN'
    END AS risk_color,

    CASE
        WHEN milestone_code = 'HARVEST_LOCKS_READY'
            THEN 'Nejdříve ověřit worker locks, active runs a ochranu proti duplicitnímu spuštění na více PC.'

        WHEN milestone_code = 'HARVEST_PEOPLE_READY'
            THEN 'Dokončit People readiness: hráči, trenéři, profily, season stats, match stats a provider matrix.'

        WHEN milestone_code = 'HARVEST_MEDIA_READY'
            THEN 'Dokončit Media readiness: ingest, parsery, merge, scoring, entity matcher a video přípravu.'

        WHEN milestone_code = 'HARVEST_PANEL_READY'
            THEN 'Doplnit panel o Harvest/People/Media readiness, roadmap a governance přehled.'

        WHEN milestone_code = 'HARVEST_DB_READY'
            THEN 'DB je téměř připravená. Ověřit jen harvest-critical ACTIVE_REVIEW objekty a storage/indexy.'

        WHEN milestone_code = 'HARVEST_DRY_RUN_READY'
            THEN 'Po DB/People/Media/Locks připravit bezpečný harvest dry-run přes planner.'

        ELSE 'Ověřit stav a doplnit další krok.'
    END AS recommendation_cz

FROM ops.project_milestones
WHERE milestone_code LIKE 'HARVEST_%'
ORDER BY
    CASE
        WHEN progress_percent < 30 THEN 1
        WHEN progress_percent < 60 THEN 2
        WHEN progress_percent < 85 THEN 3
        ELSE 4
    END,
    priority;