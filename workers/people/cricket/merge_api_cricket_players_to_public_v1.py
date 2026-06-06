# -*- coding: utf-8 -*-
"""
MATCHMATRIX WORKER
merge_api_cricket_players_to_public_v1.py

CO TO JE:
- Merge cricket hráčů ze staging.stg_provider_players do public.players.

K ČEMU TO JE:
- Dokončí první PEOPLE vrstvu pro cricket.
- Vytvoří canonical players a provider map.

KDE TO UVIDÍME:
- public.players
- public.player_provider_map

JAK SE TO VYUŽIJE:
- Web: profily hráčů, soupisky, statistiky, people vrstva.
"""

from __future__ import annotations

import os
import sys
import psycopg2
from dotenv import load_dotenv


BASE_DIR = r"C:\MatchMatrix-platform"
ENV_PATH = os.path.join(BASE_DIR, "ingest", "API-Cricket", ".env")

PROVIDER = "api_cricket"
SPORT_CODE = "CK"
SPORT_ID = 14
SEASON = "2024"


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
            NULL AS team_id,
            s.player_name AS name,
            s.first_name,
            s.last_name,
            s.short_name,
            NULL AS birth_date,
            s.nationality,
            s.position_code AS position,
            NULL AS shirt_number,
            s.height_cm,
            s.weight_kg,
            COALESCE(s.is_active, true),
            s.provider AS ext_source,
            s.external_player_id AS ext_player_id,
            NULL AS photo_url,
            %s AS sport_id,
            NOW(),
            NOW()
        FROM staging.stg_provider_players s
        WHERE s.provider = %s
          AND s.sport_code = %s
          AND s.season = %s
          AND s.external_player_id IS NOT NULL
          AND NOT EXISTS (
              SELECT 1
              FROM public.players p
              WHERE p.ext_source = s.provider
                AND p.ext_player_id = s.external_player_id
                AND p.sport_id = %s
          );
    """

    with conn.cursor() as cur:
        cur.execute(sql, (SPORT_ID, PROVIDER, SPORT_CODE, SEASON, SPORT_ID))
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
            p.id AS player_id,
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
        WHERE s.provider = %s
          AND s.sport_code = %s
          AND s.season = %s
          AND NOT EXISTS (
              SELECT 1
              FROM public.player_provider_map m
              WHERE m.provider = s.provider
                AND m.provider_player_id = s.external_player_id
          );
    """

    with conn.cursor() as cur:
        cur.execute(sql, (SPORT_ID, PROVIDER, SPORT_CODE, SEASON))
        return cur.rowcount


def main() -> int:
    load_environment()

    print("=" * 80)
    print("MATCHMATRIX CK PLAYERS MERGE TO PUBLIC V1")
    print("=" * 80)
    print("PROVIDER:", PROVIDER)
    print("SPORT   :", SPORT_CODE)
    print("SPORT_ID:", SPORT_ID)
    print("SEASON  :", SEASON)
    print("=" * 80)

    conn = get_db_connection()
    conn.autocommit = False

    try:
        inserted_players = merge_players(conn)
        inserted_maps = merge_provider_map(conn)

        conn.commit()

        print("PLAYERS INSERTED:", inserted_players)
        print("MAPS INSERTED   :", inserted_maps)
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