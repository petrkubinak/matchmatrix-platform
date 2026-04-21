-- 005_check_hb_teams_fixtures_after_leagues_fix.sql

-- 1) HB teams provider map
SELECT
    COUNT(*) AS hb_team_provider_map_count
FROM public.team_provider_map
WHERE provider = 'api_handball';

-- 2) HB teams v public.teams
SELECT
    COUNT(*) AS hb_public_teams_count
FROM public.teams
WHERE ext_source = 'api_handball';

-- 3) HB league_teams vazby
SELECT
    COUNT(*) AS hb_league_teams_count
FROM public.league_teams lt
JOIN public.leagues l
  ON l.id = lt.league_id
WHERE l.ext_source = 'api_handball';

-- 4) HB matches
SELECT
    COUNT(*) AS hb_matches_count
FROM public.matches
WHERE ext_source = 'api_handball';

-- 5) HB matches po ligách
SELECT
    l.name,
    COUNT(m.id) AS matches_count
FROM public.matches m
JOIN public.leagues l
  ON l.id = m.league_id
WHERE m.ext_source = 'api_handball'
GROUP BY l.name
ORDER BY matches_count DESC, l.name;

-- 6) HB fixtures ve stagingu bez napojení na league_provider_map
SELECT
    COUNT(*) AS hb_fixtures_missing_league_map
FROM staging.stg_provider_fixtures sf
LEFT JOIN public.league_provider_map lpm
  ON lpm.provider = sf.provider
 AND lpm.provider_league_id = sf.external_league_id
WHERE sf.provider = 'api_handball'
  AND lpm.league_id IS NULL;

-- 7) HB fixtures ve stagingu bez napojení na team_provider_map
SELECT
    COUNT(*) AS hb_fixtures_missing_team_map
FROM staging.stg_provider_fixtures sf
LEFT JOIN public.team_provider_map htp
  ON htp.provider = sf.provider
 AND htp.provider_team_id = sf.home_team_external_id
LEFT JOIN public.team_provider_map atp
  ON atp.provider = sf.provider
 AND atp.provider_team_id = sf.away_team_external_id
WHERE sf.provider = 'api_handball'
  AND (
      htp.team_id IS NULL
      OR atp.team_id IS NULL
  );