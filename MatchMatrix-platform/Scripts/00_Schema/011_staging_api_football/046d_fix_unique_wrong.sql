-- odstranění špatného unique indexu

DROP INDEX IF EXISTS ux_player_season_statistics_unique;
DROP INDEX IF EXISTS ux_player_season_statistics_main;