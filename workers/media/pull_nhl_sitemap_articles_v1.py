# pull_nhl_sitemap_articles_v1.py
# MATCHMATRIX NHL SITEMAP INGEST V1

import requests
import psycopg2
import xml.etree.ElementTree as ET
from datetime import datetime

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "postgres",
    "password": "postgres"
}

SITEMAP_URL = "https://www.nhl.com/sitemap.xml"

HEADERS = {
    "User-Agent": "MatchMatrixBot/1.0"
}

def save_article(conn, url):
    with conn.cursor() as cur:
        cur.execute("""
            INSERT INTO staging.stg_media_articles (
                provider,
                source_name,
                source_type,
                title,
                url,
                parse_status,
                created_at,
                updated_at
            )
            VALUES (
                %s,
                %s,
                %s,
                %s,
                %s,
                'pending',
                now(),
                now()
            )
            ON CONFLICT DO NOTHING
        """, (
            "nhl_sitemap",
            "NHL",
            "sitemap",
            url.split("/")[-1][:250],
            url
        ))

def main():
    print("=== NHL SITEMAP INGEST V1 ===")

    response = requests.get(
        SITEMAP_URL,
        headers=HEADERS,
        timeout=30
    )

    print(f"HTTP STATUS: {response.status_code}")

    root = ET.fromstring(response.text)

    urls = []

    for loc in root.iter("{http://www.sitemaps.org/schemas/sitemap/0.9}loc"):
        value = loc.text

        if value and "/news/" in value:
            urls.append(value)

    print(f"NEWS URLS FOUND: {len(urls)}")

    conn = psycopg2.connect(**DB_CONFIG)

    inserted = 0

    for url in urls[:200]:
        save_article(conn, url)
        inserted += 1

    conn.commit()
    conn.close()

    print(f"INSERTED: {inserted}")

if __name__ == "__main__":
    main()