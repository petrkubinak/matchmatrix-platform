-- check_article_match_candidates_v1.sql
-- Hledá kandidáty article -> match podle:
-- title/raw_text obsahuje home nebo away team
-- a článek je v rozumném časovém okně okolo zápasu

WITH candidate_matches AS (
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
            WHEN lower(coalesce(a.title, '') || ' ' || coalesce(a.raw_text, '')) LIKE '%' || lower(ht.name) || '%'
             AND lower(coalesce(a.title, '') || ' ' || coalesce(a.raw_text, '')) LIKE '%' || lower(at.name) || '%'
                THEN 'BOTH_TEAMS'
            WHEN lower(coalesce(a.title, '') || ' ' || coalesce(a.raw_text, '')) LIKE '%' || lower(ht.name) || '%'
                THEN 'HOME_ONLY'
            WHEN lower(coalesce(a.title, '') || ' ' || coalesce(a.raw_text, '')) LIKE '%' || lower(at.name) || '%'
                THEN 'AWAY_ONLY'
            ELSE 'NO_TEAM'
        END AS match_reason
    FROM public.articles a
    JOIN public.matches m
      ON a.published_at IS NOT NULL
     AND m.kickoff BETWEEN (a.published_at - INTERVAL '14 days')
                       AND (a.published_at + INTERVAL '14 days')
    JOIN public.teams ht ON ht.id = m.home_team_id
    JOIN public.teams at ON at.id = m.away_team_id
    LEFT JOIN public.leagues l ON l.id = m.league_id
    WHERE a.article_quality_score >= 70
      AND (
          lower(coalesce(a.title, '') || ' ' || coalesce(a.raw_text, '')) LIKE '%' || lower(ht.name) || '%'
       OR lower(coalesce(a.title, '') || ' ' || coalesce(a.raw_text, '')) LIKE '%' || lower(at.name) || '%'
      )
)
SELECT
    match_reason,
    COUNT(*) AS candidates
FROM candidate_matches
GROUP BY match_reason
ORDER BY candidates DESC;


-- Ukázka kandidátů
WITH candidate_matches AS (
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
            WHEN lower(coalesce(a.title, '') || ' ' || coalesce(a.raw_text, '')) LIKE '%' || lower(ht.name) || '%'
             AND lower(coalesce(a.title, '') || ' ' || coalesce(a.raw_text, '')) LIKE '%' || lower(at.name) || '%'
                THEN 'BOTH_TEAMS'
            WHEN lower(coalesce(a.title, '') || ' ' || coalesce(a.raw_text, '')) LIKE '%' || lower(ht.name) || '%'
                THEN 'HOME_ONLY'
            WHEN lower(coalesce(a.title, '') || ' ' || coalesce(a.raw_text, '')) LIKE '%' || lower(at.name) || '%'
                THEN 'AWAY_ONLY'
            ELSE 'NO_TEAM'
        END AS match_reason
    FROM public.articles a
    JOIN public.matches m
      ON a.published_at IS NOT NULL
     AND m.kickoff BETWEEN (a.published_at - INTERVAL '14 days')
                       AND (a.published_at + INTERVAL '14 days')
    JOIN public.teams ht ON ht.id = m.home_team_id
    JOIN public.teams at ON at.id = m.away_team_id
    LEFT JOIN public.leagues l ON l.id = m.league_id
    WHERE a.article_quality_score >= 70
      AND (
          lower(coalesce(a.title, '') || ' ' || coalesce(a.raw_text, '')) LIKE '%' || lower(ht.name) || '%'
       OR lower(coalesce(a.title, '') || ' ' || coalesce(a.raw_text, '')) LIKE '%' || lower(at.name) || '%'
      )
)
SELECT *
FROM candidate_matches
ORDER BY
    CASE match_reason
        WHEN 'BOTH_TEAMS' THEN 1
        WHEN 'HOME_ONLY' THEN 2
        WHEN 'AWAY_ONLY' THEN 3
        ELSE 4
    END,
    published_at DESC
LIMIT 50;