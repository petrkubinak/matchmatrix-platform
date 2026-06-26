-- =========================================================
-- MATCHMATRIX
-- PEOPLE QUALITY BACKFILL JOB INSERT V1
-- =========================================================
--
-- Co skript dělá:
-- ---------------------------------------------------------
-- Vloží do ops.ingest_planner nové PEOPLE BACKFILL joby
-- pro ligy s nízkou kvalitou player statistics coverage.
--
-- Zdroj:
-- ---------------------------------------------------------
-- ops.people_quality_backfill_queue
--
-- Cíl:
-- ---------------------------------------------------------
-- opakované dotažení:
-- - appearances
-- - ratings
-- - goals
-- - player statistics
--
-- Použití:
-- ---------------------------------------------------------
-- PEOPLE QUALITY IMPROVEMENT
--
-- Zaměřeno hlavně na:
-- ---------------------------------------------------------
-- - Premier League
-- - La Liga
-- - Serie A
-- - Ligue 1
-- - Bundesliga
-- - Eredivisie
-- - Championship
--
-- Co to zlepší:
-- ---------------------------------------------------------
-- - player detail pages
-- - AI scouting
-- - predictions
-- - player rankings
-- - trending players
-- - fantasy layer
-- - analytics
--
-- Web/App:
-- ---------------------------------------------------------
-- Uživatel uvidí:
-- - plnější statistiky hráčů
-- - více ratings
-- - více goals/assists
-- - lepší AI comparisons
-- - kvalitnější predictions
--
-- =========================================================

INSERT INTO ops.ingest_planner
(
    provider,
    sport_code,
    entity,
    provider_league_id,
    season,
    run_group,
    priority,
    status,
    attempts,
    next_run,
    created_at,
    updated_at
)
SELECT
    'api_football' AS provider,
    'FB' AS sport_code,
    'players' AS entity,
    lpm.provider_league_id,
    q.season,
    'FB_PEOPLE_QUALITY_BACKFILL_2024' AS run_group,
    q.priority,
    'pending' AS status,
    0 AS attempts,
    NOW() AS next_run,
    NOW() AS created_at,
    NOW() AS updated_at
FROM ops.people_quality_backfill_queue q
JOIN public.league_provider_map lpm
    ON lpm.league_id = q.league_id
    AND lpm.provider = 'api_football'
WHERE q.priority <= 10;