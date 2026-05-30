"""
===============================================================================
MATCHMATRIX – API FOOTBALL FIXTURE PLAYERS RAW INGEST V1
===============================================================================

CO TO DĚLÁ
-----------
Stáhne fixture player statistics z API-Football endpointu:

/fixtures/players

a uloží RAW payload do:

staging.stg_api_payloads

K ČEMU TO JE
-------------
První reálný RAW ingest pro:

public.player_match_statistics

JAK TO VYUŽIJEME
----------------
Budoucí pipeline:

provider
→ RAW payload
→ parser
→ staging match stats
→ public.player_match_statistics
→ AI/player form/fantasy/web

WEB / APP VÝSTUP
----------------
- výkon hráče v zápase
- player form
- fantasy scoring
- player momentum
- lineup analytics
- match detail hráče
===============================================================================
"""

import os
import json
import hashlib
import requests
import psycopg2

from datetime import datetime
from dotenv import load_dotenv

# ============================================================================
# LOAD ENV
# ============================================================================

load_dotenv()

API_KEY = os.getenv("APISPORTS_KEY")

if not API_KEY:
    raise Exception("API_SPORTS_KEY not found in .env")

DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")

BASE_URL = "https://v3.football.api-sports.io"

HEADERS = {
    "x-apisports-key": API_KEY
}

# ============================================================================
# TEST FIXTURE
# ============================================================================

FIXTURE_ID = 1208310
SEASON = "2024"

# ============================================================================
# REQUEST
# ============================================================================

url = BASE_URL + "/fixtures/players"

params = {
    "fixture": FIXTURE_ID
}

print("=" * 80)
print("MATCHMATRIX API-FOOTBALL FIXTURE PLAYERS RAW INGEST V1")
print("=" * 80)

print()
print(f"FIXTURE ID: {FIXTURE_ID}")

response = requests.get(
    url,
    headers=HEADERS,
    params=params,
    timeout=60
)

print(f"HTTP STATUS: {response.status_code}")

data = response.json()

response_items = data.get("response", [])

print(f"RESPONSE COUNT: {len(response_items)}")

if len(response_items) == 0:
    print("EMPTY RESPONSE")
    raise SystemExit()

# ============================================================================
# PAYLOAD HASH
# ============================================================================

payload_json_str = json.dumps(data, ensure_ascii=False)

payload_hash = hashlib.md5(
    payload_json_str.encode("utf-8")
).hexdigest()

# ============================================================================
# DB INSERT
# ============================================================================

conn = psycopg2.connect(
    host=DB_HOST,
    port=DB_PORT,
    dbname=DB_NAME,
    user=DB_USER,
    password=DB_PASSWORD
)

cur = conn.cursor()

insert_sql = """
INSERT INTO staging.stg_api_payloads
(
    provider,
    sport_code,
    entity_type,
    endpoint_name,
    external_id,
    season,
    fetched_at,
    payload_json,
    payload_hash,
    parse_status,
    parse_message,
    created_at
)
VALUES
(
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    NOW(),
    %s::jsonb,
    %s,
    %s,
    %s,
    NOW()
)
RETURNING id;
"""

cur.execute(
    insert_sql,
    (
        "api_football",
        "FB",
        "player_match_statistics",
        "fixtures_players",
        str(FIXTURE_ID),
        SEASON,
        payload_json_str,
        payload_hash,
        "pending",
        "Fixture player statistics RAW ingest V1"
    )
)

raw_id = cur.fetchone()[0]

conn.commit()

cur.close()
conn.close()

# ============================================================================
# DONE
# ============================================================================

print()
print("=" * 80)
print("RAW PAYLOAD INSERTED")
print(f"RAW ID: {raw_id}")
print("=" * 80)