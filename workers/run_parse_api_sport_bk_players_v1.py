# ============================================================
# run_parse_api_sport_bk_players_v1.py
# MatchMatrix - API-Sport Basketball Players Parser V1
#
# Kam uložit:
# C:\MatchMatrix-platform\workers\run_parse_api_sport_bk_players_v1.py
#
# Co dělá:
# - čte staging.stg_api_payloads
# - provider=api_sport, sport_code=basketball, entity_type=players
# - parsuje response[] do staging.stg_provider_players
# - nepoužívá raw_json, protože staging.stg_provider_players tento sloupec nemá
#
# Spuštění:
# C:\Python314\python.exe C:\MatchMatrix-platform\workers\run_parse_api_sport_bk_players_v1.py
# ============================================================

from __future__ import annotations

import json
from datetime import datetime
from typing import Any

import psycopg2
from psycopg2.extras import RealDictCursor, execute_values


DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}

PROVIDER = "api_sport"
SPORT_CODE = "basketball"
ENTITY_TYPE = "players"


def log(message: str) -> None:
    print(f"[{datetime.now().strftime('%H:%M:%S')}] {message}", flush=True)


def get_conn():
    return psycopg2.connect(**DB_CONFIG)


def safe_text(value: Any) -> str | None:
    if value is None:
        return None
    text = str(value).strip()
    return text if text else None


def safe_int(value: Any) -> int | None:
    if value is None:
        return None
    text = str(value).strip().replace("cm", "").replace("kg", "").strip()
    try:
        return int(float(text))
    except Exception:
        return None


def load_payloads(conn):
    sql = """
        SELECT
            id,
            provider,
            sport_code,
            entity_type,
            endpoint_name,
            external_id,
            season,
            payload_json
        FROM staging.stg_api_payloads
        WHERE provider = %s
          AND sport_code = %s
          AND entity_type = %s
          AND endpoint_name = 'players'
          AND COALESCE(parse_status, 'pending') IN ('pending', 'error')
        ORDER BY id;
    """

    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(sql, (PROVIDER, SPORT_CODE, ENTITY_TYPE))
        return cur.fetchall()


def mark_payload(conn, payload_id: int, status: str, message: str | None = None):
    sql = """
        UPDATE staging.stg_api_payloads
        SET
            parse_status = %s,
            parse_message = %s
        WHERE id = %s;
    """

    with conn.cursor() as cur:
        cur.execute(sql, (status, message, payload_id))


def get_team_context(conn, team_id: str, season: str):
    sql = """
        SELECT
            external_league_id,
            team_name
        FROM staging.stg_provider_teams
        WHERE provider = %s
          AND sport_code = %s
          AND external_team_id = %s
          AND season = %s
        ORDER BY id DESC
        LIMIT 1;
    """

    with conn.cursor() as cur:
        cur.execute(sql, (PROVIDER, SPORT_CODE, team_id, season))
        row = cur.fetchone()

    if not row:
        return None, None

    return safe_text(row[0]), safe_text(row[1])


def normalize_player_item(item: dict, payload_row: dict, external_league_id: str | None, team_name: str | None):
    raw_payload_id = int(payload_row["id"])
    season = safe_text(payload_row["season"])
    team_external_id = safe_text(payload_row["external_id"])

    player_id = (
        item.get("id")
        or item.get("player", {}).get("id")
        or item.get("player_id")
    )

    player_name = (
        item.get("name")
        or item.get("player", {}).get("name")
        or item.get("firstname")
        or item.get("lastname")
    )

    if not player_id or not player_name:
        return None

    first_name = (
        item.get("firstname")
        or item.get("first_name")
        or item.get("player", {}).get("firstname")
    )

    last_name = (
        item.get("lastname")
        or item.get("last_name")
        or item.get("player", {}).get("lastname")
    )

    short_name = (
        item.get("short_name")
        or item.get("short")
        or item.get("player", {}).get("short_name")
    )

    nationality = (
        item.get("nationality")
        or item.get("country")
        or item.get("player", {}).get("nationality")
    )

    birth_obj = item.get("birth") if isinstance(item.get("birth"), dict) else {}
    birth_date = (
        birth_obj.get("date")
        or item.get("birthdate")
        or item.get("birth_date")
        or item.get("date")
    )

    position_code = (
        item.get("position")
        or item.get("pos")
        or item.get("player", {}).get("position")
    )

    height_cm = (
        safe_int(item.get("height"))
        or safe_int(item.get("player", {}).get("height"))
    )

    weight_kg = (
        safe_int(item.get("weight"))
        or safe_int(item.get("player", {}).get("weight"))
    )

    return (
        PROVIDER,                        # provider
        SPORT_CODE,                      # sport_code
        safe_text(player_id),             # external_player_id
        safe_text(player_name),           # player_name
        safe_text(birth_date),            # birth_date
        safe_text(nationality),           # nationality
        team_external_id,                 # external_team_id
        season,                           # season
        raw_payload_id,                   # raw_payload_id
        True,                             # is_active
        safe_text(first_name),            # first_name
        safe_text(last_name),             # last_name
        safe_text(short_name),            # short_name
        safe_text(position_code),         # position_code
        height_cm,                        # height_cm
        weight_kg,                        # weight_kg
        None,                             # preferred_foot
        external_league_id,               # external_league_id
        team_name,                        # team_name
        None,                             # league_name
        "/players",                       # source_endpoint
    )


def extract_player_rows(conn, payload_row: dict):
    payload = payload_row["payload_json"]

    if isinstance(payload, str):
        payload = json.loads(payload)

    response = payload.get("response", []) or []
    team_id = safe_text(payload_row["external_id"])
    season = safe_text(payload_row["season"])

    external_league_id, team_name = get_team_context(
        conn=conn,
        team_id=str(team_id),
        season=str(season),
    )

    rows = []

    for item in response:
        if not isinstance(item, dict):
            continue

        row = normalize_player_item(
            item=item,
            payload_row=payload_row,
            external_league_id=external_league_id,
            team_name=team_name,
        )

        if row:
            rows.append(row)

    return rows


def insert_players(conn, rows):
    if not rows:
        return 0

    sql = """
        INSERT INTO staging.stg_provider_players
        (
            provider,
            sport_code,
            external_player_id,
            player_name,
            birth_date,
            nationality,
            external_team_id,
            season,
            raw_payload_id,
            is_active,
            first_name,
            last_name,
            short_name,
            position_code,
            height_cm,
            weight_kg,
            preferred_foot,
            external_league_id,
            team_name,
            league_name,
            source_endpoint,
            created_at,
            updated_at
        )
        VALUES %s
        ON CONFLICT (provider, external_player_id)
        DO UPDATE SET
            sport_code = EXCLUDED.sport_code,
            player_name = EXCLUDED.player_name,
            birth_date = EXCLUDED.birth_date,
            nationality = EXCLUDED.nationality,
            external_team_id = EXCLUDED.external_team_id,
            season = EXCLUDED.season,
            raw_payload_id = EXCLUDED.raw_payload_id,
            is_active = EXCLUDED.is_active,
            first_name = EXCLUDED.first_name,
            last_name = EXCLUDED.last_name,
            short_name = EXCLUDED.short_name,
            position_code = EXCLUDED.position_code,
            height_cm = EXCLUDED.height_cm,
            weight_kg = EXCLUDED.weight_kg,
            preferred_foot = EXCLUDED.preferred_foot,
            external_league_id = EXCLUDED.external_league_id,
            team_name = EXCLUDED.team_name,
            league_name = EXCLUDED.league_name,
            source_endpoint = EXCLUDED.source_endpoint,
            updated_at = NOW();
    """

    template = """
    (
        %s, %s, %s, %s, %s,
        %s, %s, %s, %s, %s,
        %s, %s, %s, %s, %s,
        %s, %s, %s, %s, %s,
        %s, NOW(), NOW()
    )
    """

    with conn.cursor() as cur:
        execute_values(cur, sql, rows, template=template, page_size=500)

    return len(rows)


def main() -> int:
    log("=" * 80)
    log("MATCHMATRIX PARSE API-SPORT BK PLAYERS V1")
    log("=" * 80)

    conn = get_conn()

    try:
        payloads = load_payloads(conn)
        log(f"Payloads found: {len(payloads)}")

        total_inserted = 0
        errors = 0

        for payload_row in payloads:
            payload_id = int(payload_row["id"])

            try:
                rows = extract_player_rows(conn, payload_row)
                inserted = insert_players(conn, rows)

                mark_payload(
                    conn,
                    payload_id,
                    "parsed",
                    f"Inserted {inserted} BK players into staging.stg_provider_players.",
                )

                conn.commit()
                total_inserted += inserted
                log(f"payload_id={payload_id} inserted={inserted}")

            except Exception as exc:
                conn.rollback()
                errors += 1

                mark_payload(conn, payload_id, "error", str(exc))
                conn.commit()

                log(f"ERROR payload_id={payload_id}: {exc}")

        log("=" * 80)
        log("SUMMARY")
        log("=" * 80)
        log(f"Payloads processed : {len(payloads)}")
        log(f"Players inserted   : {total_inserted}")
        log(f"Errors             : {errors}")
        log("RESULT             : OK" if errors == 0 else "RESULT             : ERROR")
        log("=" * 80)

        return 0 if errors == 0 else 1

    finally:
        conn.close()


if __name__ == "__main__":
    raise SystemExit(main())