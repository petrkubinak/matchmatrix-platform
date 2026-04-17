-- správný unikát (hráč + tým + liga + sezóna)

CREATE UNIQUE INDEX IF NOT EXISTS ux_player_season_statistics_correct
ON public.player_season_statistics (player_id, team_id, league_id, season);