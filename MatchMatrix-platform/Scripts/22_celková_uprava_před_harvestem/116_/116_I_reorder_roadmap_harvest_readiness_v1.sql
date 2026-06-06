/*
===============================================================================
MATCHMATRIX SQL 116_I
REORDER ROADMAP - HARVEST READINESS FIRST V1
===============================================================================
*/

UPDATE ops.project_milestones
SET
    priority = 2,
    planned_date = DATE '2026-06-10',
    status = 'IN_PROGRESS',
    progress_percent = 40,
    description = 'Připravit DB, OPS, provider routing, People, Media a panel na hromadný harvest.'
WHERE milestone_code = 'PRO_HARVEST_READY';

UPDATE ops.project_milestones
SET
    priority = 3,
    planned_date = DATE '2026-06-20',
    description = 'Dokončit football people, coaches, statistics a PRO readiness před hromadným harvestem.'
WHERE milestone_code = 'FOOTBALL_100';

UPDATE ops.project_milestones
SET
    priority = 4,
    planned_date = DATE '2026-06-23',
    description = 'Dokončit hlavní People/Core vrstvy HK a BK před hromadným harvestem.'
WHERE milestone_code = 'HK_BK_READY';

UPDATE ops.project_milestones
SET
    priority = 5,
    planned_date = DATE '2026-06-25',
    status = 'IN_PROGRESS',
    progress_percent = 35,
    description = 'Rozšířit People vrstvu na další sporty před PRO harvestem.'
WHERE milestone_code = 'PEOPLE_EXPANSION';

UPDATE ops.project_milestones
SET
    priority = 6,
    planned_date = DATE '2026-06-27',
    status = 'IN_PROGRESS',
    progress_percent = 50,
    description = 'Dokončit media ingest, parsery, merge, scoring, entity matcher a video/highlights přípravu.'
WHERE milestone_code = 'MEDIA_EXPANSION';

UPDATE ops.project_milestones
SET
    priority = 7,
    planned_date = DATE '2026-06-28',
    status = 'PLANNED',
    progress_percent = 0,
    description = 'Dokončit OPS panel pro řízení harvestu, People, Media, Scheduleru a DB governance.'
WHERE milestone_code = 'SECOND_PC_READY';

UPDATE ops.project_milestones
SET
    priority = 8,
    planned_date = DATE '2026-07-01'
WHERE milestone_code = 'MASSIVE_BACKFILL_START';