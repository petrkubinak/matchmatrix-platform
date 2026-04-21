-- 701_update_or_insert_runtime_entity_audit_hb_core_confirmed.sql
-- HB leagues / teams / fixtures
-- update-or-insert pattern podle existujicich runtime audit skriptu

-- =========================================================
-- HB LEAGUES
-- =========================================================
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM ops.runtime_entity_audit
        WHERE provider = 'api_handball'
          AND sport_code = 'HB'
          AND entity = 'leagues'
    ) THEN
        UPDATE ops.runtime_entity_audit
        SET
            current_state            = 'CONFIRMED',
            state_reason             = 'HB leagues jsou potvrzene ve smoke test chainu: pull -> raw -> parser -> staging pro api_handball funguje.',
            panel_runner_exists      = TRUE,
            planner_target_exists    = TRUE,
            batch_target_exists      = TRUE,
            pull_confirmed           = TRUE,
            raw_confirmed            = TRUE,
            staging_confirmed        = TRUE,
            provider_map_confirmed   = FALSE,
            public_merge_confirmed   = FALSE,
            downstream_confirmed     = FALSE,
            last_run_group           = 'HB_CORE',
            last_run_at              = NOW(),
            last_check_at            = NOW(),
            last_log_summary         = 'HB leagues pull/parser OK | staging.stg_provider_leagues naplneno | smoke test potvrzen',
            db_evidence_summary      = 'staging.stg_provider_leagues obsahuje HB ligy vcetne 131 Champions League, 145 EHF European League a 183 African Championship',
            next_action              = 'Rozsirit HB ingest targety a navazat HB provider_map/public merge vrstvou.',
            audit_note               = 'HB leagues jsou potvrzene ve staging vrstve. Canonical public merge zatim neni auditne potvrzen.',
            updated_at               = NOW()
        WHERE provider = 'api_handball'
          AND sport_code = 'HB'
          AND entity = 'leagues';
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
            'api_handball',
            'HB',
            'leagues',
            'CONFIRMED',
            'HB leagues jsou potvrzene ve smoke test chainu: pull -> raw -> parser -> staging pro api_handball funguje.',
            TRUE,
            TRUE,
            TRUE,
            TRUE,
            TRUE,
            TRUE,
            FALSE,
            FALSE,
            FALSE,
            'HB_CORE',
            NOW(),
            NOW(),
            'HB leagues pull/parser OK | staging.stg_provider_leagues naplneno | smoke test potvrzen',
            'staging.stg_provider_leagues obsahuje HB ligy vcetne 131 Champions League, 145 EHF European League a 183 African Championship',
            'Rozsirit HB ingest targety a navazat HB provider_map/public merge vrstvou.',
            'HB leagues jsou potvrzene ve staging vrstve. Canonical public merge zatim neni auditne potvrzen.',
            NOW(),
            NOW()
        );
    END IF;
END $$;

-- =========================================================
-- HB TEAMS
-- =========================================================
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM ops.runtime_entity_audit
        WHERE provider = 'api_handball'
          AND sport_code = 'HB'
          AND entity = 'teams'
    ) THEN
        UPDATE ops.runtime_entity_audit
        SET
            current_state            = 'CONFIRMED',
            state_reason             = 'HB teams jsou potvrzene ve smoke test chainu pro provider_league_id=131 a season=2024: pull -> raw -> parser -> staging funguje.',
            panel_runner_exists      = TRUE,
            planner_target_exists    = TRUE,
            batch_target_exists      = TRUE,
            pull_confirmed           = TRUE,
            raw_confirmed            = TRUE,
            staging_confirmed        = TRUE,
            provider_map_confirmed   = FALSE,
            public_merge_confirmed   = FALSE,
            downstream_confirmed     = FALSE,
            last_run_group           = 'HB_CORE',
            last_run_at              = NOW(),
            last_check_at            = NOW(),
            last_log_summary         = 'HB teams pull OK | parser OK | staging.stg_provider_teams naplneno pro 131/2024',
            db_evidence_summary      = 'staging.stg_provider_teams naplneno pro provider_league_id=131 season=2024 | potvrzene tymy: Aalborg, Barcelona, PSG, Veszprem a dalsi',
            next_action              = 'Navazat HB provider_map a canonical public.teams merge vrstvou.',
            audit_note               = 'HB teams jsou zatim auditne potvrzene do staging vrstvy. Provider_map/public merge jeste neni potvrzen.',
            updated_at               = NOW()
        WHERE provider = 'api_handball'
          AND sport_code = 'HB'
          AND entity = 'teams';
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
            'api_handball',
            'HB',
            'teams',
            'CONFIRMED',
            'HB teams jsou potvrzene ve smoke test chainu pro provider_league_id=131 a season=2024: pull -> raw -> parser -> staging funguje.',
            TRUE,
            TRUE,
            TRUE,
            TRUE,
            TRUE,
            TRUE,
            FALSE,
            FALSE,
            FALSE,
            'HB_CORE',
            NOW(),
            NOW(),
            'HB teams pull OK | parser OK | staging.stg_provider_teams naplneno pro 131/2024',
            'staging.stg_provider_teams naplneno pro provider_league_id=131 season=2024 | potvrzene tymy: Aalborg, Barcelona, PSG, Veszprem a dalsi',
            'Navazat HB provider_map a canonical public.teams merge vrstvou.',
            'HB teams jsou zatim auditne potvrzene do staging vrstvy. Provider_map/public merge jeste neni potvrzen.',
            NOW(),
            NOW()
        );
    END IF;
END $$;

-- =========================================================
-- HB FIXTURES
-- =========================================================
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM ops.runtime_entity_audit
        WHERE provider = 'api_handball'
          AND sport_code = 'HB'
          AND entity = 'fixtures'
    ) THEN
        UPDATE ops.runtime_entity_audit
        SET
            current_state            = 'CONFIRMED',
            state_reason             = 'HB fixtures jsou potvrzene ve smoke test chainu: handball endpoint games funguje, parser se spousti a staging fixtures je naplneny.',
            panel_runner_exists      = TRUE,
            planner_target_exists    = TRUE,
            batch_target_exists      = TRUE,
            pull_confirmed           = TRUE,
            raw_confirmed            = TRUE,
            staging_confirmed        = TRUE,
            provider_map_confirmed   = FALSE,
            public_merge_confirmed   = FALSE,
            downstream_confirmed     = FALSE,
            last_run_group           = 'HB_CORE',
            last_run_at              = NOW(),
            last_check_at            = NOW(),
            last_log_summary         = 'HB fixtures endpoint games OK | parser OK | staging.stg_provider_fixtures count=132 pro 131/2024',
            db_evidence_summary      = 'staging.stg_provider_fixtures count=132 pro provider_league_id=131 season=2024 | priklady: 164635, 164636, 164553',
            next_action              = 'Rozsirit HB targety o dalsi konkretni souteze a pripravit merge do public.matches.',
            audit_note               = 'HB fixtures jsou auditne potvrzene ve staging vrstve. Public.matches merge jeste neni potvrzen.',
            updated_at               = NOW()
        WHERE provider = 'api_handball'
          AND sport_code = 'HB'
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
            'api_handball',
            'HB',
            'fixtures',
            'CONFIRMED',
            'HB fixtures jsou potvrzene ve smoke test chainu: handball endpoint games funguje, parser se spousti a staging fixtures je naplneny.',
            TRUE,
            TRUE,
            TRUE,
            TRUE,
            TRUE,
            TRUE,
            FALSE,
            FALSE,
            FALSE,
            'HB_CORE',
            NOW(),
            NOW(),
            'HB fixtures endpoint games OK | parser OK | staging.stg_provider_fixtures count=132 pro 131/2024',
            'staging.stg_provider_fixtures count=132 pro provider_league_id=131 season=2024 | priklady: 164635, 164636, 164553',
            'Rozsirit HB targety o dalsi konkretni souteze a pripravit merge do public.matches.',
            'HB fixtures jsou auditne potvrzene ve staging vrstve. Public.matches merge jeste neni potvrzen.',
            NOW(),
            NOW()
        );
    END IF;
END $$;

-- =========================================================
-- KONTROLA
-- =========================================================
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
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND entity IN ('leagues','teams','fixtures')
ORDER BY entity;