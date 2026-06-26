/*
MATCHMATRIX SQL 120_Q_X Match Same Day Duplicate Audit V1

CO TO JE:
- Audit zápasů se stejnými týmy a stejným datem.

K ČEMU TO JE:
- Ověříme, jestli existují dva různé match_id pro Real Madrid vs Barcelona dne 2025-10-26.

KDE TO UVIDÍME:
- V DBeaveru.

JAK SE TO VYUŽIJE:
- Pokud najdeme duplicitu, navážeme match duplicate governance.
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
    WHERE m.sport_id = 1
      AND m.kickoff::date = DATE '2025-10-26'
      AND (
            ht.name ILIKE '%Real Madrid%'
         OR ht.name ILIKE '%Barcelona%'
         OR at.name ILIKE '%Real Madrid%'
         OR at.name ILIKE '%Barcelona%'
      )
)
SELECT
    match_date,
    sport_id,
    team_low,
    team_high,
    COUNT(*) AS duplicate_count,
    STRING_AGG(match_id::text, ', ' ORDER BY kickoff) AS match_ids,
    STRING_AGG(COALESCE(ext_source, '?') || ':' || COALESCE(ext_match_id, '?'), ' | ' ORDER BY kickoff) AS provider_refs,
    STRING_AGG(home_team || ' vs ' || away_team || ' | ' || COALESCE(league_name, '?'), ' || ' ORDER BY kickoff) AS match_names
FROM matches_norm
GROUP BY
    match_date,
    sport_id,
    team_low,
    team_high
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, match_date DESC;