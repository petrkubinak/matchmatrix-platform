-- =====================================================================
-- 295_fb_team_cleanup_final_note.sql
-- Finalni poznamka ke stavu FB team canonical cleanup
-- =====================================================================

-- FINALNI STAV:
-- staging.stg_provider_teams = 1458
-- team_provider_map mapped   = 1457
-- zbyvajici 1 pripad neni realny unmapped tym,
-- ale duplicate provider ID:

-- Arsenal:
-- external_team_id = 9419
-- candidate team_id = 118199
-- jiz existujici provider mapping:
-- provider = api_football
-- provider_team_id = 42
-- team_id = 118199

-- ZAVER:
-- FB teams canonical cleanup / provider map cleanup je funkcne hotovy.
-- Zbyvajici 1 radek klasifikovat jako DUPLICATE_PROVIDER_ID.
-- Neinsertovat do public.team_provider_map.