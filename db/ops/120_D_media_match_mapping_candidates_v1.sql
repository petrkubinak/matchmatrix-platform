/*
MATCHMATRIX SQL 120_D Media Match Mapping Candidates V1

CO TO JE:
- Kandidátní audit pro napojení článků na konkrétní zápasy.

K ČEMU TO JE:
- Najde články typu match preview / lineups / where to watch / matchday
  a připraví je pro bezpečné ruční nebo automatické mapování na public.matches.

KDE TO UVIDÍME:
- OPS / Media Command Center / Match Context Engine.

JAK SE TO VYUŽIJE:
- Další krok bude vytvořit bezpečný INSERT do public.article_match_map.
*/

CREATE OR REPLACE VIEW ops.v_media_match_mapping_candidates_v1 AS
SELECT
    a.id AS article_id,
    a.title,
    a.content_source_id,
    a.published_at,
    a.url,

    atm.team_id,
    t.name AS mapped_team_name,

    alm.league_id,
    l.name AS mapped_league_name,

    CASE
        WHEN a.title ILIKE '% vs %' THEN 'TITLE_HAS_VS'
        WHEN a.title ILIKE '% v %' THEN 'TITLE_HAS_V'
        WHEN a.title ILIKE '%matchday%' THEN 'TITLE_HAS_MATCHDAY'
        WHEN a.title ILIKE '%lineup%' OR a.title ILIKE '%lineups%' THEN 'TITLE_HAS_LINEUP'
        WHEN a.title ILIKE '%probable teams%' THEN 'TITLE_HAS_PROBABLE_TEAMS'
        WHEN a.title ILIKE '%where to watch%' THEN 'TITLE_HAS_WHERE_TO_WATCH'
        WHEN a.title ILIKE '%final day%' THEN 'TITLE_HAS_FINAL_DAY'
        ELSE 'OTHER_MATCH_SIGNAL'
    END AS match_signal,

    'NEEDS_MATCH_RESOLUTION' AS candidate_status,

    now() AS audited_at

FROM public.articles a
LEFT JOIN public.article_team_map atm
    ON atm.article_id = a.id
LEFT JOIN public.teams t
    ON t.id = atm.team_id
LEFT JOIN public.article_league_map alm
    ON alm.article_id = a.id
LEFT JOIN public.leagues l
    ON l.id = alm.league_id
LEFT JOIN public.article_match_map amm
    ON amm.article_id = a.id
WHERE amm.article_id IS NULL
  AND (
        a.title ILIKE '% vs %'
     OR a.title ILIKE '% v %'
     OR a.title ILIKE '%matchday%'
     OR a.title ILIKE '%lineup%'
     OR a.title ILIKE '%lineups%'
     OR a.title ILIKE '%probable teams%'
     OR a.title ILIKE '%where to watch%'
     OR a.title ILIKE '%final day%'
  );