# -*- coding: utf-8 -*-
"""
MATCHMATRIX WORKER
merge_basketball_players_to_public_v1.py

CO TO JE:
- Merge BK hráčů ze staging.stg_provider_players do public.players.

K ČEMU TO JE:
- Dokončí aktuální BK PEOPLE vrstvu ze staging do public.
- Vytvoří canonical players a player_provider_map.

KDE TO UVIDÍME:
- public.players
- public.player_provider_map
- ops.v_people_pipeline_summary_v1

JAK SE TO VYUŽIJE:
- Web: hráči, soupisky, profily, people vrstva pro basketbal.
"""

from __future__ import annotations

import os
import sys
import psycopg2
from dotenv import load_dotenv


BASE_DIR = r"C:\MatchMatrix-platform"
ENV_PATH = os.path.join(BASE_DIR, "ingest", ".env")

SPORT_ID = 3
SPORT_CODES = ("BK", "basketball")


def load_environment() -> None:
    if os.path.exists(ENV_PATH):
        load_dotenv(ENV_PATH)


def get_db_connection():
    return psycopg2.connect(
        host=os.getenv("PGHOST", "localhost"),
        port=int(os.getenv("PGPORT", "5432")),
        dbname=os.getenv("PGDATABASE", "matchmatrix"),
        user=os.getenv("PGUSER", "matchmatrix"),
        password=os.getenv("PGPASSWORD", "matchmatrix_pass"),
    )


def merge_players(conn) -> int:
    sql = """
        INSERT INTO public.players (
            team_id,
            name,
            first_name,
            last_name,
            short_name,
            birth_date,
            nationality,
            position,
            shirt_number,
            height_cm,
            weight_kg,
            is_active,
            ext_source,
            ext_player_id,
            photo_url,
            sport_id,
            created_at,
            updated_at
        )
        SELECT
            NULL,
            s.player_name,
            s.first_name,
            s.last_name,
            s.short_name,
            NULL,
            s.nationality,
            s.position_code,
            NULL,
            s.height_cm,
            s.weight_kg,
            COALESCE(s.is_active, true),
            s.provider,
            s.external_player_id,
            NULL,
            %s,
            NOW(),
            NOW()
        FROM staging.stg_provider_players s
        WHERE s.sport_code IN ('BK', 'basketball')
          AND s.external_player_id IS NOT NULL
          AND s.player_name IS NOT NULL
          AND NOT EXISTS (
              SELECT 1
              FROM public.players p
              WHERE p.ext_source = s.provider
                AND p.ext_player_id = s.external_player_id
          );
    """

    with conn.cursor() as cur:
        cur.execute(sql, (SPORT_ID,))
        return cur.rowcount


def merge_provider_map(conn) -> int:
    sql = """
        INSERT INTO public.player_provider_map (
            provider,
            provider_player_id,
            player_id,
            provider_team_id,
            provider_team_name,
            provider_player_name,
            is_active,
            created_at,
            updated_at
        )
        SELECT
            s.provider,
            s.external_player_id,
            p.id,
            s.external_team_id,
            s.team_name,
            s.player_name,
            COALESCE(s.is_active, true),
            NOW(),
            NOW()
        FROM staging.stg_provider_players s
        JOIN public.players p
          ON p.ext_source = s.provider
         AND p.ext_player_id = s.external_player_id
         AND p.sport_id = %s
        WHERE s.sport_code IN ('BK', 'basketball')
          AND s.external_player_id IS NOT NULL
          AND NOT EXISTS (
              SELECT 1
              FROM public.player_provider_map m
              WHERE m.provider = s.provider
                AND m.provider_player_id = s.external_player_id
                AND m.player_id = p.id
          );
    """

    with conn.cursor() as cur:
        cur.execute(sql, (SPORT_ID,))
        return cur.rowcount


def main() -> int:
    load_environment()

    print("=" * 80)
    print("MATCHMATRIX BK PLAYERS MERGE TO PUBLIC V1")
    print("=" * 80)
    print("SPORT_ID:", SPORT_ID)
    print("SPORT   : BK / basketball")
    print("=" * 80)

    conn = get_db_connection()
    conn.autocommit = False

    try:
        players_inserted = merge_players(conn)
        maps_inserted = merge_provider_map(conn)

        conn.commit()

        print("PLAYERS INSERTED:", players_inserted)
        print("MAPS INSERTED   :", maps_inserted)
        print("DONE")
        return 0

    except Exception as exc:
        conn.rollback()
        print("ERROR:", type(exc).__name__, exc)
        return 1

    finally:
        conn.close()


if __name__ == "__main__":
    sys.exit(main())