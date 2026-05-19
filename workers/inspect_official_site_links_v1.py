# inspect_official_site_links_v1.py
# Inspect official site links for MEDIA worker tuning

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


def get_site_root(base_url: str) -> str:
    parsed = urlparse(base_url)
    return f"{parsed.scheme}://{parsed.netloc}"


conn = psycopg.connect(DB_DSN)

sql = """
SELECT
    name,
    base_url
FROM public.content_sources
WHERE is_active = true
  AND source_type = 'official_site'
  AND name = 'UEFA'
"""

source = conn.execute(sql).fetchone()
conn.close()

name, base_url = source
site_root = get_site_root(base_url)

print("=" * 80)
print("INSPECT OFFICIAL SITE LINKS V1")
print("=" * 80)
print(f"SOURCE: {name}")
print(f"URL   : {base_url}")
print(f"ROOT  : {site_root}")

response = requests.get(base_url, headers=HEADERS, timeout=20)
print(f"HTTP STATUS: {response.status_code}")
response.raise_for_status()

soup = BeautifulSoup(response.text, "html.parser")
links = soup.find_all("a")

urls = []

for link in links:
    href = link.get("href")
    if not href:
        continue

    full_url = urljoin(site_root, href)

    if full_url.startswith(site_root):
        urls.append(full_url)

print(f"INTERNAL LINKS FOUND: {len(urls)}")
print("-" * 80)

for url in sorted(set(urls))[:100]:
    print(url)