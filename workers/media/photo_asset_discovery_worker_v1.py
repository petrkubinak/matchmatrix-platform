# =============================================================================
# MATCHMATRIX WORKER 19_5_T
# PHOTO ASSET DISCOVERY WORKER V1.1
# =============================================================================
#
# CO TO JE:
# - Worker pro dohledávání fotografií hráčů.
# - Bere hráče bez photo_url z public.players.
# - Hledá kandidáty přes Wikidata API.
# - Výsledek ukládá do staging.stg_player_photo_candidates.
#
# K ČEMU TO JE:
# - Zvýšit pokrytí fotek hráčů v MatchMatrix.
# - První cíl: FB hráči, kde je aktuálně photo coverage cca 27 %.
#
# KDE TO UVIDÍME:
# - staging.stg_player_photo_candidates
# - ops.v_photo_review_panel_v1
# - ops.v_photo_review_dashboard_v1
# - později public.players.photo_url
# - detail hráče na webu
#
# JAK SE TO VYUŽIJE:
# - Worker pouze navrhuje kandidáty.
# - Nezapisuje přímo do public.players.photo_url.
# - Kandidáti se schvalují přes panel / review.
# - Approved kandidáti se následně mergují do public.players.photo_url.
#
# OPRAVY V1.1:
# - UTF-8 výstup pro Windows konzoli / panel log.
# - Ošetření Wikidata rate limitu 429.
# - Výchozí sleep zvýšen na 5 s.
# - Nepřidává duplicitní kandidáty pro stejného hráče + wikidata_id/photo_url.
# - Fetch přeskočí hráče, kteří už mají kandidáta ve staging review tabulce.
# - DB default sjednocen na uživatele matchmatrix.
# =============================================================================

import argparse
import os
import sys
import time
from typing import Any, Dict, List, Optional

import psycopg2
import requests

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

BASE_DIR = r"C:\MatchMatrix-platform"

DB_HOST = os.getenv("MATCHMATRIX_DB_HOST", "localhost")
DB_PORT = os.getenv("MATCHMATRIX_DB_PORT", "5432")
DB_NAME = os.getenv("MATCHMATRIX_DB_NAME", "matchmatrix")
DB_USER = os.getenv("MATCHMATRIX_DB_USER", "matchmatrix")
DB_PASSWORD = os.getenv("MATCHMATRIX_DB_PASSWORD", "matchmatrix_pass")

WIKIDATA_SEARCH_URL = "https://www.wikidata.org/w/api.php"
COMMONS_SPECIAL_FILE_URL = "https://commons.wikimedia.org/wiki/Special:FilePath/"

USER_AGENT = "MatchMatrixPhotoDiscovery/1.1 (research; local development; contact=local)"


class RateLimitError(RuntimeError):
    pass


def safe_print(text: str = "") -> None:
    try:
        print(str(text))
    except UnicodeEncodeError:
        print(str(text).encode("utf-8", errors="replace").decode("utf-8", errors="replace"))


def db_connect():
    return psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
    )


def fetch_players(conn, sport_code: str, limit: int) -> List[Dict[str, Any]]:
    sql = """
        SELECT
            p.id AS player_id,
            p.name AS player_name,
            p.photo_url,
            s.code AS sport_code
        FROM public.players p
        JOIN public.sports s
            ON s.id = p.sport_id
        WHERE s.code = %s
          AND (p.photo_url IS NULL OR length(trim(p.photo_url)) = 0)
          AND NOT EXISTS (
              SELECT 1
              FROM staging.stg_player_photo_candidates c
              WHERE c.player_id = p.id
                AND c.sport_code = s.code
                AND c.review_status IN ('PENDING', 'APPROVED')
          )
        ORDER BY p.id
        LIMIT %s;
    """

    with conn.cursor() as cur:
        cur.execute(sql, (sport_code, limit))
        rows = cur.fetchall()

    return [
        {
            "player_id": row[0],
            "player_name": row[1],
            "photo_url": row[2],
            "sport_code": row[3],
        }
        for row in rows
    ]


def get_json_with_retry(session: requests.Session, params: Dict[str, Any], sleep_seconds: float, max_retries: int = 3) -> Dict[str, Any]:
    last_error: Optional[Exception] = None

    for attempt in range(1, max_retries + 1):
        response = session.get(
            WIKIDATA_SEARCH_URL,
            params=params,
            headers={"User-Agent": USER_AGENT},
            timeout=25,
        )

        if response.status_code == 429:
            wait_seconds = max(10.0, sleep_seconds * attempt * 2)
            safe_print(f"RATE LIMIT 429: čekám {wait_seconds:.1f} s a zkusím znovu ({attempt}/{max_retries})")
            time.sleep(wait_seconds)
            last_error = RateLimitError("Wikidata 429 Too Many Requests")
            continue

        try:
            response.raise_for_status()
            return response.json()
        except Exception as exc:
            last_error = exc
            if attempt < max_retries:
                wait_seconds = max(5.0, sleep_seconds * attempt)
                safe_print(f"HTTP/API retry: {exc} | čekám {wait_seconds:.1f} s ({attempt}/{max_retries})")
                time.sleep(wait_seconds)
                continue
            raise

    raise last_error or RateLimitError("Wikidata request failed after retries")


def wikidata_search_player(session: requests.Session, player_name: str, sleep_seconds: float) -> Optional[Dict[str, Any]]:
    params = {
        "action": "wbsearchentities",
        "search": player_name,
        "language": "en",
        "format": "json",
        "limit": 1,
    }

    data = get_json_with_retry(session, params, sleep_seconds)
    results = data.get("search", [])

    if not results:
        return None

    item = results[0]
    return {
        "wikidata_id": item.get("id"),
        "label": item.get("label"),
        "description": item.get("description"),
        "wikidata_url": item.get("concepturi"),
    }


def wikidata_get_image_claim(session: requests.Session, wikidata_id: str, sleep_seconds: float) -> Optional[str]:
    params = {
        "action": "wbgetentities",
        "ids": wikidata_id,
        "props": "claims",
        "format": "json",
    }

    data = get_json_with_retry(session, params, sleep_seconds)
    entity = data.get("entities", {}).get(wikidata_id, {})
    claims = entity.get("claims", {})

    image_claims = claims.get("P18", [])
    if not image_claims:
        return None

    mainsnak = image_claims[0].get("mainsnak", {})
    datavalue = mainsnak.get("datavalue", {})
    value = datavalue.get("value")

    if not value:
        return None

    return str(value)


def build_commons_file_url(commons_file: str) -> str:
    safe_file = commons_file.replace(" ", "_")
    return f"{COMMONS_SPECIAL_FILE_URL}{safe_file}"


def insert_candidate(
    conn,
    player_id: int,
    player_name: str,
    sport_code: str,
    wikidata_id: str,
    wikidata_url: str,
    commons_file: str,
    photo_url: str,
    confidence_score: float,
) -> bool:
    sql = """
        INSERT INTO staging.stg_player_photo_candidates (
            player_id,
            player_name,
            sport_code,
            provider,
            source_system,
            source_url,
            wikidata_id,
            wikipedia_url,
            commons_file,
            photo_url,
            license_name,
            license_url,
            confidence_score,
            review_status,
            created_at,
            updated_at
        )
        SELECT
            %s, %s, %s,
            'wikimedia',
            'wikidata',
            %s,
            %s,
            NULL,
            %s,
            %s,
            'REVIEW_REQUIRED',
            NULL,
            %s,
            'PENDING',
            NOW(),
            NOW()
        WHERE NOT EXISTS (
            SELECT 1
            FROM staging.stg_player_photo_candidates c
            WHERE c.player_id = %s
              AND c.sport_code = %s
              AND COALESCE(c.wikidata_id, '') = COALESCE(%s, '')
              AND COALESCE(c.photo_url, '') = COALESCE(%s, '')
        );
    """

    with conn.cursor() as cur:
        cur.execute(
            sql,
            (
                player_id,
                player_name,
                sport_code,
                wikidata_url,
                wikidata_id,
                commons_file,
                photo_url,
                confidence_score,
                player_id,
                sport_code,
                wikidata_id,
                photo_url,
            ),
        )
        return cur.rowcount > 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--sport", default="FB")
    parser.add_argument("--limit", type=int, default=25)
    parser.add_argument("--sleep", type=float, default=5.0)
    parser.add_argument("--max-retries", type=int, default=3)
    args = parser.parse_args()

    safe_print("=" * 80)
    safe_print("MATCHMATRIX PHOTO ASSET DISCOVERY WORKER V1.1")
    safe_print("=" * 80)
    safe_print(f"SPORT : {args.sport}")
    safe_print(f"LIMIT : {args.limit}")
    safe_print(f"SLEEP : {args.sleep}")
    safe_print("=" * 80)

    found = 0
    inserted = 0
    skipped = 0
    duplicates = 0
    errors = 0
    rate_limits = 0

    conn = db_connect()
    session = requests.Session()

    try:
        players = fetch_players(conn, args.sport, args.limit)
        safe_print(f"PLAYERS LOADED: {len(players)}")

        for player in players:
            player_id = player["player_id"]
            player_name = player["player_name"]
            sport_code = player["sport_code"]

            safe_print("-" * 80)
            safe_print(f"PLAYER {player_id}: {player_name}")

            try:
                wd = wikidata_search_player(session, player_name, args.sleep)

                if not wd:
                    safe_print("WIKIDATA: no result")
                    skipped += 1
                    time.sleep(args.sleep)
                    continue

                wikidata_id = wd["wikidata_id"]
                wikidata_url = wd["wikidata_url"]

                safe_print(f"WIKIDATA: {wikidata_id} | {wikidata_url}")

                time.sleep(args.sleep)
                commons_file = wikidata_get_image_claim(session, wikidata_id, args.sleep)

                if not commons_file:
                    safe_print("IMAGE: no P18 image claim")
                    skipped += 1
                    time.sleep(args.sleep)
                    continue

                photo_url = build_commons_file_url(commons_file)

                was_inserted = insert_candidate(
                    conn=conn,
                    player_id=player_id,
                    player_name=player_name,
                    sport_code=sport_code,
                    wikidata_id=wikidata_id,
                    wikidata_url=wikidata_url,
                    commons_file=commons_file,
                    photo_url=photo_url,
                    confidence_score=70.00,
                )

                conn.commit()
                found += 1

                if was_inserted:
                    inserted += 1
                    safe_print(f"PHOTO CANDIDATE: {photo_url}")
                else:
                    duplicates += 1
                    safe_print(f"DUPLICATE CANDIDATE SKIPPED: {photo_url}")

            except RateLimitError as exc:
                conn.rollback()
                errors += 1
                rate_limits += 1
                safe_print(f"RATE LIMIT ERROR: {exc}")
            except Exception as exc:
                conn.rollback()
                errors += 1
                safe_print(f"ERROR: {exc}")

            time.sleep(args.sleep)

    finally:
        conn.close()
        session.close()

    safe_print("=" * 80)
    safe_print("DONE")
    safe_print("=" * 80)
    safe_print(f"FOUND      : {found}")
    safe_print(f"INSERTED   : {inserted}")
    safe_print(f"DUPLICATES : {duplicates}")
    safe_print(f"SKIPPED    : {skipped}")
    safe_print(f"ERRORS     : {errors}")
    safe_print(f"RATE_LIMIT : {rate_limits}")
    safe_print("=" * 80)

    return 0 if errors == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
