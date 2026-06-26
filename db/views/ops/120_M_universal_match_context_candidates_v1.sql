/*
MATCHMATRIX SQL 120_M Universal Match Context Candidates V1

CO TO JE:
- Univerzální kandidátní resolver article -> match napříč systémem.

K ČEMU TO JE:
- Najde články, které mají ligu a potenciální match signál.
- Připraví kandidáty pro obecný Match Context Engine.

KDE TO UVIDÍME:
- OPS / Media Command Center / Match Context Engine.

JAK SE TO VYUŽIJE:
- Další krok vybere nejlepší match kandidáty podle skóre a confidence.
*/

CREATE OR REPLACE VIEW ops.v_universal_match_context_candidates_v1 AS
SELECT
    a.id AS article_id,
    a.title,
    a.published_at,
    a.content_type,
    a.content_source_id,

    alm.league_id AS article_league_id,
    l.name AS article_league_name,

    CASE
        WHEN a.title ILIKE '% vs %' THEN 'VS_SIGNAL'
        WHEN a.title ILIKE '% v %' THEN 'V_SIGNAL'
        WHEN a.title ILIKE '%matchday%' THEN 'MATCHDAY_SIGNAL'
        WHEN a.title ILIKE '%lineup%' OR a.title ILIKE '%lineups%' THEN 'LINEUP_SIGNAL'
        WHEN a.title ILIKE '%preview%' THEN 'PREVIEW_SIGNAL'
        WHEN a.title ILIKE '%where to watch%' THEN 'WATCH_SIGNAL'
        WHEN a.title ILIKE '%final day%' THEN 'FINAL_DAY_SIGNAL'
        ELSE 'NO_MATCH_SIGNAL'
    END AS match_signal,

    CASE
        WHEN amm.article_id IS NULL THEN 'MISSING_MATCH_LINK'
        ELSE 'HAS_MATCH_LINK'
    END AS match_link_status,

    now() AS audited_at

FROM public.articles a
LEFT JOIN public.article_league_map alm
    ON alm.article_id = a.id
LEFT JOIN public.leagues l
    ON l.id = alm.league_id
LEFT JOIN public.article_match_map amm
    ON amm.article_id = a.id
WHERE amm.article_id IS NULL
  AND alm.league_id IS NOT NULL
  AND (
        a.title ILIKE '% vs %'
     OR a.title ILIKE '% v %'
     OR a.title ILIKE '%matchday%'
     OR a.title ILIKE '%lineup%'
     OR a.title ILIKE '%lineups%'
     OR a.title ILIKE '%preview%'
     OR a.title ILIKE '%where to watch%'
     OR a.title ILIKE '%final day%'
  );