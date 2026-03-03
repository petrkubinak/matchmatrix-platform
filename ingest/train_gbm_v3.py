import os
import joblib
import numpy as np
import pandas as pd

from sqlalchemy import create_engine

from sklearn.ensemble import HistGradientBoostingClassifier
from sklearn.metrics import (
    balanced_accuracy_score,
    classification_report,
    confusion_matrix,
    log_loss,
)
from sklearn.calibration import CalibratedClassifierCV


# ===== CONFIG =====
DATASET_VIEW = "ml_match_dataset_v2"
ARTIFACT_PATH = "artifacts/gbm_v3_calibrated.joblib"

TEST_SIZE = 0.20          # posledních 20% = test (time split)
CALIB_FRACTION = 0.20     # z tréninku posledních 20% použijeme na kalibraci

RANDOM_STATE = 42

MODEL_PARAMS = dict(
    max_depth=6,
    learning_rate=0.05,
    max_iter=500,
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
    print("=== MATCHMATRIX: TRAIN GBM V3 (weighted + calibrated) ===")

    dsn = os.environ.get("DB_DSN")
    if not dsn:
        raise KeyError("DB_DSN is not set. Expected SQLAlchemy URL, e.g. postgresql+psycopg2://user:pass@localhost:5432/matchmatrix")

    engine = create_engine(dsn)

    df = pd.read_sql(f"SELECT * FROM {DATASET_VIEW}", engine)
    print(f"Loaded rows: {len(df)}")

    if "result_label" not in df.columns:
        raise KeyError("result_label not found in dataset")

    # ---- Target ----
    y = df["result_label"].astype(int)

    # ---- Features ----
    drop_cols = {"match_id", "kickoff", "result_label"}
    feature_cols = [c for c in df.columns if c not in drop_cols]
    X = df[feature_cols].copy()

    # ---- Time split: train+calib | test ----
    n = len(df)
    n_test = int(round(n * TEST_SIZE))
    n_train_full = n - n_test

    X_train_full = X.iloc[:n_train_full]
    y_train_full = y.iloc[:n_train_full]
    X_test = X.iloc[n_train_full:]
    y_test = y.iloc[n_train_full:]

    # ---- Calib split inside train_full: train | calib (time split) ----
    n_calib = int(round(n_train_full * CALIB_FRACTION))
    n_train = n_train_full - n_calib

    X_train = X_train_full.iloc[:n_train]
    y_train = y_train_full.iloc[:n_train]
    X_calib = X_train_full.iloc[n_train:]
    y_calib = y_train_full.iloc[n_train:]

    print(f"Split sizes: train={len(X_train)}, calib={len(X_calib)}, test={len(X_test)}")

    # ---- Class weights (train only) ----
    class_weights = compute_class_weights(y_train)
    sample_weight_train = y_train.map(class_weights).astype(float)

    print("Class counts (train):", y_train.value_counts().to_dict())
    print("Class weights:", {int(k): float(v) for k, v in class_weights.items()})

    # ---- Fit base model (weighted) ----
    base_model = HistGradientBoostingClassifier(**MODEL_PARAMS)
    base_model.fit(X_train, y_train, sample_weight=sample_weight_train)

   # ---- Calibrate on calibration set (no leakage) ----
    # Některé verze sklearn nepodporují cv="prefit".
    # Kalibraci učíme přes CV pouze uvnitř calib setu.
    sample_weight_calib = y_calib.map(class_weights).astype(float)

    calibrator = CalibratedClassifierCV(
        estimator=HistGradientBoostingClassifier(**MODEL_PARAMS),
        method="sigmoid",   # nebo "isotonic"
        cv=3
    )

    calibrator.fit(X_calib, y_calib, sample_weight=sample_weight_calib)

    # ---- Evaluate on test ----
    preds = calibrator.predict(X_test)
    proba = calibrator.predict_proba(X_test)

    labels = calibrator.classes_
    ll = log_loss(y_test, proba, labels=labels)

    print("\n=== RESULTS (GBM V3 - weighted + calibrated) ===")
    print("Balanced accuracy:", balanced_accuracy_score(y_test, preds))
    print("LogLoss:", ll)
    print("\nClassification report:\n")
    print(classification_report(y_test, preds, digits=4))

    print("\nConfusion matrix (rows=true, cols=pred):")
    print("labels order:", labels)
    print(confusion_matrix(y_test, preds, labels=labels))

    # ---- Save artifact ----
    os.makedirs(os.path.dirname(ARTIFACT_PATH), exist_ok=True)
    joblib.dump(
        {
            "model": calibrator,          # calibrated pipeline
            "base_model": base_model,     # pro debug
            "feature_cols": feature_cols,
            "labels": labels,
            "dataset": DATASET_VIEW,
            "model_params": MODEL_PARAMS,
            "class_weights": class_weights,
            "test_size": TEST_SIZE,
            "calib_fraction": CALIB_FRACTION,
            "calibration_method": "isotonic",
        },
        ARTIFACT_PATH,
    )

    print(f"\nModel saved: {ARTIFACT_PATH}")
    print("Done.")


if __name__ == "__main__":
    main()
