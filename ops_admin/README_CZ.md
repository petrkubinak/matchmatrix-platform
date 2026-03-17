# MatchMatrix – audit souborů ve Windows

Tato sada dělá audit projektových složek a porovnání proti minulému běhu.

## Co kontroluje

- `C:\MatchMatrix-platform\workers`
- `C:\MatchMatrix-platform\ingest`
- `C:\MatchMatrix-platform\ingest\API-Football`
- `C:\MatchMatrix-platform\MatchMatrix-platform\Scripts`
- `C:\MatchMatrix-platform\MatchMatrix-platform\Dump`

## Co vytváří

Výstupní složka:

`C:\MatchMatrix-platform\reports\file_audit`

V ní vznikne:

- `latest_report.md` – poslední souhrnný report
- `latest_files.csv` – kompletní seznam souborů
- `latest_changes.csv` – změny oproti minulému běhu
- `latest_snapshot.json` – poslední snapshot
- `snapshots\snapshot_YYYYMMDD_HHMMSS.json` – historie běhů
- `csv\files_YYYYMMDD_HHMMSS.csv`
- `csv\changes_YYYYMMDD_HHMMSS.csv`
- `md\report_YYYYMMDD_HHMMSS.md`

## Kam uložit

### 1. Python skript
Ulož jako:

`C:\MatchMatrix-platform\ops_admin\matchmatrix_file_audit.py`

### 2. PowerShell spouštěč
Ulož jako:

`C:\MatchMatrix-platform\ops_admin\run_matchmatrix_file_audit.ps1`

## Jak spustit

PowerShell:

```powershell
C:\MatchMatrix-platform\ops_admin\run_matchmatrix_file_audit.ps1
```

nebo přímo Python:

```powershell
C:\Python314\python.exe C:\MatchMatrix-platform\ops_admin\matchmatrix_file_audit.py --output-dir C:\MatchMatrix-platform\reports\file_audit
```

## Co report umí

- spočítá soubory po složkách
- ukáže nejnovější změny
- rozliší `NEW`, `MODIFIED`, `DELETED`
- vede historii snapshotů
- umožní navázat práci podle času změny souborů

## Poznámka

Aktuálně audit kontroluje soubory a složky, které jsi přesně zadal. Pokud budeš chtít, doplníme později ještě:

- DBeaver workspace metadata
- export posledních SQL skriptů podle data změny
- samostatný OPS dashboard panel v Tkinteru nebo PowerShell GUI
- denní automatický běh přes Task Scheduler
