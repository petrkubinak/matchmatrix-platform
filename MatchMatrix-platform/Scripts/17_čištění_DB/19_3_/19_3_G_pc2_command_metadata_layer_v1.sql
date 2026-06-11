/*
MATCHMATRIX SQL 19_3_G
PC2 Command Metadata Layer V1

CO TO JE:
- Doplnění popisu ke každému PC2 příkazu.

K ČEMU TO JE:
- Aby panel neukazoval jen technický příkaz.
- U každé akce uvidíš:
  CO TO JE
  K ČEMU TO JE
  KAM SE UKLÁDÁ
  KDE TO UVIDÍME
  JAK SE TO VYUŽIJE
  OČEKÁVANÝ VÝSLEDEK

KDE TO UVIDÍME:
- OPS Panel V18
- PC2 Command Center
- Detail PC2 příkazu

JAK SE TO VYUŽIJE:
- Klikneš na řádek PC2 fronty.
- Uvidíš význam akce před spuštěním.
- Později to může použít i automatický režim.
*/

ALTER TABLE ops.pc2_run_command_queue
ADD COLUMN IF NOT EXISTS action_description TEXT,
ADD COLUMN IF NOT EXISTS purpose_description TEXT,
ADD COLUMN IF NOT EXISTS target_tables TEXT,
ADD COLUMN IF NOT EXISTS panel_usage TEXT,
ADD COLUMN IF NOT EXISTS expected_result TEXT;


UPDATE ops.pc2_run_command_queue
SET
    action_description = CASE
        WHEN target_layer = 'CORE'
            THEN 'Doplnění základní CORE vrstvy pro sport ' || sport_code || '.'
        WHEN target_layer = 'PEOPLE'
            THEN 'Doplnění PEOPLE vrstvy pro sport ' || sport_code || '.'
        WHEN target_layer = 'MEDIA'
            THEN 'Doplnění MEDIA vrstvy pro sport ' || sport_code || '.'
        WHEN target_layer = 'ODDS'
            THEN 'Doplnění ODDS vrstvy pro sport ' || sport_code || '.'
        ELSE 'PC2 harvest akce.'
    END,

    purpose_description = CASE
        WHEN target_layer = 'CORE'
            THEN 'Bez CORE vrstvy nelze bezpečně navázat People, Media, Odds ani Context Engine.'
        WHEN target_layer = 'PEOPLE'
            THEN 'People vrstva je základ pro hráče, trenéry, profily, statistiky, media linking a budoucí web.'
        WHEN target_layer = 'MEDIA'
            THEN 'Media vrstva navazuje články, videa a obsah na existující sporty, týmy, hráče a zápasy.'
        WHEN target_layer = 'ODDS'
            THEN 'Odds vrstva navazuje kurzy na existující zápasy a připravuje Ticket Engine.'
        ELSE 'Akce je součástí PC2 harvest orchestrace.'
    END,

    target_tables = CASE
        WHEN target_layer = 'CORE'
            THEN 'raw/staging fixtures, public.matches, public.teams, public.leagues'
        WHEN target_layer = 'PEOPLE'
            THEN 'raw/staging players, public.players, public.player_provider_map, public.player_external_identity'
        WHEN target_layer = 'MEDIA'
            THEN 'staging.stg_media_articles, public.articles, public.article_team_map, public.article_player_map'
        WHEN target_layer = 'ODDS'
            THEN 'raw/staging odds, public.odds, public.bookmakers, public.market_outcomes'
        ELSE 'ops / public podle typu akce'
    END,

    panel_usage = CASE
        WHEN target_layer = 'CORE'
            THEN 'Sport Completion, Harvest, PC2 Command Center, budoucí web lig/týmů/zápasů.'
        WHEN target_layer = 'PEOPLE'
            THEN 'People Pipeline, Sport Completion, profily hráčů, media linking, predikce.'
        WHEN target_layer = 'MEDIA'
            THEN 'Media Command Center, detail týmu/hráče/zápasu, webové články a highlights.'
        WHEN target_layer = 'ODDS'
            THEN 'Odds Command Center, Ticket Engine, predikce a value betting.'
        ELSE 'PC2 Command Center.'
    END,

    expected_result = CASE
        WHEN target_layer = 'CORE'
            THEN sport_code || ' má doplněnou CORE vrstvu a může pokračovat do PEOPLE vrstvy.'
        WHEN target_layer = 'PEOPLE'
            THEN sport_code || ' má doplněnou PEOPLE vrstvu a může pokračovat do MEDIA vrstvy.'
        WHEN target_layer = 'MEDIA'
            THEN sport_code || ' má doplněnou MEDIA vrstvu a může pokračovat do ODDS/CONTEXT vrstvy.'
        WHEN target_layer = 'ODDS'
            THEN sport_code || ' má doplněnou ODDS vrstvu pro Ticket Engine.'
        ELSE sport_code || ' PC2 akce dokončena.'
    END,

    updated_at = now()
WHERE run_group = '19_3_PC2_DEPENDENCY_QUEUE';


CREATE OR REPLACE VIEW ops.v_pc2_run_command_queue_v2 AS
SELECT
    id,
    sport_code,
    sport_name,
    target_layer,
    execution_bucket,
    priority_score,
    command_title,
    run_status,
    safety_mode,
    panel_action_enabled,
    command_text,

    action_description,
    purpose_description,
    target_tables,
    panel_usage,
    expected_result,

    last_started_at,
    last_finished_at,
    last_result,
    updated_at
FROM ops.pc2_run_command_queue
WHERE panel_visible = true
ORDER BY
    priority_score,
    sport_code,
    target_layer;


SELECT
    id,
    sport_code,
    target_layer,
    run_status,
    action_description,
    expected_result
FROM ops.v_pc2_run_command_queue_v2
ORDER BY id;