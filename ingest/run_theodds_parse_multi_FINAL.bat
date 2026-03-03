@echo off
setlocal

REM DB připojení
set DB_DSN=host=localhost port=5432 dbname=matchmatrix user=mm_ingest password=mm_ingest_123
set THEODDS_LEAGUE_WHITELIST=soccer_epl,soccer_germany_bundesliga,soccer_italy_serie_a,soccer_france_ligue_one,soccer_spain_la_liga,soccer_netherlands_eredivisie,soccer_portugal_primeira_liga,soccer_uefa_champs_league

REM The Odds API klíč (doporučení: nastav si permanentně v systému nebo sem doplň)
REM set THEODDS_API_KEY=PASTE_YOUR_KEY_HERE

REM Volitelné ladění / omezení
REM set THEODDS_REGIONS=eu
REM set THEODDS_SLEEP_SEC=1.2
REM set THEODDS_MAX_LEAGUES=10

cd /d "%~dp0"
python "%~dp0theodds_parse_multi_FINAL.py"

pause
