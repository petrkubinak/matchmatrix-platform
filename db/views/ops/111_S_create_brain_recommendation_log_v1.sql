/*
MATCHMATRIX SQL 111_S

BRAIN RECOMMENDATION LOG V1

CO TO JE:
- Historie rozhodnutí Autonomous OPS Brain.

K ČEMU TO JE:
- Učení Brainu.
- Audit doporučení.
- Budoucí AI Learning Engine.

KDE TO UVIDÍME:
- Panel AI OPS.
- Budoucí Autonomous Dispatcher.

JAK SE TO VYUŽIJE:
- Brain doporučí akci.
- Dispatcher ji spustí.
- Výsledek se porovná.
- Brain se bude učit.
*/

CREATE TABLE IF NOT EXISTS ops.brain_recommendation_log (

    id BIGSERIAL PRIMARY KEY,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    brain_rank INTEGER,
    brain_score NUMERIC(12,2),

    brain_decision TEXT,
    brain_decision_reason TEXT,

    provider TEXT,
    sport_code TEXT,
    entity TEXT,

    league_id TEXT,
    season TEXT,
    run_group TEXT,

    recommended_focus TEXT,

    ai_decision TEXT,
    ai_risk_level TEXT,

    execution_status TEXT,
    execution_result TEXT,

    notes TEXT
);

CREATE INDEX IF NOT EXISTS ix_brain_log_created
ON ops.brain_recommendation_log(created_at DESC);

CREATE INDEX IF NOT EXISTS ix_brain_log_sport
ON ops.brain_recommendation_log(sport_code);

CREATE INDEX IF NOT EXISTS ix_brain_log_provider
ON ops.brain_recommendation_log(provider);