/*
MATCHMATRIX SQL 109_R Create Blocked Items Repair Queue V1

CO TO JE:
- Fronta blokovaných položek, které AI nedovolí spustit.

K ČEMU TO JE:
- Aby bylo jasné, proč je položka blokovaná.
- Aby panel ukázal, co se má opravit.
- Aby šla položka po opravě vrátit do bezpečné fronty.

KDE TO UVIDÍME:
- Panel V18
- AI OPS
- BLOKOVANÉ / OPRAVY

JAK SE TO VYUŽIJE:
- Admin klikne na blokovanou položku.
- Panel ukáže doporučený opravný krok.
- Po ověření půjde položku resetovat a vrátit do fronty.
*/


CREATE OR REPLACE VIEW ops.v_blocked_items_repair_queue_v1 AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            CASE
                WHEN ai_risk_level = 'VYSOKÉ' THEN 1
                WHEN ai_risk_level = 'STŘEDNÍ' THEN 2
                ELSE 3
            END,
            recommendation_rank
    ) AS repair_rank,

    recommendation_rank,

    provider,
    sport_code,
    entity,
    league_id,
    season,
    run_group,

    ai_decision,
    ai_risk_level,
    autonomous_safe,

    ai_reason,
    suggested_retry_after,

    CASE
        WHEN ai_decision = 'POZASTAVIT' THEN 'OVĚŘIT PROVIDERA / LIGU / SCOPE'
        WHEN ai_decision = 'POČKAT' THEN 'NECHAT COOLDOWN DOBĚHNOUT'
        ELSE 'RUČNÍ KONTROLA'
    END AS repair_action,

    CASE
        WHEN ai_decision = 'POZASTAVIT' THEN
            'Zkontrolovat, jestli provider vrací data pro danou ligu/sezónu. Pokud ano, resetovat attempts a vrátit do pending.'
        WHEN ai_decision = 'POČKAT' THEN
            'Položka není kritická, ale má opakované pokusy. Po cooldownu ji lze zkusit znovu.'
        ELSE
            'Vyžaduje ruční posouzení.'
    END AS repair_detail,

    CASE
        WHEN ai_decision = 'POZASTAVIT' THEN 'HIGH'
        WHEN ai_decision = 'POČKAT' THEN 'MEDIUM'
        ELSE 'LOW'
    END AS repair_priority,

    false AS can_execute_now,

    now() AS generated_at

FROM ops.v_ai_ops_dashboard_panel_v1
WHERE panel_safety_state = 'BLOKOVANÉ';


CREATE OR REPLACE VIEW ops.v_blocked_items_repair_summary_v1 AS
SELECT
    COUNT(*) AS blocked_total,

    COUNT(*) FILTER (
        WHERE ai_decision = 'POZASTAVIT'
    ) AS hold_total,

    COUNT(*) FILTER (
        WHERE ai_decision = 'POČKAT'
    ) AS wait_total,

    COUNT(*) FILTER (
        WHERE repair_priority = 'HIGH'
    ) AS high_priority_repairs,

    COUNT(*) FILTER (
        WHERE repair_priority = 'MEDIUM'
    ) AS medium_priority_repairs,

    COUNT(*) FILTER (
        WHERE repair_priority = 'LOW'
    ) AS low_priority_repairs,

    now() AS generated_at

FROM ops.v_blocked_items_repair_queue_v1;