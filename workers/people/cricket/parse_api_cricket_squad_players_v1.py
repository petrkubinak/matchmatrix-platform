# -*- coding: utf-8 -*-
"""
MATCHMATRIX WORKER
parse_api_cricket_squad_players_v1.py

CO TO JE:
- Parser cricket squad players z RAW payloadů Cricbuzz RapidAPI.

K ČEMU TO JE:
- Převádí hráče z endpointu:
  /series/v1/{series_id}/squads/{squad_id}
  do staging.stg_provider_players.

KDE TO UVIDÍME:
- staging.stg_provider_players
- staging.stg_api_payloads parse_status = parsed/error

JAK SE TO VYUŽIJE:
- Další merge převede cricket hráče do public.players a player_provider_map.
"""

from __future__ import annotations

import os
import sys
from typing import Any, Dict, List, Optional, Tuple

import psycopg2
from psycopg2.extras import RealDictCursor, execute_values
from dotenv import load_dotenv


BASE_DIR = r"C:\MatchMatrix-platform"
ENV_PATH = os.path.join(BASE_DIR, "ingest", "API-Cricket", ".env")

PROVIDER = "api_cricket"
SPORT_CODE = "CK"
ENTITY_TYPE = "players"
ENDPOINT_NAME = "series_v1_squad_players"


def load_environment() -> None:
    if os.path.exists(ENV_PATH):
        load_dotenv(ENV_PATH)


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


def split_name(full_name: str) -> Tuple[Optional[str], Optional[str]]:
    parts = full_name.strip().split()

    if not parts:
        return None, None

    if len(parts) == 1:
        return parts[0], None

    return parts[0], " ".join(parts[1:])


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
          AND endpoint_name = %s
          AND parse_status = 'pending'
        ORDER BY id;
    """

    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(sql, (PROVIDER, SPORT_CODE, ENTITY_TYPE, ENDPOINT_NAME))
        return list(cur.fetchall())


def extract_players(payload_row: Dict[str, Any]) -> List[Tuple]:
    payload = payload_row["payload_json"]

    season = to_text(payload.get("season") or payload_row.get("season"))
    external_team_id = to_text(payload.get("team_id"))
    team_name = to_text(payload.get("squad_name"))
    external_league_id = to_text(payload.get("series_id"))
    league_name = to_text(payload.get("series_name"))

    raw_payload_id = payload_row["id"]

    api_payload = payload.get("payload") or {}
    response = api_payload.get("response") or {}

    players = response.get("player") or []

    rows = []
    seen = set()

    for p in players:
        if not isinstance(p, dict):
            continue

        if p.get("isHeader"):
            continue

        external_player_id = to_text(p.get("id"))
        player_name = to_text(p.get("name"))

        if not external_player_id or not player_name:
            continue

        if external_player_id in seen:
            continue

        seen.add(external_player_id)

        first_name, last_name = split_name(player_name)

        rows.append((
            PROVIDER,
            SPORT_CODE,
            external_player_id,
            player_name,
            None,                       # birth_date
            None,                       # nationality
            external_team_id,
            season,
            raw_payload_id,
            True,                       # is_active
            first_name,
            last_name,
            player_name,                # short_name
            to_text(p.get("role")),      # position_code
            None,                       # height_cm
            None,                       # weight_kg
            None,                       # preferred_foot
            external_league_id,
            team_name,
            league_name,
            ENDPOINT_NAME
        ))

    return rows


def upsert_players(conn, rows: List[Tuple]) -> int:
    if not rows:
        return 0

    keys = sorted({(r[0], r[1], r[2], r[17], r[6], r[7]) for r in rows})
    # provider, sport_code, external_player_id, external_league_id, external_team_id, season

    with conn.cursor() as cur:
        delete_sql = """
            DELETE FROM staging.stg_provider_players t
            USING (VALUES %s) AS src(
                provider,
                sport_code,
                external_player_id,
                external_league_id,
                external_team_id,
                season
            )
            WHERE t.provider = src.provider
              AND t.sport_code = src.sport_code
              AND t.external_player_id = src.external_player_id
              AND COALESCE(t.external_league_id, '') = COALESCE(src.external_league_id, '')
              AND COALESCE(t.external_team_id, '') = COALESCE(src.external_team_id, '')
              AND COALESCE(t.season, '') = COALESCE(src.season, '');
        """

        execute_values(
            cur,
            delete_sql,
            keys,
            template="(%s,%s,%s,%s,%s,%s)"
        )

        insert_sql = """
            INSERT INTO staging.stg_provider_players (
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
                source_endpoint
            )
            VALUES %s;
        """

        execute_values(
            cur,
            insert_sql,
            rows,
            template="(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"
        )

    return len(rows)


def mark_payload_success(conn, payload_id: int, message: str) -> None:
    with conn.cursor() as cur:
        cur.execute(
            """
            UPDATE staging.stg_api_payloads
            SET parse_status = 'parsed',
                parse_message = %s
            WHERE id = %s;
            """,
            (message[:1000], payload_id),
        )


def mark_payload_error(conn, payload_id: int, message: str) -> None:
    with conn.cursor() as cur:
        cur.execute(
            """
            UPDATE staging.stg_api_payloads
            SET parse_status = 'error',
                parse_message = %s
            WHERE id = %s;
            """,
            (message[:1000], payload_id),
        )


def main() -> int:
    load_environment()

    print("=" * 80)
    print("MATCHMATRIX CK SQUAD PLAYERS PARSER V1")
    print("=" * 80)

    conn = get_db_connection()
    conn.autocommit = False

    processed = 0
    parsed = 0
    errors = 0
    inserted_total = 0

    try:
        payloads = fetch_pending_payloads(conn)

        print("PENDING PAYLOADS:", len(payloads))

        for payload_row in payloads:
            payload_id = payload_row["id"]

            print("-" * 80)
            print("PAYLOAD_ID:", payload_id)
            print("SQUAD_ID  :", payload_row.get("external_id"))

            try:
                rows = extract_players(payload_row)
                inserted = upsert_players(conn, rows)

                mark_payload_success(
                    conn,
                    payload_id,
                    f"OK | players_inserted={inserted}"
                )

                conn.commit()

                processed += 1
                parsed += 1
                inserted_total += inserted

                print("OK | inserted:", inserted)

            except Exception as exc:
                conn.rollback()

                try:
                    mark_payload_error(
                        conn,
                        payload_id,
                        f"ERROR | {type(exc).__name__}: {exc}"
                    )
                    conn.commit()
                except Exception:
                    conn.rollback()

                processed += 1
                errors += 1

                print("ERROR:", type(exc).__name__, exc)

        print("=" * 80)
        print("DONE")
        print("PROCESSED      :", processed)
        print("PARSED         :", parsed)
        print("ERRORS         :", errors)
        print("INSERTED TOTAL :", inserted_total)
        print("=" * 80)

        return 0

    except Exception as exc:
        conn.rollback()
        print("FATAL ERROR:", type(exc).__name__, exc)
        return 1

    finally:
        conn.close()


if __name__ == "__main__":
    sys.exit(main())