Zápis pro nový chat

Pokračujeme v MatchMatrix na větvi:

HB Teams Completion → HB CORE READY
Aktuální stav

Cíl není řešit jednotlivé tabulky, ale připravit celý sport do stavu:

SPORT READY
= CORE + PEOPLE + MEDIA + ODDS

U každého sportu postupujeme po vrstvách:

1. CORE
2. PEOPLE
3. MEDIA
4. ODDS
Důležité pravidlo

Používáme novou sjednocenou staging architekturu:

staging.stg_api_payloads
staging.stg_provider_leagues
staging.stg_provider_teams
staging.stg_provider_fixtures
staging.stg_provider_players

Nezačínat automaticky se starými tabulkami typu:

staging.api_handball_teams
staging.api_hockey_teams

Ty nemusí existovat.

HB stav před opravou
HB fixtures staging: 14 128
HB teams staging: 1 005
missing provider teams: 463
blocked fixtures: 4 853
merge-ready fixtures: 9 275

Příčina:

HB Teams harvest nebyl dokončený.

Planner:

DONE    211
PENDING 633

Navíc v ops.ingest_entity_plan chyběl worker binding:

api_handball / HB / teams / worker_script = NULL

Opraveno na:

ingest/API-Házená/pull_api_handball_teams.ps1
Další nalezený blokátor

V souboru:

C:\MatchMatrix-platform\ingest\API-Sport\pull_api_sport_teams.ps1

byla natvrdo cesta:

C:\Python314\python.exe

Opraveno na:

$pythonExe = (Get-Command python).Source
Po opravě

Test 10 jobů prošel OK.

Stav po prvním testu:

done    221
error    10
pending 613
teams   1107

Dnes spuštěna dávka 100 jobů.

Aktuální stav:

done    321
error    10
pending 513
teams   1160

To znamená:

+100 jobů DONE
+53 týmů ve staging.stg_provider_teams
Další krok v novém chatu

Pokračovat další dávkou HB Teams:

cd C:\MatchMatrix-platform

python workers\run_ingest_planner_jobs.py --sport HB --entity teams --run-group HB_HISTORICAL_CORE_2022_2024 --limit 100

Potom ověřit:

SELECT
    status,
    COUNT(*) AS jobs
FROM ops.ingest_planner
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND entity = 'teams'
GROUP BY status
ORDER BY status;

a:

SELECT COUNT(*)
FROM staging.stg_provider_teams
WHERE provider = 'api_handball';
Po dojetí pending jobů

Až bude pending co nejblíže 0, resetovat starých 10 error jobů, protože vznikly před opravou Python cesty.

Potom znovu spočítat:

missing provider teams
blocked fixtures
merge-ready fixtures

Cíl:

snížit missing provider teams
odblokovat co nejvíc z 4 853 fixtures
dokončit HB CORE
Pracovní pravidla

Postupujeme po jedné akci.

Každý SQL skript má mít MatchMatrix hlavičku:

CO TO JE
K ČEMU TO JE
KDE TO UVIDÍME
JAK SE TO VYUŽIJE

SQL spouštíme v DBeaveru.

Python/PowerShell spouštíme ve VS terminálu.

U skriptů vždy uvádět:

přesná složka
název souboru
spouštěcí příkaz

Cílem není jen oprava HB, ale princip:

jeden sport dotáhnout přes CORE → PEOPLE → MEDIA → ODDS
až do SPORT READY