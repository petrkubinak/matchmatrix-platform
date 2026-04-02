# TicketMatrixPlatform – denní přehled vývoje

Datum: 02.04.2026  
Čas kontroly systému: 11:28

---

## 1. Co je TicketMatrixPlatform

TicketMatrixPlatform je sportovní datová a analytická platforma.
Interní pracovní název projektu je zatím MatchMatrix.

Cílem systému je:
- sbírat sportovní data
- ukládat je do databáze
- počítat statistiky a predikce
- připravovat inteligentní práci s tikety

---

## 2. Co se dnes zkontrolovalo

Byly zkontrolovány tyto části projektu:

- Celý projekt

Celkem bylo projito 1721 sledovaných souborů.

Ve srovnání s minulým auditem:
- bylo přidáno 53 nových souborů
- u 2 souborů proběhla úprava

---

## 3. Stav databáze

Databáze je dostupná a základní stav je následující:

- ligy: 2986
- týmy: 5437
- zápasy: 105603
- hráči: 1490

Player pipeline přehled:
- import hráčů: 1546
- staging hráčů: 1465
- public hráči: 1490
- statistiky hráčů na zápas: 0


---

## 4. Stav systému a repozitáře

Git větev:
- main

Poslední commit:
- 38bf38e | 2026-03-31 16:52:13 +0200 | update players pipeline

Aktuální neuložené změny:
- M MatchMatrix-platform/.dbeaver/.project-metadata.json.bak
-  M MatchMatrix-platform/.dbeaver/project-metadata.json
-  D ingest/run_theodds_parse_multi_FINAL.bat
-  D ingest/theodds_parse_multi_FINAL.py
-  D reports/audit/2026-03-17/09-48-14/MATCHMATRIX_AUDIT_REPORT.md
-  D reports/audit/2026-03-17/09-48-14/changes.csv
-  D reports/audit/2026-03-17/09-48-14/files.csv
-  D reports/audit/2026-03-17/09-48-14/run_meta.json

---

## 5. Kam jsme se dnes posunuli

Na základě dnešního auditu je vidět, že projekt má:
- funkční audit souborů
- přehled změn proti minulému běhu
- kontrolu Git stavu
- Project Navigator pro rychlé otevření hlavních částí projektu
- přímý přehled o databázi, OPS tabulkách a API budgetu


Hlavní změněné soubory dnes:
- ingest\TheOdds\theodds_parse_multi_V3.py
- MatchMatrix-platform\.dbeaver\project-metadata.json
- db\audit\473_audit_manual_team_mapping_candidates.sql
- db\audit\474_audit_unmapped_top_league_teams_side_by_side.sql
- db\audit\477_audit_review_batch2_candidates.sql
- db\audit\481_audit_theodds_against_canonical_match_lookup.sql
- db\audit\483_audit_theodds_against_preferred_team_name_lookup.sql
- db\audit\484_audit_suspicious_team_aliases.sql

---

## 6. V čem budeme pokračovat

Doporučené další kroky:
- dokončit vizuální styl webu TicketMatrixPlatform
- navázat frontend na reálná data z databáze
- pokračovat v players pipeline a Ticket Intelligence vrstvě

---

## 7. Doporučení před ukončením práce

Nezapomenout:
- zkontrolovat změněné soubory
- uložit důležité skripty
- vytvořit Git commit
- poslat změny na GitHub

Doporučené příkazy:
git add .
git commit -m "TicketMatrixPlatform update"
git push
