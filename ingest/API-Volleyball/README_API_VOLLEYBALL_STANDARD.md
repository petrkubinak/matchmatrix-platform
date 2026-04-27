# API-Volleyball – MatchMatrix ingest standard

## Stav
VB core data jsou v DB potvrzená:
- leagues: CONFIRMED
- teams: CONFIRMED
- fixtures: CONFIRMED
- odds: PLANNED
- players: PLANNED / provider endpoint /players neexistuje

## Cíl složky
Tato složka musí obsahovat stejný fyzický pattern jako ostatní sporty:

### Pull
- pull_api_volleyball_leagues_v1.ps1
- pull_api_volleyball_teams_v1.ps1
- pull_api_volleyball_fixtures_v1.ps1
- pull_api_volleyball_odds_v1.ps1
- pull_api_volleyball_players_raw_v1.ps1

### Parse
- parse_api_volleyball_leagues_v1.py
- parse_api_volleyball_teams_v1.py
- parse_api_volleyball_fixtures_v1.py
- parse_api_volleyball_odds_v1.py
- parse_api_volleyball_players_v1.py

## Poznámka
Core VB je potvrzené v DB, ale fyzická složka byla nekompletní.
Tento standard dorovnává složku, aby odpovídala TN/HB/RGB/CK patternu.

## Players
API-Volleyball endpoint /players neexistuje.
Players proto zůstávají jako people layer pro náhradního providera.