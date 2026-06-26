/*
================================================================================
MATCHMATRIX 104_R - ADD INDEX PLAYERS SPORT_ID V1
================================================================================
*/

CREATE INDEX IF NOT EXISTS idx_players_sport_id
ON public.players (sport_id);