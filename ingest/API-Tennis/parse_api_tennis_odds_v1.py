# -*- coding: utf-8 -*-
"""
parse_api_tennis_odds_v1.py

Účel:
- načte RAW TN odds payloady z public.api_raw_payloads
- vytáhne winner odds pro home/away
- najde odpovídající public.matches.id přes ext_match_id
- uloží do public.odds jako:
    HOME -> market_outcome_id = 10
    AWAY -> market_outcome_id = 11

JSON shape:
{
    "away": {
        "id": ...,
        "actual": 20,
        "expected": 36,
        "fractionalValue": "7/4"
    },
    "home": {
        "id": ...,
        "actual": 70,
        "expected": 71,
        "fractionalValue": "2/5"
    }
}

Poznámka:
- bookmaker v endpointu provider/1 zatím mapujeme natvrdo na bookmaker_id = 2 (Tipsport)
- ukládáme DECIMAL ODDS přepočtené z fractionalValue
"""

from __future__ import annotations

import argparse
import os
import re
import sys
from decimal import Decimal, InvalidOperation, ROUND_HALF_UP
from pathlib import Path
from typing import Any, Optional

import psycopg2
import psycopg2.extras
from dotenv import load_dotenv


SCRIPT_DIR = Path(__file__).resolve().parent
ENV_PATH = SCRIPT_DIR / ".env"

if ENV_PATH.exists():
    load_dotenv(dotenv_path=ENV_PATH, override=True)
else:
    load_dotenv(override=True)


SOURCE = "api_tennis"
MARKET_OUTCOME_HOME_ID = 10
MARKET_OUTCOME_AWAY_ID = 11

BOOKMAKER_ID_PROVIDER_1 = 2

ENDPOINT_REGEX = re.compile(r"/api/tennis/event/(\d+)/provider/(\d+)/winning-odds")


def get_conn():
    host = os.getenv("PGHOST", "localhost").strip()
    port = os.getenv("PGPORT", "5432").strip()
    dbname = os.getenv("PGDATABASE", "matchmatrix").strip()
    user = os.getenv("PGUSER", "matchmatrix").strip()
    password = os.getenv("PGPASSWORD", "matchmatrix_pass").strip()

    return psycopg2.connect(
        host=host,
        port=port,
        dbname=dbname,
        user=user,
        password=password,
    )


def extract_endpoint_parts(endpoint: str) -> tuple[Optional[str], Optional[int]]:
    m = ENDPOINT_REGEX.search(endpoint or "")
    if not m:
        return None, None
    return m.group(1), int(m.group(2))


def load_raw_rows(cur, limit: int) -> list[dict[str, Any]]:
    cur.execute(
        """
        select
            id,
            run_id,
            source,
            endpoint,
            fetched_at,
            payload
        from public.api_raw_payloads
        where source = %s
          and endpoint like %s
        order by id desc
        limit %s
        """,
        (SOURCE, "/api/tennis/event/%/provider/%/winning-odds", limit),
    )
    return list(cur.fetchall())


def load_match_map(cur) -> dict[str, int]:
    cur.execute(
        """
        select ext_match_id, id
        from public.matches
        where ext_source = %s
          and ext_match_id is not null
        """,
        (SOURCE,),
    )
    return {str(r["ext_match_id"]): int(r["id"]) for r in cur.fetchall()}


def map_provider_id_to_bookmaker_id(provider_id: int) -> Optional[int]:
    if provider_id == 1:
        return BOOKMAKER_ID_PROVIDER_1
    return None


def fractional_to_decimal(value: Any) -> Optional[Decimal]:
    """
    Převod fractional odds:
    2/5 -> 1.40
    7/4 -> 2.75
    """
    if value is None:
        return None

    text = str(value).strip()
    if not text or "/" not in text:
        return None

    try:
        left, right = text.split("/", 1)
        a = Decimal(left.strip())
        b = Decimal(right.strip())
        if b == 0:
            return None
        dec = Decimal("1") + (a / b)
        return dec.quantize(Decimal("0.001"), rounding=ROUND_HALF_UP)
    except (InvalidOperation, ValueError):
        return None


def parse_home_away_fractional(payload: Any) -> tuple[Optional[Decimal], Optional[Decimal]]:
    """
    Očekávaný shape:
    payload["home"]["fractionalValue"]
    payload["away"]["fractionalValue"]
    """
    if not isinstance(payload, dict):
        raise ValueError("Payload není dict")

    home = payload.get("home")
    away = payload.get("away")

    if not isinstance(home, dict) or not isinstance(away, dict):
        raise ValueError("Payload nemá očekávané home/away objekty")

    home_odd = fractional_to_decimal(home.get("fractionalValue"))
    away_odd = fractional_to_decimal(away.get("fractionalValue"))

    if home_odd is None and away_odd is None:
        raise ValueError("Payload nemá validní fractionalValue pro home ani away")

    return home_odd, away_odd


def insert_odds(
    cur,
    match_id: int,
    bookmaker_id: int,
    market_outcome_id: int,
    odd_value: Decimal,
    collected_at: Optional[str],
) -> None:
    cur.execute(
        """
        insert into public.odds
            (match_id, bookmaker_id, market_outcome_id, odd_value, collected_at)
        values
            (%s, %s, %s, %s, coalesce(%s::timestamp, now()))
        """,
        (match_id, bookmaker_id, market_outcome_id, odd_value, collected_at),
    )


def main() -> int:
    parser = argparse.ArgumentParser(description="Parse TN RAW odds -> public.odds")
    parser.add_argument("--limit", type=int, default=20, help="Kolik RAW payloadů načíst")
    parser.add_argument("--dry-run", action="store_true", help="Jen test, bez insertu")
    args = parser.parse_args()

    conn = None
    try:
        conn = get_conn()
        conn.autocommit = False

        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            print("=" * 70)
            print("MATCHMATRIX TN ODDS PARSER V1")
            print("=" * 70)
            print(f"LIMIT     : {args.limit}")
            print(f"DRY RUN   : {args.dry_run}")
            print("=" * 70)

            match_map = load_match_map(cur)
            raw_rows = load_raw_rows(cur, args.limit)

            print(f"Loaded match_map     : {len(match_map)}")
            print(f"Loaded raw rows      : {len(raw_rows)}")

            inserted = 0
            skipped_no_match = 0
            skipped_no_bookmaker = 0
            skipped_bad_payload = 0

            for row in raw_rows:
                ext_match_id, provider_id = extract_endpoint_parts(row["endpoint"])
                if not ext_match_id or provider_id is None:
                    skipped_bad_payload += 1
                    print(f"[SKIP ENDPOINT] raw_id={row['id']} endpoint={row['endpoint']}")
                    continue

                match_id = match_map.get(ext_match_id)
                if not match_id:
                    skipped_no_match += 1
                    print(f"[SKIP MATCH] ext_match_id={ext_match_id}")
                    continue

                bookmaker_id = map_provider_id_to_bookmaker_id(provider_id)
                if not bookmaker_id:
                    skipped_no_bookmaker += 1
                    print(f"[SKIP BOOKMAKER] provider_id={provider_id}")
                    continue

                try:
                    home_odd, away_odd = parse_home_away_fractional(row["payload"])
                except Exception as exc:
                    skipped_bad_payload += 1
                    print(f"[SKIP PAYLOAD] raw_id={row['id']} ext_match_id={ext_match_id} error={exc}")
                    continue

                if home_odd is not None:
                    if not args.dry_run:
                        insert_odds(
                            cur=cur,
                            match_id=match_id,
                            bookmaker_id=bookmaker_id,
                            market_outcome_id=MARKET_OUTCOME_HOME_ID,
                            odd_value=home_odd,
                            collected_at=str(row["fetched_at"]) if row["fetched_at"] is not None else None,
                        )
                    inserted += 1

                if away_odd is not None:
                    if not args.dry_run:
                        insert_odds(
                            cur=cur,
                            match_id=match_id,
                            bookmaker_id=bookmaker_id,
                            market_outcome_id=MARKET_OUTCOME_AWAY_ID,
                            odd_value=away_odd,
                            collected_at=str(row["fetched_at"]) if row["fetched_at"] is not None else None,
                        )
                    inserted += 1

            if args.dry_run:
                conn.rollback()
                print("DRY RUN -> rollback")
            else:
                conn.commit()
                print("COMMIT OK")

            print("-" * 70)
            print(f"inserted             : {inserted}")
            print(f"skipped_no_match     : {skipped_no_match}")
            print(f"skipped_no_bookmaker : {skipped_no_bookmaker}")
            print(f"skipped_bad_payload  : {skipped_bad_payload}")
            print("-" * 70)

        return 0

    except Exception as exc:
        if conn:
            conn.rollback()
        print(f"FATAL ERROR: {exc}")
        return 1

    finally:
        if conn:
            conn.close()


if __name__ == "__main__":
    sys.exit(main())