# -*- coding: utf-8 -*-
"""
parse_api_cricket_teams_v1.py
---------------------------------------------------------
CRICKET teams parser
Tok:
    staging.stg_api_payloads
        -> parse cricket teams
        -> staging.stg_provider_teams
        -> update parse_status / parse_message zpět do stg_api_payloads
"""

from __future__ import annotations

import os
import sys
from typing import Any, Dict, Iterable, List, Optional, Tuple

import psycopg2
from psycopg2.extras import RealDictCursor, execute_values

try:
    from dotenv import load_dotenv
except ImportError:
    load_dotenv = None


PROVIDER = "api_cricket"
SPORT_CODE = "CK"
ENTITY_TYPE = "teams"

DEFAULT_ENV_PATH = r"C:\MatchMatrix-platform\ingest\API-Cricket\.env"


def load_environment() -> None:
    if load_dotenv and os.path.exists(DEFAULT_ENV_PATH):
        load_dotenv(DEFAULT_ENV_PATH)


def get_db_connection():
    return psycopg2.connect(
        host=os.getenv("PGHOST", "localhost"),
        port=int(os.getenv("PGPORT", "5432")),
        dbname=os.getenv("PGDATABASE", "matchmatrix"),
        user=os.getenv("PGUSER", "matchmatrix"),
        password=os.getenv("PGPASSWORD", "matchmatrix_pass"),
    )


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


def walk_dicts(obj: Any) -> Iterable[Dict[str, Any]]:
    if isinstance(obj, dict):
        yield obj
        for value in obj.values():
            yield from walk_dicts(value)
    elif isinstance(obj, list):
        for item in obj:
            yield from walk_dicts(item)


def looks_like_team_block(d: Dict[str, Any]) -> bool:
    keys = set(d.keys())

    if "teamId" in keys and ("teamName" in keys or "name" in keys):
        return True

    signals = 0
    if "teamId" in keys or "id" in keys:
        signals += 1
    if "teamName" in keys or "name" in keys or "shortName" in keys:
        signals += 1
    if "imageId" in keys or "image" in keys:
        signals += 1
    if "countryName" in keys or "country" in keys:
        signals += 1

    return signals >= 2


def find_team_blocks(payload: Any) -> List[Dict[str, Any]]:
    blocks: List[Dict[str, Any]] = []
    for d in walk_dicts(payload):
        if looks_like_team_block(d):
            blocks.append(d)
    return blocks


def build_logo_url(team_block: Dict[str, Any]) -> Optional[str]:
    image_id = pick_first(
        team_block.get("imageId"),
        team_block.get("image_id"),
        team_block.get("image"),
    )
    image_id = to_text(image_id)
    if not image_id:
        return None

    # Cricbuzz image CDN fallback pattern
    return f"https://static.cricbuzz.com/a/img/v1/152x152/i1/c{image_id}/team-logo.jpg"


def extract_team_row(raw_payload_id: int, block: Dict[str, Any]) -> Optional[Tuple]:
    provider_team_id = to_text(
        pick_first(
            block.get("teamId"),
            block.get("id"),
            block.get("team_id"),
        )
    )
    if not provider_team_id:
        return None

    team_name = to_text(
        pick_first(
            block.get("teamName"),
            block.get("name"),
            block.get("shortName"),
        )
    )
    if not team_name:
        return None

    team_code = to_text(
        pick_first(
            block.get("teamSName"),
            block.get("shortName"),
            block.get("abbr"),
            block.get("code"),
        )
    )

    city = to_text(
        pick_first(
            block.get("city"),
            block.get("location"),
        )
    )

    country_name = to_text(
        pick_first(
            block.get("countryName"),
            block.get("country"),
        )
    )

    logo_url = build_logo_url(block)

    return (
        PROVIDER,
        SPORT_CODE,
        provider_team_id,
        team_name,
        team_code,
        city,
        None,       # coach
        None,       # owner
        None,       # stadium
        None,       # established
        logo_url,
        country_name,
        None,       # country_code
        None,       # country_flag_url
        raw_payload_id,
    )


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


def upsert_teams(conn, rows: List[Tuple]) -> int:
    if not rows:
        return 0

    unique_keys = sorted({(r[0], r[2]) for r in rows})  # provider, provider_team_id

    with conn.cursor() as cur:
        delete_sql = """
            DELETE FROM staging.stg_provider_teams t
            USING (VALUES %s) AS src(provider, provider_team_id)
            WHERE t.provider = src.provider
              AND t.provider_team_id = src.provider_team_id;
        """
        execute_values(
            cur,
            delete_sql,
            unique_keys,
            template="(%s,%s)"
        )

        insert_sql = """
            INSERT INTO staging.stg_provider_teams (
                provider,
                sport_code,
                provider_team_id,
                team_name,
                team_code,
                city,
                coach,
                owner,
                stadium,
                established,
                logo_url,
                country_name,
                country_code,
                country_flag_url,
                raw_json
            ) VALUES %s;
        """
        # stg_provider_teams má 12 sloupců podle exportu, ale reálný detail tu nemáme celý.
        # Bezpečně použijeme raw insert přes explicitní mapping v druhé verzi níže.
        # Tato větev se nepoužije.
        raise RuntimeError("Use upsert_teams_v2 instead")


def upsert_teams_v2(conn, rows: List[Tuple], raw_payload_map: Dict[str, Dict[str, Any]]) -> int:
    """
    Upsert do staging.stg_provider_teams podle reálné struktury tabulky.
    Business klíč:
        provider + sport_code + external_team_id
    """
    if not rows:
        return 0

    # row layout:
    # 0 provider
    # 1 sport_code
    # 2 external_team_id
    # 3 team_name
    # 4 team_code     -> nepoužijeme, tabulka ho nemá
    # 5 city          -> nepoužijeme, tabulka ho nemá
    # ...
    # 11 country_name
    # ...
    # raw_payload_id předáváme zvlášť z payloadu
    unique_keys = sorted({(r[0], r[1], r[2]) for r in rows})

    with conn.cursor() as cur:
        delete_sql = """
            DELETE FROM staging.stg_provider_teams t
            USING (VALUES %s) AS src(provider, sport_code, external_team_id)
            WHERE t.provider = src.provider
              AND t.sport_code = src.sport_code
              AND t.external_team_id = src.external_team_id;
        """
        execute_values(
            cur,
            delete_sql,
            unique_keys,
            template="(%s,%s,%s)"
        )

        insert_rows = []
        for row in rows:
            provider = row[0]
            sport_code = row[1]
            external_team_id = row[2]
            team_name = row[3]
            country_name = row[11]
            raw_payload_id = row[14]

            # Pro první verzi zatím external_league_id a season neznáme spolehlivě
            insert_rows.append((
                provider,
                sport_code,
                external_team_id,
                team_name,
                country_name,
                None,           # external_league_id
                None,           # season
                raw_payload_id,
                True            # is_active
            ))

        insert_sql = """
            INSERT INTO staging.stg_provider_teams (
                provider,
                sport_code,
                external_team_id,
                team_name,
                country_name,
                external_league_id,
                season,
                raw_payload_id,
                is_active
            ) VALUES %s;
        """
        execute_values(
            cur,
            insert_sql,
            insert_rows,
            template="(%s,%s,%s,%s,%s,%s,%s,%s,%s)"
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


def main() -> int:
    load_environment()

    print("======================================")
    print("MATCHMATRIX CRICKET TEAMS PARSER")
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
                team_blocks = find_team_blocks(payload_json)

                print(f"TEAM BLOCKS FOUND: {len(team_blocks)}")

                rows: List[Tuple] = []
                raw_payload_map: Dict[str, Dict[str, Any]] = {}
                seen_team_ids = set()

                for block in team_blocks:
                    row = extract_team_row(payload_id, block)
                    if not row:
                        continue

                    team_id = row[2]
                    if team_id in seen_team_ids:
                        continue

                    seen_team_ids.add(team_id)
                    rows.append(row)
                    raw_payload_map[team_id] = block

                inserted = upsert_teams_v2(conn, rows, raw_payload_map)
                message = f"OK | team_blocks={len(team_blocks)} | inserted={inserted}"

                mark_payload_success(conn, payload_id, message)
                conn.commit()

                processed_payloads += 1
                parsed_payloads += 1
                inserted_rows_total += inserted

                print(message)

            except Exception as exc:
                conn.rollback()

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