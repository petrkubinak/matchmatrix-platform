/*
MATCHMATRIX SQL 109_Z Create Learning Evaluation Layer V1

CO TO JE:
- Vyhodnocovací vrstva učící smyčky.

K ČEMU TO JE:
- Vyhodnocuje resetované položky.
- Připravuje kandidáty pro zápis do repair_outcome_learning.

KDE TO UVIDÍME:
- AI OPS
- LEARNING LOOP
- KNOWLEDGE BASE

JAK SE TO VYUŽIJE:
- Reset
- Nový běh
- Vyhodnocení
- Uložení zkušenosti
*/


CREATE OR REPLACE VIEW ops.v_learning_evaluation_candidates_v1 AS
SELECT
    p.reset_audit_id,

    p.provider,
    p.sport_code,
    p.entity,
    p.league_id,
    p.season,
    p.run_group,

    p.reset_at,

    ip.id AS planner_id,
    ip.status,
    ip.attempts,
    ip.last_attempt,

    CASE

        WHEN ip.status IN ('done','completed','success')
        THEN 'CONFIRMED_OK'

        WHEN ip.status IN ('error','failed')
             AND COALESCE(ip.attempts,0) > 0
        THEN 'FAILED_AGAIN'

        WHEN ip.status = 'pending'
             AND p.reset_at < now() - interval '6 hours'
        THEN 'NOT_EVALUATED'

        ELSE 'WAITING'

    END AS suggested_outcome,

    CASE

        WHEN ip.status IN ('done','completed','success')
        THEN 'Resetovaná položka po novém běhu proběhla úspěšně.'

        WHEN ip.status IN ('error','failed')
        THEN 'Po resetu se chyba objevila znovu.'

        WHEN ip.status = 'pending'
        THEN 'Ještě neproběhl nový běh.'

        ELSE 'Čeká na další data.'

    END AS evaluation_note

FROM ops.v_repair_learning_pending_capture_v1 p
LEFT JOIN ops.ingest_planner ip
    ON ip.provider = p.provider
   AND ip.sport_code = p.sport_code
   AND ip.entity = p.entity
   AND COALESCE(ip.provider_league_id,'') = COALESCE(p.league_id,'')
   AND COALESCE(ip.season,'') = COALESCE(p.season,'')
   AND COALESCE(ip.run_group,'') = COALESCE(p.run_group,'');



CREATE OR REPLACE VIEW ops.v_learning_evaluation_summary_v1 AS
SELECT

    COUNT(*) AS total_candidates,

    COUNT(*) FILTER (
        WHERE suggested_outcome='CONFIRMED_OK'
    ) AS confirmed_ok,

    COUNT(*) FILTER (
        WHERE suggested_outcome='FAILED_AGAIN'
    ) AS failed_again,

    COUNT(*) FILTER (
        WHERE suggested_outcome='WAITING'
    ) AS waiting,

    COUNT(*) FILTER (
        WHERE suggested_outcome='NOT_EVALUATED'
    ) AS not_evaluated,

    now() AS generated_at

FROM ops.v_learning_evaluation_candidates_v1;