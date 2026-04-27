# -*- coding: utf-8 -*-
"""
CRICKET fixtures recent pull
endpoint: /matches/v1/recent
"""

import os
import sys
import json
import hashlib
import requests
import psycopg2
from psycopg2.extras import Json
from dotenv import load_dotenv

ENV_PATH = r"C:\MatchMatrix-platform\ingest\API-Cricket\.env"
PROVIDER = "api_cricket"
SPORT_CODE = "CK"
ENTITY_TYPE = "fixtures"

URL = "https://cricbuzz-cricket.p.rapidapi.com/matches/v1/recent"


def get_conn():
    return psycopg2.connect(
        host="localhost",
        port=5432,
        dbname="matchmatrix",
        user="matchmatrix",
        password="matchmatrix_pass"
    )


def get_env(name):
    v = os.getenv(name)
    if not v:
        raise Exception(f"Missing ENV: {name}")
    return v


def payload_hash(payload):
    raw = json.dumps(payload, sort_keys=True).encode("utf-8")
    return hashlib.sha256(raw).hexdigest()


def main():
    print("======================================")
    print("MATCHMATRIX CRICKET FIXTURES RECENT PULL")
    print("======================================")

    # 🔑 LOAD ENV
    if os.path.exists(ENV_PATH):
        load_dotenv(ENV_PATH)

    headers = {
        "x-rapidapi-key": get_env("RAPIDAPI_KEY"),
        "x-rapidapi-host": "cricbuzz-cricket.p.rapidapi.com"
    }

    r = requests.get(URL, headers=headers, timeout=60)
    r.raise_for_status()

    payload = r.json()

    conn = get_conn()
    conn.autocommit = False

    try:
        with conn.cursor() as cur:
            cur.execute("""
                INSERT INTO staging.stg_api_payloads (
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
                    created_at
                )
                VALUES (%s,%s,%s,%s,NULL,NULL,now(),%s,%s,'pending',now())
                RETURNING id;
            """, (
                PROVIDER,
                SPORT_CODE,
                ENTITY_TYPE,
                "matches_v1_recent",
                Json(payload),
                payload_hash(payload)
            ))

            pid = cur.fetchone()[0]

        conn.commit()

        print(f"RAW SAVED: payload_id={pid}")
        print("DONE")

    except Exception as e:
        conn.rollback()
        print("ERROR:", e)

    finally:
        conn.close()


if __name__ == "__main__":
    sys.exit(main())