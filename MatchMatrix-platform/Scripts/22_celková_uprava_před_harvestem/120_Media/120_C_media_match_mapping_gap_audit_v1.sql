/*
MATCHMATRIX SQL 120_C Media Match Mapping Gap Audit V1

CO TO JE:
- Audit článků bez napojení na konkrétní zápas.

K ČEMU TO JE:
- Ukáže kandidáty, které půjde později napojit na public.matches.

KDE TO UVIDÍME:
- OPS / Media Command Center / Match Context Engine.

JAK SE TO VYUŽIJE:
- Připraví pravidla pro automatické article -> match mapování.
*/

CREATE OR REPLACE VIEW ops.v_media_match_mapping_gap_audit_v1 AS
SELECT
    a.id AS article_id,
    a.title,
    a.content_source_id,
    a.published_at,
    a.url,

    CASE
        WHEN a.title ILIKE '% vs %'
          OR a.title ILIKE '% v %'
          OR a.title ILIKE '%matchday%'
          OR a.title ILIKE '%lineup%'
          OR a.title ILIKE '%lineups%'
          OR a.title ILIKE '%probable teams%'
          OR a.title ILIKE '%where to watch%'
          OR a.title ILIKE '%preview%'
          OR a.title ILIKE '%final day%'
        THEN 'MATCH_CANDIDATE'
        ELSE 'GENERAL_MEDIA'
    END AS match_mapping_candidate_type,

    CASE
        WHEN amm.article_id IS NULL THEN 'MISSING_MATCH_LINK'
        ELSE 'HAS_MATCH_LINK'
    END AS match_mapping_status,

    now() AS audited_at
FROM public.articles a
LEFT JOIN public.article_match_map amm
    ON amm.article_id = a.id;