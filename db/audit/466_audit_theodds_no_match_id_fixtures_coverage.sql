-- 466_audit_theodds_no_match_id_fixtures_coverage.sql
-- Audit coverage pro případy THEODDS = team matched, ale NO MATCH ID
-- Zaměřeno na konkrétní team_id z logu:
-- 27987 Cruzeiro
-- 27990 Flamengo
-- 28061 Palmeiras

-- =========================================================
-- 1) VSTUPNÍ TÝMY
-- =========================================================
WITH target_teams AS (
    SELECT 27987::bigint AS team_id, 'Cruzeiro'::text AS expected_name
    UNION ALL
    SELECT 27990::bigint, 'Flamengo'
    UNION ALL
    SELECT 28061::bigint, 'Palmeiras'
)

SELECT
    t.id,
    t.name,
    t.ext_source,
    t.ext_team_id
FROM public.teams t
JOIN target_teams x
  ON x.team_id = t.id
ORDER BY t.id;


-- =========================================================
-- 2) CELKOVÉ POKRYTÍ MATCHES PRO KAŽDÝ TEAM_ID
--    (min/max kickoff, kolik home/away, kolik future)
-- =========================================================
WITH target_teams AS (
    SELECT 27987::bigint AS team_id, 'Cruzeiro'::text AS expected_name
    UNION ALL
    SELECT 27990::bigint, 'Flamengo'
    UNION ALL
    SELECT 28061::bigint, 'Palmeiras'
),
team_matches AS (
    SELECT
        x.team_id,
        x.expected_name,
        m.id AS match_id,
        m.kickoff,
        m.league_id,
        CASE
            WHEN m.home_team_id = x.team_id THEN 'HOME'
            WHEN m.away_team_id = x.team_id THEN 'AWAY'
            ELSE 'OTHER'
        END AS side
    FROM target_teams x
    JOIN public.matches m
      ON m.home_team_id = x.team_id
      OR m.away_team_id = x.team_id
)
SELECT
    team_id,
    expected_name,
    COUNT(*) AS matches_total,
    MIN(kickoff) AS first_kickoff,
    MAX(kickoff) AS last_kickoff,
    COUNT(*) FILTER (WHERE side = 'HOME') AS home_matches,
    COUNT(*) FILTER (WHERE side = 'AWAY') AS away_matches,
    COUNT(*) FILTER (WHERE kickoff >= NOW()) AS future_matches,
    MIN(kickoff) FILTER (WHERE kickoff >= NOW()) AS first_future_kickoff,
    MAX(kickoff) FILTER (WHERE kickoff >= NOW()) AS last_future_kickoff
FROM team_matches
GROUP BY team_id, expected_name
ORDER BY team_id;


-- =========================================================
-- 3) POSLEDNÍCH 20 ZÁPASŮ PRO KAŽDÝ TEAM_ID
-- =========================================================
WITH target_teams AS (
    SELECT 27987::bigint AS team_id, 'Cruzeiro'::text AS expected_name
    UNION ALL
    SELECT 27990::bigint, 'Flamengo'
    UNION ALL
    SELECT 28061::bigint, 'Palmeiras'
),
team_matches AS (
    SELECT
        x.team_id,
        x.expected_name,
        m.id AS match_id,
        m.league_id,
        l.name AS league_name,
        m.kickoff,
        m.home_team_id,
        th.name AS home_team_name,
        m.away_team_id,
        ta.name AS away_team_name,
        ROW_NUMBER() OVER (
            PARTITION BY x.team_id
            ORDER BY m.kickoff DESC, m.id DESC
        ) AS rn
    FROM target_teams x
    JOIN public.matches m
      ON m.home_team_id = x.team_id
      OR m.away_team_id = x.team_id
    LEFT JOIN public.leagues l
      ON l.id = m.league_id
    LEFT JOIN public.teams th
      ON th.id = m.home_team_id
    LEFT JOIN public.teams ta
      ON ta.id = m.away_team_id
)
SELECT
    team_id,
    expected_name,
    match_id,
    league_id,
    league_name,
    kickoff,
    home_team_id,
    home_team_name,
    away_team_id,
    away_team_name
FROM team_matches
WHERE rn <= 20
ORDER BY team_id, kickoff DESC, match_id DESC;


-- =========================================================
-- 4) BUDOUCÍ ZÁPASY PRO TYTO TEAM_ID
-- =========================================================
WITH target_teams AS (
    SELECT 27987::bigint AS team_id, 'Cruzeiro'::text AS expected_name
    UNION ALL
    SELECT 27990::bigint, 'Flamengo'
    UNION ALL
    SELECT 28061::bigint, 'Palmeiras'
)
SELECT
    x.team_id,
    x.expected_name,
    m.id AS match_id,
    m.league_id,
    l.name AS league_name,
    m.kickoff,
    m.home_team_id,
    th.name AS home_team_name,
    m.away_team_id,
    ta.name AS away_team_name
FROM target_teams x
JOIN public.matches m
  ON m.home_team_id = x.team_id
  OR m.away_team_id = x.team_id
LEFT JOIN public.leagues l
  ON l.id = m.league_id
LEFT JOIN public.teams th
  ON th.id = m.home_team_id
LEFT JOIN public.teams ta
  ON ta.id = m.away_team_id
WHERE m.kickoff >= NOW()
ORDER BY x.team_id, m.kickoff, m.id;


-- =========================================================
-- 5) AUDIT KONKRÉTNÍCH DVOJIC Z LOGU
--    zkusí najít budoucí zápasy pro páry:
--    Cruzeiro vs Vitoria
--    Flamengo vs Santos
--    Bahia vs Palmeiras
--
--    DŮLEŽITÉ:
--    Tady dávám ID přesně podle logu / známých větví.
--    Pokud zjistíš jiné správné team_id pro soupeře, přepiš je.
-- =========================================================
WITH target_pairs AS (
    -- home_team_id, away_team_id, label
    SELECT 27987::bigint AS home_team_id, 586::bigint   AS away_team_id, 'Cruzeiro vs Vitoria'::text AS pair_label
    UNION ALL
    SELECT 27990::bigint, 23::bigint,    'Flamengo vs Santos'
    UNION ALL
    SELECT 13::bigint,    28061::bigint, 'Bahia vs Palmeiras'
),
pair_matches AS (
    SELECT
        p.pair_label,
        p.home_team_id AS expected_home_team_id,
        p.away_team_id AS expected_away_team_id,
        m.id AS match_id,
        m.league_id,
        l.name AS league_name,
        m.kickoff,
        m.home_team_id,
        th.name AS home_team_name,
        m.away_team_id,
        ta.name AS away_team_name,
        CASE
            WHEN m.home_team_id = p.home_team_id
             AND m.away_team_id = p.away_team_id
            THEN 'DIRECT'
            WHEN m.home_team_id = p.away_team_id
             AND m.away_team_id = p.home_team_id
            THEN 'REVERSED'
            ELSE 'OTHER'
        END AS pair_match_type
    FROM target_pairs p
    JOIN public.matches m
      ON (
            (m.home_team_id = p.home_team_id AND m.away_team_id = p.away_team_id)
         OR (m.home_team_id = p.away_team_id AND m.away_team_id = p.home_team_id)
         )
    LEFT JOIN public.leagues l
      ON l.id = m.league_id
    LEFT JOIN public.teams th
      ON th.id = m.home_team_id
    LEFT JOIN public.teams ta
      ON ta.id = m.away_team_id
)
SELECT
    pair_label,
    expected_home_team_id,
    expected_away_team_id,
    match_id,
    league_id,
    league_name,
    kickoff,
    home_team_id,
    home_team_name,
    away_team_id,
    away_team_name,
    pair_match_type
FROM pair_matches
ORDER BY pair_label, kickoff DESC, match_id DESC;


-- =========================================================
-- 6) DO JAKÉHO DATA SAHÁ KAŽDÁ LIGA PRO TYTO TEAM_ID
-- =========================================================
WITH target_teams AS (
    SELECT 27987::bigint AS team_id, 'Cruzeiro'::text AS expected_name
    UNION ALL
    SELECT 27990::bigint, 'Flamengo'
    UNION ALL
    SELECT 28061::bigint, 'Palmeiras'
),
team_league_coverage AS (
    SELECT
        x.team_id,
        x.expected_name,
        m.league_id,
        l.name AS league_name,
        COUNT(*) AS matches_total,
        MIN(m.kickoff) AS first_kickoff,
        MAX(m.kickoff) AS last_kickoff,
        COUNT(*) FILTER (WHERE m.kickoff >= NOW()) AS future_matches,
        MIN(m.kickoff) FILTER (WHERE m.kickoff >= NOW()) AS first_future_kickoff,
        MAX(m.kickoff) FILTER (WHERE m.kickoff >= NOW()) AS last_future_kickoff
    FROM target_teams x
    JOIN public.matches m
      ON m.home_team_id = x.team_id
      OR m.away_team_id = x.team_id
    LEFT JOIN public.leagues l
      ON l.id = m.league_id
    GROUP BY x.team_id, x.expected_name, m.league_id, l.name
)
SELECT
    team_id,
    expected_name,
    league_id,
    league_name,
    matches_total,
    first_kickoff,
    last_kickoff,
    future_matches,
    first_future_kickoff,
    last_future_kickoff
FROM team_league_coverage
ORDER BY team_id, last_kickoff DESC NULLS LAST, league_id;


-- =========================================================
-- 7) EXTRA: EXISTUJE PRO STEJNÝ NÁZEV JINÁ TEAM VĚTEV?
--    Pomůže najít duplicity typu stejný klub na jiném team_id.
-- =========================================================
WITH target_names AS (
    SELECT 'Cruzeiro'::text AS team_name
    UNION ALL
    SELECT 'Flamengo'
    UNION ALL
    SELECT 'Palmeiras'
)
SELECT
    t.id,
    t.name,
    t.ext_source,
    t.ext_team_id
FROM public.teams t
JOIN target_names n
  ON lower(t.name) LIKE lower(n.team_name) || '%'
ORDER BY t.name, t.ext_source, t.id;