# ============================================================================
# fetch_player_profiles_by_ids_v1.py
# Cíl:
#   Stáhnout player profiles z API-Football podle seznamu player IDs
#   a uložit do staging.stg_api_payloads
# ============================================================================

import os
import time
import json
import requests
import psycopg2
from pathlib import Path
from dotenv import load_dotenv

# =========================
# LOAD .env
# =========================
ENV_PATH = Path(r"C:\MatchMatrix-platform\.env")
load_dotenv(dotenv_path=ENV_PATH)

# =========================
# CONFIG
# =========================
API_KEY = os.getenv("APISPORTS_KEY")
BASE_URL = os.getenv("APISPORTS_BASE", "https://v3.football.api-sports.io")

DB = {
    "host": os.getenv("PGHOST"),
    "port": int(os.getenv("PGPORT", "5432")),
    "dbname": os.getenv("PGDATABASE"),
    "user": os.getenv("PGUSER"),
    "password": os.getenv("PGPASSWORD"),
}

HEADERS = {
    "x-apisports-key": API_KEY
}

# =========================
# INPUT – batch 1
# =========================
PLAYER_IDS = [
    101350, 104827, 106737, 1094, 113587,
    11379, 118360, 119762, 119948, 122230,
    127122, 128962, 128980, 129697, 129701,
    133992, 134465, 134470, 134555, 136790
]

# =========================
# VALIDATION
# =========================
required = {
    "APISPORTS_KEY": API_KEY,
    "PGHOST": DB["host"],
    "PGDATABASE": DB["dbname"],
    "PGUSER": DB["user"],
    "PGPASSWORD": DB["password"],
}
missing = [k for k, v in required.items() if not v]
if missing:
    raise RuntimeError(f"Chybí proměnné v .env: {', '.join(missing)}")

print("TEST DB CONNECT...")
conn = psycopg2.connect(**DB)
print("DB OK")

cur = conn.cursor()

# =========================
# FETCH LOOP
# =========================
for pid in PLAYER_IDS:
    url = f"{BASE_URL}/players?id={pid}"
    print(f"Fetching player {pid}")

    try:
        r = requests.get(url, headers=HEADERS, timeout=60)
        data = r.json()

        cur.execute("""
            INSERT INTO staging.stg_api_payloads (
                provider,
                sport_code,
                entity_type,
                endpoint_name,
                external_id,
                payload_json,
                fetched_at,
                parse_status
            )
            VALUES (%s, %s, %s, %s, %s, %s::jsonb, NOW(), %s)
        """, (
            "api_football",
            "football",
            "player_profiles",
            "players",
            str(pid),
            json.dumps(data, ensure_ascii=False),
            "pending"
        ))

        conn.commit()
        time.sleep(6.5)  # bezpečně pod 10 req/min

    except Exception as e:
        print(f"ERROR for player {pid}: {e}")
        conn.rollback()

cur.close()
conn.close()

print("DONE")