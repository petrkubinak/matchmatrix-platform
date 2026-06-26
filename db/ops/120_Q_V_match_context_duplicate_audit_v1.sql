/*
MATCHMATRIX SQL 120_Q_V Match Context Duplicate Audit V1

CO TO JE:
- Audit duplicitních zápasů v kandidátech Match Context Engine.

K ČEMU TO JE:
- Zjistíme, odkud se bere duplicitní zápas Barcelona vs Real Madrid.

KDE TO UVIDÍME:
- V DBeaveru jako seznam duplicit podle match_id / ext_match_id.

JAK SE TO VYUŽIJE:
- Podle výsledku opravíme view nebo funkci V3 tak, aby engine vracel každý zápas jen jednou.
*/

WITH ctx AS (
    SELECT *
    FROM ops.fn_context_match_pair_search_v2(
        'Barcelona',
        'Real Madrid',
        1,
        100
    )
)
SELECT
    match_id,
    ext_source,
    ext_match_id,
    kickoff,
    home_team,
    away_team,
    league_name,
    season,
    COUNT(*) AS duplicate_count
FROM ctx
GROUP BY
    match_id,
    ext_source,
    ext_match_id,
    kickoff,
    home_team,
    away_team,
    league_name,
    season
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, kickoff DESC;