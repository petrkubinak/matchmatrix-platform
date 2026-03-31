from __future__ import annotations

import argparse
import json
import os
from datetime import datetime, timezone
from typing import Any

import psycopg2
import psycopg2.extras

DB_CONFIG = {
    "host": os.getenv("POSTGRES_HOST", "localhost"),
    "port": int(os.getenv("POSTGRES_PORT", "5432")),
    "dbname": os.getenv("POSTGRES_DB", "matchmatrix"),
    "user": os.getenv("POSTGRES_USER", "matchmatrix"),
    "password": os.getenv("POSTGRES_PASSWORD", "matchmatrix_pass"),
}

PROVIDER = "api_hockey"
SPORT_CODE = "HK"
ENTITY = "players"
PAYLOAD_TABLE = "staging.stg_api_payloads"
TARGET_TABLE = "staging.stg_provider_players"


def now_utc() -> datetime:
    return datetime.now(timezone.utc)


def get_connection():
    return psycopg2.connect(**DB_CONFIG)


def get_existing_columns(schema: str, table: str) -> list[str]:
    sql = """
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = %s AND table_name = %s
        ORDER BY ordinal_position
    """
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(sql, (schema, table))
            return [row[0] for row in cur.fetchall()]


def get_target_pk_or_unique_key(schema: str, table: str) -> list[str]:
    sql = """
        SELECT kcu.column_name
        FROM information_schema.table_constraints tc
        JOIN information_schema.key_column_usage kcu
          ON tc.constraint_name = kcu.constraint_name
         AND tc.table_schema = kcu.table_schema
         AND tc.table_name = kcu.table_name
        WHERE tc.table_schema = %s
          AND tc.table_name = %s
          AND tc.constraint_type IN ('PRIMARY KEY', 'UNIQUE')
        ORDER BY CASE WHEN tc.constraint_type='PRIMARY KEY' THEN 0 ELSE 1 END, kcu.ordinal_position
    """
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(sql, (schema, table))
            return [row[0] for row in cur.fetchall()]


def fetch_payload_rows(payload_id: int | None, limit: int) -> list[dict[str, Any]]:
    candidates = [
        "payload_json",
        "payload",
        "raw_payload",
        "response_json",
    ]
    existing = get_existing_columns("staging", "stg_api_payloads")
    json_col = next((c for c in candidates if c in existing), None)
    if json_col is None:
        raise RuntimeError("staging.stg_api_payloads exists but no JSON payload column was found.")

    filters = ["provider = %s", "entity = %s"]
    params: list[Any] = [PROVIDER, ENTITY]
    if "sport_code" in existing:
        filters.append("sport_code = %s")
        params.append(SPORT_CODE)
    if payload_id is not None and "id" in existing:
        filters.append("id = %s")
        params.append(payload_id)

    sql = f"""
        SELECT id, {json_col} AS payload, source_endpoint, endpoint, season, provider_league_id, provider_team_id
        FROM {PAYLOAD_TABLE}
        WHERE {' AND '.join(filters)}
        ORDER BY id DESC
        LIMIT %s
    """
    params.append(limit)

    with get_connection() as conn:
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute(sql, params)
            return [dict(row) for row in cur.fetchall()]


def pick(source: dict[str, Any], *paths: str) -> Any:
    for path in paths:
        current: Any = source
        ok = True
        for part in path.split("."):
            if isinstance(current, dict) and part in current:
                current = current[part]
            else:
                ok = False
                break
        if ok and current not in (None, "", [], {}):
            return current
    return None


def normalize_int(value: Any) -> int | None:
    if value in (None, ""):
        return None
    try:
        if isinstance(value, str):
            value = value.strip().lower().replace("cm", "").replace("kg", "")
        return int(float(value))
    except Exception:
        return None


def normalize_date(value: Any) -> Any:
    if not value:
        return None
    if isinstance(value, str):
        return value[:10]
    return value


def flatten_player(item: dict[str, Any], payload_row: dict[str, Any]) -> dict[str, Any] | None:
    player = item.get("player") if isinstance(item.get("player"), dict) else item
    team = item.get("team") if isinstance(item.get("team"), dict) else {}
    league = item.get("league") if isinstance(item.get("league"), dict) else {}

    ext_player_id = pick(player, "id", "player_id")
    if ext_player_id is None:
        return None

    first_name = pick(player, "firstname", "first_name")
    last_name = pick(player, "lastname", "last_name")
    full_name = pick(player, "name", "full_name")
    if not full_name:
        full_name = " ".join([part for part in [first_name, last_name] if part]).strip() or str(ext_player_id)

    row = {
        "provider": PROVIDER,
        "sport_code": SPORT_CODE,
        "external_player_id": str(ext_player_id),
        "player_name": full_name,
        "name": full_name,
        "first_name": first_name,
        "last_name": last_name,
        "short_name": pick(player, "short_name"),
        "birth_date": normalize_date(pick(player, "birth.date", "birth_date", "date_of_birth")),
        "nationality": pick(player, "birth.country", "nationality", "country"),
        "position": pick(player, "position", "type"),
        "shirt_number": normalize_int(pick(player, "number", "shirt_number")),
        "height_cm": normalize_int(pick(player, "height", "height_cm")),
        "weight_kg": normalize_int(pick(player, "weight", "weight_kg")),
        "photo_url": pick(player, "photo", "image", "photo_url"),
        "external_team_id": str(pick(team, "id") or payload_row.get("provider_team_id")) if pick(team, "id") or payload_row.get("provider_team_id") else None,
        "team_name": pick(team, "name"),
        "external_league_id": str(pick(league, "id") or payload_row.get("provider_league_id")) if pick(league, "id") or payload_row.get("provider_league_id") else None,
        "league_name": pick(league, "name"),
        "season": str(pick(league, "season") or payload_row.get("season")) if pick(league, "season") or payload_row.get("season") else None,
        "source_endpoint": payload_row.get("source_endpoint") or payload_row.get("endpoint"),
        "raw_payload_id": payload_row.get("id"),
        "raw_json": psycopg2.extras.Json(item),
        "is_active": True,
        "created_at": now_utc(),
        "updated_at": now_utc(),
        "ext_source": PROVIDER,
        "ext_player_id": str(ext_player_id),
    }
    return row


def extract_player_rows(payload_row: dict[str, Any]) -> list[dict[str, Any]]:
    payload = payload_row.get("payload")
    if isinstance(payload, str):
        payload = json.loads(payload)
    if not isinstance(payload, dict):
        return []

    response = payload.get("response")
    if not isinstance(response, list):
        return []

    rows: list[dict[str, Any]] = []
    for item in response:
        if not isinstance(item, dict):
            continue
        row = flatten_player(item, payload_row)
        if row:
            rows.append(row)
    return rows


def upsert_rows(rows: list[dict[str, Any]]) -> int:
    if not rows:
        return 0
    existing_cols = get_existing_columns("staging", "stg_provider_players")
    if not existing_cols:
        raise RuntimeError("staging.stg_provider_players not found.")

    insert_cols = [col for col in existing_cols if col in rows[0]]
    if not insert_cols:
        raise RuntimeError("No compatible columns found in staging.stg_provider_players.")

    unique_cols = [c for c in get_target_pk_or_unique_key("staging", "stg_provider_players") if c in insert_cols and c != "id"]
    if not unique_cols:
        preferred = [
            "provider",
            "external_player_id",
            "season",
            "external_team_id",
        ]
        unique_cols = [c for c in preferred if c in insert_cols]

    values_sql = ", ".join(["%s"] * len(insert_cols))
    update_cols = [c for c in insert_cols if c not in unique_cols]

    sql = f"INSERT INTO {TARGET_TABLE} ({', '.join(insert_cols)}) VALUES ({values_sql})"
    if unique_cols:
        if update_cols:
            sql += (
                f" ON CONFLICT ({', '.join(unique_cols)}) DO UPDATE SET "
                + ", ".join([f"{c} = EXCLUDED.{c}" for c in update_cols])
            )
        else:
            sql += f" ON CONFLICT ({', '.join(unique_cols)}) DO NOTHING"

    payload = [[row.get(col) for col in insert_cols] for row in rows]
    with get_connection() as conn:
        with conn.cursor() as cur:
            psycopg2.extras.execute_batch(cur, sql, payload, page_size=500)
        conn.commit()
    return len(rows)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Parse HK players payloads into staging.stg_provider_players.")
    parser.add_argument("--payload-id", type=int)
    parser.add_argument("--limit", type=int, default=20)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    print("=== MATCHMATRIX: HK PLAYERS PARSE ===")
    payload_rows = fetch_payload_rows(payload_id=args.payload_id, limit=args.limit)
    print(f"payload_rows={len(payload_rows)}")

    total_rows = 0
    for payload_row in payload_rows:
        rows = extract_player_rows(payload_row)
        inserted = upsert_rows(rows)
        total_rows += inserted
        print(f"payload_id={payload_row.get('id')} parsed_rows={len(rows)} upserted_rows={inserted}")

    print(f"TOTAL_UPSERTED={total_rows}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
