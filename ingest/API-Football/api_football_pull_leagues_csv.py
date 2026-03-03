import os, csv, json, argparse
import requests
from datetime import datetime

def load_env(path: str) -> None:
    if not os.path.exists(path):
        return
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, v = line.split("=", 1)
            os.environ.setdefault(k.strip(), v.strip())

def api_get(base: str, key: str, endpoint: str, params: dict) -> dict:
    url = f"{base.rstrip('/')}/{endpoint.lstrip('/')}"
    r = requests.get(url, headers={"x-apisports-key": key}, params=params, timeout=30)
    r.raise_for_status()
    return r.json()

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True, help="Output CSV path")
    ap.add_argument("--run-id", type=int, required=True)
    ap.add_argument("--search", default=None, help="Optional league search string")
    args = ap.parse_args()

    load_env(os.path.join(os.path.dirname(__file__), ".env"))
    key  = os.environ.get("APISPORTS_KEY")
    base = os.environ.get("APISPORTS_BASE", "https://v3.football.api-sports.io")
    if not key:
        raise SystemExit("Missing APISPORTS_KEY in ingest/.env")

    params = {}
    if args.search:
        params["search"] = args.search

    data = api_get(base, key, "/leagues", params)
    resp = data.get("response", [])

    os.makedirs(os.path.dirname(args.out), exist_ok=True)

    with open(args.out, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        # columns must match staging table load
        w.writerow(["run