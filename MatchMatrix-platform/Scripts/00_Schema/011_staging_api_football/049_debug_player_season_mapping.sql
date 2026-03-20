-- 049_debug_player_season_mapping.sql

-- 1) Kolik distinct kombinací vůbec máme ve stagingu
SELECT
    COUNT(*) AS raw_rows,
    COUNT(DISTINCT (provider, player_external_id, team_external_id, external_league_id, season)) AS distinct_player_team_league_season
FROM staging.stg_provider_player_season_stats;

-- 2) Kolik z nich má mapovaného hráče
SELECT
    COUNT(DISTINCT (s.provider, s.player_external_id, s.team_external_id, s.external_league_id, s.season)) AS mapped_player_rows
FROM staging.stg_provider_player_season_stats s
JOIN public.player_provider_map ppm
  ON ppm.provider = s.provider
 AND ppm.provider_player_id = s.player_external_id;

-- 3) Kolik z nich má mapovaný tým
SELECT
    COUNT(DISTINCT (s.provider, s.player_external_id, s.team_external_id, s.external_league_id, s.season)) AS mapped_team_rows
FROM staging.stg_provider_player_season_stats s
JOIN public.player_provider_map ppm
  ON ppm.provider = s.provider
 AND ppm.provider_player_id = s.player_external_id
JOIN public.team_provider_map tpm
  ON tpm.provider = s.provider
 AND tpm.provider_team_id = s.team_external_id;

-- 4) Kolik z nich má mapovanou i ligu
SELECT
    COUNT(DISTINCT (s.provider, s.player_external_id, s.team_external_id, s.external_league_id, s.season)) AS fully_mapped_rows
FROM staging.stg_provider_player_season_stats s
JOIN public.player_provider_map ppm
  ON ppm.provider = s.provider
 AND ppm.provider_player_id = s.player_external_id
JOIN public.team_provider_map tpm
  ON tpm.provider = s.provider
 AND tpm.provider_team_id = s.team_external_id
JOIN public.league_provider_map lpm
  ON lpm.provider = s.provider
 AND lpm.provider_league_id = s.external_league_id;

-- 5) Hráči ze stagingu, kteří chybí v player_provider_map
SELECT
    s.provider,
    s.player_external_id,
    MAX(s.player_name) AS player_name,
    COUNT(*) AS rows_count
FROM staging.stg_provider_player_season_stats s
LEFT JOIN public.player_provider_map ppm
  ON ppm.provider = s.provider
 AND ppm.provider_player_id = s.player_external_id
WHERE ppm.player_id IS NULL
GROUP BY s.provider, s.player_external_id
ORDER BY rows_count DESC, player_name
LIMIT 100;

-- 6) Týmy ze stagingu, které chybí v team_provider_map
SELECT
    s.provider,
    s.team_external_id,
    MAX(s.team_name) AS team_name,
    COUNT(*) AS rows_count
FROM staging.stg_provider_player_season_stats s
JOIN public.player_provider_map ppm
  ON ppm.provider = s.provider
 AND ppm.provider_player_id = s.player_external_id
LEFT JOIN public.team_provider_map tpm
  ON tpm.provider = s.provider
 AND tpm.provider_team_id = s.team_external_id
WHERE tpm.team_id IS NULL
GROUP BY s.provider, s.team_external_id
ORDER BY rows_count DESC, team_name
LIMIT 100;

-- 7) Ligy ze stagingu, které chybí v league_provider_map
SELECT
    s.provider,
    s.external_league_id,
    COUNT(*) AS rows_count
FROM staging.stg_provider_player_season_stats s
JOIN public.player_provider_map ppm
  ON ppm.provider = s.provider
 AND ppm.provider_player_id = s.player_external_id
LEFT JOIN public.league_provider_map lpm
  ON lpm.provider = s.provider
 AND lpm.provider_league_id = s.external_league_id
WHERE lpm.league_id IS NULL
GROUP BY s.provider, s.external_league_id
ORDER BY rows_count DESC, s.external_league_id
LIMIT 100;