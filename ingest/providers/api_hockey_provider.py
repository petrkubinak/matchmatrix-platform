from __future__ import annotations

import os
import subprocess
from typing import Any, Dict, List

from base_provider import BaseProvider


class ApiHockeyProvider(BaseProvider):
    """
    Unified provider wrapper pro API-Hockey.
    """

    def __init__(self, provider_code: str, sport_code: str) -> None:
        super().__init__(provider_code, sport_code)
        self.base_dir = r"C:\MatchMatrix-platform"
        self.ps_dir = os.path.join(self.base_dir, "ingest", "API-Hockey")

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

        assert process.stdout is not None
        for line in process.stdout:
            stdout_lines += 1
            print(line.rstrip())

        process.wait()

        status = "ok" if process.returncode == 0 else "error"

        return {
            "status": status,
            "message": "Command finished.",
            "command": command,
            "returncode": process.returncode,
            "stdout_lines": stdout_lines,
        }

    def _ps_base_command(self, ps1_path: str, run_id: Any) -> List[str]:
        return [
            "powershell",
            "-ExecutionPolicy", "Bypass",
            "-File", ps1_path,
            "-RunId", str(run_id),
        ]

    def pull_leagues(self, **kwargs: Any) -> Dict[str, Any]:
        ps1 = os.path.join(self.ps_dir, "pull_api_hockey_leagues.ps1")
        run_id = kwargs.get("run_id")
        command = self._ps_base_command(ps1, run_id)
        return self._run_command(command, cwd=self.ps_dir)

    def pull_teams(self, **kwargs: Any) -> Dict[str, Any]:
        ps1 = os.path.join(self.ps_dir, "pull_api_hockey_teams.ps1")
        run_id = kwargs.get("run_id")
        command = self._ps_base_command(ps1, run_id)
        return self._run_command(command, cwd=self.ps_dir)

    def pull_fixtures(self, **kwargs: Any) -> Dict[str, Any]:
        raise NotImplementedError(
            "API-Hockey fixtures zatím ve V1 nejsou napojené. "
            "Nejdřív připravíme source wrapper / pull script."
        )

    def pull_odds(self, **kwargs: Any) -> Dict[str, Any]:
        raise NotImplementedError(
            "API-Hockey odds zatím ve V1 nejsou napojené. "
            "Nejdřív připravíme source wrapper / pull script."
        )

    def pull_players(self, **kwargs: Any) -> Dict[str, Any]:
        raise NotImplementedError(
            "API-Hockey players zatím ve V1 nejsou napojené."
        )