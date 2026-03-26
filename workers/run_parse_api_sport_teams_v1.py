import psycopg2

conn = psycopg2.connect(
    host="localhost",
    port=5432,
    dbname="matchmatrix",
    user="matchmatrix",
    password="matchmatrix_pass"
)

cur = conn.cursor()

print("=== PARSE TEAMS (SHORT) ===")

cur.execute("""
SELECT id, provider, sport_code, external_id, season, payload_json
FROM staging.stg_api_payloads
WHERE entity_type = 'teams'
  AND parse_status = 'pending'
""")

rows = cur.fetchall()
print("Payloads:", len(rows))

for r in rows:
    pid, provider, sport, ext_id, season, payload = r
    league_id = ext_id.split("_")[0]

    for t in payload["response"]:
        cur.execute("""
        INSERT INTO staging.stg_provider_teams
        (provider, sport_code, external_team_id, team_name, external_league_id, season, created_at, updated_at)
        VALUES (%s,%s,%s,%s,%s,%s,NOW(),NOW())
        ON CONFLICT DO NOTHING
        """, (
            provider,
            sport,
            t["id"],
            t["name"],
            league_id,
            season
        ))

    cur.execute("""
    UPDATE staging.stg_api_payloads
    SET parse_status = 'processed'
    WHERE id = %s
    """, (pid,))

conn.commit()
cur.close()
conn.close()

print("DONE")