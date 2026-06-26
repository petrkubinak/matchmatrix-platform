/*
761_people_find_fb_players_staging_v1.sql

Účel:
- najít, jestli FB players opravdu existují ve staging.stg_provider_players
- ověřit raw_payload_id a vyplněná pole
*/

SELECT
    id,
    provider,
    sport_code,
    external_player_id,
    player_name,
    external_team_id,
    team_name,
    external_league_id,
    league_name,
    season,
    raw_payload_id,
    source_endpoint,
    created_at
FROM staging.stg_provider_players
WHERE provider = 'api_football'
  AND sport_code = 'FB'
ORDER BY created_at DESC, id DESC
LIMIT 50;