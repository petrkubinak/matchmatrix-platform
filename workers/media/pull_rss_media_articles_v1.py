# pull_rss_media_articles_v1.py
# MATCHMATRIX MEDIA RSS INGEST V1

import hashlib
import json
import os
import sys
from datetime import datetime

import feedparser
import psycopg
import requests
from dotenv import load_dotenv


# =========================================================
# ENV
# =========================================================

BASE_DIR = r"C:\MatchMatrix-platform"

ENV_PATHS = [
    os.path.join(BASE_DIR, ".env"),
    os.path.join(BASE_DIR, "ingest", ".env"),
]

for env_path in ENV_PATHS:
    if os.path.exists(env_path):
        load_dotenv(env_path)

DB_DSN = (
    "host=localhost "
    "port=5432 "
    "dbname=matchmatrix "
    "user=matchmatrix "
    "password=matchmatrix_pass"
)


# =========================================================
# DB
# =========================================================

conn = psycopg.connect(DB_DSN)
conn.autocommit = True


# =========================================================
# HELPERS
# =========================================================

def make_hash(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


# =========================================================
# LOAD SOURCES
# =========================================================

sql_sources = """
SELECT
    id,
    name,
    source_type,
    rss_url,
    language_code,
    country_code
FROM public.content_sources
WHERE is_active = true
  AND source_type IN ('rss', 'sitemap')
  AND rss_url IS NOT NULL
ORDER BY id
"""

sources = conn.execute(sql_sources).fetchall()

print("=" * 80)
print("MATCHMATRIX RSS MEDIA INGEST V1")
print("=" * 80)
print(f"RSS SOURCES: {len(sources)}")
print("=" * 80)


# =========================================================
# PROCESS RSS
# =========================================================

inserted = 0
skipped = 0

for source in sources:

    source_id = source[0]
    source_name = source[1]
    source_type = source[2]
    rss_url = source[3]
    language_code = source[4]
    country_code = source[5]

    print(f"\nSOURCE: {source_name}")
    print(f"RSS   : {rss_url}")

    try:

        headers = {
            "User-Agent": "MatchMatrixBot/1.0 (+https://matchmatrix.local)"
        }

        response = requests.get(
            rss_url,
            headers=headers,
            timeout=20
        )

        response.raise_for_status()

        feed = feedparser.parse(response.content)

        entries = feed.entries

        print(f"ENTRIES: {len(entries)}")

        for entry in entries:

            title = entry.get("title", "").strip()
            url = entry.get("link", "").strip()
            summary = entry.get("summary", "")

            published_at = None

            if hasattr(entry, "published_parsed") and entry.published_parsed:
                published_at = datetime(*entry.published_parsed[:6])

            if not title or not url:
                skipped += 1
                continue

            payload_hash = make_hash(url)

            payload_json = json.dumps(entry, default=str)

            sql_insert = """
            INSERT INTO staging.stg_media_articles
            (
                provider,
                source_name,
                source_type,
                title,
                url,
                summary,
                raw_text,
                raw_html,
                author_name,
                published_at,
                language_code,
                country_code,
                external_article_id,
                payload_json,
                payload_hash
            )
            VALUES
            (
                %s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s
            )
            ON CONFLICT (provider, url)
            DO NOTHING
            """

            conn.execute(
                sql_insert,
                (
                    source_name.lower(),
                    source_name,
                    source_type,
                    title,
                    url,
                    summary,
                    summary,
                    summary,
                    None,
                    published_at,
                    language_code,
                    country_code,
                    None,
                    payload_json,
                    payload_hash,
                ),
            )

            inserted += 1

    except Exception as e:
        print(f"ERROR: {e}")

print("\n" + "=" * 80)
print("DONE")
print("=" * 80)
print(f"INSERTED: {inserted}")
print(f"SKIPPED : {skipped}")
print("=" * 80)

conn.close()