import psycopg2
import json
from datetime import datetime

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass"
}

def run():
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()

    cur.execute("""
        SELECT payload
        FROM staging.stg_api_payloads
        WHERE provider = 'api_tennis'
          AND sport_code = 'TN'
          AND entity = 'teams'
        ORDER BY fetched_at DESC
    """)

    rows = cur.fetchall()

    for (payload,) in rows:
        data = payload.get("response", [])

        for team in data:
            name = team.get("name")

            if not name:
                continue

            cur.execute("""
                INSERT INTO staging.stg_provider_teams (
                    provider,
                    sport_code,
                    team_name,
                    raw_payload,
                    created_at
                )
                VALUES (%s, %s, %s, %s, %s)
                ON CONFLICT DO NOTHING
            """, (
                "api_tennis",
                "TN",
                name,
                json.dumps(team),
                datetime.utcnow()
            ))

    conn.commit()
    cur.close()
    conn.close()

if __name__ == "__main__":
    run()