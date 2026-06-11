/*
MATCHMATRIX SQL 120_E Media Match Resolution Candidates V1

CO TO JE:
- Bezpečný návrh article -> match kandidátů.

K ČEMU TO JE:
- Najde možné zápasy pro články podle názvu článku a týmů.

KDE TO UVIDÍME:
- OPS / Media Command Center / Match Context Engine.

JAK SE TO VYUŽIJE:
- Teprve další krok rozhodne, které vazby půjdou bezpečně vložit do public.article_match_map.
*/

CREATE OR REPLACE VIEW ops.v_media_match_resolution_candidates_v1 AS
SELECT
    c.article_id,
    c.title,
    c.mapped_league_name,
    c.match_signal,

    m.id AS match_id,
    m.kickoff,
    m.status,
    ht.name AS home_team,
    at.name AS away_team,
    l.name AS match_league_name,
    m.season,
    m.ext_source,
    m.ext_match_id,

    CASE
        WHEN c.title ILIKE '%Barcelona%' AND c.title ILIKE '%Real Madrid%'
             AND (
                 (ht.name ILIKE '%Barcelona%' AND at.name ILIKE '%Real Madrid%')
              OR (ht.name ILIKE '%Real Madrid%' AND at.name ILIKE '%Barcelona%')
             )
        THEN 'BARCELONA_REAL_MADRID'

        WHEN c.title ILIKE '%Betis%' AND c.title ILIKE '%Real Madrid%'
             AND (
                 (ht.name ILIKE '%Betis%' AND at.name ILIKE '%Real Madrid%')
              OR (ht.name ILIKE '%Real Madrid%' AND at.name ILIKE '%Betis%')
             )
        THEN 'BETIS_REAL_MADRID'

        ELSE 'NO_SAFE_TEAM_PAIR'
    END AS resolution_rule,

    CASE
        WHEN m.ext_source = 'football_data' THEN 100
        WHEN m.ext_source = 'api_football' THEN 90
        WHEN m.ext_source = 'football_data_uk' THEN 70
        ELSE 50
    END AS provider_priority,

    now() AS audited_at

FROM ops.v_media_match_mapping_candidates_v1 c
JOIN public.matches m
    ON (
        (
            c.title ILIKE '%Barcelona%'
            AND c.title ILIKE '%Real Madrid%'
            AND (
                m.home_team_id IN (
                    SELECT id FROM public.teams WHERE name ILIKE '%Barcelona%' OR name ILIKE '%Real Madrid%'
                )
                AND
                m.away_team_id IN (
                    SELECT id FROM public.teams WHERE name ILIKE '%Barcelona%' OR name ILIKE '%Real Madrid%'
                )
            )
        )
        OR
        (
            c.title ILIKE '%Betis%'
            AND c.title ILIKE '%Real Madrid%'
            AND (
                m.home_team_id IN (
                    SELECT id FROM public.teams WHERE name ILIKE '%Betis%' OR name ILIKE '%Real Madrid%'
                )
                AND
                m.away_team_id IN (
                    SELECT id FROM public.teams WHERE name ILIKE '%Betis%' OR name ILIKE '%Real Madrid%'
                )
            )
        )
    )
JOIN public.teams ht
    ON ht.id = m.home_team_id
JOIN public.teams at
    ON at.id = m.away_team_id
LEFT JOIN public.leagues l
    ON l.id = m.league_id
WHERE c.mapped_league_name ILIKE '%Liga%'
ORDER BY
    c.article_id,
    provider_priority DESC,
    m.kickoff DESC;