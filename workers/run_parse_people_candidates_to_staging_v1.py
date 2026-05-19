"""
run_parse_people_candidates_to_staging_v1.py

Účel:
- parse RAW payloads (743,744,745,746)
- zapis do:
    staging.stg_provider_players
    staging.stg_provider_coaches
- nastaví parse_status = 'parsed'
"""

import json
from datetime import datetime

import psycopg


DB_DSN = "host=localhost port=5432 dbname=matchmatrix user=matchmatrix password=matchmatrix_pass"

RAW_IDS = [743, 744, 745, 746]


def safe_int(val):
    try:
        return int(val)
    except:
        return None


def parse_fb_players(conn, raw_id, payload):
    rows = payload.get("response", [])
    inserted = 0

    with conn.cursor() as cur:
        for item in rows:
            p = item.get("player", {})
            stats = item.get("statistics", [])

            team = stats[0]["team"] if stats else {}
            league = stats[0]["league"] if stats else {}

            cur.execute("""
                INSERT INTO staging.stg_provider_players (
                    provider, sport_code,
                    external_player_id, player_name,
                    first_name, last_name,
                    birth_date, nationality,
                    height_cm, weight_kg,
                    external_team_id, team_name,
                    external_league_id, league_name,
                    season,
                    position_code,
                    raw_payload_id,
                    source_endpoint,
                    created_at
                )
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,now())
                ON CONFLICT DO NOTHING
            """, (
                "api_football", "FB",
                p.get("id"), p.get("name"),
                p.get("firstname"), p.get("lastname"),
                p.get("birth", {}).get("date"),
                p.get("nationality"),
                safe_int(p.get("height")),
                safe_int(p.get("weight")),
                team.get("id"), team.get("name"),
                league.get("id"), league.get("name"),
                league.get("season"),
                stats[0]["games"].get("position") if stats else None,
                raw_id,
                "players"
            ))
            inserted += 1

    return inserted


def parse_fb_coaches(conn, raw_id, payload):
    rows = payload.get("response", [])
    inserted = 0

    with conn.cursor() as cur:
        for c in rows:
            team = c.get("team", {})

            cur.execute("""
                INSERT INTO staging.stg_provider_coaches (
                    provider, sport_code,
                    external_coach_id, coach_name,
                    first_name, last_name,
                    birth_date, nationality,
                    team_external_id, team_name,
                    raw_payload_id,
                    source_endpoint,
                    created_at
                )
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,now())
                ON CONFLICT DO NOTHING
            """, (
                "api_football", "FB",
                c.get("id"), c.get("name"),
                c.get("firstname"), c.get("lastname"),
                c.get("birth", {}).get("date"),
                c.get("nationality"),
                team.get("id"), team.get("name"),
                raw_id,
                "coachs"
            ))
            inserted += 1

    return inserted


def parse_simple_players(conn, raw_id, payload, provider, sport):
    rows = payload.get("response", [])
    inserted = 0

    with conn.cursor() as cur:
        for p in rows:
            cur.execute("""
                INSERT INTO staging.stg_provider_players (
                    provider, sport_code,
                    external_player_id, player_name,
                    first_name, last_name,
                    birth_date, nationality,
                    height_cm, weight_kg,
                    season,
                    position_code,
                    raw_payload_id,
                    source_endpoint,
                    created_at
                )
                VALUES (%s,%s,%s,%s,%s,%s,NULL,NULL,NULL,NULL,NULL,%s,%s,%s,now())
                ON CONFLICT DO NOTHING
            """, (
                provider, sport,
                p.get("id"), p.get("name"),
                None, None,
                p.get("position"),
                raw_id,
                "players"
            ))
            inserted += 1

    return inserted


def main():
    print("=== PARSE PEOPLE CANDIDATES V1 ===")

    with psycopg.connect(DB_DSN) as conn:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT id, provider, sport_code, entity_type, payload_json
                FROM staging.stg_api_payloads
                WHERE id = ANY(%s)
            """, (RAW_IDS,))
            raws = cur.fetchall()

        for raw_id, provider, sport, entity, payload in raws:
            print(f"\n--- {raw_id} | {provider} | {sport} | {entity} ---")

            payload = payload if isinstance(payload, dict) else json.loads(payload)

            try:
                if provider == "api_football" and entity == "players":
                    cnt = parse_fb_players(conn, raw_id, payload)

                elif provider == "api_football" and entity == "coaches":
                    cnt = parse_fb_coaches(conn, raw_id, payload)

                elif entity == "players":
                    cnt = parse_simple_players(conn, raw_id, payload, provider, sport)

                else:
                    cnt = 0

                print(f"Inserted: {cnt}")

                with conn.cursor() as cur:
                    cur.execute("""
                        UPDATE staging.stg_api_payloads
                        SET parse_status='parsed', parse_message=%s
                        WHERE id=%s
                    """, (f"Parsed OK, rows={cnt}", raw_id))

            except Exception as e:
                print(f"ERROR: {e}")

                with conn.cursor() as cur:
                    cur.execute("""
                        UPDATE staging.stg_api_payloads
                        SET parse_status='error', parse_message=%s
                        WHERE id=%s
                    """, (str(e)[:500], raw_id))

        conn.commit()

    print("\nDONE")


if __name__ == "__main__":
    main()