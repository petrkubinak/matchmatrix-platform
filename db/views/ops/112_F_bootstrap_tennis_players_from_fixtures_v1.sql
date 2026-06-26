/*
MATCHMATRIX SQL 112_F
CO TO JE:
- Bootstrap TN hráčů z tenisových fixtures.
- U tenisu bereme player_1/player_2 jako hráčské entity.

K ČEMU TO JE:
- Naplní staging.stg_provider_players pro Tennis.
- Připraví TN PEOPLE merge do public.players a public.player_provider_map.

KDE TO UVIDÍME:
- PEOPLE záložka panelu.
- ops.v_people_pipeline_audit_v1.
- ops.v_people_pipeline_summary_v1.

JAK SE TO VYUŽIJE:
- Profil tenisty.
- Tenisové zápasy s hráčskými entitami.
- Budoucí tenisové ratingy, forma a porovnání hráčů.
*/

WITH src AS (
    SELECT DISTINCT
        'api_tennis'::text AS provider,
        'TN'::text AS sport_code,
        md5(lower(trim(player_name))) AS external_player_id,
        trim(player_name) AS player_name,
        NULL::text AS external_team_id,
        NULL::text AS team_name,
        'fixtures_bootstrap'::text AS source_endpoint
    FROM (
        SELECT player_1 AS player_name
        FROM staging.api_tennis_fixtures
        WHERE player_1 IS NOT NULL
          AND trim(player_1) <> ''

        UNION

        SELECT player_2 AS player_name
        FROM staging.api_tennis_fixtures
        WHERE player_2 IS NOT NULL
          AND trim(player_2) <> ''
    ) x
)
INSERT INTO staging.stg_provider_players (
    provider,
    sport_code,
    external_player_id,
    player_name,
    external_team_id,
    team_name,
    source_endpoint,
    created_at,
    updated_at
)
SELECT
    provider,
    sport_code,
    external_player_id,
    player_name,
    external_team_id,
    team_name,
    source_endpoint,
    now(),
    now()
FROM src
ON CONFLICT DO NOTHING;