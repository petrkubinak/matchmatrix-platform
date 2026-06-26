/*
MATCHMATRIX SCRIPT

NÁZEV:
20_3_F_core_media_year_gap_audit_v2.sql

CO TO JE:
Audit rozdílu mezi rokem článků a rokem zápasů v databázi.

K ČEMU TO JE:
Ověření, zda nízké MEDIA MATCH COVERAGE
není způsobeno chybou parseru, ale chybějícími
sezónami a zápasy v CORE vrstvě.

KDE TO UVIDÍME:
DBeaver

JAK SE TO VYUŽIJE:
Potvrzení připravenosti na velký harvest.
Rozhodnutí, zda řešit MEDIA nebo nejdříve rozšířit CORE.

POZNÁMKA:
public.matches nemá match_date.
Datum zápasu je ve sloupci kickoff.
*/

WITH media_years AS (
    SELECT
        EXTRACT(YEAR FROM published_at)::integer AS data_year,
        COUNT(*) AS articles
    FROM public.articles
    WHERE published_at IS NOT NULL
    GROUP BY EXTRACT(YEAR FROM published_at)
),

match_years AS (
    SELECT
        EXTRACT(YEAR FROM kickoff)::integer AS data_year,
        COUNT(*) AS matches
    FROM public.matches
    WHERE kickoff IS NOT NULL
    GROUP BY EXTRACT(YEAR FROM kickoff)
)

SELECT
    COALESCE(my.data_year, gy.data_year) AS year,

    COALESCE(my.articles, 0) AS articles,
    COALESCE(gy.matches, 0) AS matches,

    CASE
        WHEN COALESCE(my.articles, 0) > 0
         AND COALESCE(gy.matches, 0) = 0
            THEN 'MEDIA_WITHOUT_CORE'

        WHEN COALESCE(my.articles, 0) = 0
         AND COALESCE(gy.matches, 0) > 0
            THEN 'CORE_WITHOUT_MEDIA'

        WHEN COALESCE(my.articles, 0) > 0
         AND COALESCE(gy.matches, 0) > 0
            THEN 'COVERED'

        ELSE 'EMPTY'
    END AS status

FROM media_years my
FULL OUTER JOIN match_years gy
    ON my.data_year = gy.data_year

ORDER BY year DESC;