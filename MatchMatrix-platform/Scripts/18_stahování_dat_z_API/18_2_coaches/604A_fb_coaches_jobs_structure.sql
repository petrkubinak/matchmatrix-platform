-- 604A_fb_coaches_jobs_structure.sql
-- Účel:
-- zjistit skutečnou strukturu ops.jobs a ops.scheduler_queue
-- abychom věděli, jak se jmenují sloupce

-- 1) struktura ops.jobs
select
    table_name,
    column_name,
    data_type
from information_schema.columns
where table_schema = 'ops'
  and table_name = 'jobs'
order by ordinal_position;

-- 2) struktura ops.scheduler_queue
select
    table_name,
    column_name,
    data_type
from information_schema.columns
where table_schema = 'ops'
  and table_name = 'scheduler_queue'
order by ordinal_position;