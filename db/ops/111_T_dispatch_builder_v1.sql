/*
MATCHMATRIX SQL 111_T

DISPATCH BUILDER V1

CO TO JE:
- Naplní dispatch queue z Brainu.

K ČEMU TO JE:
- Převod doporučení → připravená akce.

BEZPEČNOST:
- Bere pouze RUN.
- Nevkládá duplicity.
*/

INSERT INTO ops.dispatch_queue (

    brain_rank,
    brain_score,

    provider,
    sport_code,
    entity,

    league_id,
    season,
    run_group,

    dispatch_reason

)
SELECT

    b.brain_rank,
    b.brain_score,

    b.provider,
    b.sport_code,
    b.entity,

    b.league_id,
    b.season,
    b.run_group,

    b.brain_decision_reason

FROM ops.v_autonomous_ops_brain_v4 b

WHERE b.brain_decision = 'RUN'

AND NOT EXISTS (

    SELECT 1
    FROM ops.dispatch_queue q
    WHERE q.dispatch_status IN ('PENDING','RUNNING')
      AND q.provider = b.provider
      AND q.sport_code = b.sport_code
      AND q.entity = b.entity
      AND COALESCE(q.league_id,'') = COALESCE(b.league_id,'')
      AND COALESCE(q.season,'') = COALESCE(b.season,'')
      AND COALESCE(q.run_group,'') = COALESCE(b.run_group,'')

);