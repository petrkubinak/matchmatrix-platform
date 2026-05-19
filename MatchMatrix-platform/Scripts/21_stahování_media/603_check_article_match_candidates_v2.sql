-- check_article_match_candidates_v2.sql
-- Hledá article -> match kandidáty přes už hotový article_team_map.
-- Smysl:
-- pokud článek mapuje tým a existuje zápas tohoto týmu blízko published_at,
-- je to kandidát pro article_match_map.

WITH article_teams AS (
    SELECT
        atm.article_id,
        atm.team_id
    FROM public.article_team_map atm
),
candidate_matches AS (
    SELECT
        a.id AS article_id,
        a.title,
        a.published_at,
        m.id AS match_id,
        m.kickoff,
        ht.name AS home_team,
        at.name AS away_team,
        l.name AS league_name,
        CASE
            WHEN m.home_team_id = atx.team_id THEN 'ARTICLE_TEAM_IS_HOME'
            WHEN m.away_team_id = atx.team_id THEN 'ARTICLE_TEAM_IS_AWAY'
            ELSE 'UNKNOWN'
        END AS match_reason
    FROM public.articles a
    JOIN article_teams atx
      ON atx.article_id = a.id
    JOIN public.matches m
      ON (
             m.home_team_id = atx.team_id
          OR m.away_team_id = atx.team_id
         )
     AND a.published_at IS NOT NULL
     AND m.kickoff BETWEEN (a.published_at - INTERVAL '14 days')
                       AND (a.published_at + INTERVAL '14 days')
    JOIN public.teams ht ON ht.id = m.home_team_id
    JOIN public.teams at ON at.id = m.away_team_id
    LEFT JOIN public.leagues l ON l.id = m.league_id
    WHERE COALESCE(a.article_quality_score, 0) >= 70
)
SELECT
    match_reason,
    COUNT(*) AS candidates
FROM candidate_matches
GROUP BY match_reason
ORDER BY candidates DESC;


WITH article_teams AS (
    SELECT
        atm.article_id,
        atm.team_id
    FROM public.article_team_map atm
),
candidate_matches AS (
    SELECT
        a.id AS article_id,
        a.title,
        a.published_at,
        m.id AS match_id,
        m.kickoff,
        ht.name AS home_team,
        at.name AS away_team,
        l.name AS league_name,
        CASE
            WHEN m.home_team_id = atx.team_id THEN 'ARTICLE_TEAM_IS_HOME'
            WHEN m.away_team_id = atx.team_id THEN 'ARTICLE_TEAM_IS_AWAY'
            ELSE 'UNKNOWN'
        END AS match_reason
    FROM public.articles a
    JOIN article_teams atx
      ON atx.article_id = a.id
    JOIN public.matches m
      ON (
             m.home_team_id = atx.team_id
          OR m.away_team_id = atx.team_id
         )
     AND a.published_at IS NOT NULL
     AND m.kickoff BETWEEN (a.published_at - INTERVAL '14 days')
                       AND (a.published_at + INTERVAL '14 days')
    JOIN public.teams ht ON ht.id = m.home_team_id
    JOIN public.teams at ON at.id = m.away_team_id
    LEFT JOIN public.leagues l ON l.id = m.league_id
    WHERE COALESCE(a.article_quality_score, 0) >= 70
)
SELECT *
FROM candidate_matches
ORDER BY published_at DESC, kickoff DESC
LIMIT 50;