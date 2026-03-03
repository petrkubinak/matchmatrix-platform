import os
import json
import joblib
import numpy as np
import pandas as pd
import psycopg2
import sklearn
import inspect

from sklearn.linear_model import LogisticRegression
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.pipeline import Pipeline
from sklearn.metrics import (
    accuracy_score,
    balanced_accuracy_score,
    classification_report,
    confusion_matrix,
    log_loss,
    f1_score,
)
from sklearn.model_selection import ParameterGrid

print("sklearn version:", sklearn.__version__)
print("LogisticRegression module:", LogisticRegression.__module__)
print("LogisticRegression file:", inspect.getsourcefile(LogisticRegression))

DB_DSN = os.environ["DB_DSN"]

TEST_DAYS = int(os.getenv("MM_TEST_DAYS", "365"))
MIN_KICKOFF = os.getenv("MM_MIN_KICKOFF", "")


def load_data() -> pd.DataFrame:
    where = "where 1=1"
    params = []

    if MIN_KICKOFF:
        where += " and kickoff >= %s"
        params.append(MIN_KICKOFF)

    sql = f"""
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

            -- diff features (musí existovat ve view)
            last5_points_diff,
            last5_gd_diff,
            rest_days_diff,

            result_label
        from ml_match_dataset_v2
        {where}
        order by kickoff
    """

    with psycopg2.connect(DB_DSN) as conn:
        df = pd.read_sql_query(sql, conn, params=params)

    df["kickoff"] = pd.to_datetime(df["kickoff"])
    df = df.dropna(subset=["kickoff", "result_label"])

    # Features mohou obsahovat NULL → doplníme 0
    feature_cols = [
        "home_last5_points", "away_last5_points",
        "home_last5_gf", "home_last5_ga",
        "away_last5_gf", "away_last5_ga",
        "home_rest_days", "away_rest_days",
        "h2h_last5_goal_diff",
        "last5_points_diff", "last5_gd_diff", "rest_days_diff",
    ]
    for c in feature_cols:
        if c in df.columns:
            df[c] = df[c].fillna(0)

    df["league_id"] = df["league_id"].astype(int)

    # Label musí být z {-1,0,1}
    df["result_label"] = df["result_label"].astype(int)
    df = df[df["result_label"].isin([-1, 0, 1])]

    return df


def time_split(df: pd.DataFrame):
    max_dt = df["kickoff"].max()
    cutoff = max_dt - pd.Timedelta(days=TEST_DAYS)

    train = df[df["kickoff"] < cutoff].copy()
    test = df[df["kickoff"] >= cutoff].copy()

    if len(train) < 1000 or len(test) < 200:
        print(f"[WARN] train/test je malé (train={len(train)}, test={len(test)}).")

    return train, test, cutoff


def build_model(C_value: float, draw_weight: float) -> Pipeline:
    numeric_features = [
        "home_last5_points", "away_last5_points",
        "home_last5_gf", "home_last5_ga",
        "away_last5_gf", "away_last5_ga",
        "home_rest_days", "away_rest_days",
        "h2h_last5_goal_diff",
        "last5_points_diff",
        "last5_gd_diff",
        "rest_days_diff",
    ]
    categorical_features = ["league_id"]

    pre = ColumnTransformer(
        transformers=[
            ("num", StandardScaler(), numeric_features),
            ("cat", OneHotEncoder(handle_unknown="ignore"), categorical_features),
        ],
        remainder="drop",
    )

    # Váhy tříd – cíleně ladíme remízu
    cw = {-1: 1.0, 0: float(draw_weight), 1: 1.0}

    clf = LogisticRegression(
        solver="lbfgs",
        max_iter=2000,
        class_weight=cw,
        C=float(C_value),
    )

    return Pipeline([
        ("pre", pre),
        ("lr", clf),
    ])


def evaluate(model: Pipeline, X_test: pd.DataFrame, y_test: np.ndarray):
    y_pred = model.predict(X_test)
    proba = model.predict_proba(X_test)

    classes = [int(x) for x in model.named_steps["lr"].classes_]

    acc = accuracy_score(y_test, y_pred)
    bal_acc = balanced_accuracy_score(y_test, y_pred)
    macro_f1 = f1_score(y_test, y_pred, average="macro")
    ll = log_loss(y_test, proba, labels=classes)
    cm = confusion_matrix(y_test, y_pred, labels=classes)

    # draw-only metriky (pro info)
    rep = classification_report(y_test, y_pred, labels=classes, output_dict=True, zero_division=0)
    draw_key = "0"
    draw_prec = rep.get(draw_key, {}).get("precision", float("nan"))
    draw_rec = rep.get(draw_key, {}).get("recall", float("nan"))
    draw_f1 = rep.get(draw_key, {}).get("f1-score", float("nan"))

    return {
        "accuracy": acc,
        "balanced_accuracy": bal_acc,
        "macro_f1": macro_f1,
        "logloss": ll,
        "confusion_matrix": cm,
        "classes": classes,
        "draw_precision": draw_prec,
        "draw_recall": draw_rec,
        "draw_f1": draw_f1,
    }


def main():
    df = load_data()
    print("Loaded rows:", len(df))
    print("Date range:", df["kickoff"].min(), "->", df["kickoff"].max())

    train, test, cutoff = time_split(df)
    print("Cutoff:", cutoff)
    print("Train:", len(train), "Test:", len(test))

    X_train = train.drop(columns=["result_label"])
    y_train = train["result_label"].values

    X_test = test.drop(columns=["result_label"])
    y_test = test["result_label"].values

    # ===== GRID SEARCH (C × draw_weight) – vybíráme podle MIN logloss =====
    grid = {
        "C": [0.1, 0.3, 1.0, 3.0, 10.0],
        "draw_weight": [1.0, 1.2, 1.4, 1.6, 1.8, 2.0],
    }

    best = None
    best_model = None

    for params in ParameterGrid(grid):
        model = build_model(C_value=params["C"], draw_weight=params["draw_weight"])
        model.fit(X_train, y_train)

        metrics = evaluate(model, X_test, y_test)

        print(
            f"\nC={params['C']:<4}  draw_w={params['draw_weight']:<3}  "
            f"logloss={metrics['logloss']:.4f}  "
            f"acc={metrics['accuracy']:.4f}  bal_acc={metrics['balanced_accuracy']:.4f}  "
            f"draw_rec={metrics['draw_recall']:.2f}"
        )

        if best is None or metrics["logloss"] < best["logloss"]:
            best = {**metrics, "C": params["C"], "draw_weight": params["draw_weight"]}
            best_model = model

    print("\n=== BEST MODEL (by logloss) ===")
    print("Best C:", best["C"])
    print("Best draw_weight:", best["draw_weight"])
    print("Accuracy:", round(best["accuracy"], 4))
    print("Balanced Acc:", round(best["balanced_accuracy"], 4))
    print("Macro F1:", round(best["macro_f1"], 4))
    print("LogLoss:", round(best["logloss"], 4))
    print("Draw (prec/rec/f1):", round(best["draw_precision"], 4), round(best["draw_recall"], 4), round(best["draw_f1"], 4))
    print("\nClasses:", best["classes"])
    print("\nConfusion matrix:\n", best["confusion_matrix"])
    print("\nClassification report:\n",
          classification_report(y_test,
                                best_model.predict(X_test),
                                labels=best["classes"],
                                digits=4,
                                zero_division=0))

    # ===== SAVE =====
    out_dir = os.path.join(os.path.dirname(__file__), "artifacts")
    os.makedirs(out_dir, exist_ok=True)

    model_path = os.path.join(out_dir, "baseline_logreg_v3.joblib")
    joblib.dump(best_model, model_path)

    meta = {
        "rows_total": int(len(df)),
        "rows_train": int(len(train)),
        "rows_test": int(len(test)),
        "cutoff": str(cutoff),
        "test_days": TEST_DAYS,
        "min_kickoff": MIN_KICKOFF or None,
        "classes": best["classes"],
        "best_C": float(best["C"]),
        "best_draw_weight": float(best["draw_weight"]),
        "accuracy": float(best["accuracy"]),
        "balanced_accuracy": float(best["balanced_accuracy"]),
        "macro_f1": float(best["macro_f1"]),
        "logloss": float(best["logloss"]),
        "draw_precision": float(best["draw_precision"]),
        "draw_recall": float(best["draw_recall"]),
        "draw_f1": float(best["draw_f1"]),
        "confusion_matrix": best["confusion_matrix"].tolist(),
        "sklearn_version": sklearn.__version__,
        "dataset_view": "ml_match_dataset_v2",
    }

    meta_path = os.path.join(out_dir, "baseline_logreg_v3_meta.json")
    with open(meta_path, "w", encoding="utf-8") as f:
        json.dump(meta, f, ensure_ascii=False, indent=2)

    print("\nSaved:")
    print(" -", model_path)
    print(" -", meta_path)


if __name__ == "__main__":
    main()
