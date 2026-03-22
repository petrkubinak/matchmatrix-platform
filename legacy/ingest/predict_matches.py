import os
import joblib
import pandas as pd
import psycopg2
from datetime import datetime, timezone

DB_DSN = os.environ["DB_DSN"]

MODEL_PATH = os.getenv("MM_MODEL_PATH", os.path.join(os.path.dirname(__file__), "artifacts", "baseline_logreg_v3.joblib"))
MODEL_CODE = os.getenv("MM_MODEL_CODE", "baseline_logreg_v3")

# kolik dní dopředu predikovat (default 14)
DAYS_AHEAD = int(os.getenv("MM_PRED_DAYS_AHEAD", "14"))

def load_future_matches() -> pd.DataFrame:
    sql = """
        select
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
        from ml_match_predict_dataset_v1
        where kickoff >= now()
          and kickoff < now() + (%s || ' days')::interval
        order by kickoff
    """
    with psycopg2.connect(DB_DSN) as conn:
        return pd.read_sql_query(sql, conn, params=[DAYS_AHEAD])

def fillna_features(df: pd.DataFrame) -> pd.DataFrame:
    feature_cols = [
        "home_last5_points","away_last5_points",
        "home_last5_gf","home_last5_ga",
        "away_last5_gf","away_last5_ga",
        "home_rest_days","away_rest_days",
        "h2h_last5_goal_diff",
        "last5_points_diff","last5_gd_diff","rest_days_diff",
    ]
    for c in feature_cols:
        if c in df.columns:
            df[c] = df[c].fillna(0)
    df["league_id"] = df["league_id"].astype(int)
    return df

def insert_predictions(df_pred: pd.DataFrame, run_ts: datetime):
    sql = """
        insert into ml_predictions (
            model_code, run_ts,
            match_id, league_id, kickoff,
            p_away, p_draw, p_home
        )
        values (%s, %s, %s, %s, %s, %s, %s, %s)
    """
    rows = [
        (
            MODEL_CODE, run_ts,
            int(r.match_id), int(r.league_id) if pd.notna(r.league_id) else None, r.kickoff,
            float(r.p_away), float(r.p_draw), float(r.p_home)
        )
        for r in df_pred.itertuples(index=False)
    ]
    if not rows:
        print("No rows to insert.")
        return

    with psycopg2.connect(DB_DSN) as conn:
        with conn.cursor() as cur:
            cur.executemany(sql, rows)
        conn.commit()
    print(f"Inserted {len(rows)} predictions into ml_predictions.")

def main():
    print("Loading model:", MODEL_PATH)
    model = joblib.load(MODEL_PATH)

    df = load_future_matches()
    print("Future matches loaded:", len(df))
    if df.empty:
        return

    df = fillna_features(df)

    X = df.copy()  # model pipeline si bere sloupce sám přes ColumnTransformer

    # predict probabilities
    proba = model.predict_proba(X)

    classes = list(model.named_steps["lr"].classes_)
    class_index = {cls: i for i, cls in enumerate(classes)}

    # mapujeme na p_away (-1), p_draw (0), p_home (1)
    df["p_away"] = proba[:, class_index[-1]]
    df["p_draw"] = proba[:, class_index[0]]
    df["p_home"] = proba[:, class_index[1]]

    run_ts = datetime.now(timezone.utc)

    insert_predictions(
        df[[
            "match_id", "league_id", "kickoff",
            "p_away", "p_draw", "p_home"
        ]],
        run_ts
    )

    print("Prediction run finished.")

if __name__ == "__main__":
    main()


   
