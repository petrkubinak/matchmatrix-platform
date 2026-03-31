DROP VIEW IF EXISTS public.v_current_product_standings;

CREATE VIEW public.v_current_product_standings AS
SELECT
    ls.league_id,
    l.name AS league_name,
    l.country,
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
    ls.form_last_5,
    ls.form_last_10,
    ls.form_last_15,
    pal.source,
    pal.usage,
    pal.priority,
    pal.is_active
FROM public.league_standings ls
JOIN public.product_active_leagues pal
  ON pal.league_id = ls.league_id
 AND pal.season = ls.season
 AND pal.usage = 'ticket_studio'
 AND pal.is_active = TRUE
JOIN public.leagues l
  ON l.id = ls.league_id
JOIN public.teams t
  ON t.id = ls.team_id
WHERE ls.table_type = 'overall';