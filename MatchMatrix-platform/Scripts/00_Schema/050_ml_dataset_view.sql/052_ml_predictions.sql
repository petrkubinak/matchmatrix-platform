CREATE TABLE IF NOT EXISTS ml_predictions (
    id            bigserial PRIMARY KEY,
    model_code    text NOT NULL,
    run_ts        timestamptz NOT NULL DEFAULT now(),

    match_id      bigint NOT NULL REFERENCES matches(id),
    league_id     bigint,
    kickoff       timestamptz,

    p_away        double precision NOT NULL,
    p_draw        double precision NOT NULL,
    p_home        double precision NOT NULL,

    created_at    timestamptz NOT NULL DEFAULT now()
);

-- 1 match může mít víc predikcí v čase (re-run), ale nechceme duplicitní zápis pro stejný model+run_ts.
CREATE INDEX IF NOT EXISTS ix_ml_predictions_match ON ml_predictions(match_id);
CREATE INDEX IF NOT EXISTS ix_ml_predictions_model ON ml_predictions(model_code);
CREATE INDEX IF NOT EXISTS ix_ml_predictions_run_ts ON ml_predictions(run_ts);

-- Volitelné: když chceš upsert „poslední predikce“ místo historizace:
-- CREATE UNIQUE INDEX IF NOT EXISTS ux_ml_predictions_model_match
--   ON ml_predictions(model_code, match_id);
