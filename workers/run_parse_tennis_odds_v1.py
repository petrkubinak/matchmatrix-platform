# -*- coding: utf-8 -*-
"""
run_parse_tennis_odds_v1.py

Účel:
- načte TN odds RAW data ze staging vrstvy
- najde odpovídající match_id v public.matches
- najde bookmaker_id v public.bookmakers
- namapuje odds na 2-way market:
    HOME -> market_outcome_id = 10
    AWAY -> market_outcome_id = 11
- uloží do public.odds

Poznámka:
Tato verze je schválně CORE / MINIMAL.
Neřeší detail statistik ani enrichment.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from dataclasses import dataclass
from decimal import Decimal, InvalidOperation
from typing import Any, Iterable, Optional

import psycopg2
import psycopg2.extras


# =========================================================
# KONSTANTY
# =========================================================

EXT_SOURCE = "api_tennis"
MARKET_OUTCOME_HOME_ID = 10
MARKET_OUTCOME_AWAY_ID = 11

# TODO:
# Až potvrdíš skutečný RAW table name pro TN odds,
# uprav níže TN_ODDS_RAW_TABLE.
TN_ODDS_RAW_TABLE = "staging.api_tennis_odds_raw"


# =========================================================
# DATOVÉ TYPY
# =========================================================

@dataclass
class ParsedOdd:
    ext_match_id: str
    bookmaker_name: str
    side: str            # HOME / AWAY
    odd_value: Decimal
    collected_at: Optional[str] = None


# =========================================================
# DB
# =========================================================

def get_conn():
    """
    DB připojení:
    1) z env proměnných
    2) fallback na local docker default
    """
    host = os.getenv("DB_HOST", "localhost")
    port = os.getenv("DB_PORT", "5432")
    dbname = os.getenv("DB_NAME", "matchmatrix")
    user = os.getenv("DB_USER", "matchmatrix")
    password = os.getenv("DB_PASSWORD", "matchmatrix_pass")

    return psycopg2.connect(
        host=host,
        port=port,
        dbname=dbname,
        user=user,
        password=password,
    )


# =========================================================
# HELPERY
# =========================================================

def safe_decimal(value: Any) -> Optional[Decimal]:
    if value is None:
        return None
    try:
        return Decimal(str(value))
    except (InvalidOperation, ValueError):
        return None


def normalize_bookmaker_name(name: str) -> str:
    return (name or "").strip()


def map_side_to_market_outcome_id(side: str) -> Optional[int]:
    side_up = (side or "").upper().strip()
    if side_up == "HOME":
        return MARKET_OUTCOME_HOME_ID
    if side_up == "AWAY":
        return MARKET_OUTCOME_AWAY_ID
    return None


def extract_json_payload(row: dict[str, Any]) -> Any:
    """
    Očekává některý z běžných názvů sloupců.
    Když bude tvoje TN RAW tabulka jiná, uprav zde.
    """
    for key in ("payload_json", "payload", "raw_json", "response_json", "json_data"):
        if key in row and row[key] is not None:
            value = row[key]
            if isinstance(value, (dict, list)):
                return value
            if isinstance(value, str):
                return json.loads(value)
    raise KeyError("Nenalezen JSON payload sloupec. Uprav extract_json_payload().")


# =========================================================
# PARSING RAW ODDS
# =========================================================

def parse_payload_to_odds(payload: Any) -> list[ParsedOdd]:
    """
    Tohle je záměrně flexibilní parser skeleton.

    Očekávaný logický výstup:
    - ext_match_id
    - bookmaker_name
    - HOME odd
    - AWAY odd

    Protože neznáme přesný RAW JSON tvar, jsou zde 2 cesty:
    A) přímý standardní tvar
    B) fallback přes ruční úpravu parseru po prvním vzorku
    """

    parsed: list[ParsedOdd] = []

    # -----------------------------------------------------
    # VARIANTA A: očekávaný jednoduchý tvar
    # -----------------------------------------------------
    # Např.
    # {
    #   "eventId": "362385",
    #   "bookmakers": [
    #       {
    #           "name": "Tipsport",
    #           "homeOdd": 1.85,
    #           "awayOdd": 1.95
    #       }
    #   ]
    # }

    event_id = None
    if isinstance(payload, dict):
        for key in ("eventId", "event_id", "matchId", "match_id", "id"):
            if key in payload and payload[key] is not None:
                event_id = str(payload[key])
                break

        bookmakers = payload.get("bookmakers")
        if event_id and isinstance(bookmakers, list):
            for bookmaker in bookmakers:
                if not isinstance(bookmaker, dict):
                    continue

                bookmaker_name = normalize_bookmaker_name(
                    bookmaker.get("name") or bookmaker.get("bookmaker") or bookmaker.get("bookmakerName")
                )
                if not bookmaker_name:
                    continue

                home_odd = safe_decimal(
                    bookmaker.get("homeOdd") or bookmaker.get("home_odd") or bookmaker.get("oddHome")
                )
                away_odd = safe_decimal(
                    bookmaker.get("awayOdd") or bookmaker.get("away_odd") or bookmaker.get("oddAway")
                )

                collected_at = bookmaker.get("collected_at") or bookmaker.get("collectedAt")

                if home_odd:
                    parsed.append(
                        ParsedOdd(
                            ext_match_id=event_id,
                            bookmaker_name=bookmaker_name,
                            side="HOME",
                            odd_value=home_odd,
                            collected_at=collected_at,
                        )
                    )

                if away_odd:
                    parsed.append(
                        ParsedOdd(
                            ext_match_id=event_id,
                            bookmaker_name=bookmaker_name,
                            side="AWAY",
                            odd_value=away_odd,
                            collected_at=collected_at,
                        )
                    )

            if parsed:
                return parsed

    # -----------------------------------------------------
    # VARIANTA B: fallback
    # -----------------------------------------------------
    # Pokud RAW JSON není v očekávaném tvaru,
    # necháme parser explicitně selhat a upravíme ho podle vzorku.
    raise ValueError(
        "Nepodařilo se rozpoznat JSON strukturu TN odds payloadu. "
        "Pošli 1 vzorek RAW payloadu a parser doplníme přesně na tvoje API."
    )


# =========================================================
# DB LOOKUP
# =========================================================

def load_match_map(cur) -> dict[str, int]:
    cur.execute(
        """
        select ext_match_id, id
        from public.matches
        where ext_source = %s
          and ext_match_id is not null
        """,
        (EXT_SOURCE,),
    )
    rows = cur.fetchall()
    return {str(r["ext_match_id"]): r["id"] for r in rows}


def load_bookmaker_map(cur) -> dict[str, int]:
    cur.execute(
        """
        select id, name
        from public.bookmakers
        """
    )
    rows = cur.fetchall()
    return {normalize_bookmaker_name(r["name"]): r["id"] for r in rows}


# =========================================================
# UPSERT / INSERT
# =========================================================

def insert_odds(
    cur,
    match_id: int,
    bookmaker_id: int,
    market_outcome_id: int,
    odd_value: Decimal,
    collected_at: Optional[str],
) -> None:
    """
    Aktuální public.odds nemá unique constraint v zadání,
    takže vkládáme jednoduše INSERT.
    Později můžeme přidat dedup logiku.
    """
    cur.execute(
        """
        insert into public.odds
            (match_id, bookmaker_id, market_outcome_id, odd_value, collected_at)
        values
            (%s, %s, %s, %s, coalesce(%s::timestamp, now()))
        """,
        (match_id, bookmaker_id, market_outcome_id, odd_value, collected_at),
    )


# =========================================================
# RAW LOAD
# =========================================================

def load_raw_rows(cur, limit: int) -> list[dict[str, Any]]:
    """
    Minimal varianta:
    očekává TN RAW odds tabulku.
    Když je název jiný, uprav TN_ODDS_RAW_TABLE.
    """
    sql = f"""
        select *
        from {TN_ODDS_RAW_TABLE}
        order by 1 desc
        limit %s
    """
    cur.execute(sql, (limit,))
    return list(cur.fetchall())


# =========================================================
# MAIN
# =========================================================

def main() -> int:
    parser = argparse.ArgumentParser(description="Parse TN odds RAW -> public.odds")
    parser.add_argument("--limit", type=int, default=100, help="Kolik RAW řádků načíst")
    parser.add_argument("--dry-run", action="store_true", help="Jen vypíše statistiku, bez insertu")
    args = parser.parse_args()

    conn = None
    try:
        conn = get_conn()
        conn.autocommit = False

        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            print("=" * 70)
            print("MATCHMATRIX TN ODDS PARSER V1")
            print("=" * 70)
            print(f"RAW TABLE : {TN_ODDS_RAW_TABLE}")
            print(f"LIMIT     : {args.limit}")
            print(f"DRY RUN   : {args.dry_run}")
            print("=" * 70)

            match_map = load_match_map(cur)
            bookmaker_map = load_bookmaker_map(cur)
            raw_rows = load_raw_rows(cur, args.limit)

            print(f"Loaded match_map     : {len(match_map)}")
            print(f"Loaded bookmaker_map : {len(bookmaker_map)}")
            print(f"Loaded raw rows      : {len(raw_rows)}")

            inserted = 0
            skipped_no_match = 0
            skipped_no_bookmaker = 0
            skipped_bad_side = 0
            skipped_bad_payload = 0

            for row in raw_rows:
                try:
                    payload = extract_json_payload(row)
                    parsed_odds = parse_payload_to_odds(payload)
                except Exception as exc:
                    skipped_bad_payload += 1
                    print(f"[SKIP PAYLOAD] row={row.get('id')} error={exc}")
                    continue

                for odd in parsed_odds:
                    match_id = match_map.get(str(odd.ext_match_id))
                    if not match_id:
                        skipped_no_match += 1
                        print(f"[SKIP MATCH] ext_match_id={odd.ext_match_id}")
                        continue

                    bookmaker_id = bookmaker_map.get(normalize_bookmaker_name(odd.bookmaker_name))
                    if not bookmaker_id:
                        skipped_no_bookmaker += 1
                        print(f"[SKIP BOOKMAKER] bookmaker={odd.bookmaker_name}")
                        continue

                    market_outcome_id = map_side_to_market_outcome_id(odd.side)
                    if not market_outcome_id:
                        skipped_bad_side += 1
                        print(f"[SKIP SIDE] side={odd.side}")
                        continue

                    if not args.dry_run:
                        insert_odds(
                            cur=cur,
                            match_id=match_id,
                            bookmaker_id=bookmaker_id,
                            market_outcome_id=market_outcome_id,
                            odd_value=odd.odd_value,
                            collected_at=odd.collected_at,
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
            print(f"skipped_bad_side     : {skipped_bad_side}")
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