/*
MATCHMATRIX SQL 120_O Insert Direct Match Context V1

CO TO JE:
- Bezpečný INSERT jednoho ověřeného direct match článku.

K ČEMU TO JE:
- Doplní article -> match vazbu pro Atlético Madrid vs FC Barcelona.

KDE TO UVIDÍME:
- Match Context Dashboard / detail zápasu / Media Command Center.

JAK SE TO VYUŽIJE:
- Článek se zobrazí u konkrétního zápasu.
*/

INSERT INTO public.article_match_map (
    article_id,
    match_id,
    created_at
)
SELECT
    405 AS article_id,
    66735 AS match_id,
    now()
WHERE NOT EXISTS (
    SELECT 1
    FROM public.article_match_map
    WHERE article_id = 405
      AND match_id = 66735
);