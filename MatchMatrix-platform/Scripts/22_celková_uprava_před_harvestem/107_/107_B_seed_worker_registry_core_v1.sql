/*
MATCHMATRIX SQL 107_B
Seed worker registry core workers V1

CO TO JE:
- Naplnění centrální worker registry základními produkčními workery.
- Registrují se hlavní orchestration workery používané schedulerem a panelem.

K ČEMU TO JE:
- Aby scheduler věděl:
  co existuje,
  co je production-safe,
  co lze automaticky spouštět,
  jaké timeouty a retry používat.

NA CO TO BUDE:
- SAFE EXECUTION MODE
- automation scheduler
- RUN NEXT engine
- autonomous orchestration
- worker runtime governance

KDE TO POUŽIJEME:
- ops.worker_registry
- budoucí worker resolver
- future retry engine
- C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V17.py
*/

INSERT INTO ops.worker_registry (
    worker_code,
    worker_name,
    worker_script,
    worker_type,
    sport_code,
    entity,
    layer_code,
    supports_scheduler,
    supports_retry,
    supports_parallel,
    timeout_sec,
    max_attempts,
    is_enabled,
    is_production_safe,
    worker_status,
    notes
)
VALUES

(
    'CORE_INGEST_V3',
    'Unified Core Ingest Cycle',
    'workers/run_ingest_cycle_v3.py',
    'python',
    NULL,
    'core',
    'core',
    true,
    true,
    false,
    300,
    3,
    true,
    true,
    'production_ready',
    'Main controlled ingest orchestration worker.'
),

(
    'PEOPLE_PIPELINE_V22',
    'People Pipeline Planner Runner',
    'workers/run_people_pipeline_v22_from_planner.py',
    'python',
    NULL,
    'players',
    'people',
    true,
    true,
    false,
    600,
    3,
    true,
    true,
    'production_ready',
    'Planner-driven people ingestion pipeline.'
),

(
    'MEDIA_PIPELINE_V1',
    'Media Pipeline Runner',
    'workers/media/run_media_pipeline_v1.py',
    'python',
    NULL,
    'media',
    'media',
    true,
    true,
    false,
    600,
    3,
    true,
    true,
    'implemented',
    'Unified media orchestration pipeline.'
),

(
    'MEDIA_MERGE_V1',
    'Media Merge To Public',
    'workers/media/merge_media_articles_to_public_v1.py',
    'python',
    NULL,
    'articles',
    'media',
    true,
    true,
    false,
    300,
    3,
    true,
    true,
    'runtime_tested',
    'Merge media articles from staging to public.'
),

(
    'MATCH_ARTICLE_PLAYERS_V1',
    'Match Article Players',
    'workers/media/match_article_players_v1_1.py',
    'python',
    NULL,
    'article_players',
    'media',
    false,
    true,
    false,
    300,
    3,
    true,
    true,
    'runtime_tested',
    'Media article player entity matcher.'
),

(
    'MATCH_ARTICLE_ENTITIES_V1',
    'Match Article Entities',
    'workers/media/match_article_entities_v1.py',
    'python',
    NULL,
    'article_entities',
    'media',
    false,
    true,
    false,
    300,
    3,
    true,
    true,
    'runtime_tested',
    'Media entity matcher for teams/leagues.'
)

ON CONFLICT (worker_code)
DO NOTHING;