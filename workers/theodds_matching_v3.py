# C:\MatchMatrix-platform\workers\theodds_matching_v3.py
# ------------------------------------------------------------
# MATCHMATRIX / THEODDS V3
# Helper modul pro:
# - UTF-8 bezpečnou normalizaci názvů týmů
# - odstranění diakritiky
# - základní sjednocení názvů
# - jednoduché similarity skóre
# - klasifikaci důvodu selhání matchingu
#
# Cíl:
# tento soubor bude volat run_theodds_ingest_v3.py
# ------------------------------------------------------------

from __future__ import annotations

import re
import unicodedata
from difflib import SequenceMatcher
from typing import Iterable


# Slova, která často jen znečišťují matching
GENERIC_WORDS = {
    "fc", "cf", "ac", "afc", "fk", "sk", "bk",
    "club", "football", "soccer", "team", "deportivo",
    "club atletico", "atletico club"
}

# Časté náhrady / sjednocení
REPLACEMENTS = {
    "&": " and ",
    "utd": "united",
    "mtk": "mtk",   # ponecháváme, jen ukázka že můžeš rozšiřovat
    "st.": "saint",
    "st ": "saint ",
    "int'l": "international",
}

CHAR_REPLACEMENTS = {
    "ø": "o",
    "ö": "o",
    "ó": "o",
    "ò": "o",
    "ô": "o",
    "õ": "o",
    "ő": "o",
    "ø": "o",
    "æ": "ae",
    "å": "a",
    "ä": "a",
    "á": "a",
    "à": "a",
    "â": "a",
    "ã": "a",
    "č": "c",
    "ć": "c",
    "ç": "c",
    "ď": "d",
    "đ": "d",
    "é": "e",
    "è": "e",
    "ê": "e",
    "ë": "e",
    "ě": "e",
    "í": "i",
    "ì": "i",
    "î": "i",
    "ï": "i",
    "ľ": "l",
    "ĺ": "l",
    "ń": "n",
    "ň": "n",
    "ñ": "n",
    "ř": "r",
    "ŕ": "r",
    "š": "s",
    "ś": "s",
    "ť": "t",
    "ú": "u",
    "ù": "u",
    "û": "u",
    "ü": "u",
    "ů": "u",
    "ý": "y",
    "ž": "z",
    "ź": "z",
    "ż": "z",
}

SAFE_TOKEN_REPLACEMENTS = {
    "utd": "united",
    "man": "manchester",
    "mtk": "mtk",
}

def strip_accents(value: str) -> str:
    """
    Odstraní diakritiku a doplní ruční převody speciálních znaků.
    Bolívar -> bolivar
    Peñarol -> penarol
    København -> kobenhavn
    """
    if value is None:
        return ""

    text = value
    for old, new in CHAR_REPLACEMENTS.items():
        text = text.replace(old, new).replace(old.upper(), new.upper())

    normalized = unicodedata.normalize("NFKD", text)
    return "".join(ch for ch in normalized if not unicodedata.combining(ch))

def replace_safe_tokens(value: str) -> str:
    """
    Nahrazuje jen bezpečné samostatné tokeny.
    """
    if not value:
        return ""

    words = value.split()
    mapped = [SAFE_TOKEN_REPLACEMENTS.get(w, w) for w in words]
    return normalize_whitespace(" ".join(mapped))

def normalize_whitespace(value: str) -> str:
    """Sjednotí mezery."""
    return re.sub(r"\s+", " ", value).strip()


def basic_cleanup(value: str) -> str:
    """
    Základní očištění textu:
    - lowercase
    - UTF-8 / diakritika pryč
    - interpunkce pryč
    - náhrady z REPLACEMENTS
    """
    if value is None:
        return ""

    text = value.strip().lower()
    text = strip_accents(text)

    for old, new in REPLACEMENTS.items():
        text = text.replace(old, new)

    # vše kromě písmen/čísel/mezery nahradíme mezerou
    text = re.sub(r"[^a-z0-9 ]+", " ", text)
    text = normalize_whitespace(text)
    return text


def remove_generic_words(value: str) -> str:
    """
    Odstraní generická slova typu FC, SC, Club...
    """
    if not value:
        return ""

    words = value.split()
    filtered = [w for w in words if w not in GENERIC_WORDS]
    return normalize_whitespace(" ".join(filtered))


def normalize_team_name(value: str) -> str:
    """
    Hlavní normalizace týmového názvu.

    Důležité:
    - běžně odstraňujeme generická slova (fc, sc, club...)
    - ale u některých názvů je "club" součást identity a NESMÍ zmizet,
      jinak vznikají kolize:
        Club Nacional -> nacional   (špatně)
        CD Nacional   -> nacional   (jiný klub)

    Proto pro citlivé prefixy zachováme původní tvar po basic cleanup.
    """
    text = basic_cleanup(value)
    text = replace_safe_tokens(text)

    # --- citlivé výjimky: "club" je zde součást identity ---
    # Club Nacional / Club Nacional de Football / Club Nacional Potosi ...
    if text.startswith("club nacional"):
        return normalize_whitespace(text)

    # standardní větev pro ostatní týmy
    text = remove_generic_words(text)
    return normalize_whitespace(text)


def token_set(value: str) -> set[str]:
    """
    Rozbije text na množinu tokenů.
    """
    if not value:
        return set()
    return {x for x in value.split() if x}


def token_overlap_score(a: str, b: str) -> float:
    """
    Pomocné skóre podle překryvu tokenů.
    0.0 až 1.0
    """
    set_a = token_set(a)
    set_b = token_set(b)

    if not set_a or not set_b:
        return 0.0

    common = len(set_a & set_b)
    denom = max(len(set_a), len(set_b))
    if denom == 0:
        return 0.0

    return common / denom


def sequence_score(a: str, b: str) -> float:
    """
    Difflib similarity 0.0 až 1.0
    """
    if not a or not b:
        return 0.0
    return SequenceMatcher(None, a, b).ratio()


def combined_similarity(raw_a: str, raw_b: str) -> float:
    """
    Kombinované similarity skóre.
    Používá:
    - sequence ratio
    - token overlap
    - containment bonus
    """
    a = normalize_team_name(raw_a)
    b = normalize_team_name(raw_b)

    seq = sequence_score(a, b)
    tok = token_overlap_score(a, b)

    containment = 0.0
    if a and b and (a in b or b in a):
        containment = 0.20

    score = (seq * 0.55) + (tok * 0.25) + containment
    return round(min(score, 1.0), 4)


def best_candidate(source_name: str, candidate_names: Iterable[str]) -> tuple[str | None, float]:
    """
    Vrátí nejlepšího kandidáta + score.
    """
    best_name = None
    best_score = 0.0

    for candidate in candidate_names:
        score = combined_similarity(source_name, candidate)
        if score > best_score:
            best_name = candidate
            best_score = score

    return best_name, best_score


def classify_matching_issue(
    home_name: str | None,
    away_name: str | None,
    matched_home: bool,
    matched_away: bool,
    match_id: int | None,
    similarity_score: float | None = None,
) -> str:
    """
    Vrátí jednotný důvod selhání / stavu pro logging.

    Použití ve workeru:
    - nejdřív namatchuješ home/away týmy
    - potom zkusíš dohledat match_id
    - pak zavoláš tuto funkci
    """
    if not home_name or not away_name:
        return "MISSING_TEAM_NAME"

    if not matched_home and not matched_away:
        return "NO_TEAM_MATCH_BOTH"

    if not matched_home:
        return "NO_TEAM_MATCH_HOME"

    if not matched_away:
        return "NO_TEAM_MATCH_AWAY"

    if match_id is None:
        if similarity_score is not None and similarity_score < 0.75:
            return "LOW_COVERAGE"
        return "NO_MATCH_ID"

    return "MATCH_OK"


def build_match_debug_payload(
    provider_name: str,
    league_name: str | None,
    event_name: str | None,
    home_name_raw: str | None,
    away_name_raw: str | None,
    home_name_normalized: str | None,
    away_name_normalized: str | None,
    best_home_candidate: str | None,
    best_away_candidate: str | None,
    best_home_score: float | None,
    best_away_score: float | None,
    match_id: int | None,
    issue_code: str,
) -> dict:
    """
    Jednotný debug payload pro log / DB / JSON dump.
    """
    return {
        "provider": provider_name,
        "league_name": league_name,
        "event_name": event_name,
        "home_raw": home_name_raw,
        "away_raw": away_name_raw,
        "home_normalized": home_name_normalized,
        "away_normalized": away_name_normalized,
        "best_home_candidate": best_home_candidate,
        "best_away_candidate": best_away_candidate,
        "best_home_score": best_home_score,
        "best_away_score": best_away_score,
        "match_id": match_id,
        "issue_code": issue_code,
    }


if __name__ == "__main__":
    # Rychlý lokální test
    samples = [
        ("Peñarol", "Penarol"),
        ("Bolívar", "Bolivar"),
        ("Man Utd", "Manchester United"),
        ("FC København", "Kobenhavn"),
        ("Club Atlético Peñarol", "Penarol"),
    ]

    print("=== THEODDS MATCHING V3 TEST ===")
    for left, right in samples:
        print(f"{left!r} vs {right!r}")
        print("  norm L:", normalize_team_name(left))
        print("  norm R:", normalize_team_name(right))
        print("  score :", combined_similarity(left, right))
        print()