import os
import json
import joblib
import pandas as pd
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.metrics import classification_report, log_loss, balanced_accuracy_score
from sklearn.model_selection import train_test_split

DB_DSN = os.environ["DB_DSN"]

print("=== MATCHMATRIX: TRAIN GBM V1 ===")

import psycopg2

conn = psycopg2.connect(DB_DSN)

df = pd.read_sql("SELECT * FROM ml_match_dataset_v2", conn)

conn.close()

print(f"Loaded rows: {len(df)}")

X = df.drop(columns=["result_label", "match_id", "kickoff"])
y = df["result_label"]

# Fill missing values
X = X.fillna(0)

# Time split (bez leakage)
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, shuffle=False
)

from sklearn.ensemble import HistGradientBoostingClassifier

model = HistGradientBoostingClassifier(
    max_depth=6,
    learning_rate=0.05
)

model.fit(X_train, y_train)

proba = model.predict_proba(X_test)
preds = model.predict(X_test)

print("\n=== RESULTS (GBM V1) ===")
print("Balanced accuracy:", balanced_accuracy_score(y_test, preds))
print("LogLoss:", log_loss(y_test, proba))
print("\nClassification report:\n")
print(classification_report(y_test, preds))

os.makedirs("artifacts", exist_ok=True)

joblib.dump(model, "artifacts/gbm_v1.joblib")

print("\nModel saved: artifacts/gbm_v1.joblib")
