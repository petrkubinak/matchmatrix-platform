# TicketMatrixPlatform – denní přehled vývoje

Datum: 17.03.2026  
Čas kontroly systému: 12:44

---

## 1. Co je TicketMatrixPlatform

TicketMatrixPlatform je datová a analytická platforma pro sportovní data.
Systém sbírá data ze zdrojů, ukládá je do databáze, připravuje statistiky
a vytváří podklady pro budoucí predikce a inteligentní práci s tikety.

Interní pracovní název projektu je zatím MatchMatrix.

---

## 2. Co se dnes zkontrolovalo

Byl zkontrolován projekt v těchto částech:

- Celý projekt
- Workers
- Ingest
- API-Football
- Scripts
- Dump
- DB
- Docs

Celkem bylo projito 755 sledovaných souborů.

Ve srovnání s minulým auditem:
- 38 souborů bylo odstraněno


---

## 3. Stav databáze

Databáze je dostupná a základní stav je následující:

- ligy: 2713
- týmy: 5234
- zápasy: 107089
- hráči: 559

Player pipeline přehled:
- import hráčů: 540
- staging hráčů: 533
- public hráči: 559
- statistiky hráčů na zápas: 0


---

## 4. Stav systému a repozitáře

Git větev:
- main

Poslední commit:
- ca41518 | 2026-03-17 10:32:39 +0100 | MatchMatrix ingest + players pipeline updates

Aktuální neuložené změny:
- M MatchMatrix-platform/.dbeaver/.project-metadata.json.bak
-  M MatchMatrix-platform/.dbeaver/project-metadata.json
-  D MatchMatrix-platform/Dump/dump-matchmatrix-202602272251_leagues.sql
-  D MatchMatrix-platform/Dump/dump-matchmatrix-202602282349.sql
-  D MatchMatrix-platform/Dump/dump-matchmatrix-202603012240.sql
-  D MatchMatrix-platform/Dump/dump-matchmatrix-202603020927.sql
-  D MatchMatrix-platform/Dump/dump-matchmatrix-202603022246.sql
-  D MatchMatrix-platform/Dump/dump-matchmatrix-202603091608.sql

Pokud zde vidíš změny, které mají zůstat, je dobré je po práci uložit do Git a GitHub.

---

## 5. Kam jsme se dnes posunuli

Na základě dnešního auditu je vidět, že projekt má:
- funkční kontrolu souborů
- přehled o změnách proti minulému běhu
- kontrolu Git stavu

- přímý přehled o databázi, OPS tabulkách a API budgetu


Hlavní změněné soubory dnes:
- db\audit\079_audit_player_season_statistics_report_v1.sql
- db\audit\080_debug_player_stats_merge_mapping_v1.sql
- db\audit\cleanup_player_season_stats_scope_95_2024_v1.sql
- logs\reports\mm_report_2026-03-04_12-34-26.txt
- reports\file_audit\csv\changes_20260317_085252.csv
- reports\file_audit\csv\changes_20260317_091237.csv
- reports\file_audit\csv\files_20260317_085252.csv
- reports\file_audit\csv\files_20260317_091237.csv

---

## 6. V čem budeme pokračovat

Doporučené další kroky:
- navázat dalším rozšířením players pipeline
- zkontrolovat poslední job_runs a případné warningy
- pokračovat ve feature engine pro týmy a hráče

---

## 7. Doporučení před ukončením práce

Nezapomenout:
- zkontrolovat změněné soubory
- uložit důležité skripty
- vytvořit Git commit
- poslat změny na GitHub

Doporučené příkazy:
git add .
git commit -m "TicketMatrixPlatform / MatchMatrix update"
git push
