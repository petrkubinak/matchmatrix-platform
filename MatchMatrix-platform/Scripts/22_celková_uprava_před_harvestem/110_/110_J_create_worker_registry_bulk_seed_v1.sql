/*
MATCHMATRIX SQL 110_J Create Worker Registry Bulk Seed V1

CO TO JE:
- Doplnění centrálního registru workerů.

K ČEMU TO JE:
- Panel a AI OPS budou vědět, co který worker dělá.
- Launcher bude umět vybrat správný worker.
- Připraví se základ pro autonomní spouštění.

KDE TO UVIDÍME:
- Panel V18+
- AI OPS
- Worker Registry
- Autonomous Launcher

JAK SE TO VYUŽIJE:
- AI akce najde vhodný worker.
- Worker se spustí se správnými parametry.
- Výsledek se vrátí do OPS a learning vrstvy.
*/


INSERT INTO ops.worker_capability_registry
(
    worker_code,
    worker_path,
    supports_provider,
    supports_sport,
    supports_entity,
    supports_league_id,
    supports_season,
    supports_run_group,
    supports_direct_execution,
    worker_type,
    notes,
    is_active
)
VALUES

(
    'HARVEST_MASTER_V1',
    'workers/run_harvest_master_v1.py',
    true,true,true,false,false,true,true,
    'MASTER_ORCHESTRATOR',
    'Nejvyšší orchestrátor: core / odds / people / media / all.',
    true
),

(
    'FULL_HARVEST_CYCLE_V1',
    'workers/run_full_harvest_cycle_v1.py',
    true,true,true,false,false,true,true,
    'FULL_HARVEST_ORCHESTRATOR',
    'Spouští core ingest cycle a volitelně people/media cycle.',
    true
),

(
    'INGEST_PLANNER_WORKER',
    'workers/run_ingest_planner_jobs.py',
    true,true,true,true,true,true,true,
    'PLANNER_ORCHESTRATOR',
    'Centrální executor ops.ingest_planner. Umí claim job, retry, timeout, max_attempts.',
    true
),

(
    'PEOPLE_PIPELINE_V22',
    'workers/run_people_pipeline_v22_from_planner.py',
    true,true,true,true,true,true,true,
    'PEOPLE_ORCHESTRATOR',
    'Planner-driven PEOPLE worker pro players, paging, provider fallback, staging/public merge.',
    true
),

(
    'PEOPLE_MEDIA_CYCLE_V1',
    'workers/run_people_media_cycle_v1.py',
    true,true,true,false,false,true,true,
    'PEOPLE_MEDIA_ORCHESTRATOR',
    'Nadstavba pro people/media podle ops.ingest_entity_plan.',
    true
),

(
    'MEDIA_PIPELINE_V1',
    'workers/run_media_pipeline_v1.py',
    false,false,false,false,false,false,true,
    'MEDIA_ORCHESTRATOR',
    'Hlavní media orchestrátor: official site, RSS, parse, merge, entity match, score.',
    true
),

(
    'UNIFIED_STAGING_PUBLIC_MERGE_V3',
    'workers/run_unified_staging_to_public_merge_v3.py',
    false,false,false,false,false,false,true,
    'CORE_MERGE_ENGINE',
    'Merge staging -> public pro leagues, teams, players, matches a provider mapy.',
    true
),

(
    'PLAYERS_FETCH_ONLY_V1',
    'workers/run_players_fetch_only_v1.py',
    true,true,false,true,true,false,true,
    'PEOPLE_FETCH_WRAPPER',
    'API-Football players fetch wrapper. Umí single mode i batch mode.',
    true
),

(
    'BK_PLAYERS_FETCH_V1',
    'workers/run_players_fetch_bk_only_v1.py',
    true,true,false,true,true,true,true,
    'PEOPLE_FETCH_WORKER',
    'BK players fetch z ops.ingest_targets do staging.stg_api_payloads.',
    true
),

(
    'HK_PLAYERS_FETCH_V1',
    'workers/run_players_fetch_hk_only_v1.py',
    true,true,false,true,true,false,true,
    'PEOPLE_FETCH_WORKER',
    'HK players fetch. Umí team_id, league_id, season, run_id.',
    true
),

(
    'HK_PLAYERS_PIPELINE_V1',
    'workers/run_players_pipeline_hk_v1.py',
    true,true,false,true,true,false,true,
    'PEOPLE_PIPELINE',
    'HK pipeline: fetch -> parse -> bridge -> public merge -> season stats bridge.',
    true
),

(
    'SCHEDULER_QUEUE_EXECUTOR_V2',
    'workers/run_scheduler_queue_executor_v2.py',
    true,true,false,true,false,false,true,
    'SCHEDULER_EXECUTOR',
    'Executor ops.scheduler_queue: pending -> running -> done/error.',
    true
),

(
    'THEODDS_INGEST_V3',
    'workers/run_theodds_ingest_v3.py',
    false,false,false,false,false,false,true,
    'ODDS_INGEST',
    'Aktuální TheOdds ingest wrapper V3.',
    true
),

(
    'MEDIA_QUEUE_WORKERS_V1',
    'workers/media/run_media_queue_workers_v1.py',
    false,false,false,false,false,false,true,
    'MEDIA_QUEUE_ORCHESTRATOR',
    'Spouští media queue workery: quality filter a breaking news.',
    true
),

(
    'MEDIA_BREAKING_NEWS_V1',
    'workers/media/run_media_breaking_news_worker_v1.py',
    false,false,false,false,false,false,true,
    'MEDIA_AI_WORKER',
    'Zpracuje ops.media_refresh_queue request_type=breaking_news_score.',
    true
),

(
    'MEDIA_QUALITY_FILTER_V1',
    'workers/media/run_media_quality_filter_worker_v1.py',
    false,false,false,false,false,false,true,
    'MEDIA_FILTER',
    'Zpracuje ops.media_refresh_queue request_type=quality_filter.',
    true
),

(
    'MEDIA_VELOCITY_SNAPSHOT_V1',
    'workers/media/run_media_velocity_snapshot_worker_v1.py',
    false,false,false,false,false,false,true,
    'MEDIA_ANALYTICS',
    'Zapisuje media velocity snapshoty do ops.media_article_velocity_log.',
    true
),

(
    'MEDIA_ASSET_ENRICHMENT_V1',
    'workers/media/run_media_asset_enrichment_v1.py',
    false,false,false,false,false,false,true,
    'MEDIA_ASSET_ENGINE',
    'Doplňuje player photos, team logos a league logos z enrichment queue.',
    true
),

(
    'PLAYER_TRENDING_ENGINE_V1',
    'workers/run_player_trending_engine_v1.py',
    false,false,false,false,false,false,true,
    'ANALYTICS_ENGINE',
    'Počítá public.player_trending z článků a article_player_map.',
    true
)

ON CONFLICT (worker_code)
DO UPDATE SET
    worker_path = EXCLUDED.worker_path,
    supports_provider = EXCLUDED.supports_provider,
    supports_sport = EXCLUDED.supports_sport,
    supports_entity = EXCLUDED.supports_entity,
    supports_league_id = EXCLUDED.supports_league_id,
    supports_season = EXCLUDED.supports_season,
    supports_run_group = EXCLUDED.supports_run_group,
    supports_direct_execution = EXCLUDED.supports_direct_execution,
    worker_type = EXCLUDED.worker_type,
    notes = EXCLUDED.notes,
    is_active = EXCLUDED.is_active,
    updated_at = now();


CREATE OR REPLACE VIEW ops.v_worker_registry_panel_v1 AS
SELECT
    worker_code AS "Kód workeru",
    worker_type AS "Typ workeru",
    worker_path AS "Cesta",
    supports_provider AS "Provider",
    supports_sport AS "Sport",
    supports_entity AS "Entita",
    supports_league_id AS "Liga",
    supports_season AS "Sezóna",
    supports_run_group AS "Run group",
    supports_direct_execution AS "Přímé spuštění",
    is_active AS "Aktivní",
    notes AS "Poznámka"
FROM ops.worker_capability_registry
ORDER BY
    worker_type,
    worker_code;