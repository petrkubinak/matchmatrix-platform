# -*- coding: utf-8 -*-

import os
import json
import requests
from dotenv import load_dotenv

ENV_PATH = r"C:\MatchMatrix-platform\ingest\API-Cricket\.env"

load_dotenv(ENV_PATH)

BASE = os.getenv("RAPIDAPI_CRICKET_BASE", "https://cricbuzz-cricket.p.rapidapi.com").rstrip("/")
HOST = os.getenv("RAPIDAPI_CRICKET_HOST", "cricbuzz-cricket.p.rapidapi.com")
KEY = os.getenv("RAPIDAPI_KEY")

HEADERS = {
    "x-rapidapi-key": KEY,
    "x-rapidapi-host": HOST,
    "Content-Type": "application/json",
}

CANDIDATES = [
    "/series/v1/7607/squads/43915",
    "/series/v1/7607/squads/43915/players",
    "/series/v1/7607/squad/43915",
    "/series/v1/7607/squad/43915/players",
    "/squads/v1/43915",
    "/squads/v1/43915/players",
]

for path in CANDIDATES:
    print("-" * 80)
    print("GET:", path)

    try:
        r = requests.get(BASE + path, headers=HEADERS, timeout=30)
        print("STATUS:", r.status_code)

        try:
            print(json.dumps(r.json(), ensure_ascii=False)[:700])
        except Exception:
            print(r.text[:700])

    except Exception as e:
        print("ERROR:", e)