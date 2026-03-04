-- 091_api_football_merge_run_mode.sql

-- =========================================
-- Nastavení režimu (ručně uprav před během)
-- =========================================

-- Možnosti:
-- 'pull_merge'
-- 'merge_only'

WITH settings AS (
    SELECT 
        'merge_only'::text AS mode,
        123::int          AS run_id
),

guard AS (
    SELECT
        CASE
            WHEN mode = 'merge_only' AND run_id IS NULL
            THEN 1/0
            ELSE 1
        END AS guard_ok
    FROM settings
)

SELECT * FROM guard;