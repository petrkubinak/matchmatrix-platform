-- 509_debug_real_madrid_and_sporting_arsenal.sql
-- Cíl:
-- 1) ověřit duplicitu aliasu Real Madrid
-- 2) ověřit, zda Sporting Lisbon vs Arsenal existuje v matches obráceně

-- =========================================================
-- A. Alias detail: Real Madrid
-- =========================================================
SELECT
    ta.id,
    ta.team_id,
    t.name AS canonical_team_name,
    ta.alias,
    ta.source
FROM public.team_aliases ta
JOIN public.teams t
  ON t.id = ta.team_id
WHERE lower(trim(public.unaccent(ta.alias))) = lower(trim(public.unaccent('Real Madrid')))
ORDER BY ta.team_id, ta.id;


-- =========================================================
-- B. Team profile pro Real Madrid ID z debug výstupu
-- =========================================================
SELECT
    t.id,
    t.name,
    t.ext_source,
    t.ext_team_id,
    (SELECT count(*) FROM public.team_provider_map tpm WHERE tpm.team_id = t.id) AS provider_map_count,
    (SELECT count(*) FROM public.matches m WHERE m.home_team_id = t.id OR m.away_team_id = t.id) AS matches_count
FROM public.teams t
WHERE t.id IN (81, 12092)
ORDER BY t.id;


-- =========================================================
-- C. Najdi Arsenal / Sporting kolem stejného kickoffu v obou směrech
-- =========================================================
SELECT
    m.id,
    m.kickoff,
    m.home_team_id,
    th.name AS home_team_name,
    m.away_team_id,
    ta.name AS away_team_name,
    m.ext_source,
    m.ext_match_id,
    m.status
FROM public.matches m
JOIN public.teams th ON th.id = m.home_team_id
JOIN public.teams ta ON ta.id = m.away_team_id
WHERE m.kickoff BETWEEN '2026-04-07 00:00:00' AND '2026-04-08 23:59:59'
  AND (
        (m.home_team_id = 87 AND m.away_team_id = 11910)
     OR (m.home_team_id = 11910 AND m.away_team_id = 87)
  )
ORDER BY m.kickoff, m.id;


-- =========================================================
-- D. Alias detail: Sporting Lisbon / Arsenal
-- =========================================================
SELECT
    ta.team_id,
    t.name AS canonical_team_name,
    ta.alias,
    ta.source
FROM public.team_aliases ta
JOIN public.teams t
  ON t.id = ta.team_id
WHERE lower(trim(public.unaccent(ta.alias))) IN (
    lower(trim(public.unaccent('Sporting Lisbon'))),
    lower(trim(public.unaccent('Arsenal')))
)
ORDER BY ta.alias, ta.team_id;