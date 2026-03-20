BEGIN;

-- 1) Smaž staré alias řádky jen pro test scope
DELETE FROM staging.stg_provider_player_season_stats
WHERE external_league_id = '95'
  AND season = '2024'
  AND stat_name IN (
      'goals',
      'red_cards',
      'yellow_cards',
      'substitute_in',
      'substitute_out',
      'substitute_bench',
      'shots_on_target'
  );

COMMIT;