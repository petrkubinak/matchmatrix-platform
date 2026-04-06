-- =====================================================================
-- 574_attach_now_linker_safe.sql
-- Účel:
-- Bezpečný attach ATTACH_NOW backlogu z public.unmatched_theodds
--
-- LOGIKA:
-- 1) bereme jen issue_code = 'NO_MATCH_ID'
-- 2) bereme jen best_home_score = 1 a best_away_score = 1
-- 3) mapujeme TheOdds league_name -> public.leagues.theodds_key
-- 4) mapujeme home/away kandidáty přes team_aliases
-- 5) attach provádíme JEN pokud:
--    - home alias resolve je jednoznačný
--    - away alias resolve je jednoznačný
--    - existuje přesně 1 canonical match ve stejné lize se stejným párem
-- 6) výjimky neattachujeme:
--    - Atlético/Barcelona La Liga vs UCL
--    - Australia vs Jordan
--    - Universidad Católica (CHI) edge cases
-- =====================================================================

-- ---------------------------------------------------------------------
-- A) PREVIEW: co je připravené na bezpečný attach
-- ---------------------------------------------------------------------
WITH src AS (
    SELECT
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
    SELECT
        s.*,
        l.id   AS league_id,
        l.name AS canonical_league_name
    FROM src s
    JOIN public.leagues l
      ON lower(l.theodds_key) = lower(s.league_name)
),
home_alias_candidates AS (
    SELECT
        lm.*,
        ta.team_id AS home_team_id
    FROM league_map lm
    JOIN public.team_aliases ta
      ON lower(public.unaccent(ta.alias)) = lower(public.unaccent(lm.best_home_candidate))
),
home_alias_unique AS (
    SELECT
        hac.provider,
        hac.league_name,
        hac.event_name,
        hac.home_raw,
        hac.away_raw,
        hac.home_normalized,
        hac.away_normalized,
        hac.best_home_candidate,
        hac.best_away_candidate,
        hac.best_home_score,
        hac.best_away_score,
        hac.match_id,
        hac.issue_code,
        hac.league_id,
        hac.canonical_league_name,
        MIN(hac.home_team_id) AS home_team_id
    FROM home_alias_candidates hac
    GROUP BY
        hac.provider,
        hac.league_name,
        hac.event_name,
        hac.home_raw,
        hac.away_raw,
        hac.home_normalized,
        hac.away_normalized,
        hac.best_home_candidate,
        hac.best_away_candidate,
        hac.best_home_score,
        hac.best_away_score,
        hac.match_id,
        hac.issue_code,
        hac.league_id,
        hac.canonical_league_name
    HAVING COUNT(DISTINCT hac.home_team_id) = 1
),
away_alias_candidates AS (
    SELECT
        hua.*,
        ta.team_id AS away_team_id
    FROM home_alias_unique hua
    JOIN public.team_aliases ta
      ON lower(public.unaccent(ta.alias)) = lower(public.unaccent(hua.best_away_candidate))
),
away_alias_unique AS (
    SELECT
        aac.provider,
        aac.league_name,
        aac.event_name,
        aac.home_raw,
        aac.away_raw,
        aac.home_normalized,
        aac.away_normalized,
        aac.best_home_candidate,
        aac.best_away_candidate,
        aac.best_home_score,
        aac.best_away_score,
        aac.match_id,
        aac.issue_code,
        aac.league_id,
        aac.canonical_league_name,
        aac.home_team_id,
        MIN(aac.away_team_id) AS away_team_id
    FROM away_alias_candidates aac
    GROUP BY
        aac.provider,
        aac.league_name,
        aac.event_name,
        aac.home_raw,
        aac.away_raw,
        aac.home_normalized,
        aac.away_normalized,
        aac.best_home_candidate,
        aac.best_away_candidate,
        aac.best_home_score,
        aac.best_away_score,
        aac.match_id,
        aac.issue_code,
        aac.league_id,
        aac.canonical_league_name,
        aac.home_team_id
    HAVING COUNT(DISTINCT aac.away_team_id) = 1
),
match_candidates AS (
    SELECT
        aau.*,
        m.id AS candidate_match_id
    FROM away_alias_unique aau
    JOIN public.matches m
      ON m.league_id     = aau.league_id
     AND m.home_team_id  = aau.home_team_id
     AND m.away_team_id  = aau.away_team_id
),
match_unique AS (
    SELECT
        mc.provider,
        mc.league_name,
        mc.event_name,
        mc.home_raw,
        mc.away_raw,
        mc.home_normalized,
        mc.away_normalized,
        mc.best_home_candidate,
        mc.best_away_candidate,
        mc.best_home_score,
        mc.best_away_score,
        mc.match_id,
        mc.issue_code,
        mc.league_id,
        mc.canonical_league_name,
        mc.home_team_id,
        mc.away_team_id,
        MIN(mc.candidate_match_id) AS candidate_match_id
    FROM match_candidates mc
    GROUP BY
        mc.provider,
        mc.league_name,
        mc.event_name,
        mc.home_raw,
        mc.away_raw,
        mc.home_normalized,
        mc.away_normalized,
        mc.best_home_candidate,
        mc.best_away_candidate,
        mc.best_home_score,
        mc.best_away_score,
        mc.match_id,
        mc.issue_code,
        mc.league_id,
        mc.canonical_league_name,
        mc.home_team_id,
        mc.away_team_id
    HAVING COUNT(DISTINCT mc.candidate_match_id) = 1
)
SELECT
    provider,
    league_name,
    canonical_league_name,
    event_name,
    home_raw,
    away_raw,
    best_home_candidate,
    best_away_candidate,
    home_team_id,
    away_team_id,
    candidate_match_id
FROM match_unique
ORDER BY league_name, event_name;

-- ---------------------------------------------------------------------
-- B) SOUHRN: kolik řádků je skutečně bezpečně attachnutelných
-- ---------------------------------------------------------------------
WITH src AS (
    SELECT
        u.provider,
        u.league_name,
        u.event_name,
        u.home_raw,
        u.away_raw,
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
        lm.provider, lm.league_name, lm.event_name, lm.home_raw, lm.away_raw,
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
        ho.provider, ho.league_name, ho.event_name, ho.home_raw, ho.away_raw,
        ho.best_home_candidate, ho.best_away_candidate,
        ho.best_home_score, ho.best_away_score, ho.match_id, ho.issue_code, ho.league_id, ho.home_team_id
    HAVING COUNT(DISTINCT ta.team_id) = 1
),
match_ok AS (
    SELECT
        ao.league_name,
        COUNT(*) AS rows_count
    FROM away_ok ao
    JOIN public.matches m
      ON m.league_id    = ao.league_id
     AND m.home_team_id = ao.home_team_id
     AND m.away_team_id = ao.away_team_id
    GROUP BY ao.league_name, ao.event_name, ao.home_raw, ao.away_raw
    HAVING COUNT(DISTINCT m.id) = 1
)
SELECT
    league_name,
    COUNT(*) AS safe_attach_rows
FROM match_ok
GROUP BY league_name
ORDER BY safe_attach_rows DESC, league_name;


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
)
UPDATE public.unmatched_theodds u
SET match_id = mu.candidate_match_id::text
FROM match_unique mu
WHERE u.ctid = mu.ctid;
