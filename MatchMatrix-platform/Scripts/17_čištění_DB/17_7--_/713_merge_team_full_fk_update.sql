-- 713_merge_team_full_fk_update.sql
-- PARAMETRY:
-- změň jen tyto 2 hodnoty

-- 🔽 ZMĚŇ
-- OLD TEAM
-- NEW TEAM
DO $$
DECLARE
    v_old_team_id INT := 14578;
    v_new_team_id INT := 13202;
BEGIN

-- CORE TABULKY
UPDATE public.league_standings SET team_id = v_new_team_id WHERE team_id = v_old_team_id;
UPDATE public.league_team_seasons SET team_id = v_new_team_id WHERE team_id = v_old_team_id;
UPDATE public.league_teams SET team_id = v_new_team_id WHERE team_id = v_old_team_id;

UPDATE public.matches SET home_team_id = v_new_team_id WHERE home_team_id = v_old_team_id;
UPDATE public.matches SET away_team_id = v_new_team_id WHERE away_team_id = v_old_team_id;

UPDATE public.team_provider_map SET team_id = v_new_team_id WHERE team_id = v_old_team_id;
UPDATE public.team_aliases SET team_id = v_new_team_id WHERE team_id = v_old_team_id;

-- STATISTICS
UPDATE public.team_match_statistics SET team_id = v_new_team_id WHERE team_id = v_old_team_id;
UPDATE public.player_match_statistics SET team_id = v_new_team_id WHERE team_id = v_old_team_id;
UPDATE public.player_season_statistics SET team_id = v_new_team_id WHERE team_id = v_old_team_id;

-- HISTORY
UPDATE public.player_team_history SET team_id = v_new_team_id WHERE team_id = v_old_team_id;
UPDATE public.team_coach_history SET team_id = v_new_team_id WHERE team_id = v_old_team_id;
UPDATE public.team_transfers SET from_team_id = v_new_team_id WHERE from_team_id = v_old_team_id;
UPDATE public.team_transfers SET to_team_id = v_new_team_id WHERE to_team_id = v_old_team_id;

-- PLAYERS
UPDATE public.players SET team_id = v_new_team_id WHERE team_id = v_old_team_id;

-- MATCH DATA
UPDATE public.lineups SET team_id = v_new_team_id WHERE team_id = v_old_team_id;
UPDATE public.match_events SET team_id = v_new_team_id WHERE team_id = v_old_team_id;

-- EXTRA
UPDATE public.team_social_links SET team_id = v_new_team_id WHERE team_id = v_old_team_id;
UPDATE public.team_stadiums SET team_id = v_new_team_id WHERE team_id = v_old_team_id;
UPDATE public.team_translations SET team_id = v_new_team_id WHERE team_id = v_old_team_id;
UPDATE public.user_favorite_teams SET team_id = v_new_team_id WHERE team_id = v_old_team_id;

-- OPTIONAL
UPDATE public.injuries SET team_id = v_new_team_id WHERE team_id = v_old_team_id;
UPDATE public.article_team_map SET team_id = v_new_team_id WHERE team_id = v_old_team_id;

END $$;