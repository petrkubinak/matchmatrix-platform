# ============================================================================
# parse_api_football_player_profiles_v1.py
# Cíl:
#   Naparsovat payloady z stg_api_payloads do stg_provider_player_profiles
# ============================================================================

import os
import json
import psycopg2
from dotenv import load_dotenv
from pathlib import Path

# =========================
# LOAD ENV
# =========================
ENV_PATH = Path(r"C:\MatchMatrix-platform\.env")
load_dotenv(dotenv_path=ENV_PATH)

DB = {
    "host": os.getenv("PGHOST"),
    "port": int(os.getenv("PGPORT", "5432")),
    "dbname": os.getenv("PGDATABASE"),
    "user": os.getenv("PGUSER"),
    "password": os.getenv("PGPASSWORD"),
}

# =========================
# CONNECT
# =========================
conn = psycopg2.connect(**DB)
cur = conn.cursor()

# =========================
# LOAD PAYLOADS
# =========================
cur.execute("""
SELECT id, payload_json
FROM staging.stg_api_payloads
WHERE provider = 'api_football'
  AND entity_type = 'player_profiles'
  AND parse_status = 'pending'
""")

rows = cur.fetchall()
print(f"Payloads to process: {len(rows)}")

# =========================
# PARSE LOOP
# =========================
for payload_id, payload_json in rows:
    data = payload_json

    try:
        for item in data.get("response", []):
            player = item.get("player", {})
            stats = item.get("statistics", [])

            for stat in stats:
                team = stat.get("team", {})
                league = stat.get("league", {})

                cur.execute("""
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
                """, (
                    "api_football",
                    "football",
                    player.get("id"),
                    player.get("name"),
                    player.get("firstname"),
                    player.get("lastname"),
                    player.get("nationality"),
                    player.get("position"),
                    player.get("height"),
                    player.get("weight"),
                    team.get("id"),
                    team.get("name"),
                    league.get("id"),
                    league.get("name"),
                    league.get("season"),
                    True
                ))

        # označit jako parsed
        cur.execute("""
            UPDATE staging.stg_api_payloads
            SET parse_status = 'done'
            WHERE id = %s
        """, (payload_id,))

        conn.commit()

    except Exception as e:
        print(f"ERROR payload {payload_id}: {e}")
        conn.rollback()

cur.close()
conn.close()

print("DONE")