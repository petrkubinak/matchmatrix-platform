# -*- coding: utf-8 -*-
"""
===============================================================================
MATCHMATRIX 20_2_D – VB VOLLEYBOX RAW PULL V1
===============================================================================

CO TO JE:
První RAW pull worker pro nového providera Volleybox.

K ČEMU TO JE:
Ověříme, že umíme stáhnout HTML profil hráče a týmu z Volleyboxu
a bezpečně uložit RAW data pro pozdější parser.

KDE TO UVIDÍME:
Lokální RAW soubory:
C:\\MatchMatrix-platform\\data\\raw\\volleybox\\

JAK SE TO VYUŽIJE:
Další krok 20_2_E parser z RAW HTML vytáhne:
- provider_player_id
- provider_team_id
- jméno hráče
- tým
- profil URL
- případně foto a základní atributy

NAVAZUJE NA:
20_2_A_VB_VOLLEYBOX_PROVIDER_AUDIT
20_2_B_VB_VOLLEYBOX_PROVIDER_RESEARCH
20_2_C_VOLLEYBOX_TECHNICAL_FEASIBILITY

DALŠÍ KROK:
20_2_E_VB_VOLLEYBOX_PARSE_V1

SPUŠTĚNÍ:
cd C:\\MatchMatrix-platform
C:\\Python314\\python.exe workers\\volleyball\\20_2_D_VB_VOLLEYBOX_RAW_PULL_V1.py

POZNÁMKA:
Volleybox je zatím APPROVED_FOR_PROTOTYPE / TERMS_REVIEW.
Tento worker je pouze technický prototyp na malém počtu ručně zadaných URL.
===============================================================================
"""

from __future__ import annotations

import re
import json
import time
from datetime import datetime
from pathlib import Path
from urllib.request import Request, urlopen
from urllib.error import HTTPError, URLError


BASE_DIR = Path(r"C:\MatchMatrix-platform")
RAW_DIR = BASE_DIR / "data" / "raw" / "volleybox"

TEST_URLS = [
    "https://volleybox.net/cs/jozef-verdinek-p89945",
    "https://volleybox.net/cs/modena-volley-t1737",
]


def detect_entity_and_id(url: str) -> tuple[str, str]:
    player_match = re.search(r"-p(\d+)", url)
    if player_match:
        return "player", player_match.group(1)

    team_match = re.search(r"-t(\d+)", url)
    if team_match:
        return "team", team_match.group(1)

    return "unknown", "unknown"


def safe_filename(entity_type: str, provider_id: str) -> str:
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    return f"volleybox_{entity_type}_{provider_id}_{ts}.json"


def fetch_html(url: str) -> tuple[int, str]:
    request = Request(
        url,
        headers={
            "User-Agent": (
                "MatchMatrixResearchBot/0.1 "
                "(technical prototype; contact: internal research)"
            ),
            "Accept": "text/html,application/xhtml+xml",
            "Accept-Language": "cs,en;q=0.8",
        },
    )

    with urlopen(request, timeout=30) as response:
        status_code = int(response.status)
        html = response.read().decode("utf-8", errors="replace")

    return status_code, html


def write_raw_payload(url: str, status_code: int, html: str, error: str | None = None) -> Path:
    entity_type, provider_id = detect_entity_and_id(url)

    RAW_DIR.mkdir(parents=True, exist_ok=True)

    payload = {
        "provider": "volleybox",
        "sport_code": "VB",
        "entity_type": entity_type,
        "provider_id": provider_id,
        "source_url": url,
        "fetched_at": datetime.now().isoformat(timespec="seconds"),
        "http_status": status_code,
        "error": error,
        "raw_html": html,
    }

    out_file = RAW_DIR / safe_filename(entity_type, provider_id)

    with out_file.open("w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)

    return out_file


def main() -> int:
    print("=" * 80)
    print("MATCHMATRIX 20_2_D – VB VOLLEYBOX RAW PULL V1")
    print("=" * 80)
    print(f"RAW_DIR: {RAW_DIR}")
    print(f"URLS   : {len(TEST_URLS)}")
    print("=" * 80)

    ok = 0
    fail = 0

    for url in TEST_URLS:
        entity_type, provider_id = detect_entity_and_id(url)

        print("-" * 80)
        print(f"URL          : {url}")
        print(f"entity_type  : {entity_type}")
        print(f"provider_id  : {provider_id}")

        try:
            status_code, html = fetch_html(url)
            out_file = write_raw_payload(url, status_code, html)

            print(f"HTTP         : {status_code}")
            print(f"HTML chars   : {len(html)}")
            print(f"RAW saved    : {out_file}")
            ok += 1

        except HTTPError as e:
            error_msg = f"HTTPError: {e.code} {e.reason}"
            out_file = write_raw_payload(url, int(e.code), "", error_msg)
            print(f"ERROR        : {error_msg}")
            print(f"RAW saved    : {out_file}")
            fail += 1

        except URLError as e:
            error_msg = f"URLError: {e.reason}"
            out_file = write_raw_payload(url, 0, "", error_msg)
            print(f"ERROR        : {error_msg}")
            print(f"RAW saved    : {out_file}")
            fail += 1

        except Exception as e:
            error_msg = f"{type(e).__name__}: {e}"
            out_file = write_raw_payload(url, 0, "", error_msg)
            print(f"ERROR        : {error_msg}")
            print(f"RAW saved    : {out_file}")
            fail += 1

        time.sleep(2)

    print("=" * 80)
    print("SUMMARY")
    print(f"OK   : {ok}")
    print(f"FAIL : {fail}")
    print("=" * 80)

    return 0 if fail == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())