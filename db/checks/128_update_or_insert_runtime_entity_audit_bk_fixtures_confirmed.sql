-- 128_update_or_insert_runtime_entity_audit_bk_fixtures_confirmed.sql

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM ops.runtime_entity_audit
        WHERE provider = 'api_sport'
          AND sport_code = 'BK'
          AND entity = 'fixtures'
    ) THEN
        UPDATE ops.runtime_entity_audit
        SET
            current_state            = 'CONFIRMED',
            state_reason             = 'BK fixtures jsou potvrzene od pull/raw/staging az po merge do public.matches a league mapping.',
            panel_runner_exists      = TRUE,
            planner_target_exists    = TRUE,
            batch_target_exists      = TRUE,
            pull_confirmed           = TRUE,
            raw_confirmed            = TRUE,
            staging_confirmed        = TRUE,
            provider_map_confirmed   = TRUE,
            public_merge_confirmed   = TRUE,
            downstream_confirmed     = FALSE,
            last_run_group           = 'BK_TOP',
            last_run_at              = NOW(),
            last_check_at            = NOW(),
            last_log_summary         = 'BK fixtures merge probehl OK: status mapping + score extraction + league mapping',
            db_evidence_summary      = 'stg_provider_fixtures BK=326 | public.matches inserted=320 | public.leagues api_sport_basketball ext_league_id=117 potvrzeno',
            next_action              = 'Prevest rucni BK kroky do finalniho opakovatelneho pipeline SQL baliku.',
            audit_note               = 'BK fixtures uz nejsou jen staging confirmed. Jsou potvrzene v canonical core vrstve.',
            updated_at               = NOW()
        WHERE provider = 'api_sport'
          AND sport_code = 'BK'
          AND entity = 'fixtures';
    ELSE
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
            last_run_at,
            last_check_at,
            last_log_summary,
            db_evidence_summary,
            next_action,
            audit_note,
            created_at,
            updated_at
        )
        VALUES (
            'api_sport',
            'BK',
            'fixtures',
            'CONFIRMED',
            'BK fixtures jsou potvrzene od pull/raw/staging az po merge do public.matches a league mapping.',
            TRUE,
            TRUE,
            TRUE,
            TRUE,
            TRUE,
            TRUE,
            TRUE,
            TRUE,
            FALSE,
            'BK_TOP',
            NOW(),
            NOW(),
            'BK fixtures merge probehl OK: status mapping + score extraction + league mapping',
            'stg_provider_fixtures BK=326 | public.matches inserted=320 | public.leagues api_sport_basketball ext_league_id=117 potvrzeno',
            'Prevest rucni BK kroky do finalniho opakovatelneho pipeline SQL baliku.',
            'BK fixtures uz nejsou jen staging confirmed. Jsou potvrzene v canonical core vrstve.',
            NOW(),
            NOW()
        );
    END IF;
END $$;

SELECT
    provider,
    sport_code,
    entity,
    current_state,
    pull_confirmed,
    raw_confirmed,
    staging_confirmed,
    provider_map_confirmed,
    public_merge_confirmed,
    last_run_group,
    db_evidence_summary,
    next_action
FROM ops.runtime_entity_audit
WHERE provider = 'api_sport'
  AND sport_code = 'BK'
  AND entity = 'fixtures';