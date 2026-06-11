/*
MATCHMATRIX SQL 23_3_L

PC2 MEDIA ASSET PLAN V1

CO TO JE:
- Roadmapa pro media asset vrstvu.
- Fotky hráčů, trenérů, týmů a stadionů.

K ČEMU TO JE:
- Připravit nejcennější media vrstvu MatchMatrix.
- Určit priority providerů.
- Připravit budoucí media enrichment workery.

KDE TO UVIDÍME:
- OPS Panel
- Media Command Center
- PC2 Dashboard
- Asset Readiness

JAK SE TO VYUŽIJE:
- Player Cards
- Team Cards
- Stadium Pages
- Match Context
- Mobilní aplikace

NAVAZUJE NA:
- 23_3_J_create_pc2_media_provider_audit_v1.sql
- 23_3_K_create_pc2_media_execution_plan_v1.sql

DALŠÍ KROK:
- 23_3_M_create_provider_research_master_plan_v1.sql
*/

DROP VIEW IF EXISTS ops.v_pc2_media_asset_plan_v1;

CREATE OR REPLACE VIEW ops.v_pc2_media_asset_plan_v1 AS

SELECT *
FROM (
    VALUES

    (
        1,
        'PLAYER_PHOTOS',
        'FB',
        'api_football',
        'CRITICAL',
        'PLAYER_CARDS',
        'RESEARCH_PROVIDER'
    ),

    (
        2,
        'COACH_PHOTOS',
        'FB',
        'api_football',
        'HIGH',
        'COACH_CARDS',
        'RESEARCH_PROVIDER'
    ),

    (
        3,
        'TEAM_LOGOS',
        'FB',
        'api_football',
        'CRITICAL',
        'TEAM_CARDS',
        'RESEARCH_PROVIDER'
    ),

    (
        4,
        'STADIUM_PHOTOS',
        'FB',
        'api_football',
        'HIGH',
        'MATCH_CONTEXT',
        'RESEARCH_PROVIDER'
    ),

    (
        5,
        'PLAYER_PHOTOS',
        'BK',
        'sportsdataio',
        'HIGH',
        'PLAYER_CARDS',
        'RESEARCH_PROVIDER'
    ),

    (
        6,
        'PLAYER_PHOTOS',
        'HK',
        'sportsdataio',
        'HIGH',
        'PLAYER_CARDS',
        'RESEARCH_PROVIDER'
    ),

    (
        7,
        'PLAYER_PHOTOS',
        'AFB',
        'sportsdataio',
        'HIGH',
        'PLAYER_CARDS',
        'RESEARCH_PROVIDER'
    )

) AS t (
    priority_order,
    asset_type,
    sport_code,
    preferred_provider,
    priority_level,
    target_usage,
    next_action
);