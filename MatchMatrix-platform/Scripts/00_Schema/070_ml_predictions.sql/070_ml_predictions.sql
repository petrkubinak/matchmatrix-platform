-- 070_ml_predictions.sql
-- Tabulka na uložení predikcí modelu (predict pipeline výstup).
-- Bezpečné: CREATE IF NOT EXISTS + indexy IF NOT EXISTS.

CREATE TABLE IF NOT EXISTS public.ml_predictions (
  id          bigserial PRIMARY KEY,
  model_code  text NOT NULL,                 -- např. 'gbm_v3'
  run_ts      timestamptz NOT NULL DEFAULT now(),
  match_id    bigint NOT NULL REFERENCES public.matches(id) ON DELETE CASCADE,
  league_id   bigint NULL REFERENCES public.leagues(id) ON DELETE SET NULL,
  kickoff     timestamptz NULL,

  p_home      double precision NULL,
  p_draw      double precision NULL,
  p_away      double precision NULL,

  created_at  timestamptz NOT NULL DEFAULT now()
);

-- Aby šel upsert: v rámci jedné "run_ts" nechceme duplicitní match pro stejný model
CREATE UNIQUE INDEX IF NOT EXISTS ux_ml_predictions_model_run_match
ON public.ml_predictions(model_code, run_ts, match_id);

CREATE INDEX IF NOT EXISTS ix_ml_predictions_match
ON public.ml_predictions(match_id);

CREATE INDEX IF NOT EXISTS ix_ml_predictions_kickoff
ON public.ml_predictions(kickoff);

CREATE INDEX IF NOT EXISTS ix_ml_predictions_model_run
ON public.ml_predictions(model_code, run_ts);
