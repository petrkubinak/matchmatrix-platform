import json
import psycopg

DB_DSN = "host=localhost port=5432 dbname=matchmatrix user=matchmatrix password=matchmatrix_pass"
RAW_ID = 743

def safe_int(val):
    try:
        return int(val) if val not in (None, "") else None
    except Exception:
        return None

def main():
    print("=== FIX PARSE FB PLAYERS RAW 743 ===")

    with psycopg.connect(DB_DSN) as conn:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT payload_json
                FROM staging.stg_api_payloads
                WHERE id = %s
            """, (RAW_ID,))
            row = cur.fetchone()

        if not row:
            raise RuntimeError("RAW 743 not found")

        payload = row[0] if isinstance(row[0], dict) else json.loads(row[0])
        items = payload.get("response", [])

        inserted = 0

        with conn.cursor() as cur:
            for item in items:
                player = item.get("player") or {}
                stats = item.get("statistics") or []
                stat0 = stats[0] if stats else {}

                team = stat0.get("team") or {}
                league = stat0.get("league") or {}
                games = stat0.get("games") or {}

                cur.execute("""
                    INSERT INTO staging.stg_provider_players (
                        provider,
                        sport_code,
                        external_player_id,
                        player_name,
                        first_name,
                        last_name,
                        birth_date,
                        nationality,
                        height_cm,
                        weight_kg,
                        external_team_id,
                        team_name,
                        external_league_id,
                        league_name,
                        season,
                        position_code,
                        raw_payload_id,
                        source_endpoint,
                        created_at
                    )
                    VALUES (
                        'api_football',
                        'FB',
                        %s, %s, %s, %s, %s, %s,
                        %s, %s,
                        %s, %s,
                        %s, %s,
                        %s, %s,
                        %s,
                        'players',
                        now()
                    )
                    ON CONFLICT DO NOTHING;
                """, (
                    str(player.get("id")) if player.get("id") is not None else None,
                    player.get("name"),
                    player.get("firstname"),
                    player.get("lastname"),
                    player.get("birth", {}).get("date"),
                    player.get("nationality"),
                    safe_int(player.get("height")),
                    safe_int(player.get("weight")),
                    str(team.get("id")) if team.get("id") is not None else None,
                    team.get("name"),
                    str(league.get("id")) if league.get("id") is not None else None,
                    league.get("name"),
                    str(league.get("season")) if league.get("season") is not None else None,
                    games.get("position"),
                    RAW_ID
                ))

                inserted += cur.rowcount

            cur.execute("""
                UPDATE staging.stg_api_payloads
                SET parse_status = 'parsed',
                    parse_message = %s
                WHERE id = %s
            """, (f"Parsed FB players FIX OK, inserted={inserted}", RAW_ID))

        conn.commit()

    print(f"DONE inserted={inserted}")

if __name__ == "__main__":
    main()