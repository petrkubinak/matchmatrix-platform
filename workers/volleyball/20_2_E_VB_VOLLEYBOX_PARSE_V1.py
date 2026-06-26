# -*- coding: utf-8 -*-
"""
===============================================================================
MATCHMATRIX 20_2_E – VB VOLLEYBOX PARSE V1
===============================================================================

CO TO JE:
První parser pro Volleybox RAW payloady.

K ČEMU TO JE:
Ověříme, že z HTML uloženého workerem 20_2_D umíme vytáhnout základní
strukturovaná metadata.

KDE TO UVIDÍME:
C:\\MatchMatrix-platform\\data\\parsed\\volleybox\\

JAK SE TO VYUŽIJE:
Další krok 20_2_F uloží parsed výstup do staging vrstvy.
Další verze parseru bude doplňovat:
- full_name
- nationality
- position
- club
- photo_url

NAVAZUJE NA:
20_2_D_VB_VOLLEYBOX_RAW_PULL_V1

DALŠÍ KROK:
20_2_F_VB_VOLLEYBOX_STAGING_V1

SPUŠTĚNÍ:
cd C:\\MatchMatrix-platform
C:\\Python314\\python.exe workers\\volleyball\\20_2_E_VB_VOLLEYBOX_PARSE_V1.py
===============================================================================
"""

from __future__ import annotations

import json
import re
from datetime import datetime
from html import unescape
from pathlib import Path


BASE_DIR = Path(r"C:\MatchMatrix-platform")
RAW_DIR = BASE_DIR / "data" / "raw" / "volleybox"
PARSED_DIR = BASE_DIR / "data" / "parsed" / "volleybox"


def clean_text(value: str | None) -> str:
    if not value:
        return ""

    value = unescape(value)
    value = re.sub(r"<[^>]+>", " ", value)
    value = re.sub(r"\s+", " ", value)
    return value.strip()


def extract_title(html: str) -> str:
    patterns = [
        r"<title[^>]*>(.*?)</title>",
        r'<meta\s+property=["\']og:title["\']\s+content=["\'](.*?)["\']',
        r'<meta\s+name=["\']title["\']\s+content=["\'](.*?)["\']',
        r"<h1[^>]*>(.*?)</h1>",
    ]

    for pattern in patterns:
        match = re.search(pattern, html, flags=re.IGNORECASE | re.DOTALL)
        if match:
            title = clean_text(match.group(1))
            title = re.sub(r"\s*\|\s*Volleybox.*$", "", title, flags=re.IGNORECASE)
            title = re.sub(r"\s*-\s*Volleybox.*$", "", title, flags=re.IGNORECASE)
            return title.strip()

    return ""


def extract_meta_description(html: str) -> str:
    patterns = [
        r'<meta\s+name=["\']description["\']\s+content=["\'](.*?)["\']',
        r'<meta\s+property=["\']og:description["\']\s+content=["\'](.*?)["\']',
    ]

    for pattern in patterns:
        match = re.search(pattern, html, flags=re.IGNORECASE | re.DOTALL)
        if match:
            return clean_text(match.group(1))

    return ""


def extract_og_image(html: str) -> str:
    patterns = [
        r'<meta\s+property=["\']og:image["\']\s+content=["\'](.*?)["\']',
        r'<meta\s+name=["\']twitter:image["\']\s+content=["\'](.*?)["\']',
    ]

    for pattern in patterns:
        match = re.search(pattern, html, flags=re.IGNORECASE | re.DOTALL)
        if match:
            return clean_text(match.group(1))

    return ""


def parse_raw_file(raw_file: Path) -> dict:
    with raw_file.open("r", encoding="utf-8") as f:
        payload = json.load(f)

    html = payload.get("raw_html") or ""

    parsed = {
        "provider": "volleybox",
        "sport_code": "VB",
        "entity_type": payload.get("entity_type"),
        "provider_id": payload.get("provider_id"),
        "source_url": payload.get("source_url"),
        "http_status": payload.get("http_status"),
        "raw_file": str(raw_file),
        "raw_html_size": len(html),
        "page_title": extract_title(html),
        "meta_description": extract_meta_description(html),
        "photo_url": extract_og_image(html),
        "parsed_at": datetime.now().isoformat(timespec="seconds"),
        "parse_status": "OK" if html else "EMPTY_HTML",
        "parse_note": "",
    }

    if not html:
        parsed["parse_note"] = "RAW payload neobsahuje HTML."
    elif not parsed["page_title"]:
        parsed["parse_status"] = "PARTIAL"
        parsed["parse_note"] = "Nepodařilo se vytáhnout title/name."
    else:
        parsed["parse_note"] = "Základní metadata byla úspěšně vytěžena."

    return parsed


def parsed_filename(parsed: dict) -> str:
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    entity_type = parsed.get("entity_type") or "unknown"
    provider_id = parsed.get("provider_id") or "unknown"
    return f"volleybox_parsed_{entity_type}_{provider_id}_{ts}.json"


def main() -> int:
    print("=" * 80)
    print("MATCHMATRIX 20_2_E – VB VOLLEYBOX PARSE V1")
    print("=" * 80)
    print(f"RAW_DIR    : {RAW_DIR}")
    print(f"PARSED_DIR : {PARSED_DIR}")
    print("=" * 80)

    if not RAW_DIR.exists():
        print("RAW_DIR neexistuje.")
        return 1

    PARSED_DIR.mkdir(parents=True, exist_ok=True)

    raw_files = sorted(
        RAW_DIR.glob("volleybox_*.json"),
        key=lambda p: p.stat().st_mtime,
        reverse=True,
    )

    print(f"RAW FILES FOUND : {len(raw_files)}")

    ok = 0
    fail = 0

    for raw_file in raw_files:
        print("-" * 80)
        print(f"RAW FILE: {raw_file}")

        try:
            parsed = parse_raw_file(raw_file)

            out_file = PARSED_DIR / parsed_filename(parsed)
            with out_file.open("w", encoding="utf-8") as f:
                json.dump(parsed, f, ensure_ascii=False, indent=2)

            print(f"ENTITY      : {parsed.get('entity_type')}")
            print(f"PROVIDER ID : {parsed.get('provider_id')}")
            print(f"TITLE       : {parsed.get('page_title')}")
            print(f"STATUS      : {parsed.get('parse_status')}")
            print(f"PARSED FILE : {out_file}")

            if parsed.get("parse_status") in ("OK", "PARTIAL"):
                ok += 1
            else:
                fail += 1

        except Exception as e:
            print(f"ERROR       : {type(e).__name__}: {e}")
            fail += 1

    print("=" * 80)
    print("SUMMARY")
    print(f"PARSED OK : {ok}")
    print(f"FAILED    : {fail}")
    print("=" * 80)

    return 0 if fail == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())