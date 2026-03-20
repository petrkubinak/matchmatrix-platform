from __future__ import annotations

from typing import Dict, Tuple, Type

from api_football_provider import ApiFootballProvider
from api_hockey_provider import ApiHockeyProvider
from base_provider import BaseProvider

# Klíč: (provider_code, sport_code)
PROVIDERS: Dict[Tuple[str, str], Type[BaseProvider]] = {
    ("api_football", "football"): ApiFootballProvider,
    ("api_hockey", "hockey"): ApiHockeyProvider,
}


def get_provider_class(provider_code: str, sport_code: str) -> Type[BaseProvider]:
    key = ((provider_code or "").strip().lower(), (sport_code or "").strip().lower())

    if key not in PROVIDERS:
        available = ", ".join([f"{p}/{s}" for p, s in sorted(PROVIDERS.keys())])
        raise ValueError(
            f"Provider pro kombinaci {key[0]}/{key[1]} nebyl nalezen. "
            f"Dostupné kombinace: {available}"
        )

    return PROVIDERS[key]