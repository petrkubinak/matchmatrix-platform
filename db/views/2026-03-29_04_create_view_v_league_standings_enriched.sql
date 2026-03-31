-- =========================================================
-- MatchMatrix
-- Soubor: C:\MatchMatrix-platform\db\views\2026-03-29_04_create_view_v_league_standings_enriched.sql
-- Účel: rychlý pohled pro UI/detail zápasu nad league_standings
-- Spouštět v DBeaveru
-- =========================================================

CREATE OR REPLACE VIEW public.v_league_standings_enriched AS
SELECT
    ls.id,
    ls.league_id,
    l.name AS league_name,
    l.sport_id,
    s.code AS sport_code,
    s.name AS sport_name,
    ls.season,
    ls.team_id,
    t.name AS team_name,

    ls.position,
    ls.played,
    ls.wins,
    ls.draws,
    ls.losses,
    ls.goals_for,
    ls.goals_against,
    ls.goal_diff,
    ls.points,

    ls.home_played,
    ls.home_wins,
    ls.home_draws,
    ls.home_losses,
    ls.home_goals_for,
    ls.home_goals_against,
    ls.home_goal_diff,
    ls.home_points,

    ls.away_played,
    ls.away_wins,
    ls.away_draws,
    ls.away_losses,
    ls.away_goals_for,
    ls.away_goals_against,
    ls.away_goal_diff,
    ls.away_points,

    ls.form_last_5,
    ls.form_last_10,
    ls.form_last_15,

    ls.wins_last_5,
    ls.draws_last_5,
    ls.losses_last_5,
    ls.points_last_5,

    ls.wins_last_10,
    ls.draws_last_10,
    ls.losses_last_10,
    ls.points_last_10,

    ls.wins_last_15,
    ls.draws_last_15,
    ls.losses_last_15,
    ls.points_last_15,

    ls.table_type,
    ls.standings_source,
    ls.computed_at,
    ls.created_at,
    ls.updated_at
FROM public.league_standings ls
JOIN public.leagues l
  ON l.id = ls.league_id
JOIN public.sports s
  ON s.id = l.sport_id
JOIN public.teams t
  ON t.id = ls.team_id;