/*
MATCHMATRIX SQL 120_P_A_5 Alias Collision Context Audit V1

CO TO JE:
- Audit aliasů mapovaných na více týmů.

K ČEMU TO JE:
- Rozliší bezpečné kolize od nebezpečných.

KDE TO UVIDÍME:
- OPS / Match Context Engine.

JAK SE TO VYUŽIJE:
- Rozhodne, jestli resolver může alias použít automaticky,
  nebo musí přidat confidence/review.
*/

WITH alias_collisions AS (
    SELECT
        lower(trim(alias)) AS alias_key
    FROM public.team_aliases
    GROUP BY lower(trim(alias))
    HAVING COUNT(DISTINCT team_id) > 1
)
SELECT
    ac.alias_key,
    COUNT(DISTINCT ta.team_id) AS team_count,
    COUNT(DISTINCT t.sport_id) AS sport_count,

    CASE
        WHEN COUNT(DISTINCT t.sport_id) > 1
            THEN 'SAFE_DIFFERENT_SPORT'

        WHEN COUNT(DISTINCT t.sport_id) = 1
             AND COUNT(DISTINCT ta.team_id) > 1
            THEN 'RISK_SAME_SPORT'

        ELSE 'UNKNOWN'
    END AS collision_type

FROM alias_collisions ac
JOIN public.team_aliases ta
    ON lower(trim(ta.alias)) = ac.alias_key
JOIN public.teams t
    ON t.id = ta.team_id

GROUP BY ac.alias_key
ORDER BY
    team_count DESC,
    alias_key;