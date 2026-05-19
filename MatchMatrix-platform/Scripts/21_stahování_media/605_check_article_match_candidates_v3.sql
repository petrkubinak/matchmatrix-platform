-- check_article_match_candidates_v3.sql
-- Hledá article -> match kandidáty bez published_at.
-- Používá jen již hotový article_team_map:
-- článek musí mít namapovaný home i away tým daného zápasu.

WITH article_team_pairs AS (
    SELECT
        atm.article_id,
        m.id AS match_id,
        m.kickoff,
        m.league_id,
        m.home_team_id,
        m.away_team_id,
        ht.name AS home_team,
        at.name AS away_team
    FROM public.article_team_map atm
    JOIN public.matches m
      ON atm.team_id IN (m.home_team_id, m.away_team_id)
    JOIN public.teams ht ON ht.id = m.home_team_id
    JOIN public.teams at ON at.id = m.away_team_id
),
article_match_candidates AS (
    SELECT
        article_id,
        match_id,
        kickoff,
        league_id,
        home_team,
        away_team,
        COUNT(DISTINCT CASE
            WHEN home_team_id IN (
                SELECT team_id
                FROM public.article_team_map x
                WHERE x.article_id = article_team_pairs.article_id
            )
            THEN home_team_id
        END) AS has_home_team,
        COUNT(DISTINCT CASE
            WHEN away_team_id IN (
                SELECT team_id
                FROM public.article_team_map x
                WHERE x.article_id = article_team_pairs.article_id
            )
            THEN away_team_id
        END) AS has_away_team
    FROM article_team_pairs
    GROUP BY
        article_id,
        match_id,
        kickoff,
        league_id,
        home_team,
        away_team
)
SELECT
    COUNT(*) AS candidates_both_teams
FROM article_match_candidates
WHERE has_home_team = 1
  AND has_away_team = 1;


-- Ukázka kandidátů
WITH article_team_pairs AS (
    SELECT
        atm.article_id,
        a.title,
        a.article_quality_score,
        m.id AS match_id,
        m.kickoff,
        l.name AS league_name,
        m.home_team_id,
        m.away_team_id,
        ht.name AS home_team,
        at.name AS away_team
    FROM public.article_team_map atm
    JOIN public.articles a ON a.id = atm.article_id
    JOIN public.matches m
      ON atm.team_id IN (m.home_team_id, m.away_team_id)
    LEFT JOIN public.leagues l ON l.id = m.league_id
    JOIN public.teams ht ON ht.id = m.home_team_id
    JOIN public.teams at ON at.id = m.away_team_id
    WHERE COALESCE(a.article_quality_score, 0) >= 70
),
article_match_candidates AS (
    SELECT
        article_id,
        title,
        article_quality_score,
        match_id,
        kickoff,
        league_name,
        home_team,
        away_team,
        COUNT(DISTINCT CASE
            WHEN home_team_id IN (
                SELECT team_id
                FROM public.article_team_map x
                WHERE x.article_id = article_team_pairs.article_id
            )
            THEN home_team_id
        END) AS has_home_team,
        COUNT(DISTINCT CASE
            WHEN away_team_id IN (
                SELECT team_id
                FROM public.article_team_map x
                WHERE x.article_id = article_team_pairs.article_id
            )
            THEN away_team_id
        END) AS has_away_team
    FROM article_team_pairs
    GROUP BY
        article_id,
        title,
        article_quality_score,
        match_id,
        kickoff,
        league_name,
        home_team,
        away_team
)
SELECT *
FROM article_match_candidates
WHERE has_home_team = 1
  AND has_away_team = 1
ORDER BY article_id, kickoff DESC
LIMIT 100;