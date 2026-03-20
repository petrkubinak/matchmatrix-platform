from __future__ import annotations

from abc import ABC
from typing import Any, Dict, Optional


class BaseProvider(ABC):
    """
    Základní provider třída pro Unified Ingest V1.

    V1 je záměrně jednoduchý wrapper:
    - provider dostane provider_code a sport_code
    - expose metody pro entity
    - konkrétní provider si sám řeší, jak daný krok spustí
      (python / powershell / bat / interní logika)

    Návratová hodnota všech pull_* metod:
    {
        "status": "ok" | "warning" | "error",
        "message": "...",
        "command": [...],        # volitelně, co bylo spuštěno
        "returncode": 0,         # volitelně
        "stdout_lines": 120      # volitelně
    }
    """

    def __init__(self, provider_code: str, sport_code: str) -> None:
        self.provider_code = provider_code
        self.sport_code = sport_code

    def pull_leagues(self, **kwargs: Any) -> Dict[str, Any]:
        raise NotImplementedError(
            f"Provider {self.provider_code}/{self.sport_code} nepodporuje entity=leagues."
        )

    def pull_teams(self, **kwargs: Any) -> Dict[str, Any]:
        raise NotImplementedError(
            f"Provider {self.provider_code}/{self.sport_code} nepodporuje entity=teams."
        )

    def pull_fixtures(self, **kwargs: Any) -> Dict[str, Any]:
        raise NotImplementedError(
            f"Provider {self.provider_code}/{self.sport_code} nepodporuje entity=fixtures."
        )

    def pull_odds(self, **kwargs: Any) -> Dict[str, Any]:
        raise NotImplementedError(
            f"Provider {self.provider_code}/{self.sport_code} nepodporuje entity=odds."
        )

    def pull_players(self, **kwargs: Any) -> Dict[str, Any]:
        raise NotImplementedError(
            f"Provider {self.provider_code}/{self.sport_code} nepodporuje entity=players."
        )

    def dispatch(self, entity: str, **kwargs: Any) -> Dict[str, Any]:
        """
        Spustí správnou metodu podle entity.
        """
        entity = (entity or "").strip().lower()

        if entity == "leagues":
            return self.pull_leagues(**kwargs)
        if entity == "teams":
            return self.pull_teams(**kwargs)
        if entity == "fixtures":
            return self.pull_fixtures(**kwargs)
        if entity == "odds":
            return self.pull_odds(**kwargs)
        if entity == "players":
            return self.pull_players(**kwargs)

        raise ValueError(f"Neznámá entity '{entity}'.")