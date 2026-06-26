/*
===============================================================================
MATCHMATRIX SQL 114_C
PUBLIC TABLE GOVERNANCE CATALOG V1
===============================================================================
*/

DELETE FROM ops.database_object_governance
WHERE schema_name = 'public'
  AND object_type = 'TABLE';

INSERT INTO ops.database_object_governance (
    schema_name,
    object_name,
    object_type,
    governance_status,
    is_master,
    domain_area,
    owner_layer,
    migration_action,
    what_is_it,
    purpose,
    cleanup_note,
    reviewed_by,
    reviewed_at,
    updated_at
)
SELECT
    'public' AS schema_name,
    t.table_name AS object_name,
    'TABLE' AS object_type,

    CASE
        WHEN t.table_name IN (
            'sports','countries','languages',
            'leagues','teams','matches','seasons',
            'league_provider_map','team_provider_map','player_provider_map',
            'players','player_external_identity',
            'coaches','coach_provider_map','team_coaches','team_coach_history',
            'odds','bookmakers','markets','market_outcomes',
            'articles','content_sources',
            'article_league_map','article_team_map','article_player_map','article_match_map',
            'media_entity_aliases',
            'mm_match_ratings','mm_team_ratings','match_features','ml_predictions','mm_value_bets',
            'generated_runs','generated_tickets','generated_ticket_blocks','generated_ticket_fixed',
            'tickets'
        ) THEN 'ACTIVE_MASTER'

        WHEN t.table_name LIKE 'user_%'
          OR t.table_name IN ('users','subscriptions','subscription_plans','notification_queue','user_notifications')
        THEN 'ACTIVE_REVIEW'

        WHEN t.table_name IN (
            'work_pl_aliases',
            'unmatched_theodds',
            'closing_odds'
        ) THEN 'LEGACY_KEEP'

        WHEN t.table_name LIKE 'ticket_%'
          OR t.table_name LIKE 'template_%'
          OR t.table_name LIKE 'generated_%'
          OR t.table_name LIKE 'mm_ticket_%'
          OR t.table_name LIKE 'media_%'
          OR t.table_name LIKE 'article_%'
          OR t.table_name LIKE 'player_%'
          OR t.table_name LIKE 'team_%'
          OR t.table_name LIKE 'league_%'
          OR t.table_name LIKE 'translation_%'
          OR t.table_name LIKE 'ai_%'
          OR t.table_name LIKE 'canonical_%'
        THEN 'ACTIVE'

        ELSE 'ACTIVE_REVIEW'
    END AS governance_status,

    CASE
        WHEN t.table_name IN (
            'sports','countries','languages',
            'leagues','teams','matches','seasons',
            'league_provider_map','team_provider_map','player_provider_map',
            'players','player_external_identity',
            'coaches','coach_provider_map','team_coaches','team_coach_history',
            'odds','bookmakers','markets','market_outcomes',
            'articles','content_sources',
            'article_league_map','article_team_map','article_player_map','article_match_map',
            'media_entity_aliases',
            'mm_match_ratings','mm_team_ratings','match_features','ml_predictions','mm_value_bets',
            'generated_runs','generated_tickets','generated_ticket_blocks','generated_ticket_fixed',
            'tickets'
        ) THEN true
        ELSE false
    END AS is_master,

    CASE
        WHEN t.table_name IN ('leagues','teams','matches','seasons','sports','countries','league_standings','league_teams') THEN 'CORE'
        WHEN t.table_name LIKE 'player_%' OR t.table_name IN ('players','coaches','coach_provider_map','team_coaches','team_coach_history') THEN 'PEOPLE'
        WHEN t.table_name IN ('odds','bookmakers','markets','market_outcomes','closing_odds') THEN 'ODDS'
        WHEN t.table_name LIKE 'media_%' OR t.table_name LIKE 'article_%' OR t.table_name IN ('articles','content_sources') THEN 'MEDIA'
        WHEN t.table_name LIKE 'ticket_%' OR t.table_name LIKE 'template_%' OR t.table_name LIKE 'generated_%' THEN 'TICKETS'
        WHEN t.table_name LIKE 'mm_%' OR t.table_name LIKE 'ml_%' OR t.table_name='match_features' THEN 'ML_MMR'
        WHEN t.table_name LIKE 'user_%' OR t.table_name IN ('users','subscriptions','subscription_plans','notification_queue','user_notifications') THEN 'USERS'
        WHEN t.table_name LIKE '%translation%' OR t.table_name IN ('languages','ai_translations') THEN 'TRANSLATION'
        ELSE 'PUBLIC'
    END AS domain_area,

    'Public Canonical Layer' AS owner_layer,
    'KEEP' AS migration_action,
    'Public databázová tabulka MatchMatrix.' AS what_is_it,
    'Součást produktové, analytické nebo webové vrstvy.' AS purpose,
    'Nemazat bez dalšího dependency auditu.' AS cleanup_note,
    'ChatGPT + Petr DB audit' AS reviewed_by,
    NOW() AS reviewed_at,
    NOW() AS updated_at
FROM information_schema.tables t
WHERE t.table_schema='public'
  AND t.table_type='BASE TABLE';

CREATE OR REPLACE VIEW ops.v_public_table_catalog_v1 AS
SELECT *
FROM ops.database_object_governance
WHERE schema_name='public'
  AND object_type='TABLE'
ORDER BY governance_status, domain_area, object_name;