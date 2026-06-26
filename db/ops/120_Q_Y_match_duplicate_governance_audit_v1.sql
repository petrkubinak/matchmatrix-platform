/*
MATCHMATRIX SQL 120_Q_Y Match Duplicate Governance Audit V1

CO TO JE:
- Audit duplicitních zápasů podle sportu, dne a dvojice týmů.

K ČEMU TO JE:
- Najdeme všechny případy, kde máme stejný zápas uložený vícekrát z různých providerů.

KDE TO UVIDÍME:
- V DBeaveru jako seznam duplicitních skupin.

JAK SE TO VYUŽIJE:
- Další krok vytvoří HOLD / MERGE plán, aby Context Engine, statistiky a web nepoužívaly duplicitní zápasy.
*/

WITH matches_norm AS (
    SELECT
        m.id AS match_id,
        m.ext_source,
        m.ext_match_id,
        m.kickoff::date AS match_date,
        m.kickoff,
        m.sport_id,
        m.league_id,
        l.name AS league_name,
        m.season,
        m.status,
        m.home_score,
        m.away_score,
        m.home_team_id,
        ht.name AS home_team,
        m.away_team_id,
        at.name AS away_team,
        LEAST(m.home_team_id, m.away_team_id) AS team_low,
        GREATEST(m.home_team_id, m.away_team_id) AS team_high
    FROM public.matches m
    JOIN public.teams ht ON ht.id = m.home_team_id
    JOIN public.teams at ON at.id = m.away_team_id
    LEFT JOIN public.leagues l ON l.id = m.league_id
)
SELECT
    sport_id,
    match_date,
    team_low,
    team_high,
    COUNT(*) AS duplicate_count,
    STRING_AGG(match_id::text, ', ' ORDER BY kickoff, match_id) AS match_ids,
    STRING_AGG(COALESCE(ext_source, '?') || ':' || COALESCE(ext_match_id, '?'), ' | ' ORDER BY kickoff, match_id) AS provider_refs,
    STRING_AGG(
        home_team || ' vs ' || away_team
        || ' | ' || COALESCE(league_name, '?')
        || ' | ' || COALESCE(status, '?')
        || ' | ' || COALESCE(home_score::text, '?') || ':' || COALESCE(away_score::text, '?'),
        ' || '
        ORDER BY kickoff, match_id
    ) AS match_detail
FROM matches_norm
GROUP BY
    sport_id,
    match_date,
    team_low,
    team_high
HAVING COUNT(*) > 1
ORDER BY
    duplicate_count DESC,
    match_date DESC;