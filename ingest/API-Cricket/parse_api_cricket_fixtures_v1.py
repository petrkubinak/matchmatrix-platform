# -*- coding: utf-8 -*-
"""
parse_api_cricket_fixtures_v1.py
---------------------------------------------------------
CRICKET fixtures parser
Tok:
    staging.stg_api_payloads
        -> parse cricket live matches
        -> staging.stg_provider_fixtures
        -> update parse_status / parse_message zpět do stg_api_payloads

Určeno pro:
    provider   = api_cricket
    sport_code = CK
    entity_type= fixtures

Poznámka:
- Cricbuzz/RapidAPI payload může mít více vnořených struktur.
- Parser je proto napsaný robustně a hledá match bloky rekurzivně.
- První verze cílí hlavně na endpoint matches/v1/live.
"""

from __future__ import annotations

import json
import os
import sys
from datetime import datetime, timezone
from typing import Any, Dict, Iterable, List, Optional, Tuple

import psycopg2
from psycopg2.extras import Json, RealDictCursor, execute_values

try:
    from dotenv import load_dotenv
except ImportError:
    load_dotenv = None


# ---------------------------------------------------------
# KONFIG
# ---------------------------------------------------------
PROVIDER = "api_cricket"
SPORT_CODE = "CK"
ENTITY_TYPE = "fixtures"

DEFAULT_ENV_PATH = r"C:\MatchMatrix-platform\ingest\API-Cricket\.env"


# ---------------------------------------------------------
# ENV / DB
# ---------------------------------------------------------
def load_environment() -> None:
    """Načte .env, pokud existuje."""
    if load_dotenv and os.path.exists(DEFAULT_ENV_PATH):
        load_dotenv(DEFAULT_ENV_PATH)


def get_db_connection():
    """Vrátí DB connection z ENV nebo fallback hodnot."""
    return psycopg2.connect(
        host=os.getenv("PGHOST", "localhost"),
        port=int(os.getenv("PGPORT", "5432")),
        dbname=os.getenv("PGDATABASE", "matchmatrix"),
        user=os.getenv("PGUSER", "matchmatrix"),
        password=os.getenv("PGPASSWORD", "matchmatrix_pass"),
    )


# ---------------------------------------------------------
# POMOCNÉ FUNKCE
# ---------------------------------------------------------
def to_text(value: Any) -> Optional[str]:
    if value is None:
        return None
    text = str(value).strip()
    return text if text else None


def pick_first(*values: Any) -> Any:
    for value in values:
        if value is None:
            continue
        if isinstance(value, str) and value.strip() == "":
            continue
        return value
    return None


def parse_datetime_safe(value: Any) -> Optional[datetime]:
    """
    Zkusí převést hodnotu na datetime.
    Podporuje:
    - ISO string
    - epoch seconds
    - epoch milliseconds
    """
    if value is None:
        return None

    # epoch number
    if isinstance(value, (int, float)):
        try:
            # ms vs s
            if value > 10_000_000_000:
                return datetime.fromtimestamp(value / 1000.0, tz=timezone.utc)
            return datetime.fromtimestamp(value, tz=timezone.utc)
        except Exception:
            return None

    text = to_text(value)
    if not text:
        return None

    # ISO variants
    candidates = [
        text,
        text.replace("Z", "+00:00"),
    ]

    for candidate in candidates:
        try:
            dt = datetime.fromisoformat(candidate)
            if dt.tzinfo is None:
                return dt.replace(tzinfo=timezone.utc)
            return dt
        except Exception:
            pass

    # numeric string epoch
    if text.isdigit():
        try:
            raw = int(text)
            if raw > 10_000_000_000:
                return datetime.fromtimestamp(raw / 1000.0, tz=timezone.utc)
            return datetime.fromtimestamp(raw, tz=timezone.utc)
        except Exception:
            return None

    return None


def dig(obj: Any, path: List[str], default: Any = None) -> Any:
    """
    Bezpečné čtení z nested dictu.
    """
    cur = obj
    for key in path:
        if not isinstance(cur, dict):
            return default
        cur = cur.get(key)
        if cur is None:
            return default
    return cur


def walk_dicts(obj: Any) -> Iterable[Dict[str, Any]]:
    """
    Rekurzivně projde payload a vrátí všechny dicty.
    """
    if isinstance(obj, dict):
        yield obj
        for value in obj.values():
            yield from walk_dicts(value)
    elif isinstance(obj, list):
        for item in obj:
            yield from walk_dicts(item)


def looks_like_match_info(d: Dict[str, Any]) -> bool:
    """
    Heuristika pro Cricbuzz match block.
    """
    keys = set(d.keys())

    if "matchInfo" in keys:
        return True

    signals = 0
    if "matchId" in keys or "match_id" in keys:
        signals += 1
    if "team1" in keys or "team2" in keys:
        signals += 1
    if "seriesId" in keys or "seriesName" in keys:
        signals += 1
    if "status" in keys or "state" in keys:
        signals += 1

    return signals >= 2


def find_match_blocks(payload: Any) -> List[Dict[str, Any]]:
    """
    Najde všechny match-like bloky v payloadu.
    Dedup podle external_fixture_id později.
    """
    blocks: List[Dict[str, Any]] = []

    for d in walk_dicts(payload):
        if looks_like_match_info(d):
            blocks.append(d)

    return blocks


def extract_team_id(team_obj: Any) -> Optional[str]:
    if not isinstance(team_obj, dict):
        return None
    return to_text(
        pick_first(
            team_obj.get("teamId"),
            team_obj.get("id"),
            team_obj.get("team_id"),
        )
    )


def extract_team_name(team_obj: Any) -> Optional[str]:
    if not isinstance(team_obj, dict):
        return None
    return to_text(
        pick_first(
            team_obj.get("teamName"),
            team_obj.get("name"),
            team_obj.get("shortName"),
        )
    )


def extract_score(score_block: Any, inning_prefixes: Tuple[str, ...]) -> Optional[str]:
    """
    Zkusí složit score text z různých score struktur.
    Vrací text, protože stg_provider_fixtures má home_score/away_score jako text. 
    """
    if score_block is None:
        return None

    # Když score už je přímo text/číslo
    if isinstance(score_block, (str, int, float)):
        return to_text(score_block)

    if not isinstance(score_block, dict):
        return None

    # Nejprve přímé možnosti
    direct = pick_first(
        score_block.get("score"),
        score_block.get("runs"),
        score_block.get("display"),
    )
    if direct is not None and not isinstance(direct, dict):
        return to_text(direct)

    parts: List[str] = []

    # inning1 / inngs1 / inning2 ...
    for prefix in inning_prefixes:
        inning = score_block.get(prefix)
        if isinstance(inning, dict):
            runs = pick_first(inning.get("runs"), inning.get("score"))
            wickets = pick_first(inning.get("wickets"), inning.get("wkts"))
            overs = inning.get("overs")

            part = None
            if runs is not None and wickets is not None:
                part = f"{runs}/{wickets}"
            elif runs is not None:
                part = str(runs)

            if part and overs is not None:
                part = f"{part} ({overs})"

            if part:
                parts.append(part)

    if parts:
        return " | ".join(parts)

    # fallback: vše rozumně zploštit
    try:
        return json.dumps(score_block, ensure_ascii=False)
    except Exception:
        return to_text(score_block)


def extract_fixture_row(raw_payload_id: int, payload_row: Dict[str, Any], block: Dict[str, Any]) -> Optional[Tuple]:
    """
    Z jednoho match bloku vytáhne row pro stg_provider_fixtures.
    """
    match_info = block.get("matchInfo") if isinstance(block.get("matchInfo"), dict) else block
    match_score = block.get("matchScore") if isinstance(block.get("matchScore"), dict) else block.get("score")

    external_fixture_id = to_text(
        pick_first(
            dig(match_info, ["matchId"]),
            dig(match_info, ["match_id"]),
            block.get("matchId"),
            block.get("match_id"),
        )
    )
    if not external_fixture_id:
        return None

    external_league_id = to_text(
        pick_first(
            dig(match_info, ["seriesId"]),
            dig(match_info, ["series", "id"]),
            dig(match_info, ["leagueId"]),
            payload_row.get("external_id"),
        )
    )

    season = to_text(
        pick_first(
            payload_row.get("season"),
            dig(match_info, ["season"]),
            dig(match_info, ["seriesSeason"]),
            dig(match_info, ["series", "season"]),
        )
    )

    team1 = pick_first(
        dig(match_info, ["team1"]),
        block.get("team1"),
    )
    team2 = pick_first(
        dig(match_info, ["team2"]),
        block.get("team2"),
    )

    home_team_external_id = extract_team_id(team1) or extract_team_name(team1)
    away_team_external_id = extract_team_id(team2) or extract_team_name(team2)

    fixture_date = parse_datetime_safe(
        pick_first(
            dig(match_info, ["startDate"]),
            dig(match_info, ["startDateTime"]),
            dig(match_info, ["matchStartTimestamp"]),
            dig(match_info, ["date"]),
            dig(match_info, ["start_time"]),
            block.get("startDate"),
        )
    )

    status_text = to_text(
        pick_first(
            dig(match_info, ["status"]),
            dig(match_info, ["state"]),
            dig(match_info, ["matchDesc"]),
            block.get("status"),
        )
    )

    # Score blocks bývají team1Score / team2Score apod.
    home_score = extract_score(
        pick_first(
            dig(match_score, ["team1Score"]),
            dig(match_score, ["team1"]),
            dig(match_info, ["team1Score"]),
        ),
        inning_prefixes=("inngs1", "inngs2", "inning1", "inning2"),
    )

    away_score = extract_score(
        pick_first(
            dig(match_score, ["team2Score"]),
            dig(match_score, ["team2"]),
            dig(match_info, ["team2Score"]),
        ),
        inning_prefixes=("inngs1", "inngs2", "inning1", "inning2"),
    )

    return (
        PROVIDER,
        SPORT_CODE,
        external_fixture_id,
        external_league_id,
        season,
        home_team_external_id,
        away_team_external_id,
        fixture_date,
        status_text,
        home_score,
        away_score,
        raw_payload_id,
    )


# ---------------------------------------------------------
# DB OPERACE
# ---------------------------------------------------------
def fetch_pending_payloads(conn) -> List[Dict[str, Any]]:
    sql = """
        SELECT
            id,
            provider,
            sport_code,
            entity_type,
            endpoint_name,
            external_id,
            season,
            payload_json,
            parse_status,
            parse_message
        FROM staging.stg_api_payloads
        WHERE provider = %s
          AND sport_code = %s
          AND entity_type = %s
          AND parse_status = 'pending'
        ORDER BY id;
    """
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(sql, (PROVIDER, SPORT_CODE, ENTITY_TYPE))
        return list(cur.fetchall())


def upsert_fixtures(conn, rows: List[Tuple]) -> int:
    """
    Delete + insert podle přirozeného business klíče:
    provider + sport_code + external_fixture_id

    staging.stg_provider_fixtures má PK jen přes id,
    proto nejdeme přes ON CONFLICT, ale přes delete+insert.
    """
    if not rows:
        return 0

    unique_keys = sorted({(r[0], r[1], r[2]) for r in rows})

    with conn.cursor() as cur:
        # DELETE existujících řádků přes USING (VALUES ...)
        delete_sql = """
            DELETE FROM staging.stg_provider_fixtures t
            USING (VALUES %s) AS src(provider, sport_code, external_fixture_id)
            WHERE t.provider = src.provider
              AND t.sport_code = src.sport_code
              AND t.external_fixture_id = src.external_fixture_id;
        """
        execute_values(
            cur,
            delete_sql,
            unique_keys,
            template="(%s,%s,%s)"
        )

        insert_sql = """
            INSERT INTO staging.stg_provider_fixtures (
                provider,
                sport_code,
                external_fixture_id,
                external_league_id,
                season,
                home_team_external_id,
                away_team_external_id,
                fixture_date,
                status_text,
                home_score,
                away_score,
                raw_payload_id
            ) VALUES %s;
        """
        execute_values(
            cur,
            insert_sql,
            rows,
            template="(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"
        )

    return len(rows)


def mark_payload_success(conn, payload_id: int, message: str) -> None:
    sql = """
        UPDATE staging.stg_api_payloads
        SET parse_status = 'parsed',
            parse_message = %s
        WHERE id = %s;
    """
    with conn.cursor() as cur:
        cur.execute(sql, (message[:1000], payload_id))


def mark_payload_error(conn, payload_id: int, message: str) -> None:
    sql = """
        UPDATE staging.stg_api_payloads
        SET parse_status = 'error',
            parse_message = %s
        WHERE id = %s;
    """
    with conn.cursor() as cur:
        cur.execute(sql, (message[:1000], payload_id))


# ---------------------------------------------------------
# MAIN
# ---------------------------------------------------------
def main() -> int:
    load_environment()

    print("======================================")
    print("MATCHMATRIX CRICKET FIXTURES PARSER")
    print("======================================")
    print(f"PROVIDER   : {PROVIDER}")
    print(f"SPORT_CODE : {SPORT_CODE}")
    print(f"ENTITY     : {ENTITY_TYPE}")

    conn = get_db_connection()
    conn.autocommit = False

    processed_payloads = 0
    parsed_payloads = 0
    error_payloads = 0
    inserted_rows_total = 0

    try:
        payloads = fetch_pending_payloads(conn)
        print(f"PENDING PAYLOADS: {len(payloads)}")

        for payload_row in payloads:
            payload_id = payload_row["id"]
            print("--------------------------------------")
            print(f"PAYLOAD_ID : {payload_id}")
            print(f"ENDPOINT   : {payload_row.get('endpoint_name')}")

            try:
                payload_json = payload_row["payload_json"]
                match_blocks = find_match_blocks(payload_json)

                print(f"MATCH BLOCKS FOUND: {len(match_blocks)}")

                rows: List[Tuple] = []
                seen_fixture_ids = set()

                for block in match_blocks:
                    row = extract_fixture_row(payload_id, payload_row, block)
                    if not row:
                        continue

                    fixture_id = row[2]
                    if fixture_id in seen_fixture_ids:
                        continue

                    seen_fixture_ids.add(fixture_id)
                    rows.append(row)

                inserted = upsert_fixtures(conn, rows)
                message = f"OK | match_blocks={len(match_blocks)} | inserted={inserted}"

                mark_payload_success(conn, payload_id, message)
                conn.commit()

                processed_payloads += 1
                parsed_payloads += 1
                inserted_rows_total += inserted

                print(message)

            except Exception as exc:
                conn.rollback()

                # druhý pokus jen pro update error stavu
                try:
                    mark_payload_error(conn, payload_id, f"ERROR | {type(exc).__name__}: {exc}")
                    conn.commit()
                except Exception:
                    conn.rollback()

                processed_payloads += 1
                error_payloads += 1
                print(f"ERROR: payload_id={payload_id} | {type(exc).__name__}: {exc}")

        print("======================================")
        print("PARSER DONE")
        print("======================================")
        print(f"PROCESSED       : {processed_payloads}")
        print(f"PARSED          : {parsed_payloads}")
        print(f"ERROR           : {error_payloads}")
        print(f"INSERTED ROWS   : {inserted_rows_total}")
        return 0

    except Exception as exc:
        conn.rollback()
        print(f"FATAL ERROR: {type(exc).__name__}: {exc}")
        return 1

    finally:
        conn.close()


if __name__ == "__main__":
    sys.exit(main())