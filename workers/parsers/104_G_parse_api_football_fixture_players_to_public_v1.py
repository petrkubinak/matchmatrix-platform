"""
===============================================================================
MATCHMATRIX – PARSE API FOOTBALL FIXTURE PLAYERS TO PUBLIC V1
===============================================================================

CO TO DĚLÁ
-----------
Parsuje RAW payloady:

entity_type = player_match_statistics
endpoint    = fixtures_players

ze staging.stg_api_payloads
a ukládá data do:

public.player_match_statistics

K ČEMU TO JE
-------------
Buduje:
- player match performance layer
- form engine
- fantasy scoring
- AI prediction layer
- player momentum
- web player match detail

FLOW
-----
RAW payload
→ mapping match/team/player
→ stat extraction
→ public.player_match_statistics

WEB / APP VÝSTUP
----------------
- výkon hráče v zápase
- detail hráče
- forma
- AI rating
- player heat/performance
===============================================================================
"""

import os
import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv

# ============================================================================
# LOAD ENV
# ============================================================================

load_dotenv()

DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")

# ============================================================================
# CONNECT DB
# ============================================================================

conn = psycopg2.connect(
    host=DB_HOST,
    port=DB_PORT,
    dbname=DB_NAME,
    user=DB_USER,
    password=DB_PASSWORD
)

cur = conn.cursor(cursor_factory=RealDictCursor)

# ============================================================================
# LOAD PENDING RAW PAYLOADS
# ============================================================================

load_sql = """
SELECT
    id,
    external_id,
    payload_json
FROM staging.stg_api_payloads
WHERE entity_type = 'player_match_statistics'
  AND endpoint_name = 'fixtures_players'
  AND parse_status = 'pending'
ORDER BY id;
"""

cur.execute(load_sql)

payloads = cur.fetchall()

print("=" * 80)
print("MATCHMATRIX FIXTURE PLAYER MATCH STATS PARSER V1")
print("=" * 80)
print(f"PENDING PAYLOADS: {len(payloads)}")

inserted_total = 0

# ============================================================================
# PROCESS PAYLOADS
# ============================================================================

for payload in payloads:

    raw_id = payload["id"]
    fixture_external_id = payload["external_id"]
    payload_json = payload["payload_json"]

    print()
    print("-" * 80)
    print(f"RAW ID: {raw_id}")
    print(f"FIXTURE: {fixture_external_id}")

    # ========================================================================
    # MATCH MAPPING
    # ========================================================================

    match_sql = """
    SELECT id
    FROM public.matches
    WHERE ext_source = 'api_football'
      AND ext_match_id = %s
    LIMIT 1;
    """

    cur.execute(match_sql, (fixture_external_id,))
    match_row = cur.fetchone()

    if not match_row:
        print("MATCH NOT FOUND")
        continue

    match_id = match_row["id"]

    inserted_payload = 0

    # ========================================================================
    # TEAM LOOP
    # ========================================================================

    for team_block in payload_json.get("response", []):

        provider_team_id = str(
            team_block.get("team", {}).get("id")
        )

        team_map_sql = """
        SELECT team_id
        FROM public.team_provider_map
        WHERE provider = 'api_football'
          AND provider_team_id = %s
        LIMIT 1;
        """

        cur.execute(team_map_sql, (provider_team_id,))
        team_row = cur.fetchone()

        if not team_row:
            print(f"TEAM MAP MISSING: {provider_team_id}")
            continue

        team_id = team_row["team_id"]

        # ====================================================================
        # PLAYER LOOP
        # ====================================================================

        for player_block in team_block.get("players", []):

            provider_player_id = str(
                player_block.get("player", {}).get("id")
            )

            player_map_sql = """
            SELECT player_id
            FROM public.player_provider_map
            WHERE provider = 'api_football'
              AND provider_player_id = %s
            LIMIT 1;
            """

            cur.execute(player_map_sql, (provider_player_id,))
            player_row = cur.fetchone()

            if not player_row:
                print(f"PLAYER MAP MISSING: {provider_player_id}")
                continue

            player_id = player_row["player_id"]

            stats_list = player_block.get("statistics", [])

            if not stats_list:
                continue

            stats = stats_list[0]

            # ====================================================================
            # SAFE EXTRACTION
            # ====================================================================

            games = stats.get("games", {})
            goals = stats.get("goals", {})
            shots = stats.get("shots", {})
            passes = stats.get("passes", {})
            dribbles = stats.get("dribbles", {})
            tackles = stats.get("tackles", {})
            fouls = stats.get("fouls", {})
            cards = stats.get("cards", {})

            def to_int(v):
                try:
                    if v is None:
                        return 0
                    return int(float(v))
                except:
                    return 0

            def to_numeric(v):
                try:
                    if v is None:
                        return None
                    return float(v)
                except:
                    return None

            minutes_played = to_int(games.get("minutes"))
            rating = to_numeric(games.get("rating"))

            # ====================================================================
            # UPSERT
            # ====================================================================

            upsert_sql = """
            INSERT INTO public.player_match_statistics
            (
                match_id,
                team_id,
                player_id,
                minutes_played,
                goals,
                assists,
                shots_total,
                shots_on_target,
                passes_total,
                passes_accurate,
                key_passes,
                dribbles_attempted,
                dribbles_successful,
                tackles,
                interceptions,
                clearances,
                blocks,
                fouls_committed,
                fouls_drawn,
                yellow_cards,
                red_cards,
                offsides,
                saves,
                rating,
                created_at,
                updated_at
            )
            VALUES
            (
                %s,%s,%s,%s,%s,%s,%s,%s,%s,%s,
                %s,%s,%s,%s,%s,%s,%s,%s,%s,%s,
                %s,%s,%s,%s,NOW(),NOW()
            )
            ON CONFLICT (match_id, player_id)
            DO UPDATE SET
                minutes_played = EXCLUDED.minutes_played,
                goals = EXCLUDED.goals,
                assists = EXCLUDED.assists,
                shots_total = EXCLUDED.shots_total,
                shots_on_target = EXCLUDED.shots_on_target,
                passes_total = EXCLUDED.passes_total,
                passes_accurate = EXCLUDED.passes_accurate,
                key_passes = EXCLUDED.key_passes,
                dribbles_attempted = EXCLUDED.dribbles_attempted,
                dribbles_successful = EXCLUDED.dribbles_successful,
                tackles = EXCLUDED.tackles,
                interceptions = EXCLUDED.interceptions,
                clearances = EXCLUDED.clearances,
                blocks = EXCLUDED.blocks,
                fouls_committed = EXCLUDED.fouls_committed,
                fouls_drawn = EXCLUDED.fouls_drawn,
                yellow_cards = EXCLUDED.yellow_cards,
                red_cards = EXCLUDED.red_cards,
                offsides = EXCLUDED.offsides,
                saves = EXCLUDED.saves,
                rating = EXCLUDED.rating,
                updated_at = NOW();
            """

            cur.execute(
                upsert_sql,
                (
                    match_id,
                    team_id,
                    player_id,
                    minutes_played,
                    to_int(goals.get("total")),
                    to_int(goals.get("assists")),
                    to_int(shots.get("total")),
                    to_int(shots.get("on")),
                    to_int(passes.get("total")),
                    to_int(passes.get("accuracy")),
                    to_int(passes.get("key")),
                    to_int(dribbles.get("attempts")),
                    to_int(dribbles.get("success")),
                    to_int(tackles.get("total")),
                    to_int(tackles.get("interceptions")),
                    to_int(tackles.get("clearances")),
                    to_int(tackles.get("blocks")),
                    to_int(fouls.get("committed")),
                    to_int(fouls.get("drawn")),
                    to_int(cards.get("yellow")),
                    to_int(cards.get("red")),
                    to_int(games.get("offsides")),
                    to_int(games.get("saves")),
                    rating
                )
            )

            inserted_payload += 1
            inserted_total += 1

    # ========================================================================
    # MARK PARSED
    # ========================================================================

    update_sql = """
    UPDATE staging.stg_api_payloads
    SET
        parse_status = 'parsed',
        parse_message = %s
    WHERE id = %s;
    """

    cur.execute(
        update_sql,
        (
            f"Parsed to public.player_match_statistics | rows={inserted_payload}",
            raw_id
        )
    )

    conn.commit()

    print(f"INSERTED ROWS: {inserted_payload}")

# ============================================================================
# FINAL
# ============================================================================

print()
print("=" * 80)
print("DONE")
print(f"TOTAL INSERTED: {inserted_total}")
print("=" * 80)

cur.close()
conn.close()