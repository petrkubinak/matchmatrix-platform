# ============================================================================
# parse_api_football_player_profiles_v1.py
# Cíl:
#   Naparsovat payloady z stg_api_payloads do stg_provider_player_profiles
# ============================================================================

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path

import psycopg2
from dotenv import load_dotenv


# =========================
# UTF-8 stdout/stderr
# =========================
try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass


# =========================
# ARGUMENTS
# =========================
def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Parse API-Football player profiles v1")
    parser.add_argument("--provider", default="api_football")
    parser.add_argument("--sport", default="football")
    parser.add_argument("--league-id", dest="league_id", default=None)
    parser.add_argument("--season", default=None)
    parser.add_argument("--run-id", dest="run_id", default=None)
    parser.add_argument("--job-id", dest="job_id", default=None)
    return parser.parse_args()


args = parse_args()


# =========================
# LOAD ENV
# =========================
ENV_PATH = Path(__file__).resolve().parent / "API-Football" / ".env"

if not ENV_PATH.exists():
    raise RuntimeError(f".env nebyl nalezen: {ENV_PATH}")

load_dotenv(dotenv_path=ENV_PATH, override=True)

DB = {
    "host": os.getenv("PGHOST", "localhost"),
    "port": int(os.getenv("PGPORT", "5432")),
    "dbname": os.getenv("PGDATABASE", "matchmatrix"),
    "user": os.getenv("PGUSER", "matchmatrix"),
    "password": os.getenv("PGPASSWORD", "").strip(),
}

if not DB["password"]:
    raise RuntimeError(f"Chybí PGPASSWORD v .env: {ENV_PATH}")


# =========================
# HELPERS
# =========================
def parse_height_cm(value):
    if value is None:
        return None
    text = str(value).strip().lower().replace("cm", "").strip()
    if text == "":
        return None
    try:
        return int(text)
    except Exception:
        return None


def parse_weight_kg(value):
    if value is None:
        return None
    text = str(value).strip().lower().replace("kg", "").strip()
    if text == "":
        return None
    try:
        return int(text)
    except Exception:
        return None


def safe_print(message: str) -> None:
    try:
        print(message)
    except UnicodeEncodeError:
        print(message.encode("utf-8", errors="replace").decode("utf-8", errors="replace"))


# =========================
# CONNECT
# =========================
conn = psycopg2.connect(**DB)
cur = conn.cursor()

# =========================
# LOAD PAYLOADS
# =========================
sql = """
SELECT id, payload_json
FROM staging.stg_api_payloads
WHERE provider = %s
  AND entity_type = 'players'
  AND (parse_status IS NULL OR parse_status = 'pending')
"""

params = [args.provider]

if args.league_id not in (None, ""):
    sql += " AND external_id = %s"
    params.append(str(args.league_id))

if args.season not in (None, ""):
    sql += " AND season = %s"
    params.append(str(args.season))

sql += " ORDER BY id"

cur.execute(sql, params)
rows = cur.fetchall()

safe_print(f"Payloads to process: {len(rows)}")

# =========================
# PARSE LOOP
# =========================
for payload_id, payload_json in rows:
    data = payload_json

    try:
        for item in data.get("response", []):
            player = item.get("player", {}) or {}
            stats = item.get("statistics", []) or []

            for stat in stats:
                team = stat.get("team", {}) or {}
                league = stat.get("league", {}) or {}
                games = stat.get("games", {}) or {}

                cur.execute(
                    """
                    INSERT INTO staging.stg_provider_player_profiles (
                        provider,
                        sport_code,
                        external_player_id,
                        player_name,
                        first_name,
                        last_name,
                        nationality,
                        position_code,
                        height_cm,
                        weight_kg,
                        external_team_id,
                        team_name,
                        external_league_id,
                        league_name,
                        season,
                        is_active,
                        created_at,
                        updated_at
                    )
                    VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,NOW(),NOW())
                    ON CONFLICT DO NOTHING
                    """,
                    (
                        "api_football",
                        "football",
                        str(player.get("id")) if player.get("id") is not None else None,
                        player.get("name"),
                        player.get("firstname"),
                        player.get("lastname"),
                        player.get("nationality"),
                        games.get("position"),
                        parse_height_cm(player.get("height")),
                        parse_weight_kg(player.get("weight")),
                        str(team.get("id")) if team.get("id") is not None else None,
                        team.get("name"),
                        str(league.get("id")) if league.get("id") is not None else None,
                        league.get("name"),
                        str(league.get("season")) if league.get("season") is not None else None,
                        True,
                    ),
                )

        # označit jako parsed
        cur.execute(
            """
            UPDATE staging.stg_api_payloads
            SET parse_status = 'done'
            WHERE id = %s
            """,
            (payload_id,),
        )

        conn.commit()

    except Exception as e:
        conn.rollback()
        safe_print(f"ERROR payload {payload_id}: {str(e)}")

cur.close()
conn.close()

safe_print("DONE")