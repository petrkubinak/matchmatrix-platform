# -*- coding: utf-8 -*-
"""
MATCHMATRIX 112_G Merge Tennis Players To Public V1

CO TO JE:
- Python merge worker pro Tennis PEOPLE vrstvu.
- Bere hráče ze staging.stg_provider_players, kde sport_code = 'TN'.

K ČEMU TO JE:
- Vytvoří / doplní hráče do public.players.
- Vytvoří / doplní mapování do public.player_provider_map.

KDE TO UVIDÍME:
- Control Panel V17 -> PEOPLE.
- ops.v_people_pipeline_summary_v1.
- ops.v_people_pipeline_audit_v1.

JAK SE TO VYUŽIJE:
- Profil tenisty.
- Detail tenisového zápasu.
- Player rating.
- Head-to-head.
- Tennis predictions.
"""

import os
import sys
import psycopg2
import psycopg2.extras
from dotenv import load_dotenv


ENV_PATH = r"C:\MatchMatrix-platform\ingest\API-Tennis\.env"
load_dotenv(ENV_PATH)


DB_CONFIG = {
    "host": os.getenv("PGHOST", "localhost"),
    "port": int(os.getenv("PGPORT", "5432")),
    "dbname": os.getenv("PGDATABASE", "matchmatrix"),
    "user": os.getenv("PGUSER", "matchmatrix"),
    "password": os.getenv("PGPASSWORD", "matchmatrix_pass"),
}


PROVIDER = "api_tennis"
SPORT_CODE = "TN"


def get_connection():
    return psycopg2.connect(**DB_CONFIG)


def get_tennis_sport_id(cur):
    cur.execute("""
        SELECT id
        FROM public.sports
        WHERE code = %s
    """, (SPORT_CODE,))

    row = cur.fetchone()

    if not row:
        raise RuntimeError("Sport TN nebyl nalezen v public.sports")

    return row["id"]


def merge_players(cur, sport_id):
    cur.execute("""
        WITH src AS (
            SELECT DISTINCT
                provider,
                external_player_id,
                player_name
            FROM staging.stg_provider_players
            WHERE provider = %s
              AND sport_code = %s
              AND external_player_id IS NOT NULL
              AND player_name IS NOT NULL
              AND trim(player_name) <> ''
        )
        INSERT INTO public.players (
            name,
            sport_id,
            ext_source,
            ext_player_id,
            is_active,
            created_at,
            updated_at
        )
        SELECT
            src.player_name,
            %s,
            src.provider,
            src.external_player_id,
            true,
            now(),
            now()
        FROM src
        WHERE NOT EXISTS (
            SELECT 1
            FROM public.players p
            WHERE p.ext_source = src.provider
              AND p.ext_player_id = src.external_player_id
        )
    """, (PROVIDER, SPORT_CODE, sport_id))

    return cur.rowcount


def merge_provider_map(cur):
    cur.execute("""
        WITH src AS (
            SELECT DISTINCT
                provider,
                external_player_id,
                player_name
            FROM staging.stg_provider_players
            WHERE provider = %s
              AND sport_code = %s
              AND external_player_id IS NOT NULL
              AND player_name IS NOT NULL
              AND trim(player_name) <> ''
        ),
        public_players AS (
            SELECT
                id AS player_id,
                ext_source AS provider,
                ext_player_id AS external_player_id
            FROM public.players
            WHERE ext_source = %s
              AND ext_player_id IS NOT NULL
        )
        INSERT INTO public.player_provider_map (
            provider,
            provider_player_id,
            player_id,
            provider_player_name,
            is_active,
            created_at,
            updated_at
        )
        SELECT
            src.provider,
            src.external_player_id,
            pp.player_id,
            src.player_name,
            true,
            now(),
            now()
        FROM src
        JOIN public_players pp
            ON pp.provider = src.provider
           AND pp.external_player_id = src.external_player_id
        WHERE NOT EXISTS (
            SELECT 1
            FROM public.player_provider_map ppm
            WHERE ppm.provider = src.provider
              AND ppm.provider_player_id = src.external_player_id
        )
    """, (PROVIDER, SPORT_CODE, PROVIDER))

    return cur.rowcount


def print_summary(cur):
    cur.execute("""
        SELECT *
        FROM ops.v_people_pipeline_summary_v1
        WHERE sport_code = %s
    """, (SPORT_CODE,))

    row = cur.fetchone()

    print("-" * 80)
    print("TN PEOPLE SUMMARY")
    print("-" * 80)

    if not row:
        print("TN summary nenalezeno.")
        return

    for key, value in dict(row).items():
        print(f"{key}: {value}")


def main():
    print("=" * 80)
    print("MATCHMATRIX 112_G MERGE TENNIS PLAYERS TO PUBLIC V1")
    print("=" * 80)

    conn = None

    try:
        conn = get_connection()
        conn.autocommit = False

        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            sport_id = get_tennis_sport_id(cur)

            inserted_players = merge_players(cur, sport_id)
            inserted_maps = merge_provider_map(cur)

            conn.commit()

            print(f"INSERTED PLAYERS : {inserted_players}")
            print(f"INSERTED MAPS    : {inserted_maps}")

            print_summary(cur)

        print("=" * 80)
        print("DONE")
        print("=" * 80)

        return 0

    except Exception as exc:
        if conn:
            conn.rollback()

        print("=" * 80)
        print("ERROR")
        print("=" * 80)
        print(str(exc))
        return 1

    finally:
        if conn:
            conn.close()


if __name__ == "__main__":
    sys.exit(main())