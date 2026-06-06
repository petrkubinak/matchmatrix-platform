# -*- coding: utf-8 -*-
"""
MATCHMATRIX TEST
test_cricbuzz_people_endpoints_v1.py

CO TO JE:
- Smoke test možných Cricbuzz / RapidAPI people endpointů.

K ČEMU TO JE:
- Nehádáme endpoint pro CK players.
- Ověříme, která cesta vrací data a jaký má status.

KDE TO UVIDÍME:
- Výstup v terminálu.

JAK SE TO VYUŽIJE:
- Funkční endpoint pak přidáme do .env a do custom downloaderu V2.
"""

import os
import json
import requests
from dotenv import load_dotenv


ENV_PATH = r"C:\MatchMatrix-platform\ingest\API-Cricket\.env"

load_dotenv(ENV_PATH)

BASE = os.getenv("RAPIDAPI_CRICKET_BASE", "https://cricbuzz-cricket.p.rapidapi.com").rstrip("/")
HOST = os.getenv("RAPIDAPI_CRICKET_HOST", "cricbuzz-cricket.p.rapidapi.com")
KEY = os.getenv("RAPIDAPI_KEY")


if not KEY:
    raise RuntimeError("Chybí RAPIDAPI_KEY v C:\\MatchMatrix-platform\\ingest\\API-Cricket\\.env")


HEADERS = {
    "x-rapidapi-key": KEY,
    "x-rapidapi-host": HOST,
    "Content-Type": "application/json",
}


CANDIDATES = [
    "/teams/v1/international",
    "/teams/v1/league/1",
    "/teams/v1/league/IPL",
    "/teams/v1/league/ipl",

    "/stats/v1/player/search?plrN=dhoni",
    "/stats/v1/player/search?plrN=kohli",
    "/stats/v1/player/1413",
    "/stats/v1/player/8733",

    "/series/v1/international",
    "/series/v1/7607",
    "/series/v1/7607/squads",
    "/series/v1/7607/teams",
    "/series/v1/7607/points-table",
]


def compact_preview(payload):
    try:
        text = json.dumps(payload, ensure_ascii=False)[:500]
        return text.replace("\n", " ")
    except Exception:
        return str(payload)[:500]


def main():
    print("=" * 80)
    print("MATCHMATRIX CRICBUZZ PEOPLE ENDPOINT SMOKE TEST V1")
    print("=" * 80)
    print("BASE:", BASE)
    print("HOST:", HOST)
    print("=" * 80)

    for path in CANDIDATES:
        url = BASE + path
        print()
        print("-" * 80)
        print("GET:", path)

        try:
            r = requests.get(url, headers=HEADERS, timeout=30)
            print("STATUS:", r.status_code)

            try:
                payload = r.json()
                print("JSON PREVIEW:", compact_preview(payload))
            except Exception:
                print("TEXT PREVIEW:", r.text[:500].replace("\n", " "))

        except Exception as exc:
            print("ERROR:", type(exc).__name__, exc)

    print()
    print("=" * 80)
    print("DONE")
    print("=" * 80)


if __name__ == "__main__":
    main()