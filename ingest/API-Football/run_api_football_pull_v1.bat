@echo off
cd /d C:\MatchMatrix-platform\ingest\API-Football
python api_football_pull_v1.py --league-id 39 --season 2025 --fixtures
pause