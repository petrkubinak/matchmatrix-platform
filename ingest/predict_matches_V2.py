# predict_matches.py
# Predict pipeline: vezme budoucí zápasy z view ml_match_dataset_v2, spočítá p_home/p_draw/p_away
# a uloží do public.ml_predictions.

import os
import sys
from datetime import datetime, timezone

import psycopg2
import pandas as pd
import joblib


def db():
    dsn = os.environ.get("DB_DSN")
    if not dsn:
        raise RuntimeError("Missing env DB_DSN")
    conn = psycopg2.connect(dsn)
    conn.autocommit = False
    return conn


def load_dataset(conn, hours_ahead: int = 72) -> pd.DataFrame:
    # bere budoucí zápasy; view ml_match_dataset_v2 musí obsahovat minimálně:
    # match_id, league_id, kickoff + feature sloupce
    q = f"""
    SELECT *
    FROM public.ml_match_dataset_v2
    WHERE kickoff >= now()
      AND kickoff < now() + interval '{int(hours_ahead)} hours'
    ORDER BY kickoff;
    """
    return pd.read_sql(q, conn)


def main():
    model_path = os.environ.get("MODEL_PATH", r"C:\MatchMatrix-platform\models\model.joblib")
    model_code = os.environ.get("MODEL_CODE", "gbm_v3")
    hours_ahead = int(os.environ.get("HOURS_AHEAD", "168"))  # default 7 dní dopředu

    run_ts = datetime.now(timezone.utc)

    print(f"MODEL_PATH={model_path}")
    print(f"MODEL_CODE={model_code}")
    print(f"HOURS_AHEAD={hours_ahead}")
    print(f"run_ts={run_ts.isoformat()}")

    model = joblib.load(model_path)

    conn = db()
    try:
        df = load_dataset(conn, hours_ahead=hours_ahead)
        if df.empty:
            print("Neni co predikovat (0 zapasu v okne).")
            return

        # povinné sloupce
        for col in ["match_id", "league_id", "kickoff"]:
            if col not in df.columns:
                raise RuntimeError(f"View ml_match_dataset_v2 neobsahuje sloupec '{col}'")

        # features = všechno kromě identifikátorů / labelu
        drop_cols = {"match_id", "league_id", "kickoff", "result_label"}
        feature_cols = [c for c in df.columns if c not in drop_cols]

        if not feature_cols:
            raise RuntimeError("Nenalezeny zadne feature sloupce ve view ml_match_dataset_v2")

        X = df[feature_cols]

        # model musí mít predict_proba a vracet 3 sloupce (home/draw/away)
        if not hasattr(model, "predict_proba"):
            raise RuntimeError("Model nema metodu predict_proba()")

        proba = model.predict_proba(X)

        if proba.shape[1] != 3:
            raise RuntimeError(f"Ocekavam 3 tridy (H/D/A), ale model vraci {proba.shape[1]}")

        df_out = pd.DataFrame({
            "match_id": df["match_id"].astype(int),
            "league_id": df["league_id"].astype(int),
            "kickoff": df["kickoff"],
            "p_home": proba[:, 0],
            "p_draw": proba[:, 1],
            "p_away": proba[:, 2],
        })

        # Uložení do DB
        with conn.cursor() as cur:
            cur.execute("BEGIN;")

            ins = """
            INSERT INTO public.ml_predictions(
                model_code, run_ts, match_id, league_id, kickoff, p_home, p_draw, p_away
            )
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
            ON CONFLICT (model_code, run_ts, match_id)
            DO UPDATE SET
                league_id = EXCLUDED.league_id,
                kickoff   = EXCLUDED.kickoff,
                p_home    = EXCLUDED.p_home,
                p_draw    = EXCLUDED.p_draw,
                p_away    = EXCLUDED.p_away;
            """

            rows = 0
            for r in df_out.itertuples(index=False):
                cur.execute(ins, (
                    model_code, run_ts,
                    int(r.match_id),
                    int(r.league_id),
                    r.kickoff,
                    float(r.p_home), float(r.p_draw), float(r.p_away)
                ))
                rows += 1

            conn.commit()

        print(f"OK: ulozeno {rows} predikci do ml_predictions (model={model_code}, run_ts={run_ts.isoformat()})")

    finally:
        conn.close()


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)
