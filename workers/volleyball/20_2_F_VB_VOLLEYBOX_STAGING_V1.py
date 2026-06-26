# -*- coding: utf-8 -*-
"""
===============================================================================
MATCHMATRIX 20_2_F – VB VOLLEYBOX STAGING V1
===============================================================================

CO TO JE:
První staging worker pro Volleybox parsed payloady.

K ČEMU TO JE:
Načte parsed JSON soubory z:
C:\\MatchMatrix-platform\\data\\parsed\\volleybox\\

a hráčské záznamy uloží do univerzální MatchMatrix tabulky:
staging.stg_provider_players

KDE TO UVIDÍME:
DBeaver:
SELECT * FROM staging.stg_provider_players WHERE provider = 'volleybox';

JAK SE TO VYUŽIJE:
Další krok 20_2_G provede merge ze staging.stg_provider_players do:
- public.players
- public.player_provider_map
- public.player_external_identity

NAVAZUJE NA:
20_2_D_VB_VOLLEYBOX_RAW_PULL_V1
20_2_E_VB_VOLLEYBOX_PARSE_V1

DALŠÍ KROK:
20_2_G_VB_VOLLEYBOX_MERGE_V1

SPUŠTĚNÍ:
cd C:\\MatchMatrix-platform
C:\\Python314\\python.exe workers\\volleyball\\20_2_F_VB_VOLLEYBOX_STAGING_V1.py
===============================================================================
"""

from __future__ import annotations

import json
import re
from datetime import datetime
from pathlib import Path

import psycopg2


BASE_DIR = Path(r"C:\MatchMatrix-platform")
PARSED_DIR = BASE_DIR / "data" / "parsed" / "volleybox"

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}


def clean_player_name(title: str | None) -> str:
    if not title:
        return ""

    name = str(title).strip()

    # Příklad: "Jožef Verdinek - volejbalista"
    name = re.sub(r"\s*-\s*volejbalista.*$", "", name, flags=re.IGNORECASE)
    name = re.sub(r"\s*-\s*volleyball player.*$", "", name, flags=re.IGNORECASE)
    name = re.sub(r"\s*\|\s*Volleybox.*$", "", name, flags=re.IGNORECASE)
    name = re.sub(r"\s+", " ", name)

    return name.strip()


def split_name(full_name: str) -> tuple[str | None, str | None, str | None]:
    if not full_name:
        return None, None, None

    parts = full_name.split()

    if len(parts) == 1:
        return parts[0], None, parts[0]

    first_name = parts[0]
    last_name = " ".join(parts[1:])
    short_name = f"{first_name[:1]}. {last_name}"

    return first_name, last_name, short_name


def load_parsed_files() -> list[Path]:
    if not PARSED_DIR.exists():
        return []

    return sorted(
        PARSED_DIR.glob("volleybox_parsed_*.json"),
        key=lambda p: p.stat().st_mtime,
        reverse=True,
    )


def insert_player(conn, parsed: dict, parsed_file: Path) -> bool:
    entity_type = parsed.get("entity_type")

    if entity_type != "player":
        return False

    external_player_id = str(parsed.get("provider_id") or "").strip()
    player_name = clean_player_name(parsed.get("page_title"))
    first_name, last_name, short_name = split_name(player_name)

    if not external_player_id or not player_name:
        raise ValueError("Chybí external_player_id nebo player_name.")

    source_endpoint = "volleybox_profile_page"

    sql = """
        INSERT INTO staging.stg_provider_players (
            provider,
            sport_code,
            external_player_id,
            player_name,
            birth_date,
            nationality,
            external_team_id,
            season,
            raw_payload_id,
            is_active,
            created_at,
            updated_at,
            first_name,
            last_name,
            short_name,
            position_code,
            height_cm,
            weight_kg,
            preferred_foot,
            external_league_id,
            team_name,
            league_name,
            source_endpoint
        )
        VALUES (
            %(provider)s,
            %(sport_code)s,
            %(external_player_id)s,
            %(player_name)s,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            TRUE,
            NOW(),
            NOW(),
            %(first_name)s,
            %(last_name)s,
            %(short_name)s,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            %(source_endpoint)s
        )
    """

    params = {
        "provider": "volleybox",
        "sport_code": "VB",
        "external_player_id": external_player_id,
        "player_name": player_name,
        "first_name": first_name,
        "last_name": last_name,
        "short_name": short_name,
        "source_endpoint": source_endpoint,
    }

    with conn.cursor() as cur:
        cur.execute(sql, params)

    return True


def main() -> int:
    print("=" * 80)
    print("MATCHMATRIX 20_2_F – VB VOLLEYBOX STAGING V1")
    print("=" * 80)
    print(f"PARSED_DIR: {PARSED_DIR}")
    print("=" * 80)

    parsed_files = load_parsed_files()

    print(f"PARSED FILES FOUND: {len(parsed_files)}")

    if not parsed_files:
        print("Žádné parsed soubory.")
        return 1

    inserted = 0
    skipped = 0
    failed = 0

    conn = None

    try:
        conn = psycopg2.connect(**DB_CONFIG)

        for parsed_file in parsed_files:
            print("-" * 80)
            print(f"PARSED FILE: {parsed_file}")

            try:
                with parsed_file.open("r", encoding="utf-8") as f:
                    parsed = json.load(f)

                entity_type = parsed.get("entity_type")
                provider_id = parsed.get("provider_id")
                title = parsed.get("page_title")

                print(f"ENTITY     : {entity_type}")
                print(f"PROVIDER ID: {provider_id}")
                print(f"TITLE      : {title}")

                if entity_type != "player":
                    print("SKIP       : není player payload")
                    skipped += 1
                    continue

                ok = insert_player(conn, parsed, parsed_file)

                if ok:
                    inserted += 1
                    print("INSERT     : OK")
                else:
                    skipped += 1
                    print("SKIP       : není player")

            except Exception as e:
                failed += 1
                print(f"ERROR      : {type(e).__name__}: {e}")

        conn.commit()

    except Exception as e:
        if conn:
            conn.rollback()
        print("=" * 80)
        print(f"FATAL: {type(e).__name__}: {e}")
        return 1

    finally:
        if conn:
            conn.close()

    print("=" * 80)
    print("SUMMARY")
    print(f"INSERTED: {inserted}")
    print(f"SKIPPED : {skipped}")
    print(f"FAILED  : {failed}")
    print("=" * 80)

    return 0 if failed == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())