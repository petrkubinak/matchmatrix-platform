/*
===============================================================================
MATCHMATRIX SQL 117_G
HARVEST DRY RUN READINESS V1

CO TO JE:
- Audit připravenosti na bezpečný harvest dry-run.

K ČEMU TO JE:
- Ověří, že lze bezpečně spustit první harvest test.
- Zkontroluje planner, locky, readiness a cíle harvestu.

KDE TO UVIDÍME:
- OPS Panel
- Mission Control
- Harvest Dashboard
- Audit Snapshot

JAK SE TO VYUŽIJE:
- rozhodnutí, zda lze spustit dry-run
- příprava na druhé PC
- příprava na červencový backfill

ZDROJ DAT:
- ops.project_milestones
- ops.v_harvest_readiness_dashboard_v1

VÝSTUP:
- dry_run_score
- dry_run_status
- recommendation_cz

VLIV NA HARVEST:
- Přímý
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_harvest_dry_run_readiness_v1 AS
SELECT
    overall_harvest_readiness,
    db_ready_percent,
    people_ready_percent,
    media_ready_percent,
    panel_ready_percent,
    locks_ready_percent,

    CASE
        WHEN overall_harvest_readiness >= 70
         AND db_ready_percent >= 80
         AND locks_ready_percent >= 80
        THEN 100

        WHEN overall_harvest_readiness >= 60
        THEN 75

        WHEN overall_harvest_readiness >= 50
        THEN 50

        ELSE 25
    END AS dry_run_score,

    CASE
        WHEN overall_harvest_readiness >= 70
         AND db_ready_percent >= 80
         AND locks_ready_percent >= 80
        THEN 'READY_FOR_DRY_RUN'

        WHEN overall_harvest_readiness >= 60
        THEN 'NEAR_READY'

        ELSE 'NOT_READY'
    END AS dry_run_status,

    CASE
        WHEN overall_harvest_readiness >= 70
         AND db_ready_percent >= 80
         AND locks_ready_percent >= 80
        THEN 'Lze připravit první bezpečný harvest dry-run.'

        WHEN overall_harvest_readiness >= 60
        THEN 'Dokončit poslední harvest mezery a připravit dry-run.'

        ELSE 'Nejprve zvýšit harvest readiness.'
    END AS recommendation_cz

FROM ops.v_harvest_readiness_dashboard_v1;