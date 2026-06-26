/*
MATCHMATRIX SQL 109_X Create Repair Learning Capture V1

CO TO JE:
- Fronta pro zachycení výsledku po resetu opravené položky.

K ČEMU TO JE:
- Aby systém věděl, že resetovaná položka čeká na ověření výsledku.
- Aby se později dalo automaticky vyhodnotit, jestli oprava pomohla.

KDE TO UVIDÍME:
- AI OPS
- OPRAVY
- HISTORIE RESETŮ
- LEARNING LOOP

JAK SE TO VYUŽIJE:
- Reset zapíše audit.
- Tento view ukáže resetované položky, které čekají na vyhodnocení.
- Později scheduler doplní CONFIRMED_OK / FAILED_AGAIN / NEW_ERROR.
*/


CREATE OR REPLACE VIEW ops.v_repair_learning_pending_capture_v1 AS
SELECT
    r.id AS reset_audit_id,

    r.provider,
    r.sport_code,
    r.entity,
    r.provider_league_id AS league_id,
    r.season,
    r.run_group,

    r.old_status,
    r.old_attempts,
    r.old_next_run,
    r.old_last_attempt,

    r.new_status,
    r.new_attempts,
    r.new_next_run,

    r.reset_reason,
    r.reset_by,
    r.created_at AS reset_at,

    CASE
        WHEN EXISTS (
            SELECT 1
            FROM ops.repair_outcome_learning l
            WHERE l.provider = r.provider
              AND l.sport_code = r.sport_code
              AND l.entity = r.entity
              AND COALESCE(l.outcome_note, '') ILIKE '%' || COALESCE(r.provider_league_id, '') || '%'
        )
        THEN true
        ELSE false
    END AS already_learned,

    CASE
        WHEN r.created_at > now() - interval '30 minutes'
        THEN 'ČEKÁ NA OPĚTOVNÉ SPUŠTĚNÍ'
        WHEN r.created_at > now() - interval '6 hours'
        THEN 'ČEKÁ NA VYHODNOCENÍ'
        ELSE 'PŘIPRAVENO K VYHODNOCENÍ'
    END AS learning_capture_state,

    'Po dalším běhu porovnat, zda položka zůstala pending/error, nebo proběhla OK.'::text
        AS next_learning_step

FROM ops.repair_reset_audit r
WHERE NOT EXISTS (
    SELECT 1
    FROM ops.repair_outcome_learning l
    WHERE l.provider = r.provider
      AND l.sport_code = r.sport_code
      AND l.entity = r.entity
      AND COALESCE(l.outcome_note, '') ILIKE '%' || COALESCE(r.provider_league_id, '') || '%'
)
ORDER BY r.created_at DESC, r.id DESC;


CREATE OR REPLACE VIEW ops.v_repair_learning_capture_summary_v1 AS
SELECT
    COUNT(*) AS pending_learning_total,

    COUNT(*) FILTER (
        WHERE learning_capture_state = 'ČEKÁ NA OPĚTOVNÉ SPUŠTĚNÍ'
    ) AS waiting_for_rerun,

    COUNT(*) FILTER (
        WHERE learning_capture_state = 'ČEKÁ NA VYHODNOCENÍ'
    ) AS waiting_for_evaluation,

    COUNT(*) FILTER (
        WHERE learning_capture_state = 'PŘIPRAVENO K VYHODNOCENÍ'
    ) AS ready_for_evaluation,

    now() AS generated_at

FROM ops.v_repair_learning_pending_capture_v1;