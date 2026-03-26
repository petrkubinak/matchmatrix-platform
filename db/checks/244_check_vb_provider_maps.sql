-- =====================================================
-- 244_check_vb_provider_maps.sql
-- Účel:
--   Ověřit, zda pro api_volleyball existují provider mapy lig a týmů,
--   bez kterých nejdou vložit zápasy do public.matches.
-- =====================================================

-- 1) league_provider_map pro api_volleyball
SELECT
    provider,
    COUNT(*) AS cnt
FROM public.league_provider_map
WHERE provider = 'api_volleyball'
GROUP BY provider;

-- 2) team_provider_map pro api_volleyball
SELECT
    provider,
    COUNT(*) AS cnt
FROM public.team_provider_map
WHERE provider = 'api_volleyball'
GROUP BY provider;

-- 3) staging teams pro api_volleyball
SELECT
    provider,
    COUNT(*) AS cnt
FROM staging.stg_provider_teams
WHERE provider = 'api_volleyball'
GROUP BY provider;

-- 4) fixtures, které by po joinu měly/ne měly mapované týmy
SELECT
    COUNT(*) AS total_fixtures,
    COUNT(*) FILTER (WHERE htp.team_id IS NOT NULL) AS mapped_home_team,
    COUNT(*) FILTER (WHERE atp.team_id IS NOT NULL) AS mapped_away_team,
    COUNT(*) FILTER (
        WHERE htp.team_id IS NOT NULL
          AND atp.team_id IS NOT NULL
    ) AS fully_mapped_fixtures
FROM staging.stg_provider_fixtures sf
LEFT JOIN public.team_provider_map htp
  ON htp.provider = sf.provider
 AND htp.provider_team_id = sf.home_team_external_id
LEFT JOIN public.team_provider_map atp
  ON atp.provider = sf.provider
 AND atp.provider_team_id = sf.away_team_external_id
WHERE sf.provider = 'api_volleyball';