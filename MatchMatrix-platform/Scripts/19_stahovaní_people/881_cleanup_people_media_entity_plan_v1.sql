-- ============================================================
-- 881_cleanup_people_media_entity_plan_v1.sql
-- MatchMatrix - cleanup people/media entity plan
--
-- Kam uložit:
-- C:\MatchMatrix-platform\db\audit\881_cleanup_people_media_entity_plan_v1.sql
--
-- Spustit v DBeaveru.
--
-- Účel:
-- - staré people řádky bez target_table vypne nebo srovná
-- - core run_group nechá pro core entity, people/media přesune do *_PEOPLE / *_MEDIA
-- ============================================================

BEGIN;

-- 1) Srovnat api_basketball BK na starší legacy provider.
-- Primární BK people chceme držet přes api_sport / BK_PEOPLE.
UPDATE ops.ingest_entity_plan
SET
    enabled = FALSE,
    notes = COALESCE(notes, '') || ' | DISABLED by 881: legacy api_basketball people row, primary BK people provider is api_sport.',
    updated_at = NOW()
WHERE provider = 'api_basketball'
  AND sport_code = 'BK'
  AND entity IN ('players', 'coaches');

-- 2) Srovnat placeholder sporty bez reálného people pipeline.
-- Necháme je v DB jako plán, ale vypnuté, dokud nebude provider/worker.
UPDATE ops.ingest_entity_plan
SET
    enabled = FALSE,
    notes = COALESCE(notes, '') || ' | DISABLED by 881: people layer planned, missing provider/worker/target pipeline.',
    updated_at = NOW()
WHERE provider IN (
    'api_darts',
    'api_esports',
    'api_field_hockey',
    'api_mma',
    'api_tennis'
)
AND entity IN (
    'players',
    'player_profiles',
    'player_season_stats',
    'player_stats',
    'coaches'
);

-- 3) Pro jistotu doplnit target_table tam, kde people rows zůstávají enabled.
UPDATE ops.ingest_entity_plan
SET
    target_table = CASE
        WHEN entity = 'players' THEN 'staging.stg_provider_players'
        WHEN entity = 'player_profiles' THEN 'staging.stg_provider_player_profiles'
        WHEN entity = 'player_season_stats' THEN 'staging.stg_provider_player_season_stats'
        WHEN entity = 'player_stats' THEN 'staging.stg_provider_player_stats'
        WHEN entity = 'coaches' THEN 'staging.stg_provider_coaches'
        ELSE target_table
    END,
    updated_at = NOW()
WHERE enabled = TRUE
  AND entity IN (
      'players',
      'player_profiles',
      'player_season_stats',
      'player_stats',
      'coaches'
  )
  AND COALESCE(BTRIM(target_table), '') = '';

-- 4) Kontrola výsledku.
COMMIT;

SELECT
    provider,
    sport_code,
    entity,
    enabled,
    scope_type,
    ingest_mode,
    default_run_group,
    target_table,
    worker_script,
    notes
FROM ops.ingest_entity_plan
WHERE entity IN (
    'players',
    'player_profiles',
    'player_season_stats',
    'player_stats',
    'coaches',
    'highlights',
    'articles',
    'comments',
    'videos'
)
ORDER BY
    enabled DESC,
    sport_code,
    provider,
    priority,
    entity;