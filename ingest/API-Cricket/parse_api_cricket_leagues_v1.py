# -*- coding: utf-8 -*-
"""
parse_api_cricket_leagues_v1.py
---------------------------------------------------------
CRICKET leagues parser
Tok:
    staging.stg_api_payloads
        -> parse leagues / series
        -> staging.stg_provider_leagues
        -> update parse_status
"""

from __future__ import annotations

import os
import sys
from typing import Any, Dict, List, Tuple

import psycopg2
from psycopg2.extras import RealDictCursor, execute_values

# ---------------------------------------------------------
# CONFIG
# ---------------------------------------------------------
PROVIDER = "api_cricket"
SPORT_CODE = "CK"
ENTITY_TYPE = "leagues"

# ---------------------------------------------------------
# DB
# ---------------------------------------------------------
def get_conn():
    return psycopg2.connect(
        host="localhost",
        port=5432,
        dbname="matchmatrix",
        user="matchmatrix",
        password="matchmatrix_pass"
    )

# ---------------------------------------------------------
# HELPERS
# ---------------------------------------------------------
def pick(*vals):
    for v in vals:
        if v not in (None, "", {}):
            return v
    return None

def to_text(v):
    if v is None:
        return None
    return str(v).strip() or None

def walk(obj):
    if isinstance(obj, dict):
        yield obj
        for v in obj.values():
            yield from walk(v)
    elif isinstance(obj, list):
        for i in obj:
            yield from walk(i)

def is_series_block(d: Dict[str, Any]) -> bool:
    keys = set(d.keys())
    return (
        "seriesId" in keys
        or "seriesName" in keys
        or ("id" in keys and "name" in keys and "match" not in keys)
    )

# ---------------------------------------------------------
# PARSE
# ---------------------------------------------------------
def extract_leagues(payload, payload_row) -> List[Tuple]:
    rows = []
    seen = set()

    for d in walk(payload):
        if not is_series_block(d):
            continue

        ext_id = to_text(
            pick(
                d.get("seriesId"),
                d.get("id"),
                payload_row.get("external_id")
            )
        )

        if not ext_id or ext_id in seen:
            continue

        seen.add(ext_id)

        league_name = to_text(
            pick(
                d.get("seriesName"),
                d.get("name"),
                d.get("series"),
            )
        )

        country = to_text(
            pick(
                d.get("country"),
                d.get("countryName"),
                d.get("location")
            )
        )

        season = to_text(
            pick(
                payload_row.get("season"),
                d.get("season"),
                d.get("seriesSeason")
            )
        )

        rows.append((
            PROVIDER,
            SPORT_CODE,
            ext_id,
            league_name,
            country,
            season,
            True,
            payload_row["id"]
        ))

    return rows

# ---------------------------------------------------------
# DB OPERACE
# ---------------------------------------------------------
def fetch_pending(conn):
    sql = """
        SELECT *
        FROM staging.stg_api_payloads
        WHERE provider = %s
          AND sport_code = %s
          AND entity_type = %s
          AND parse_status = 'pending'
    """
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(sql, (PROVIDER, SPORT_CODE, ENTITY_TYPE))
        return cur.fetchall()

def upsert(conn, rows):
    if not rows:
        return 0

    keys = {(r[0], r[1], r[2]) for r in rows}

    with conn.cursor() as cur:
        delete_sql = """
        DELETE FROM staging.stg_provider_leagues t
        USING (VALUES %s) AS src(provider, sport_code, external_league_id)
        WHERE t.provider = src.provider
          AND t.sport_code = src.sport_code
          AND t.external_league_id = src.external_league_id;
        """
        execute_values(cur, delete_sql, list(keys), template="(%s,%s,%s)")

        insert_sql = """
        INSERT INTO staging.stg_provider_leagues (
            provider,
            sport_code,
            external_league_id,
            league_name,
            country_name,
            season,
            is_active,
            raw_payload_id
        ) VALUES %s;
        """
        execute_values(cur, insert_sql, rows)

    return len(rows)

def mark_ok(conn, pid, msg):
    with conn.cursor() as cur:
        cur.execute("""
            UPDATE staging.stg_api_payloads
            SET parse_status = 'parsed',
                parse_message = %s
            WHERE id = %s
        """, (msg[:1000], pid))

def mark_err(conn, pid, msg):
    with conn.cursor() as cur:
        cur.execute("""
            UPDATE staging.stg_api_payloads
            SET parse_status = 'error',
                parse_message = %s
            WHERE id = %s
        """, (msg[:1000], pid))

# ---------------------------------------------------------
# MAIN
# ---------------------------------------------------------
def main():
    print("======================================")
    print("MATCHMATRIX CRICKET LEAGUES PARSER")
    print("======================================")

    conn = get_conn()
    conn.autocommit = False

    payloads = fetch_pending(conn)
    print(f"PENDING PAYLOADS: {len(payloads)}")

    total = 0

    for p in payloads:
        print("--------------------------------------")
        print(f"PAYLOAD_ID : {p['id']}")

        try:
            rows = extract_leagues(p["payload_json"], p)
            inserted = upsert(conn, rows)

            mark_ok(conn, p["id"], f"OK | leagues={inserted}")
            conn.commit()

            total += inserted

            print(f"OK | inserted={inserted}")

        except Exception as e:
            conn.rollback()
            mark_err(conn, p["id"], str(e))
            conn.commit()

            print(f"ERROR: {e}")

    print("======================================")
    print("DONE")
    print(f"TOTAL INSERTED: {total}")
    print("======================================")

if __name__ == "__main__":
    sys.exit(main())