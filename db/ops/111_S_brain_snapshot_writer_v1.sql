/*
MATCHMATRIX SQL 111_S

BRAIN SNAPSHOT WRITER V1

CO TO JE:
- Zapíše aktuální TOP doporučení Brainu.

K ČEMU TO JE:
- Začínáme budovat historii rozhodování.
*/

INSERT INTO ops.brain_recommendation_log (

    brain_rank,
    brain_score,

    brain_decision,
    brain_decision_reason,

    provider,
    sport_code,
    entity,

    league_id,
    season,
    run_group,

    recommended_focus,

    ai_decision,
    ai_risk_level

)
SELECT

    brain_rank,
    brain_score,

    brain_decision,
    brain_decision_reason,

    provider,
    sport_code,
    entity,

    league_id,
    season,
    run_group,

    recommended_focus,

    ai_decision,
    ai_risk_level

FROM ops.v_autonomous_ops_brain_v4
WHERE brain_rank <= 10;