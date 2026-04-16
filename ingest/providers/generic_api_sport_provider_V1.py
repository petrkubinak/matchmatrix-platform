from __future__ import annotations

import os
import subprocess
from base_provider import BaseProvider


class GenericApiSportProvider(BaseProvider):
    """
    Generic provider pro multisport (api_sport, api_tennis, api_*)

    Používá PowerShell skripty podle entity.
    """

    def __init__(self, provider: str, sport: str):
        super().__init__(provider, sport)
        self.provider = provider
        self.sport = sport

    def dispatch(
        self,
        entity: str,
        run_id: int,
        season: str | None = None,
        league_id: str | None = None,
        run_group: str | None = None,
        days_ahead: int | None = None,
        force: bool = False,
    ):
        try:
            script_map = {
                "leagues": "pull_api_sport_leagues.ps1",
                "teams": "pull_api_sport_teams.ps1",
                "fixtures": "pull_api_sport_fixtures.ps1",
                "players": "pull_api_sport_players.ps1",
            }

            if entity not in script_map:
                raise ValueError(f"Entity '{entity}' není podporována v Generic provideru.")

            script_name = script_map[entity]

            script_path = os.path.join(
                os.getcwd(),
                "ingest",
                "API-Sport",
                script_name
            )

            sport_map = {
                "FB": "football",
                "HK": "hockey",
                "BK": "basketball",
                "VB": "volleyball",
                "HB": "handball",
                "BSB": "baseball",
                "RGB": "rugby",
                "MMA": "mma",
                "AFB": "american_football",
                "TN": "tennis",
            }

            sport_raw = str(self.sport or "").upper()
            sport_name = sport_map.get(sport_raw, str(self.sport).lower())

            cmd = [
                "powershell",
                "-ExecutionPolicy",
                "Bypass",
                "-File",
                script_path,
                "-RunId",
                str(run_id),
                "-Provider",
                str(self.provider),
                "-SportCode",
                sport_name,
            ]

            if league_id:
                cmd += ["-LeagueId", str(league_id)]

            if season and str(season).strip() != "":
                cmd += ["-Season", str(season)]

            print(f"RUN: {' '.join(cmd)}")

            result = subprocess.run(cmd, capture_output=True, text=True)

            message = result.stderr.strip()
            if not message:
                message = "Command finished."

            return {
                "status": "ok" if result.returncode == 0 else "error",
                "message": message,
                "returncode": result.returncode,
                "stdout_lines": len(result.stdout.splitlines()),
            }

        except Exception as exc:
            return {
                "status": "error",
                "message": str(exc),
                "returncode": 1,
                "stdout_lines": 0,
            }