/*
MATCHMATRIX SQL 120_K Insert LaLiga Article Match Map V1

CO TO JE:
- Bezpečný INSERT ověřených article -> match vazeb.

K ČEMU TO JE:
- Poprvé naplní public.article_match_map reálnými vazbami.

KDE TO UVIDÍME:
- Media Command Center / Match Context Engine / detail zápasu na webu.

JAK SE TO VYUŽIJE:
- Články budou napojené na konkrétní zápasy.
*/

INSERT INTO public.article_match_map (
    article_id,
    match_id,
    created_at
)
SELECT
    article_id,
    match_id,
    now()
FROM ops.v_laliga_article_match_best_candidate_v1 c
WHERE NOT EXISTS (
    SELECT 1
    FROM public.article_match_map amm
    WHERE amm.article_id = c.article_id
      AND amm.match_id = c.match_id
);