-- 802_fix_media_ops_plan_and_runtime_audit.sql
-- MATCHMATRIX MEDIA LAYER – OPS PLAN FIX + RUNTIME AUDIT SEED

BEGIN;

-- 1) Oprava target_table pro media entity
UPDATE ops.ingest_entity_plan
SET
    target_table = 'staging.stg_media_articles',
    notes = 'Media layer planned. DB base exists: content_sources, articles, article maps, translations, staging.stg_media_articles.',
    updated_at = now()
WHERE entity IN ('articles', 'comments', 'highlights')
  AND default_run_group ILIKE '%MEDIA%';

-- 2) Založení runtime audit řádků, pokud chybí
INSERT INTO ops.runtime_entity_audit (
    provider,
    sport_code,
    entity,
    current_state,
    state_reason,
    panel_runner_exists,
    planner_target_exists,
    batch_target_exists,
    pull_confirmed,
    raw_confirmed,
    staging_confirmed,
    provider_map_confirmed,
    public_merge_confirmed,
    downstream_confirmed,
    last_run_group,
    last_check_at,
    db_evidence_summary,
    next_action,
    audit_note
)
SELECT
    p.provider,
    p.sport_code,
    p.entity,
    'PLANNED',
    'MEDIA layer DB base exists, but real ingest/merge is not confirmed yet.',
    false,
    true,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    p.default_run_group,
    now(),
    'public content_sources/articles/article_*_map/article_translations + staging.stg_media_articles exist.',
    'Create/validate media worker: source -> staging.stg_media_articles -> public.articles.',
    'Seeded from media reality check.'
FROM ops.ingest_entity_plan p
WHERE p.entity IN ('articles', 'comments', 'highlights')
  AND p.default_run_group ILIKE '%MEDIA%'
  AND NOT EXISTS (
      SELECT 1
      FROM ops.runtime_entity_audit a
      WHERE a.provider = p.provider
        AND a.sport_code = p.sport_code
        AND a.entity = p.entity
  );

-- 3) Kontrola výsledku
SELECT
    provider,
    sport_code,
    entity,
    current_state,
    last_run_group,
    db_evidence_summary,
    next_action
FROM ops.runtime_entity_audit
WHERE entity IN ('articles', 'comments', 'highlights')
ORDER BY sport_code, entity, provider;

COMMIT;