-- =====================================================
-- 243_check_volleyball_by_sport_and_league.sql
-- Účel:
--   Ověřit, zda se volleyball zápasy propsaly do public.matches
--   jinak než přes ext_source.
-- =====================================================

-- 1) Kolik zápasů je v public.matches pro volleyball sport_id
SELECT
    sport_id,
    COUNT(*) AS cnt
FROM public.matches
WHERE sport_id = 10
GROUP BY sport_id;

-- 2) Kolik zápasů je navázáno na ligy, které mají provider api_volleyball
SELECT
    lpm.provider,
    COUNT(*) AS cnt
FROM public.matches m
JOIN public.league_provider_map lpm
  ON lpm.league_id = m.league_id
WHERE lpm.provider = 'api_volleyball'
GROUP BY lpm.provider;

-- 3) Detail posledních volleyball zápasů podle sport_id
SELECT
    id,
    ext_source,
    ext_match_id,
    league_id,
    season,
    kickoff,
    home_team_id,
    away_team_id,
    status,
    home_score,
    away_score,
    sport_id
FROM public.matches
WHERE sport_id = 10
ORDER BY id DESC
LIMIT 20;

-- 4) Detail posledních zápasů přes api_volleyball league map
SELECT
    m.id,
    m.ext_source,
    m.ext_match_id,
    m.league_id,
    m.season,
    m.kickoff,
    m.home_team_id,
    m.away_team_id,
    m.status,
    m.home_score,
    m.away_score,
    m.sport_id,
    lpm.provider
FROM public.matches m
JOIN public.league_provider_map lpm
  ON lpm.league_id = m.league_id
WHERE lpm.provider = 'api_volleyball'
ORDER BY m.id DESC
LIMIT 20;