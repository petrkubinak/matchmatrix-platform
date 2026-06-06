/*
MATCHMATRIX SQL 17_8_E1
TEAM SPORT NORMALIZATION AUDIT V1

CO TO JE:
- Audit týmů bez vyplněného sport_id.
- Navrhuje bezpečné doplnění sport_id podle zdrojového providera (ext_source).
- Neprovádí žádné změny v databázi.

K ČEMU TO JE:
- Odhalí týmy, které nemají přiřazený sport.
- Umožní bezpečně doplnit sport_id před deduplikací.
- Zabrání chybnému slučování týmů z různých sportů se stejným názvem.
- Připraví databázi pro TEAM SAFE MERGE PLAN.

KDE TO UVIDÍME:
- OPS Panel -> ČIŠTĚNÍ DB
- OPS Panel -> DATA QUALITY
- DBeaver audit sportovní normalizace
- DBeaver audit týmů bez sport_id

JAK SE TO VYUŽIJE:
- Další krok vytvoří plán doplnění sport_id.
- Po doplnění sport_id bude znovu přepočten TEAM DUPLICATE AUDIT.
- Výsledkem budou pouze skutečné duplicity v rámci stejného sportu.
- Následně bude možné vytvořit bezpečný TEAM SAFE MERGE PLAN bez rizika spojení týmů z různých sportů.
*/

CREATE OR REPLACE VIEW ops.v_team_sport_normalization_audit_v1 AS
SELECT
    id AS team_id,
    name AS team_name,
    ext_source,
    ext_team_id,
    sport_id AS current_sport_id,

    CASE
        WHEN ext_source IN ('api_football','api_football_missing_canonical','football_data','football_data_uk') THEN 1
        WHEN ext_source = 'api_hockey' THEN 2
        WHEN ext_source = 'api_tennis' THEN 3
        WHEN ext_source = 'api_cricket' THEN 12
        ELSE NULL
    END AS suggested_sport_id,

    CASE
        WHEN sport_id IS NOT NULL THEN 'ALREADY_SET'
        WHEN ext_source IN ('api_football','api_football_missing_canonical','football_data','football_data_uk','api_hockey','api_tennis','api_cricket')
            THEN 'SAFE_TO_FILL'
        ELSE 'NEEDS_REVIEW'
    END AS normalization_status,

    now() AS generated_at
FROM public.teams
WHERE sport_id IS NULL;