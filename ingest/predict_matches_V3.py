# predict_matches_V3.py
# Krátké připomenutí:
# - predict pipeline = vezme hotový model a spočítá pravděpodobnosti pro budoucí zápasy
# - view = "pohled" v DB (uložený SELECT), tady zdroj dat pro model

import os
import sys
from datetime import datetime, timezone

import joblib
import pandas as pd
import psycopg2

# ----------------------------------------------------------
# DB CONFIG
# ----------------------------------------------------------
# Preferujeme pevný config pro lokální MatchMatrix.
# Pokud bys někdy chtěl, můžeš to přepnout na env proměnné.
DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}

# ----------------------------------------------------------
# MODEL / PRED SETTINGS
# ----------------------------------------------------------
MODEL_PATH = os.getenv(
    "MM_MODEL_PATH",
    os.path.join(os.path.dirname(__file__), "artifacts", "baseline_logreg_v3.joblib"),
)
MODEL_CODE = os.getenv("MM_MODEL_CODE", "baseline_logreg_v3")

# kolik dní dopředu predikovat
DAYS_AHEAD = int(os.getenv("MM_PRED_DAYS_AHEAD", "14"))

# název view zdroje
PREDICT_VIEW = os.getenv("MM_PREDICT_VIEW", "public.ml_match_predict_dataset_v1")

# cílová tabulka
PRED_TABLE = os.getenv("MM_PRED_TABLE", "public.ml_predictions")


def load_future_matches(days_ahead: int) -> pd.DataFrame:
    sql = f"""
        SELECT
            match_id,
            league_id,
            kickoff,
            home_last5_points,
            away_last5_points,
            home_last5_gf,
            home_last5_ga,
            away_last5_gf,
            away_last5_ga,
            home_rest_days,
            away_rest_days,
            h2h_last5_goal_diff,
            last5_points_diff,
            last5_gd_diff,
            rest_days_diff
        FROM {PREDICT_VIEW}
        WHERE kickoff >= now()
          AND kickoff < now() + (%s || ' days')::interval
        ORDER BY kickoff
    """

    with psycopg2.connect(**DB_CONFIG) as conn:
        return pd.read_sql_query(sql, conn, params=[days_ahead])


def fillna_features(df: pd.DataFrame) -> pd.DataFrame:
    feature_cols = [
        "home_last5_points",
        "away_last5_points",
        "home_last5_gf",
        "home_last5_ga",
        "away_last5_gf",
        "away_last5_ga",
        "home_rest_days",
        "away_rest_days",
        "h2h_last5_goal_diff",
        "last5_points_diff",
        "last5_gd_diff",
        "rest_days_diff",
    ]

    for c in feature_cols:
        if c in df.columns:
            df[c] = df[c].fillna(0)

    if "league_id" in df.columns:
        df["league_id"] = df["league_id"].astype("Int64")

    return df


def insert_predictions(df_pred: pd.DataFrame, run_ts: datetime) -> None:
    sql = f"""
        INSERT INTO {PRED_TABLE} (
            model_code,
            run_ts,
            match_id,
            league_id,
            kickoff,
            p_away,
            p_draw,
            p_home
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
    """

    rows = []
    for r in df_pred.itertuples(index=False):
        rows.append(
            (
                MODEL_CODE,
                run_ts,
                int(r.match_id),
                int(r.league_id) if pd.notna(r.league_id) else None,
                r.kickoff,
                float(r.p_away),
                float(r.p_draw),
                float(r.p_home),
            )
        )

    if not rows:
        print("No rows to insert.")
        return

    with psycopg2.connect(**DB_CONFIG) as conn:
        with conn.cursor() as cur:
            cur.executemany(sql, rows)
        conn.commit()

    print(f"Inserted {len(rows)} predictions into {PRED_TABLE}.")


def main() -> None:
    print("=== MATCHMATRIX: PREDICT MATCHES ===")
    print("MODEL_CODE:", MODEL_CODE)
    print("MODEL_PATH:", MODEL_PATH)
    print("DAYS_AHEAD:", DAYS_AHEAD)
    print("PREDICT_VIEW:", PREDICT_VIEW)

    if not os.path.exists(MODEL_PATH):
        raise FileNotFoundError(f"Model nenalezen: {MODEL_PATH}")

    model = joblib.load(MODEL_PATH)

    df = load_future_matches(DAYS_AHEAD)
    print("Future matches loaded:", len(df))

    if df.empty:
        print("Neni co predikovat.")
        return

    df = fillna_features(df)

    # Model je pipeline, bere si sloupce sám přes ColumnTransformer
    X = df.copy()

    if not hasattr(model, "predict_proba"):
        raise RuntimeError("Model nema metodu predict_proba().")

    proba = model.predict_proba(X)

    # Očekáváme pipeline s krokem "lr"
    if not hasattr(model, "named_steps") or "lr" not in model.named_steps:
        raise RuntimeError("Model pipeline neobsahuje krok 'lr'.")

    classes = list(model.named_steps["lr"].classes_)
    class_index = {cls: i for i, cls in enumerate(classes)}

    for cls in (-1, 0, 1):
        if cls not in class_index:
            raise RuntimeError(f"Model classes neobsahuji {cls}. Nalezeno: {classes}")

    df["p_away"] = proba[:, class_index[-1]]
    df["p_draw"] = proba[:, class_index[0]]
    df["p_home"] = proba[:, class_index[1]]

    run_ts = datetime.now(timezone.utc)

    insert_predictions(
        df[["match_id", "league_id", "kickoff", "p_away", "p_draw", "p_home"]],
        run_ts,
    )

    print("Prediction run finished.")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)