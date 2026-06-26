/*
MATCHMATRIX SQL 110_U Create Autonomous PostRun Learning V1

CO TO JE:
- Automatický zápis learning vrstvy po dokončení akce.

K ČEMU TO JE:
- Už nebude potřeba ručně volat:
  fn_write_autonomous_learning_v1()

- Každý SUCCESS / FAILED se automaticky promítne
  do repair_outcome_learning.

KDE TO UVIDÍME:
- AI OPS
- Learning panel
- Self improvement engine

JAK SE TO VYUŽIJE:
- Launcher dokončí akci
- Trigger zapíše zkušenost
- Learning se okamžitě aktualizuje
*/


CREATE OR REPLACE FUNCTION ops.fn_autonomous_postrun_learning_v1()
RETURNS trigger
LANGUAGE plpgsql
AS
$$
BEGIN

    IF NEW.execution_status NOT IN ('SUCCESS','FAILED') THEN
        RETURN NEW;
    END IF;

    INSERT INTO ops.repair_outcome_learning
    (
        reason_code,
        provider,
        sport_code,
        entity,
        repair_action,
        outcome_code,
        outcome_note,
        created_at
    )
    SELECT

        COALESCE(NEW.action_reason, NEW.action_type),

        NEW.provider,
        NEW.sport_code,
        NEW.entity,

        NEW.action_type,

        CASE
            WHEN NEW.execution_status='SUCCESS'
            THEN 'CONFIRMED_OK'
            ELSE 'FAILED_AGAIN'
        END,

        LEFT(
            'queue_id=' || NEW.id::text ||
            ' | league=' || COALESCE(NEW.provider_league_id::text,'-') ||
            ' | season=' || COALESCE(NEW.season::text,'-') ||
            ' | run_group=' || COALESCE(NEW.run_group,'-') ||
            ' | result=' || COALESCE(NEW.execution_result,''),
            1000
        ),

        now()

    WHERE NOT EXISTS
    (
        SELECT 1
        FROM ops.repair_outcome_learning l
        WHERE l.outcome_note LIKE ('queue_id=' || NEW.id::text || ' |%')
    );

    RETURN NEW;

END;
$$;



DROP TRIGGER IF EXISTS trg_autonomous_postrun_learning_v1
ON ops.autonomous_execution_queue;



CREATE TRIGGER trg_autonomous_postrun_learning_v1
AFTER UPDATE
ON ops.autonomous_execution_queue
FOR EACH ROW
EXECUTE FUNCTION ops.fn_autonomous_postrun_learning_v1();