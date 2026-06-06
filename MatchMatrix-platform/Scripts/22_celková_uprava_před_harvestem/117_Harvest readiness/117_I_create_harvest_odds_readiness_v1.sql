/*
===============================================================================
MATCHMATRIX SQL 117_I
HARVEST ODDS READINESS V1

CO TO JE:
- Auditní view připravenosti ODDS vrstvy na hromadný harvest.

K ČEMU TO JE:
- Vyhodnocuje pokrytí kurzů po sportech.
- Kontroluje napojení odds na zápasy.
- Ukazuje, kde jsou kurzy bez použitelného match coverage.
- Identifikuje sporty bez odds providerů.

KDE TO UVIDÍME:
- OPS Panel
- Harvest Dashboard
- Odds Roadmap
- Mission Control
- Budoucí Admin Web

JAK SE TO VYUŽIJE:
- plánování odds providerů
- příprava PRO harvestu
- priorita pro napojení odds
- budoucí Value Bets engine

ZDROJ DAT:
- public.sports
- public.matches
- public.odds
- public.bookmakers
- public.market_outcomes
- public.unmatched_theodds

VÝSTUP:
- matches_with_odds
- odds_rows
- odds_readiness_score
- odds_readiness_status
- recommendation_cz

VLIV NA HARVEST:
- Přímý
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_harvest_odds_readiness_v1 AS
WITH odds_by_sport AS (
    SELECT
        s.code AS sport_code,
        s.name AS sport_name,
        COUNT(DISTINCT m.id) AS total_matches,
        COUNT(DISTINCT o.match_id) AS matches_with_odds,
        COUNT(o.*) AS odds_rows
    FROM public.sports s
    LEFT JOIN public.matches m
           ON m.sport_id = s.id
    LEFT JOIN public.odds o
           ON o.match_id = m.id
    GROUP BY s.code, s.name
),
global_stats AS (
    SELECT
        (SELECT COUNT(*) FROM public.bookmakers) AS bookmakers_count,
        (SELECT COUNT(*) FROM public.market_outcomes) AS market_outcomes_count,
        (SELECT COUNT(*) FROM public.unmatched_theodds) AS unmatched_theodds_count
)
SELECT
    o.sport_code,
    o.sport_name,
    o.total_matches,
    o.matches_with_odds,
    o.odds_rows,

    g.bookmakers_count,
    g.market_outcomes_count,
    g.unmatched_theodds_count,

    ROUND(
        CASE
            WHEN o.total_matches > 0
            THEN (o.matches_with_odds::numeric / o.total_matches::numeric) * 100
            ELSE 0
        END,
        2
    ) AS match_odds_coverage_pct,

    LEAST(
        100,
        (
            CASE WHEN o.odds_rows > 0 THEN 20 ELSE 0 END
            +
            CASE WHEN o.matches_with_odds > 0 THEN 30 ELSE 0 END
            +
            CASE
                WHEN o.total_matches > 0
                THEN LEAST(30, (o.matches_with_odds::numeric / o.total_matches::numeric) * 30)
                ELSE 0
            END
            +
            CASE WHEN g.bookmakers_count >= 10 THEN 10 ELSE 0 END
            +
            CASE WHEN g.market_outcomes_count >= 5 THEN 10 ELSE 0 END
        )
    ) AS odds_readiness_score,

    CASE
        WHEN o.odds_rows = 0 THEN 'ODDS_EMPTY'
        WHEN o.matches_with_odds = 0 THEN 'ODDS_NOT_LINKED_TO_MATCHES'
        WHEN o.total_matches > 0
         AND (o.matches_with_odds::numeric / NULLIF(o.total_matches,0)) < 0.05
        THEN 'ODDS_LOW_MATCH_COVERAGE'
        ELSE 'ODDS_BASE_READY'
    END AS odds_readiness_status,

    CASE
        WHEN o.odds_rows = 0
            THEN 'Najít nebo zapojit odds providera pro tento sport.'
        WHEN o.matches_with_odds = 0
            THEN 'Kurzy existují, ale nejsou správně napojené na public.matches.'
        WHEN o.total_matches > 0
         AND (o.matches_with_odds::numeric / NULLIF(o.total_matches,0)) < 0.05
            THEN 'Zlepšit odds → match linking a rozšířit coverage.'
        ELSE 'Základní ODDS vrstva je připravena, dále rozšířit historické a live kurzy.'
    END AS recommendation_cz

FROM odds_by_sport o
CROSS JOIN global_stats g;