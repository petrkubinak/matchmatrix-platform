from __future__ import annotations
from generic_api_sport_provider import GenericApiSportProvider
from typing import Dict, Tuple, Type

from api_football_provider import ApiFootballProvider
from api_hockey_provider import ApiHockeyProvider
from base_provider import BaseProvider

# Klíč: (provider_code, sport_code)
PROVIDERS: Dict[Tuple[str, str], Type[BaseProvider]] = {
    ("api_football", "football"): ApiFootballProvider,
    ("api_hockey", "hockey"): ApiHockeyProvider,
    # 🔥 NOVÉ SPORTY (generic)
    ("api_tennis", "tennis"): GenericApiSportProvider,
    ("api_sport", "basketball"): GenericApiSportProvider,
    ("api_volleyball", "volleyball"): GenericApiSportProvider,
    ("api_handball", "handball"): GenericApiSportProvider,
    ("api_baseball", "baseball"): GenericApiSportProvider,
    ("api_rugby", "rugby"): GenericApiSportProvider,
    ("api_cricket", "cricket"): GenericApiSportProvider,
    ("api_field_hockey", "field_hockey"): GenericApiSportProvider,
    ("api_american_football", "american_football"): GenericApiSportProvider,
    ("api_esports", "esports"): GenericApiSportProvider,
    ("api_darts", "darts"): GenericApiSportProvider,
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