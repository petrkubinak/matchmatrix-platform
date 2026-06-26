/*
===============================================================================
MATCHMATRIX SQL 114_D
STAGING GOVERNANCE CATALOG V1
===============================================================================
*/

DELETE FROM ops.database_object_governance
WHERE schema_name = 'staging';

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
    'staging',
    t.table_name,
    CASE WHEN t.table_type = 'VIEW' THEN 'VIEW' ELSE 'TABLE' END,

    CASE
        WHEN t.table_name LIKE 'stg_provider_%'
          OR t.table_name IN (
              'stg_api_payloads',
              'stg_media_articles',
              'stg_player_source_payloads'
          )
        THEN 'ACTIVE_MASTER'

        WHEN t.table_name IN (
            'api_football_fixtures',
            'api_football_leagues',
            'api_football_odds',
            'api_football_teams',
            'api_hockey_leagues',
            'api_hockey_teams',
            'api_tennis_fixtures',
            'api_tennis_leagues',
            'players_import',
            'player_provider_map_import'
        )
        THEN 'LEGACY_KEEP'

        WHEN t.table_name LIKE '%_raw'
          OR t.table_name LIKE '%_raw_%'
        THEN 'ACTIVE_REVIEW'

        WHEN t.table_name LIKE 'v_%'
        THEN 'ACTIVE_REVIEW'

        ELSE 'ACTIVE_REVIEW'
    END AS governance_status,

    CASE
        WHEN t.table_name LIKE 'stg_provider_%'
          OR t.table_name IN (
              'stg_api_payloads',
              'stg_media_articles',
              'stg_player_source_payloads'
          )
        THEN true
        ELSE false
    END AS is_master,

    CASE
        WHEN t.table_name LIKE '%football%' THEN 'FOOTBALL'
        WHEN t.table_name LIKE '%hockey%' THEN 'HOCKEY'
        WHEN t.table_name LIKE '%tennis%' THEN 'TENNIS'
        WHEN t.table_name LIKE '%american_football%' THEN 'AMERICAN_FOOTBALL'
        WHEN t.table_name LIKE '%media%' THEN 'MEDIA'
        WHEN t.table_name LIKE '%player%' OR t.table_name LIKE '%coach%' THEN 'PEOPLE'
        WHEN t.table_name LIKE '%odds%' THEN 'ODDS'
        WHEN t.table_name LIKE '%fixture%' OR t.table_name LIKE '%event%' THEN 'CORE'
        WHEN t.table_name LIKE '%team%' OR t.table_name LIKE '%league%' THEN 'CORE'
        ELSE 'STAGING'
    END AS domain_area,

    'Staging Layer',
    'KEEP',
    'Staging objekt pro import, parser nebo mezivrstvu.',
    'Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou.',
    CASE
        WHEN t.table_name LIKE 'stg_provider_%'
          OR t.table_name IN ('stg_api_payloads','stg_media_articles','stg_player_source_payloads')
        THEN 'Nemazat. Nový unified staging pattern.'

        WHEN t.table_name LIKE 'api_%'
        THEN 'Starší provider-specific staging. Ponechat do dependency auditu workerů.'

        WHEN t.table_name LIKE 'v_%'
        THEN 'Pomocné staging view. Ověřit využití před čištěním.'

        ELSE 'Nemazat bez kontroly parserů a merge workerů.'
    END,
    'ChatGPT + Petr DB audit',
    NOW(),
    NOW()
FROM information_schema.tables t
WHERE t.table_schema = 'staging';

CREATE OR REPLACE VIEW ops.v_staging_catalog_v1 AS
SELECT *
FROM ops.database_object_governance
WHERE schema_name = 'staging'
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