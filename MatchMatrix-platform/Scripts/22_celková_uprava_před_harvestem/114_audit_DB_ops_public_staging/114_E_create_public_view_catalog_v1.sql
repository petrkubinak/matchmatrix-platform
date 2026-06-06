/*
===============================================================================
MATCHMATRIX SQL 114_E
PUBLIC VIEW GOVERNANCE CATALOG V1
===============================================================================
*/

DELETE FROM ops.database_object_governance
WHERE schema_name = 'public'
  AND object_type = 'VIEW';

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
    'public',
    v.table_name,
    'VIEW',

    CASE
        WHEN v.table_name IN (
            'v_matches_today',
            'v_matches_tomorrow',
            'v_matches_week',
            'v_match_card_feed',
            'v_live_match_feed_v2',
            'v_home_feed_v1',
            'v_homepage_media_feed_v2',
            'v_homepage_top_headlines_v1',
            'v_current_product_standings',
            'v_product_matches_dedup',
            'v_people_stats_quality_audit',
            'v_player_statistics_feed',
            'v_player_form_v1',
            'v_player_form_tiers_v1',
            'v_team_player_form_v3',
            'v_media_feed_latest',
            'v_media_feed_by_team',
            'v_media_feed_by_player',
            'v_media_feed_by_league',
            'v_video_feed_v2',
            'v_web_active_leagues',
            'vw_ticket_candidates',
            'vw_ticket_items',
            'vw_ticket_summary',
            'vw_ticket_settlement_detail',
            'ml_match_predict_dataset_v1',
            'ml_feed_value_picks_latest_v1',
            'ml_value_latest_v1',
            'ml_value_ev_latest_v1',
            'v_strategy_recommendation_current'
        )
        THEN 'ACTIVE_MASTER'

        WHEN v.table_name IN (
            'v_fb_team_power_v1',
            'v_fd_matches_base',
            'v_fd_matches_today',
            'v_fd_matches_tomorrow',
            'v_fd_matches_week',
            'v_fd_matches_week_ui',
            'v_fd_matches_week_with_odds',
            'v_live_match_feed',
            'v_homepage_media_feed_v1',
            'v_team_player_form_v1',
            'v_team_player_form_v2',
            'v_video_feed_v1',
            'ml_match_dataset',
            'ml_match_dataset_v2'
        )
        THEN 'LEGACY_KEEP'

        WHEN v.table_name LIKE 'vw_%'
          OR v.table_name LIKE 'v_ticket_%'
          OR v.table_name LIKE 'v_strategy_%'
          OR v.table_name LIKE 'v_mm_%'
          OR v.table_name LIKE 'ml_%'
          OR v.table_name LIKE 'v_media_%'
          OR v.table_name LIKE 'v_video_%'
          OR v.table_name LIKE 'v_player_%'
          OR v.table_name LIKE 'v_team_%'
          OR v.table_name LIKE 'v_home%'
          OR v.table_name LIKE 'v_match%'
          OR v.table_name LIKE 'v_fd_%'
        THEN 'ACTIVE'

        ELSE 'ACTIVE_REVIEW'
    END,

    CASE
        WHEN v.table_name IN (
            'v_matches_today',
            'v_matches_tomorrow',
            'v_matches_week',
            'v_match_card_feed',
            'v_live_match_feed_v2',
            'v_home_feed_v1',
            'v_homepage_media_feed_v2',
            'v_homepage_top_headlines_v1',
            'v_current_product_standings',
            'v_product_matches_dedup',
            'v_people_stats_quality_audit',
            'v_player_statistics_feed',
            'v_player_form_v1',
            'v_player_form_tiers_v1',
            'v_team_player_form_v3',
            'v_media_feed_latest',
            'v_media_feed_by_team',
            'v_media_feed_by_player',
            'v_media_feed_by_league',
            'v_video_feed_v2',
            'v_web_active_leagues',
            'vw_ticket_candidates',
            'vw_ticket_items',
            'vw_ticket_summary',
            'vw_ticket_settlement_detail',
            'ml_match_predict_dataset_v1',
            'ml_feed_value_picks_latest_v1',
            'ml_value_latest_v1',
            'ml_value_ev_latest_v1',
            'v_strategy_recommendation_current'
        )
        THEN true
        ELSE false
    END,

    CASE
        WHEN v.table_name LIKE 'ml_%' THEN 'ML'
        WHEN v.table_name LIKE 'v_mm_%' THEN 'ML_MMR'
        WHEN v.table_name LIKE '%ticket%' OR v.table_name LIKE 'vw_ticket%' OR v.table_name LIKE 'vw_block%' THEN 'TICKETS'
        WHEN v.table_name LIKE '%media%' OR v.table_name LIKE '%video%' OR v.table_name LIKE '%news%' OR v.table_name LIKE '%headline%' THEN 'MEDIA'
        WHEN v.table_name LIKE '%player%' OR v.table_name LIKE '%people%' THEN 'PEOPLE'
        WHEN v.table_name LIKE '%team%' THEN 'TEAM'
        WHEN v.table_name LIKE '%match%' OR v.table_name LIKE 'v_fd_%' THEN 'MATCH_FEED'
        WHEN v.table_name LIKE '%strategy%' THEN 'STRATEGY'
        ELSE 'PUBLIC_VIEW'
    END,

    'Public View Layer',
    'KEEP',
    'Public view pro web, analytiku, feedy nebo ticket engine.',
    'Slouží jako výstupní vrstva nad public tabulkami.',
    'Nemazat bez dependency auditu webu a workerů.',
    'ChatGPT + Petr DB audit',
    NOW(),
    NOW()
FROM information_schema.views v
WHERE v.table_schema = 'public';

CREATE OR REPLACE VIEW ops.v_public_view_catalog_v1 AS
SELECT *
FROM ops.database_object_governance
WHERE schema_name = 'public'
  AND object_type = 'VIEW'
ORDER BY
    CASE governance_status
        WHEN 'ACTIVE_MASTER' THEN 1
        WHEN 'ACTIVE' THEN 2
        WHEN 'ACTIVE_PANEL' THEN 3
        WHEN 'ACTIVE_REVIEW' THEN 4
        WHEN 'LEGACY_KEEP' THEN 5
        WHEN 'DROP_CANDIDATE' THEN 6
        ELSE 99
    END,
    domain_area,
    object_name;