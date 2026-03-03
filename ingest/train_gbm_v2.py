import os
import joblib
import numpy as np
import pandas as pd

from sqlalchemy import create_engine

from sklearn.model_selection import train_test_split
from sklearn.metrics import (
    balanced_accuracy_score,
    classification_report,
    confusion_matrix,
    log_loss,
)
from sklearn.ensemble import HistGradientBoostingClassifier


# ===== CONFIG =====
DATASET_VIEW = "ml_match_dataset_v2"
ARTIFACT_PATH = "artifacts/gbm_v2.joblib"

TEST_SIZE = 0.20
RANDOM_STATE = 42  # jen pro determinismus některých částí (split je shuffle=False)

# Model hyperparams (rozumný start)
MODEL_PARAMS = dict(
    max_depth=6,
    learning_rate=0.05,
    max_iter=400,
    l2_regularization=0.0,
    random_state=RANDOM_STATE,
)


def compute_class_weights(y: pd.Series) -> dict:
    """
    Inverzní váhy podle četnosti tříd:
    w_c = N / (K * n_c)
    """
    counts = y.value_counts().to_dict()
    total = len(y)
    k = len(counts)
    return {cls: total / (k * cnt) for cls, cnt in counts.items()}


def main():
    print("=== MATCHMATRIX: TRAIN GBM V2 (weighted) ===")

    dsn = os.environ.get("DB_DSN")
    if not dsn:
        raise KeyError("DB_DSN (např. postgresql://user:pass@localhost:5432/matchmatrix)")

    # SQLAlchemy engine (odstraní pandas warning)
    engine = create_engine(dsn)

    query = f"SELECT * FROM {DATASET_VIEW}"
    df = pd.read_sql(query, engine)

    print(f"Loaded rows: {len(df)}")

    # ---- Target ----
    if "result_label" not in df.columns:
        raise KeyError("result_label not found in dataset")

    y = df["result_label"].astype(int)

    # ---- Feature columns ----
    # Vyloučíme ID/čas/label
    drop_cols = {"match_id", "kickoff", "result_label"}
    feature_cols = [c for c in df.columns if c not in drop_cols]

    X = df[feature_cols].copy()

    # Ošetření NaN (kdyby se někde objevily) – HGB umí NaN, ale pro jistotu:
    # X = X.replace([np.inf, -np.inf], np.nan)

    # ---- Time split (bez leakage) ----
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=TEST_SIZE, shuffle=False
    )

    # ---- Class weights (draw boost) ----
    class_weights = compute_class_weights(y_train)
    sample_weight = y_train.map(class_weights).astype(float)

    print("Class counts (train):", y_train.value_counts().to_dict())
    print("Class weights:", {int(k): float(v) for k, v in class_weights.items()})

    # ---- Train ----
    model = HistGradientBoostingClassifier(**MODEL_PARAMS)
    model.fit(X_train, y_train, sample_weight=sample_weight)

    # ---- Predict ----
    preds = model.predict(X_test)
    proba = model.predict_proba(X_test)

    # LogLoss musí mít správné pořadí labelů (podle model.classes_)
    labels = model.classes_
    ll = log_loss(y_test, proba, labels=labels)

    print("\n=== RESULTS (GBM V2 - weighted) ===")
    print("Balanced accuracy:", balanced_accuracy_score(y_test, preds))
    print("LogLoss:", ll)
    print("\nClassification report:\n")
    print(classification_report(y_test, preds, digits=4))

    print("\nConfusion matrix (rows=true, cols=pred):")
    print("labels order:", labels)
    print(confusion_matrix(y_test, preds, labels=labels))

    # ---- Save ----
    os.makedirs(os.path.dirname(ARTIFACT_PATH), exist_ok=True)
    joblib.dump(
        {
            "model": model,
            "feature_cols": feature_cols,
            "labels": labels,
            "dataset": DATASET_VIEW,
            "model_params": MODEL_PARAMS,
            "class_weights": class_weights,
        },
        ARTIFACT_PATH,
    )

    print(f"\nModel saved: {ARTIFACT_PATH}")


if __name__ == "__main__":
    main()
