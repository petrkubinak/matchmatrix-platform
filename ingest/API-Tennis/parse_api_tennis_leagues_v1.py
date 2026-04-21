# parse_api_tennis_leagues_v1.py
# =========================================================
# Tennis leagues parser
# RAW -> staging.api_tennis_leagues
# bere pouze category tournament_atp / tournament_wta
# =========================================================

import os
import json
import re
import psycopg2
import psycopg2.extras
from dotenv import load_dotenv

load_dotenv(r"C:\MatchMatrix-platform\ingest\API-Tennis\.env")

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


def normalize_gender(category: str | None) -> str | None:
    if not category:
        return None
    category = category.lower()
    if "wta" in category:
        return "women"
    if "atp" in category:
        return "men"
    return None


def normalize_category(category: str | None) -> str | None:
    if not category:
        return None
    category = category.lower()
    if category == "tournament_atp":
        return "ATP"
    if category == "tournament_wta":
        return "WTA"
    return category


def split_tournament_name(raw_name: str | None) -> tuple[str | None, str | None]:
    """
    Např.:
    'ATP Studena Croatia Open Umag - Umag'
    -> ('ATP Studena Croatia Open Umag', 'Umag')
    """
    if not raw_name:
        return None, None

    parts = [p.strip() for p in raw_name.split(" - ", 1)]
    if len(parts) == 2:
        return parts[0], parts[1]
    return raw_name.strip(), None


def make_provider_league_id(category: str | None, name: str | None, country: str | None) -> str:
    """
    Protože search endpoint nedává explicitní tournament id,
    vytvoříme stabilní synthetic provider_league_id.
    """
    base = f"{category or ''}|{name or ''}|{country or ''}".strip().lower()
    base = re.sub(r"\s+", " ", base)
    return base


def parse_raw_row(raw_payload: dict) -> list[dict]:
    category = raw_payload.get("category")
    results = raw_payload.get("result", [])

    if not isinstance(results, list):
        return []

    if not isinstance(category, str) or not category.startswith("tournament_"):
        return []

    parsed_rows = []

    for item in results:
        if not isinstance(item, dict):
            continue

        raw_name = item.get("name")
        country = item.get("countryAcr")

        name, location = split_tournament_name(raw_name)

        provider_league_id = make_provider_league_id(category, name, country)

        parsed_rows.append({
            "provider_league_id": provider_league_id,
            "season": "search_seed",
            "name": name,
            "category": normalize_category(category),
            "gender": normalize_gender(category),
            "surface": None,
            "country": country,
            "is_active": True,
            "raw_payload": item,
        })

    return parsed_rows


def upsert_parsed_row(conn, run_id: int, row: dict):
    with conn.cursor() as cur:
        cur.execute("""
            INSERT INTO staging.api_tennis_leagues (
                run_id,
                provider,
                sport_code,
                provider_league_id,
                season,
                name,
                category,
                gender,
                surface,
                country,
                is_active,
                raw_payload
            )
            VALUES (
                %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s::jsonb
            )
            ON CONFLICT (provider, sport_code, provider_league_id, season)
            DO UPDATE SET
                run_id = EXCLUDED.run_id,
                name = EXCLUDED.name,
                category = EXCLUDED.category,
                gender = EXCLUDED.gender,
                surface = EXCLUDED.surface,
                country = EXCLUDED.country,
                is_active = EXCLUDED.is_active,
                raw_payload = EXCLUDED.raw_payload,
                updated_at = now()
        """, (
            run_id,
            PROVIDER,
            SPORT_CODE,
            row["provider_league_id"],
            row["season"],
            row["name"],
            row["category"],
            row["gender"],
            row["surface"],
            row["country"],
            row["is_active"],
            json.dumps(row["raw_payload"])
        ))


def run(run_id: int):
    print("======================================")
    print("MATCHMATRIX TENNIS LEAGUES PARSER")
    print("======================================")
    print(f"RUN_ID: {run_id}")

    conn = get_connection()

    try:
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute("""
                SELECT id, payload
                FROM staging.api_tennis_leagues_raw
                WHERE run_id = %s
                ORDER BY id
            """, (run_id,))
            raw_rows = cur.fetchall()

        total_raw = len(raw_rows)
        parsed_total = 0

        for raw_row in raw_rows:
            payload = raw_row["payload"]

            if isinstance(payload, str):
                payload = json.loads(payload)

            parsed_rows = parse_raw_row(payload)

            for row in parsed_rows:
                upsert_parsed_row(conn, run_id, row)
                parsed_total += 1

        conn.commit()

        print(f"RAW ROWS       : {total_raw}")
        print(f"PARSED UPSERTS : {parsed_total}")
        print("DONE")

    finally:
        conn.close()


if __name__ == "__main__":
    run_id_input = 1776781841
    run(run_id_input)