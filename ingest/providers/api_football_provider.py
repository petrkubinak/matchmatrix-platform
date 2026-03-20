from __future__ import annotations

import os
import subprocess
from datetime import date
from typing import Any, Dict, List

from base_provider import BaseProvider


class ApiFootballProvider(BaseProvider):
    def __init__(self, provider_code: str, sport_code: str) -> None:
        super().__init__(provider_code, sport_code)
        self.base_dir = r"C:\MatchMatrix-platform"
        self.ps_dir = os.path.join(self.base_dir, "ingest", "API-Football")

    def _run_command(self, command: List[str], cwd: str | None = None) -> Dict[str, Any]:
        print("RUN:", " ".join(command))

        process = subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            cwd=cwd
        )

        stdout_lines = 0
        collected_output = []

        assert process.stdout is not None
        for line in process.stdout:
            line = line.rstrip()
            collected_output.append(line)
            stdout_lines += 1
            print(line)

        process.wait()

        full_output = "\n".join(collected_output)

        if process.returncode != 0:
            status = "error"
            message = "Command failed."
        elif "API errors:" in full_output:
            status = "error"
            message = "API returned validation or request errors."
        elif "No fixtures returned." in full_output:
            status = "warning"
            message = "No fixtures returned for this league/season/date range."
        elif "No teams returned." in full_output:
            status = "warning"
            message = "No teams returned for this league/season."
        else:
            status = "ok"
            message = "Command finished."

        return {
            "status": status,
            "message": message,
            "command": command,
            "returncode": process.returncode,
            "stdout_lines": stdout_lines,
            "output": full_output,
        }

    def _ps_base_command(self, ps1_path: str, run_id: Any) -> List[str]:
        return [
            "powershell",
            "-ExecutionPolicy", "Bypass",
            "-File", ps1_path,
            "-RunId", str(run_id),
        ]

    def _football_season_window(self, season: int) -> tuple[str, str]:
        """
        Football season window:
        season=2022 -> 2022-07-01 až 2023-06-30

        API-Football chce Y-m-d.
        """
        from_date = date(int(season), 7, 1)
        to_date = date(int(season) + 1, 6, 30)
        return from_date.strftime("%Y-%m-%d"), to_date.strftime("%Y-%m-%d")

    def pull_leagues(self, **kwargs: Any) -> Dict[str, Any]:
        ps1 = os.path.join(self.ps_dir, "pull_api_football_leagues.ps1")
        run_id = kwargs.get("run_id")
        command = self._ps_base_command(ps1, run_id)
        return self._run_command(command, cwd=self.ps_dir)

    def pull_teams(self, **kwargs: Any) -> Dict[str, Any]:
        ps1 = os.path.join(self.ps_dir, "pull_api_football_teams.ps1")
        run_id = kwargs.get("run_id")
        league_id = kwargs.get("league_id")
        season = kwargs.get("season")

        if not league_id:
            return {
                "status": "error",
                "message": "API-Football teams vyžadují parametr --league-id.",
                "command": None,
                "returncode": 2,
                "stdout_lines": 0,
            }

        if not season:
            return {
                "status": "error",
                "message": "API-Football teams vyžadují parametr --season.",
                "command": None,
                "returncode": 2,
                "stdout_lines": 0,
            }

        command = self._ps_base_command(ps1, run_id)
        command.extend(["-LeagueId", str(league_id)])
        command.extend(["-Season", str(season)])

        return self._run_command(command, cwd=self.ps_dir)

    def pull_fixtures(self, **kwargs: Any) -> Dict[str, Any]:
        ps1 = os.path.join(self.ps_dir, "pull_api_football_fixtures.ps1")
        run_id = kwargs.get("run_id")
        league_id = kwargs.get("league_id")
        season = kwargs.get("season")

        if not league_id:
            return {
                "status": "error",
                "message": "API-Football fixtures vyžadují parametr --league-id.",
                "command": None,
                "returncode": 2,
                "stdout_lines": 0,
            }

        if not season:
            return {
                "status": "error",
                "message": "API-Football fixtures vyžadují parametr --season.",
                "command": None,
                "returncode": 2,
                "stdout_lines": 0,
            }

        from_date, to_date = self._football_season_window(int(season))

        command = self._ps_base_command(ps1, run_id)
        command.extend(["-LeagueId", str(league_id)])
        command.extend(["-Season", str(season)])
        command.extend(["-From", from_date])
        command.extend(["-To", to_date])

        return self._run_command(command, cwd=self.ps_dir)

    def pull_odds(self, **kwargs: Any) -> Dict[str, Any]:
        ps1 = os.path.join(self.ps_dir, "pull_api_football_odds.ps1")
        run_id = kwargs.get("run_id")
        league_id = kwargs.get("league_id")
        season = kwargs.get("season")

        if not league_id:
            return {
                "status": "error",
                "message": "API-Football odds vyžadují parametr --league-id.",
                "command": None,
                "returncode": 2,
                "stdout_lines": 0,
            }

        if not season:
            return {
                "status": "error",
                "message": "API-Football odds vyžadují parametr --season.",
                "command": None,
                "returncode": 2,
                "stdout_lines": 0,
            }

        year = int(season)
        date_from = f"{year}-07-01"
        date_to = f"{year + 1}-06-30"

        command = self._ps_base_command(ps1, run_id)
        command.extend(["-LeagueId", str(league_id)])
        command.extend(["-Season", str(season)])
        command.extend(["-From", date_from])
        command.extend(["-To", date_to])

        return self._run_command(command, cwd=self.ps_dir)


    def pull_players(self, **kwargs: Any) -> Dict[str, Any]:
        """
        Players ingest pro API-Football.
        Přesměrováno na nový Python worker:
        pull_api_football_players_v4.py

        Důvod:
        starý PowerShell worker pull_api_football_players.ps1
        není v souladu s aktuální OPS/entity architekturou.
        """

        py_worker = os.path.join(self.base_dir, "workers", "pull_api_football_players_v4.py")

        run_id = kwargs.get("run_id")
        league_id = kwargs.get("league_id")
        season = kwargs.get("season")

        if not league_id:
            return {
                "status": "error",
                "message": "API-Football players vyžadují parametr --league-id.",
                "command": None,
                "returncode": 2,
                "stdout_lines": 0,
            }

        if not season:
            return {
                "status": "error",
                "message": "API-Football players vyžadují parametr --season.",
                "command": None,
                "returncode": 2,
                "stdout_lines": 0,
            }

        if not os.path.exists(py_worker):
            return {
                "status": "error",
                "message": f"Players worker nebyl nalezen: {py_worker}",
                "command": None,
                "returncode": 2,
                "stdout_lines": 0,
            }

        command = [
            "C:\\Python314\\python.exe",
            py_worker,
            "--provider", self.provider_code,
            "--sport", self.sport_code,
            "--league-id", str(league_id),
            "--season", str(season),
        ]

        if run_id is not None:
            command.extend(["--run-id", str(run_id)])

        return self._run_command(command, cwd=self.base_dir)