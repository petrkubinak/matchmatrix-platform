-- kolik hráčů ze stats nemá mapu
SELECT COUNT(*) 
FROM staging.stg_provider_player_season_stats s
LEFT JOIN public.player_provider_map ppm
  ON ppm.provider_player_id = s.player_external_id
WHERE ppm.player_id IS NULL;