-- =========================================================
-- MatchMatrix - Views for Web (today/tomorrow/week)
-- Timezone: Europe/Prague
-- Source datetime column: public.matches.kickoff
-- =========================================================

DROP VIEW IF EXISTS public.v_matches_week;
DROP VIEW IF EXISTS public.v_matches_tomorrow;
DROP VIEW IF EXISTS public.v_matches_today;
DROP VIEW IF EXISTS public.v_matches_base;

-- BASE VIEW: jednotný kontrakt pro API
CREATE OR REPLACE VIEW public.v_matches_base AS
SELECT
    m.id                         AS match_id,
    m.ext_source,
    m.ext_match_id,
    m.league_id,
    l.name                       AS league_name,

    'football'::text             AS sport_code,

    m.season,

    -- ✅ správný sloupec
    m.kickoff                    AS kickoff_at_utc,
    (m.kickoff AT TIME ZONE 'Europe/Prague') AS kickoff_at_local,

    m.status,

    m.home_team_id,
    COALESCE(th.name, 'TBD')     AS home_team_name,

    m.away_team_id,
    COALESCE(ta.name, 'TBD')     AS away_team_name

FROM public.matches m
JOIN public.leagues l       ON l.id = m.league_id
LEFT JOIN public.teams th   ON th.id = m.home_team_id
LEFT JOIN public.teams ta   ON ta.id = m.away_team_id
WHERE m.ext_source = 'api_football';


-- DNES (lokální den v Praze)
CREATE OR REPLACE VIEW public.v_matches_today AS
SELECT *
FROM public.v_matches_base
WHERE kickoff_at_local >= date_trunc('day', now() AT TIME ZONE 'Europe/Prague')
  AND kickoff_at_local <  date_trunc('day', now() AT TIME ZONE 'Europe/Prague') + interval '1 day';


-- ZÍTRA
CREATE OR REPLACE VIEW public.v_matches_tomorrow AS
SELECT *
FROM public.v_matches_base
WHERE kickoff_at_local >= date_trunc('day', now() AT TIME ZONE 'Europe/Prague') + interval '1 day'
  AND kickoff_at_local <  date_trunc('day', now() AT TIME ZONE 'Europe/Prague') + interval '2 day';


-- TÝDEN (dnes + 7 dní dopředu)
CREATE OR REPLACE VIEW public.v_matches_week AS
SELECT *
FROM public.v_matches_base
WHERE kickoff_at_local >= date_trunc('day', now() AT TIME ZONE 'Europe/Prague')
  AND kickoff_at_local <  date_trunc('day', now() AT TIME ZONE 'Europe/Prague') + interval '7 day';