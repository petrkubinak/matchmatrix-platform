-- =====================================================================
-- 575_attach_now_update_safe.sql
-- Účel:
-- bezpečně propsat jednoznačně nalezené candidate_match_id
-- do public.unmatched_theodds.match_id
-- =====================================================================

BEGIN;

WITH src AS (
    SELECT
        u.ctid,
        u.provider,
        u.league_name,
        u.event_name,
        u.home_raw,
        u.away_raw,
        u.home_normalized,
        u.away_normalized,
        u.best_home_candidate,
        u.best_away_candidate,
        u.best_home_score,
        u.best_away_score,
        u.match_id,
        u.issue_code
    FROM public.unmatched_theodds u
    WHERE u.issue_code = 'NO_MATCH_ID'
      AND COALESCE(u.best_home_score, 0) = 1
      AND COALESCE(u.best_away_score, 0) = 1
      AND COALESCE(u.match_id, '') = ''
      AND NOT (
            u.league_name IN ('soccer_spain_la_liga', 'soccer_uefa_champs_league')
        AND (
               lower(u.home_raw) IN ('atlético madrid', 'barcelona')
            OR lower(u.away_raw) IN ('atlético madrid', 'barcelona')
        )
      )
      AND NOT (
            u.league_name = 'soccer_fifa_world_cup'
        AND u.event_name = 'Australia vs Jordan'
      )
      AND NOT (
            u.league_name = 'soccer_conmebol_copa_libertadores'
        AND (
               lower(u.home_raw) LIKE '%universidad católica%'
            OR lower(u.away_raw) LIKE '%universidad católica%'
        )
      )
),
league_map AS (
    SELECT s.*, l.id AS league_id
    FROM src s
    JOIN public.leagues l
      ON lower(l.theodds_key) = lower(s.league_name)
),
home_ok AS (
    SELECT
        lm.*,
        MIN(ta.team_id) AS home_team_id
    FROM league_map lm
    JOIN public.team_aliases ta
      ON lower(public.unaccent(ta.alias)) = lower(public.unaccent(lm.best_home_candidate))
    GROUP BY
        lm.ctid, lm.provider, lm.league_name, lm.event_name, lm.home_raw, lm.away_raw,
        lm.home_normalized, lm.away_normalized,
        lm.best_home_candidate, lm.best_away_candidate,
        lm.best_home_score, lm.best_away_score, lm.match_id, lm.issue_code, lm.league_id
    HAVING COUNT(DISTINCT ta.team_id) = 1
),
away_ok AS (
    SELECT
        ho.*,
        MIN(ta.team_id) AS away_team_id
    FROM home_ok ho
    JOIN public.team_aliases ta
      ON lower(public.unaccent(ta.alias)) = lower(public.unaccent(ho.best_away_candidate))
    GROUP BY
        ho.ctid, ho.provider, ho.league_name, ho.event_name, ho.home_raw, ho.away_raw,
        ho.home_normalized, ho.away_normalized,
        ho.best_home_candidate, ho.best_away_candidate,
        ho.best_home_score, ho.best_away_score, ho.match_id, ho.issue_code, ho.league_id, ho.home_team_id
    HAVING COUNT(DISTINCT ta.team_id) = 1
),
match_unique AS (
    SELECT
        ao.ctid,
        MIN(m.id) AS candidate_match_id
    FROM away_ok ao
    JOIN public.matches m
      ON m.league_id    = ao.league_id
     AND m.home_team_id = ao.home_team_id
     AND m.away_team_id = ao.away_team_id
    GROUP BY ao.ctid
    HAVING COUNT(DISTINCT m.id) = 1
),
upd AS (
    UPDATE public.unmatched_theodds u
    SET match_id = mu.candidate_match_id::text
    FROM match_unique mu
    WHERE u.ctid = mu.ctid
    RETURNING
        u.provider,
        u.league_name,
        u.event_name,
        u.home_raw,
        u.away_raw,
        mu.candidate_match_id
)
SELECT *
FROM upd
ORDER BY league_name, event_name;

COMMIT;