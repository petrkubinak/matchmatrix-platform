# -*- coding: utf-8 -*-
r"""
parse_api_baseball_teams_to_staging.
py

Kam ulozit:
C:\MatchMatrix-platform\ingest\API-Sport\parse_api_baseball_teams_to_staging.py

Co dela:
1) nacte posledni RAW payload pro api_baseball / baseball / teams ze staging.stg_api_payloads
2) rozparsuje response[]
3) zapise data do staging.stg_provider_teams
4) preskoci nehratelne ligove entity:
   - American League
   - National League
5) vypise diagnostiku DB pripojeni:
   - jaky DSN pouziva
   - current_user
   - current_database
   - prava na schema staging

Spusteni:
C:\Python314\python.exe C:\MatchMatrix-platform\ingest\API-Sport\parse_api_baseball_teams_to_staging.py
"""

from __future__ import annotations

import json
import os
import sys
from typing import Any, Dict, Iterable, List, Optional, Sequence, Tuple

import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv

# nacti projektovy .env
load_dotenv(r"C:\MatchMatrix-platform\.env")


# ------------------------------------------------------------
# Zakladni nastaveni
# ------------------------------------------------------------
PYTHON_TAG = "BSB TEAMS PARSER"
PROVIDER = "api_baseball"
SPORT_CODE = "baseball"
ENTITY_VALUE = "teams"

# Tyto 2 entity nechceme ve stg_provider_teams jako hratelne tymy
NON_PLAYABLE_NAMES = {
    "american league",
    "national league",
}


# ------------------------------------------------------------
# DB pripojeni
# ------------------------------------------------------------
def get_dsn() -> str:
    """
    Vrati korektni PostgreSQL DSN.

    Podporuje:
    - normalni DSN: host=... port=... dbname=... user=... password=...
    - Windows env format: set DB_DSN=host=... port=... dbname=... user=... password=...
    """
    raw = os.environ.get("DB_DSN", "").strip()

    if raw:
        lowered = raw.lower()

        if lowered.startswith("set db_dsn="):
            raw = raw.split("=", 1)[1].strip()
        elif lowered.startswith("db_dsn="):
            raw = raw.split("=", 1)[1].strip()

        if raw:
            return raw

    # fallback pro lokalni beh
    return "host=localhost port=5432 dbname=matchmatrix user=matchmatrix password=matchmatrix_pass"


def get_conn():
    dsn = get_dsn()
    print(f"[{PYTHON_TAG}] DB_DSN used: {dsn}")
    return psycopg2.connect(dsn)


# ------------------------------------------------------------
# Pomocne utility
# ------------------------------------------------------------
def log(msg: str) -> None:
    print(f"[{PYTHON_TAG}] {msg}")


def norm_text(value: Any) -> Optional[str]:
    if value is None:
        return None
    text = str(value).strip()
    return text if text else None


def lower_text(value: Any) -> str:
    return str(value or "").strip().lower()


# ------------------------------------------------------------
# RAW payload load
# ------------------------------------------------------------
def get_table_columns(conn, schema_name: str, table_name: str) -> List[str]:
    sql = """
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = %s
      AND table_name = %s
    ORDER BY ordinal_position
    """
    with conn.cursor() as cur:
        cur.execute(sql, (schema_name, table_name))
        rows = cur.fetchall()

    return [r[0] for r in rows]


def pick_column(available: Sequence[str], candidates: Sequence[str]) -> Optional[str]:
    available_set = set(available)
    for c in candidates:
        if c in available_set:
            return c
    return None


def fetch_latest_baseball_teams_payload(conn) -> Dict[str, Any]:
    """
    Nacte posledni RAW payload pro baseball teams
    z tabulky staging.stg_api_payloads a sam si zjisti
    spravne nazvy sloupcu.
    """
    cols = get_table_columns(conn, "staging", "stg_api_payloads")
    log(f"stg_api_payloads columns: {', '.join(cols)}")

    if not cols:
        raise RuntimeError("Tabulka staging.stg_api_payloads nema dohledatelne sloupce.")

    provider_col = pick_column(cols, ["provider"])
    sport_col = pick_column(cols, ["sport_code", "sport"])
    entity_col = pick_column(cols, ["entity", "entity_type"])
    payload_col = pick_column(cols, ["payload_json", "payload", "raw_payload"])
    season_col = pick_column(cols, ["season"])
    id_col = pick_column(cols, ["id"])
    created_col = pick_column(cols, ["created_at"])

    if not provider_col:
        raise RuntimeError("V staging.stg_api_payloads chybi sloupec provider.")
    if not sport_col:
        raise RuntimeError("V staging.stg_api_payloads chybi sloupec sport_code/sport.")
    if not entity_col:
        raise RuntimeError("V staging.stg_api_payloads chybi sloupec entity/entity_type.")
    if not payload_col:
        raise RuntimeError("V staging.stg_api_payloads chybi sloupec payload_json/payload/raw_payload.")
    if not id_col:
        raise RuntimeError("V staging.stg_api_payloads chybi sloupec id.")

    sql = f"""
    SELECT *
    FROM staging.stg_api_payloads
    WHERE {provider_col} = %s
      AND {sport_col} = %s
      AND {entity_col} = %s
    ORDER BY {id_col} DESC
    LIMIT 1
    """

    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(sql, (PROVIDER, SPORT_CODE, ENTITY_VALUE))
        row = cur.fetchone()

    if not row:
        raise RuntimeError("Nenalezen zadny RAW payload pro api_baseball / baseball / teams.")

    payload_value = row.get(payload_col)
    if payload_value is None:
        raise RuntimeError("Posledni RAW payload ma prazdny payload JSON.")

    if isinstance(payload_value, str):
        payload = json.loads(payload_value)
    else:
        payload = payload_value

    if not isinstance(payload, dict):
        raise RuntimeError("Payload nema ocekavanou JSON object strukturu.")

    row["_payload_json_parsed"] = payload
    row["_season_col_name"] = season_col
    row["_created_col_name"] = created_col
    return row
    
# ------------------------------------------------------------
# Parse
# ------------------------------------------------------------
def extract_team_rows(raw_row: Dict[str, Any]) -> List[Dict[str, Any]]:
    payload = raw_row["_payload_json_parsed"]

    errors = payload.get("errors")
    if errors not in (None, [], {}):
        raise RuntimeError(f"RAW payload obsahuje API errors: {errors}")

    response = payload.get("response", [])
    if not isinstance(response, list):
        raise RuntimeError("payload.response neni list.")

    raw_payload_id = raw_row.get("id")
    season = raw_row.get("season")

    prepared: List[Dict[str, Any]] = []

    for item in response:
        if not isinstance(item, dict):
            continue

        external_team_id = norm_text(item.get("id"))
        team_name = norm_text(item.get("name"))

        country = item.get("country") or {}
        country_name = None
        if isinstance(country, dict):
            country_name = norm_text(country.get("name"))

        if not external_team_id or not team_name:
            continue

        prepared.append(
            {
                "provider": PROVIDER,
                "sport_code": SPORT_CODE,
                "external_team_id": external_team_id,
                "team_name": team_name,
                "country_name": country_name,
                "external_league_id": "1",   # MLB
                "season": norm_text(season),
                "raw_payload_id": raw_payload_id,
                "is_active": True,
            }
        )

    return prepared


def split_playable_and_non_playable(
    rows: Iterable[Dict[str, Any]]
) -> Tuple[List[Dict[str, Any]], List[Dict[str, Any]]]:
    playable: List[Dict[str, Any]] = []
    skipped: List[Dict[str, Any]] = []

    for row in rows:
        team_name_l = lower_text(row.get("team_name"))
        if team_name_l in NON_PLAYABLE_NAMES:
            skipped.append(row)
        else:
            playable.append(row)

    return playable, skipped


# ------------------------------------------------------------
# Write to staging
# ------------------------------------------------------------
def upsert_stg_provider_teams(conn, rows: Sequence[Dict[str, Any]]) -> int:
    if not rows:
        return 0

    season = rows[0]["season"]
    league_id = rows[0]["external_league_id"]

    delete_sql = """
    DELETE FROM staging.stg_provider_teams
    WHERE provider = %s
      AND sport_code = %s
      AND external_league_id = %s
      AND season = %s
    """

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
    )
    VALUES (
        %(provider)s,
        %(sport_code)s,
        %(external_team_id)s,
        %(team_name)s,
        %(country_name)s,
        %(external_league_id)s,
        %(season)s,
        %(raw_payload_id)s,
        %(is_active)s
    )
    """

    with conn.cursor() as cur:
        cur.execute(delete_sql, (PROVIDER, SPORT_CODE, league_id, season))
        cur.executemany(insert_sql, rows)

    return len(rows)


# ------------------------------------------------------------
# Main
# ------------------------------------------------------------
def main() -> int:
    conn = None
    try:
        conn = get_conn()
        conn.autocommit = False

        with conn.cursor() as cur:
            cur.execute("""
                SELECT
                    current_user,
                    current_database(),
                    has_schema_privilege(current_user, 'staging', 'USAGE') AS has_usage,
                    has_schema_privilege(current_user, 'staging', 'CREATE') AS has_create
            """)
            db_diag = cur.fetchone()
            log(
                f"DB DIAG: user={db_diag[0]} | db={db_diag[1]} | "
                f"usage={db_diag[2]} | create={db_diag[3]}"
            )

        log("Start parseru raw -> staging pro baseball teams")

        raw_row = fetch_latest_baseball_teams_payload(conn)
        payload = raw_row["_payload_json_parsed"]

        results = payload.get("results")
        log(f"RAW payload nalezen | id={raw_row.get('id')} | results={results}")

        all_rows = extract_team_rows(raw_row)
        playable_rows, skipped_rows = split_playable_and_non_playable(all_rows)

        inserted_count = upsert_stg_provider_teams(conn, playable_rows)
        conn.commit()

        log(f"Celkem rozparsovano: {len(all_rows)}")
        log(f"Preskoceno non-playable: {len(skipped_rows)}")
        if skipped_rows:
            for row in skipped_rows:
                log(
                    f"SKIP non-playable: {row['team_name']} "
                    f"(external_team_id={row['external_team_id']})"
                )

        log(f"Vlozeno do staging.stg_provider_teams: {inserted_count}")
        log("Hotovo OK")
        return 0

    except Exception as exc:
        if conn is not None:
            conn.rollback()
        log(f"CHYBA: {exc}")
        return 1

    finally:
        if conn is not None:
            conn.close()


if __name__ == "__main__":
    sys.exit(main())