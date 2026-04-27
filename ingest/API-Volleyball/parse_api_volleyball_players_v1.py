# -*- coding: utf-8 -*-
"""
parse_api_volleyball_players_v1.py

STATUS:
VB players endpoint neexistuje → parser je placeholder

Účel:
- držet standard struktury
- logovat pokus o parsování
- připraveno pro budoucí provider

"""

from pathlib import Path
import json

RAW_DIR = Path(r"C:\MatchMatrix-platform\data\raw\api_volleyball\players")


def main():
    print("=" * 70)
    print("MATCHMATRIX - VB PLAYERS PARSER V1")
    print("=" * 70)

    if not RAW_DIR.exists():
        print("RAW složka neexistuje.")
        return

    files = sorted(RAW_DIR.glob("*.json"), key=lambda p: p.stat().st_mtime, reverse=True)

    if not files:
        print("Žádné RAW soubory.")
        return

    latest = files[0]
    print(f"Použit RAW file: {latest}")

    with latest.open("r", encoding="utf-8") as f:
        data = json.load(f)

    errors = data.get("errors")
    results = data.get("results")

    print(f"errors: {errors}")
    print(f"results: {results}")

    if errors:
        print("❌ Endpoint není dostupný → parser končí.")
        return

    print("⚠️ Neočekávaný stav – data existují, nutno implementovat parsing.")


if __name__ == "__main__":
    main()