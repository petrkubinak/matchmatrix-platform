/*
MATCHMATRIX SQL 17_8_E2
TEAM SPORT NORMALIZATION PLAN V1

CO TO JE:
- Plán bezpečného doplnění sport_id pro týmy, kde sport_id chybí.
- Vychází z auditu ops.v_team_sport_normalization_audit_v1.
- Neprovádí žádné změny v databázi.

K ČEMU TO JE:
- Ukáže, které týmy můžeme bezpečně opravit.
- Oddělí automaticky opravitelné záznamy od těch, které vyžadují ruční kontrolu.
- Připraví bezpečný podklad pro budoucí UPDATE sport_id.

KDE TO UVIDÍME:
- OPS Panel -> ČIŠTĚNÍ DB
- OPS Panel -> DATA QUALITY
- DBeaver audit sportovní normalizace

JAK SE TO VYUŽIJE:
- Po kontrole tohoto plánu naváže 17_8_E3 execution skript.
- Doplnění sport_id sníží falešné duplicity týmů.
- Následně znovu přepočítáme team duplicate audit a safe merge plan.
*/

CREATE OR REPLACE VIEW ops.v_team_sport_normalization_plan_v1 AS
SELECT
    team_id,
    team_name,
    ext_source,
    ext_team_id,
    current_sport_id,
    suggested_sport_id,

    CASE
        WHEN normalization_status = 'SAFE_TO_FILL'
            THEN 'READY_FOR_UPDATE'
        ELSE 'HOLD_REVIEW'
    END AS plan_status,

    CASE
        WHEN suggested_sport_id = 1 THEN 'Football'
        WHEN suggested_sport_id = 2 THEN 'Hockey'
        WHEN suggested_sport_id = 3 THEN 'Tennis'
        WHEN suggested_sport_id = 12 THEN 'Cricket'
        ELSE 'Unknown'
    END AS suggested_sport_name,

    CASE
        WHEN normalization_status = 'SAFE_TO_FILL'
            THEN 100
        ELSE 0
    END AS confidence_score,

    CASE
        WHEN normalization_status = 'SAFE_TO_FILL'
            THEN 'Bezpečně doplnitelné podle ext_source.'
        ELSE 'Vyžaduje ruční kontrolu ext_source / sportu.'
    END AS recommendation_cz,

    now() AS generated_at
FROM ops.v_team_sport_normalization_audit_v1;