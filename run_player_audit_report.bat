@echo off

echo ============================================================
echo MATCHMATRIX - PLAYER SEASON STATISTICS AUDIT
echo ============================================================

cd /d C:\MatchMatrix-platform\workers

powershell -ExecutionPolicy Bypass -File run_audit_player_season_statistics_report_docker_v1.ps1 ^
  -ContainerName "matchmatrix_postgres" ^
  -PgUser "matchmatrix" ^
  -PgDatabase "matchmatrix"

echo.
echo ============================================================
echo AUDIT DOKONCEN
echo ============================================================
echo Report najdes ve slozce:
echo C:\MatchMatrix-platform\reports\player_audit
echo.

pause