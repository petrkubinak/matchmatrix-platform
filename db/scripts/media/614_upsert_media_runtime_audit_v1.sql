-- upsert_media_runtime_audit_v1.sql
-- Zapíše aktuální stav MEDIA layer do ops.runtime_entity_audit.

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
    audit_note,
    created_at,
    updated_at
)
SELECT
    'multi_source_media' AS provider,
    'MULTI' AS sport_code,
    'articles' AS entity,
    'PARTIAL' AS current_state,
    'MEDIA layer má funkční articles/feed/team/league mapping; match mapping čeká na fixture coverage pro NBA/NHL canonical týmy.' AS state_reason,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    'MEDIA_LAYER_V1',
    now(),
    'articles=' || total_articles ||
    ' | quality_70_plus=' || quality_70_plus ||
    ' | feed_eligible=' || feed_eligible ||
    ' | team_linked=' || team_linked_articles ||
    ' | league_linked=' || league_linked_articles ||
    ' | match_linked=' || match_linked_articles ||
    ' | quality_unmatched=' || quality_unmatched_articles,
    'Doplnit NBA/NHL fixture coverage do public.matches pro canonical team_id; potom spustit article_match_map matcher.',
    'Vytvořeno po MEDIA coverage auditu v1.',
    now(),
    now()
FROM public.v_media_layer_coverage
ON CONFLICT (provider, sport_code, entity)
DO UPDATE SET
    current_state = EXCLUDED.current_state,
    state_reason = EXCLUDED.state_reason,
    last_run_group = EXCLUDED.last_run_group,
    last_check_at = EXCLUDED.last_check_at,
    db_evidence_summary = EXCLUDED.db_evidence_summary,
    next_action = EXCLUDED.next_action,
    audit_note = EXCLUDED.audit_note,
    updated_at = now();