"""
===============================================================================
MATCHMATRIX – API FOOTBALL PEOPLE LIVE SMOKE TEST V1
===============================================================================

CO TO DĚLÁ
-----------
Provádí LIVE reality test API-Football PEOPLE endpointů.

OVĚŘUJE
--------
- players
- coaches
- injuries
- transfers

CÍL
----
Zjistit:
- co provider opravdu vrací
- které endpointy fungují
- které endpointy jsou usable
- které endpointy jsou empty/partial
- co bude dostupné po PRO aktivaci

JAK TO VYUŽIJEME
----------------
Výsledek rozhodne:
- provider priority
- PEOPLE automation
- future player_match_statistics layer
===============================================================================
"""

import os
import requests
from dotenv import load_dotenv

# ============================================================================
# LOAD ENV
# ============================================================================

load_dotenv()

API_KEY = os.getenv("APISPORTS_KEY")

if not API_KEY:
    raise Exception("API_FOOTBALL_KEY not found in .env")

BASE_URL = "https://v3.football.api-sports.io"

HEADERS = {
    "x-apisports-key": API_KEY
}

# ============================================================================
# TESTS
# ============================================================================

TESTS = [
    {
        "name": "players",
        "endpoint": "/players",
        "params": {
            "team": 33,
            "season": 2024
        }
    },
    {
        "name": "coaches",
        "endpoint": "/coachs",
        "params": {
            "team": 33
        }
    },
    {
        "name": "injuries",
        "endpoint": "/injuries",
        "params": {
            "league": 39,
            "season": 2024
        }
    },
    {
        "name": "transfers",
        "endpoint": "/transfers",
        "params": {
            "player": 276
        }
    },
    {
        "name": "fixture_player_statistics",
        "endpoint": "/fixtures/players",
        "params": {
            "fixture": 1208310
        }
    }
]

# ============================================================================
# RUN TESTS
# ============================================================================

print("=" * 80)
print("MATCHMATRIX API-FOOTBALL PEOPLE LIVE SMOKE TEST")
print("=" * 80)

for test in TESTS:

    print()
    print("-" * 80)
    print(f"TEST: {test['name']}")
    print(f"ENDPOINT: {test['endpoint']}")
    print(f"PARAMS: {test['params']}")

    url = BASE_URL + test["endpoint"]

    try:

        response = requests.get(
            url,
            headers=HEADERS,
            params=test["params"],
            timeout=60
        )

        print(f"HTTP STATUS: {response.status_code}")

        data = response.json()

        response_items = data.get("response", [])

        print(f"RESPONSE COUNT: {len(response_items)}")

        if len(response_items) > 0:
            print("STATUS: USABLE")
        else:
            print("STATUS: EMPTY")

    except Exception as e:

        print(f"ERROR: {e}")

print()
print("=" * 80)
print("DONE")
print("=" * 80)