# -*- coding: utf-8 -*-
"""
MATCHMATRIX 104_U - PARSE FB PLAYER MATCH STATS QUEUE PAYLOADS V1

Co skript dělá:
- bere RAW payloady z staging.stg_api_payloads
- filtruje API-Football /fixtures/players:
  provider='api_football'
  entity_type='fixture_player_stats'
  parse_status='pending'
- mapuje fixture -> public.matches
- mapuje team -> public.team_provider_map
- mapuje player -> public.player_provider_map
- ukládá hráčské zápasové statistiky do public.player_match_statistics

Kam výsledek vede:
- public.player_match_statistics

K čemu to slouží:
- automatická PEOPLE vrstva pro player match stats

Jak se využije na webu/aplikaci:
- detail hráče v zápase
- player form engine
- fantasy scoring
- AI prediction layer
- player momentum
"""

import os
import argparse
import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv


BASE_DIR = r"C:\MatchMatrix-platform"
ENV_PATH = os.path.join(BASE_DIR, ".env")

PROVIDER = "api_football"
SPORT_CODE = "FB"
SPORT_ID = 1
ENTITY_TYPE = "fixture_player_stats"


def get_conn():
    load_dotenv(ENV_PATH)

    return psycopg2.connect(
        host=os.getenv("PGHOST", "localhost"),
        port=os.getenv("PGPORT", "5432"),
        dbname=os.getenv("PGDATABASE", "matchmatrix"),
        user=os.getenv("PGUSER", "postgres"),
        password=os.getenv("PGPASSWORD", ""),
    )


def safe_int(value, default=0):
    if value is None:
        return default

    try:
        return int(value)
    except Exception:
        return default


def safe_numeric(value, default=None):
    if value is None:
        return default

    try:
        return float(value)
    except Exception:
        return default


def get_payloads(conn, limit):
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
    WHERE provider = %(provider)s
      AND sport_code = %(sport_code)s
      AND entity_type = %(entity_type)s
      AND parse_status = 'pending'
      AND payload_json IS NOT NULL
    ORDER BY id ASC
    LIMIT %(limit)s;
    """

    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(
            sql,
            {
                "provider": PROVIDER,
                "sport_code": SPORT_CODE,
                "entity_type": ENTITY_TYPE,
                "limit": limit,
            },
        )
        return cur.fetchall()


def get_match_id(conn, fixture_id):
    sql = """
    SELECT id
    FROM public.matches
    WHERE ext_source = %(provider)s
      AND ext_match_id = %(fixture_id)s
      AND sport_id = %(sport_id)s
    LIMIT 1;
    """

    with conn.cursor() as cur:
        cur.execute(
            sql,
            {
                "provider": PROVIDER,
                "fixture_id": str(fixture_id),
                "sport_id": SPORT_ID,
            },
        )
        row = cur.fetchone()

    return row[0] if row else None


def get_team_id(conn, provider_team_id):
    if provider_team_id is None:
        return None

    sql = """
    SELECT team_id
    FROM public.team_provider_map
    WHERE provider = %(provider)s
      AND provider_team_id = %(provider_team_id)s
    LIMIT 1;
    """

    with conn.cursor() as cur:
        cur.execute(
            sql,
            {
                "provider": PROVIDER,
                "provider_team_id": str(provider_team_id),
            },
        )
        row = cur.fetchone()

    return row[0] if row else None


def get_player_id(conn, provider_player_id):
    if provider_player_id is None:
        return None

    sql = """
    SELECT player_id
    FROM public.player_provider_map
    WHERE provider = %(provider)s
      AND provider_player_id = %(provider_player_id)s
    LIMIT 1;
    """

    with conn.cursor() as cur:
        cur.execute(
            sql,
            {
                "provider": PROVIDER,
                "provider_player_id": str(provider_player_id),
            },
        )
        row = cur.fetchone()

    return row[0] if row else None


def already_exists(conn, match_id, team_id, player_id):
    sql = """
    SELECT 1
    FROM public.player_match_statistics
    WHERE match_id = %(match_id)s
      AND player_id = %(player_id)s
    LIMIT 1;
    """

    with conn.cursor() as cur:
        cur.execute(
            sql,
            {
                "match_id": match_id,
                "player_id": player_id,
            },
        )
        return cur.fetchone() is not None


def insert_stat(conn, row):
    sql = """
    INSERT INTO public.player_match_statistics (
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
    VALUES (
        %(match_id)s,
        %(team_id)s,
        %(player_id)s,
        %(minutes_played)s,
        %(goals)s,
        %(assists)s,
        %(shots_total)s,
        %(shots_on_target)s,
        %(passes_total)s,
        %(passes_accurate)s,
        %(key_passes)s,
        %(dribbles_attempted)s,
        %(dribbles_successful)s,
        %(tackles)s,
        %(interceptions)s,
        %(blocks)s,
        %(fouls_committed)s,
        %(fouls_drawn)s,
        %(yellow_cards)s,
        %(red_cards)s,
        %(offsides)s,
        %(saves)s,
        %(rating)s,
        now(),
        now()
    )
    ON CONFLICT (match_id, player_id)
    DO NOTHING;
    """

    with conn.cursor() as cur:
        cur.execute(sql, row)


def mark_payload(conn, payload_id, status, message):
    sql = """
    UPDATE staging.stg_api_payloads
    SET
        parse_status = %(status)s,
        parse_message = %(message)s
    WHERE id = %(payload_id)s;
    """

    with conn.cursor() as cur:
        cur.execute(
            sql,
            {
                "payload_id": payload_id,
                "status": status,
                "message": message[:1000],
            },
        )


def parse_payload(conn, payload_row):
    payload_id = payload_row["id"]
    fixture_id = payload_row["external_id"]
    payload = payload_row["payload_json"]

    match_id = get_match_id(conn, fixture_id)

    if not match_id:
        mark_payload(
            conn,
            payload_id,
            "error",
            f"Match not found for fixture={fixture_id}",
        )
        return 0, 0, 0

    response = payload.get("response", []) if isinstance(payload, dict) else []

    inserted = 0
    skipped = 0
    errors = 0

    for team_block in response:
        team = team_block.get("team", {}) or {}
        provider_team_id = team.get("id")
        team_id = get_team_id(conn, provider_team_id)

        if not team_id:
            skipped += 1
            continue

        players = team_block.get("players", []) or []

        for player_block in players:
            player = player_block.get("player", {}) or {}
            provider_player_id = player.get("id")
            player_id = get_player_id(conn, provider_player_id)

            if not player_id:
                skipped += 1
                continue

            if already_exists(conn, match_id, team_id, player_id):
                skipped += 1
                continue

            stats_list = player_block.get("statistics", []) or []

            if not stats_list:
                skipped += 1
                continue

            stat = stats_list[0] or {}

            games = stat.get("games", {}) or {}
            offsides = stat.get("offsides")
            shots = stat.get("shots", {}) or {}
            goals = stat.get("goals", {}) or {}
            passes = stat.get("passes", {}) or {}
            tackles = stat.get("tackles", {}) or {}
            duels = stat.get("duels", {}) or {}
            dribbles = stat.get("dribbles", {}) or {}
            fouls = stat.get("fouls", {}) or {}
            cards = stat.get("cards", {}) or {}

            row = {
                "match_id": match_id,
                "team_id": team_id,
                "player_id": player_id,
                "minutes_played": safe_int(games.get("minutes")),
                "goals": safe_int(goals.get("total")),
                "assists": safe_int(goals.get("assists")),
                "shots_total": safe_int(shots.get("total")),
                "shots_on_target": safe_int(shots.get("on")),
                "passes_total": safe_int(passes.get("total")),
                "passes_accurate": safe_int(passes.get("accuracy")),
                "key_passes": safe_int(passes.get("key")),
                "dribbles_attempted": safe_int(dribbles.get("attempts")),
                "dribbles_successful": safe_int(dribbles.get("success")),
                "tackles": safe_int(tackles.get("total")),
                "interceptions": safe_int(tackles.get("interceptions")),
                "blocks": safe_int(tackles.get("blocks")),
                "fouls_committed": safe_int(fouls.get("committed")),
                "fouls_drawn": safe_int(fouls.get("drawn")),
                "yellow_cards": safe_int(cards.get("yellow")),
                "red_cards": safe_int(cards.get("red")),
                "offsides": safe_int(offsides),
                "saves": safe_int(goals.get("saves")),
                "rating": safe_numeric(games.get("rating")),
            }

            try:
                insert_stat(conn, row)
                inserted += 1
            except Exception as exc:
                errors += 1
                conn.rollback()
                print(
                    f"    INSERT ERROR | "
                    f"match_id={match_id} | "
                    f"team_id={team_id} | "
                    f"player_id={player_id} | "
                    f"error={exc}"
                )
                continue

    if errors > 0:
        status = "partial"
    else:
        status = "parsed"

    mark_payload(
        conn,
        payload_id,
        status,
        f"fixture={fixture_id}; match_id={match_id}; inserted={inserted}; skipped={skipped}; errors={errors}",
    )

    return inserted, skipped, errors


def print_header(limit):
    print("=" * 80)
    print("MATCHMATRIX FB PLAYER MATCH STATS QUEUE PAYLOAD PARSER V1")
    print("=" * 80)
    print(f"PROVIDER   : {PROVIDER}")
    print(f"SPORT      : {SPORT_CODE}")
    print(f"ENTITY TYPE: {ENTITY_TYPE}")
    print(f"LIMIT      : {limit}")
    print("=" * 80)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--limit", type=int, default=20)
    args = parser.parse_args()

    print_header(args.limit)

    conn = get_conn()

    total_inserted = 0
    total_skipped = 0
    total_errors = 0

    try:
        payloads = get_payloads(conn, args.limit)

        print(f"PENDING PAYLOADS: {len(payloads)}")
        print("-" * 80)

        for payload in payloads:
            try:
                inserted, skipped, errors = parse_payload(conn, payload)
                conn.commit()

                total_inserted += inserted
                total_skipped += skipped
                total_errors += errors

                print(
                    f"RAW {payload['id']} | FIXTURE {payload['external_id']} | "
                    f"INSERTED {inserted} | SKIPPED {skipped} | ERRORS {errors}"
                )

            except Exception as exc:
                conn.rollback()
                mark_payload(
                    conn,
                    payload["id"],
                    "error",
                    f"Parser crash: {exc}",
                )
                conn.commit()
                total_errors += 1
                print(f"RAW {payload['id']} | ERROR: {exc}")

        print("=" * 80)
        print("DONE")
        print(f"TOTAL INSERTED: {total_inserted}")
        print(f"TOTAL SKIPPED : {total_skipped}")
        print(f"TOTAL ERRORS  : {total_errors}")

    finally:
        conn.close()


if __name__ == "__main__":
    main()