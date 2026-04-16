-- 477_audit_review_batch2_candidates.sql
-- Cíl:
-- najít další silné kandidáty na ruční mapování
-- jen pro top ligy, jen nenamapované týmy

WITH mapped_leagues AS (
    SELECT
        clm.canonical_league_id,
        clm.provider_league_id AS api_league_id
    FROM public.canonical_league_map clm
    WHERE clm.provider = 'api_football'
      AND clm.canonical_league_id IN (5, 6, 26, 27, 28, 29, 30)
),
fd_teams AS (
    SELECT DISTINCT
        ml.canonical_league_id,
        l.name AS league_name,
        l.country,
        t.id AS canonical_team_id,
        t.name AS canonical_team_name
    FROM mapped_leagues ml
    JOIN public.leagues l
      ON l.id = ml.canonical_league_id
    JOIN public.matches m
      ON m.league_id = ml.canonical_league_id
    JOIN public.teams t
      ON t.id IN (m.home_team_id, m.away_team_id)
),
api_teams AS (
    SELECT DISTINCT
        ml.canonical_league_id,
        l.name AS league_name,
        l.country,
        t.id AS api_team_id,
        t.name AS api_team_name
    FROM mapped_leagues ml
    JOIN public.leagues l
      ON l.id = ml.canonical_league_id
    JOIN public.matches m
      ON m.league_id = ml.api_league_id
    JOIN public.teams t
      ON t.id IN (m.home_team_id, m.away_team_id)
),
mapped_canonical AS (
    SELECT DISTINCT canonical_team_id
    FROM public.canonical_team_map
    WHERE provider = 'api_football'
),
mapped_provider AS (
    SELECT DISTINCT provider_team_id
    FROM public.canonical_team_map
    WHERE provider = 'api_football'
),
fd_unmapped AS (
    SELECT *
    FROM fd_teams
    WHERE canonical_team_id NOT IN (SELECT canonical_team_id FROM mapped_canonical)
),
api_unmapped AS (
    SELECT *
    FROM api_teams
    WHERE api_team_id NOT IN (SELECT provider_team_id FROM mapped_provider)
)
SELECT
    f.country,
    f.league_name,
    f.canonical_team_id,
    f.canonical_team_name,
    a.api_team_id,
    a.api_team_name
FROM fd_unmapped f
JOIN api_unmapped a
  ON a.canonical_league_id = f.canonical_league_id
WHERE
    lower(f.canonical_team_name) LIKE '%' || lower(a.api_team_name) || '%'
    OR lower(a.api_team_name) LIKE '%' || lower(f.canonical_team_name) || '%'
ORDER BY
    f.country,
    f.league_name,
    f.canonical_team_name,
    a.api_team_name;