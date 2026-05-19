# pull_official_site_media_articles_v1.py
# MATCHMATRIX OFFICIAL SITE MEDIA INGEST V1.1
#
# Účel:
# - načte aktivní official_site zdroje z public.content_sources
# - najde odkazy na články /news/
# - uloží je do staging.stg_media_articles
# - zapíše stav běhu do ops.media_source_health_audit
#
# Spuštění:
#   cd C:\MatchMatrix-platform
#   C:\Python314\python.exe C:\MatchMatrix-platform\workers\media\pull_official_site_media_articles_v1.py

import hashlib
from urllib.parse import urljoin, urlparse

import psycopg
import requests
from bs4 import BeautifulSoup


DB_DSN = (
    "host=localhost "
    "port=5432 "
    "dbname=matchmatrix "
    "user=matchmatrix "
    "password=matchmatrix_pass"
)

HEADERS = {
    "User-Agent": "MatchMatrixBot/1.0 (+https://matchmatrix.local)"
}

WORKER_SCRIPT = r"C:\MatchMatrix-platform\workers\media\pull_official_site_media_articles_v1.py"
WORKER_TYPE = "official_site_scraper"


def make_hash(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def get_site_root(base_url: str) -> str:
    parsed = urlparse(base_url)
    return f"{parsed.scheme}://{parsed.netloc}"


def clean_title_from_url(url: str) -> str:
    slug = url.rstrip("/").split("/")[-1]
    return slug[:250] if slug else url[:250]


def normalize_provider(source_name: str) -> str:
    return source_name.lower().strip().replace(" ", "_")


def detect_sport_code(source_name: str) -> str:
    name = source_name.upper().strip()

    mapping = {
        "NBA": "BK",
        "NHL": "HK",
        "UEFA": "FB",
        "FIFA": "FB",
        "MLB": "BSB",
        "NFL": "AFB",
    }

    return mapping.get(name, "UNK")


def detect_health_status(http_status: int | None, found_urls: int, error_text: str | None) -> str:
    if error_text:
        if http_status == 403:
            return "BLOCKED"
        if http_status == 404:
            return "ERROR"
        return "ERROR"

    if http_status is None:
        return "UNKNOWN"

    if http_status >= 400:
        if http_status == 403:
            return "BLOCKED"
        if http_status == 404:
            return "ERROR"
        return "ERROR"

    if found_urls == 0:
        return "EMPTY"

    return "OK"


def upsert_media_health(
    conn,
    provider: str,
    sport_code: str,
    source_name: str,
    source_type: str,
    source_url: str,
    http_status: int | None,
    found_urls: int,
    inserted_rows: int,
    updated_rows: int,
    skipped_rows: int,
    health_status: str,
    health_note: str | None,
):
    sql = """
    INSERT INTO ops.media_source_health_audit
    (
        provider,
        sport_code,
        entity,
        source_name,
        source_type,
        source_url,
        http_status,
        found_urls,
        inserted_rows,
        updated_rows,
        skipped_rows,
        worker_script,
        worker_type,
        health_status,
        health_note,
        last_run_at,
        updated_at
    )
    VALUES
    (
        %s, %s, 'articles',
        %s, %s, %s,
        %s, %s, %s, %s, %s,
        %s, %s,
        %s, %s,
        now(), now()
    )
    ON CONFLICT (provider, sport_code, source_name, source_type, source_url)
    DO UPDATE SET
        http_status = EXCLUDED.http_status,
        found_urls = EXCLUDED.found_urls,
        inserted_rows = EXCLUDED.inserted_rows,
        updated_rows = EXCLUDED.updated_rows,
        skipped_rows = EXCLUDED.skipped_rows,
        worker_script = EXCLUDED.worker_script,
        worker_type = EXCLUDED.worker_type,
        health_status = EXCLUDED.health_status,
        health_note = EXCLUDED.health_note,
        last_run_at = now(),
        updated_at = now()
    """

    conn.execute(
        sql,
        (
            provider,
            sport_code,
            source_name,
            source_type,
            source_url,
            http_status,
            found_urls,
            inserted_rows,
            updated_rows,
            skipped_rows,
            WORKER_SCRIPT,
            WORKER_TYPE,
            health_status,
            health_note,
        ),
    )


def main():
    conn = psycopg.connect(DB_DSN)
    conn.autocommit = True

    sql_sources = """
    SELECT
        id,
        name,
        source_type,
        base_url,
        language_code,
        country_code
    FROM public.content_sources
    WHERE is_active = true
      AND source_type = 'official_site'
    ORDER BY id
    """

    sources = conn.execute(sql_sources).fetchall()

    print("=" * 80)
    print("MATCHMATRIX OFFICIAL SITE MEDIA INGEST V1.1")
    print("=" * 80)
    print(f"SOURCES: {len(sources)}")
    print("=" * 80)

    total_processed = 0
    total_inserted = 0

    for source in sources:
        source_name = source[1]
        source_type = source[2]
        base_url = source[3]
        language_code = source[4]
        country_code = source[5]

        provider = normalize_provider(source_name)
        sport_code = detect_sport_code(source_name)
        site_root = get_site_root(base_url)

        source_processed = 0
        source_inserted = 0
        source_skipped = 0
        source_updated = 0
        found_urls_count = 0
        http_status = None
        health_note = None

        print(f"\nSOURCE: {source_name}")
        print(f"URL   : {base_url}")
        print(f"ROOT  : {site_root}")
        print(f"SPORT : {sport_code}")

        try:
            response = requests.get(
                base_url,
                headers=HEADERS,
                timeout=20,
            )

            http_status = response.status_code
            print(f"HTTP STATUS: {http_status}")

            response.raise_for_status()

            soup = BeautifulSoup(response.text, "html.parser")
            links = soup.find_all("a")

            found_urls = set()

            for link in links:
                href = link.get("href")

                if not href:
                    continue

                if "/news/" not in href:
                    continue

                full_url = urljoin(site_root, href)

                if not full_url.startswith(site_root):
                    continue

                found_urls.add(full_url)

            found_urls_count = len(found_urls)
            print(f"FOUND URLS: {found_urls_count}")

            for url in sorted(found_urls)[:100]:
                source_processed += 1
                total_processed += 1

                payload_hash = make_hash(url)

                sql_insert = """
                INSERT INTO staging.stg_media_articles
                (
                    provider,
                    source_name,
                    source_type,
                    title,
                    url,
                    language_code,
                    country_code,
                    payload_hash,
                    parse_status
                )
                VALUES
                (
                    %s, %s, %s, %s, %s, %s, %s, %s, 'pending'
                )
                ON CONFLICT (provider, url)
                DO NOTHING
                """

                result = conn.execute(
                    sql_insert,
                    (
                        provider,
                        source_name,
                        source_type,
                        clean_title_from_url(url),
                        url,
                        language_code,
                        country_code,
                        payload_hash,
                    ),
                )

                if result.rowcount == 1:
                    source_inserted += 1
                    total_inserted += 1
                else:
                    source_skipped += 1

            health_status = detect_health_status(
                http_status=http_status,
                found_urls=found_urls_count,
                error_text=None,
            )

            if health_status == "OK":
                health_note = "Official site scraper OK."
            elif health_status == "EMPTY":
                health_note = "HTTP OK, ale scraper nenašel žádné /news/ odkazy."
            else:
                health_note = "Official site scraper doběhl s nestandardním stavem."

            upsert_media_health(
                conn=conn,
                provider=provider,
                sport_code=sport_code,
                source_name=source_name,
                source_type=source_type,
                source_url=base_url,
                http_status=http_status,
                found_urls=found_urls_count,
                inserted_rows=source_inserted,
                updated_rows=source_updated,
                skipped_rows=source_skipped,
                health_status=health_status,
                health_note=health_note,
            )

            print(f"INSERTED: {source_inserted}")
            print(f"SKIPPED : {source_skipped}")
            print(f"HEALTH  : {health_status}")

        except Exception as e:
            error_text = str(e)
            health_status = detect_health_status(
                http_status=http_status,
                found_urls=found_urls_count,
                error_text=error_text,
            )
            health_note = error_text[:1000]

            print(f"ERROR: {error_text}")
            print(f"HEALTH: {health_status}")

            upsert_media_health(
                conn=conn,
                provider=provider,
                sport_code=sport_code,
                source_name=source_name,
                source_type=source_type,
                source_url=base_url,
                http_status=http_status,
                found_urls=found_urls_count,
                inserted_rows=source_inserted,
                updated_rows=source_updated,
                skipped_rows=source_skipped,
                health_status=health_status,
                health_note=health_note,
            )

    print("\n" + "=" * 80)
    print("DONE")
    print("=" * 80)
    print(f"PROCESSED: {total_processed}")
    print(f"INSERTED : {total_inserted}")
    print("=" * 80)

    conn.close()


if __name__ == "__main__":
    main()