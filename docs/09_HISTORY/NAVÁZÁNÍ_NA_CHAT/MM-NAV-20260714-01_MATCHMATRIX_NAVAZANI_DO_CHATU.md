# MatchMatrix – navázání do nového chatu – 2026-07-14

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Document ID | MM-NAV-20260714-01 |
| Název dokumentu | MatchMatrix – navázání do nového chatu – 2026-07-14 |
| Typ dokumentu | CHAT_CONTINUATION |
| Verze | 1.0 |
| Stav | APPROVED |
| Původní stav zdrojového dokumentu | DRAFT – NEEDS_USER_APPROVAL |
| Datum | 2026-07-14 |
| Datum a čas uzavření | 2026-07-15T15:46:43+02:00 |
| Autor | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Pracovní oblast | Dokončení MM-DB-001, A20 V7, Docker PostgreSQL, A24/A7 a příprava MM-DB-002 |
| Primární formát | Markdown (.md) |
| Kanonické umístění | `docs/09_HISTORY/NAVÁZÁNÍ_NA_CHAT/MM-NAV-20260714-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md` |
| Zdrojový denní zápis | `MM-DL-20260714_MATCHMATRIX_DENNI_ZAPIS.md` |
| Předchozí navázání | `MM-NAV-20260712-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md` |

## 1. Identifikace navázání

| Položka              | Hodnota |
|----------------------|---|
| Document ID          | MM-NAV-20260714-01 |
| Název dokumentu      | MatchMatrix – navázání do nového chatu – 2026-07-14 |
| Typ dokumentu        | CHAT_CONTINUATION |
| Verze                | 1.0 |
| Stav dokumentu       | DRAFT – NEEDS_USER_APPROVAL |
| Datum                | 2026-07-14 |
| Autor                | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Pracovní oblast      | Dokončení MM-DB-001, A20 V7, Docker PostgreSQL, A24/A7 a příprava MM-DB-002 |
| Primární formát      | Markdown (.md) |
| Kanonické umístění   | `docs/09_HISTORY/NAVÁZÁNÍ_NA_CHAT/MM-NAV-20260714-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md` |
| Zdrojový denní zápis | `MM-DL-20260714_MATCHMATRIX_DENNI_ZAPIS.md` |

Tento dokument předává přesný stav po dokončení první hlavní databázové dokumentace MatchMatrix a po obnovení plně funkčního dokumentačního panelu. Nový chat má navázat řízeným dokončením historických dokumentů a následně zahájit `MM-DB-002`.

## 2. Výchozí kontext

Pracovní blok vycházel z dokončené dokumentační mapy, indexu databázové dokumentace a nového read-only auditu A33.

A33 vytvořil skutečný strukturální obraz databáze `matchmatrix`. Z tohoto auditu vznikl dokument:

```text
MM-DB-001 – Architektura databáze MatchMatrix
```

Během standardizace byly vyřešeny:

- chybějící závěry dvou hlavních sekcí,
- chybné pořadí souvisejících dokumentů a auditních artefaktů,
- falešná duplicita metadata `Stav`,
- blokace A20 při chybějícím top-level `unresolved_findings`,
- nedostupnost databáze při startu panelu,
- záměna Docker PostgreSQL za lokální Windows službu,
- A24 blokace způsobená nečistým Git stromem.

`MM-DB-001` byl následně kanonicky schválen, uložen do Git historie, importován přes A24 a ověřen A7.

## 3. CURRENT STATUS

### Dokumentace

- `MM-DB-001 – Architektura databáze MatchMatrix` je dokončen.
- A17 dokumentu skončil bez FAIL a PARTIAL.
- Zůstal pouze neblokující terminologický `MANUAL_REVIEW`.
- A24 skončil `HISTORY_DOCUMENT_IMPORT_APPLIED_AND_VERIFIED`.
- A7 skončil `VERIFIED`.
- Varování: 0.
- Blokátory: 0.
- Navazujícím odborným dokumentem je `MM-DB-002 – Katalog schémat a databázových objektů`.

### Git

- Hlavní repozitář: `C:\MatchMatrix-platform` na PC2.
- Větev: `main`.
- Automaticky předvyplněný PC2 snapshot: `c8478f7f7dcd`.
- Panel fáze 4 uvedl commit `a6198226e38269937c1fb3cca14a3f7b226c77f4`.
- `git push origin main` na `SSH: PC2` vrátil `Everything up-to-date`.
- `git status --short` nevrátil žádný výstup.
- Pracovní strom je čistý.
- Přesný vztah dvou uvedených commit hashů je neblokující otázka pro jednorázové ověření příkazem `git rev-parse HEAD`.

### Databáze a infrastruktura

- Produkční PostgreSQL běží v Dockeru:
  `matchmatrix_postgres`, image `postgres:16`.
- Redis běží v Dockeru:
  `matchmatrix_redis`, image `redis:7`.
- Oba kontejnery byly ověřeny jako `healthy`.
- Port 5432 je z PC1 dostupný:
  `TcpTestSucceeded : True`.
- Windows služba `postgresql-x64-18` není produkční službou projektu.
- Windows služba je správně:
  `Stopped / Disabled`.
- Q3 panel se znovu spouští standardním `.vbs` souborem.

### Dokumentační databáze

| Ukazatel | Aktuální stav |
|---|---:|
| Dokumenty | 329 |
| Verze celkem | 334 |
| Aktuální verze | 329 |
| Sekce | 3 981 |
| Vazby | 179 |
| Historie stavů | 334 |
| Importní běhy | 21 |
| Aktivní dokumenty | 329 |

## 4. Co bylo dokončeno

1. Read-only databázový audit A33.
2. Panelová integrace A33.
3. Vytvoření dokumentu `MM-DB-001`.
4. Doplnění závěrů všech hlavních kapitol.
5. Přesunutí souvisejících dokumentů a auditních artefaktů před závěr dokumentu.
6. Oprava A20 na engine V7.
7. Zachování A20 V6 v `tools/histori/`.
8. Commit a push opravy A20:
   `c8478f7`.
9. Oprava falešné duplicity řádku `Stav`.
10. Kanonický A17 bez FAIL a PARTIAL.
11. Diagnostika neotevírajícího se panelu.
12. Potvrzení, že `psycopg2` funguje a problém byl v dostupnosti DB.
13. Ověření Docker PostgreSQL a Redis.
14. Obnovení portu 5432 mezi PC1 a PC2.
15. Vrácení Windows PostgreSQL služby do stavu `Stopped / Disabled`.
16. A24 VALIDATE_ONLY.
17. A24 APPLY.
18. A7 `VERIFIED`.
19. Import jednoho nového dokumentu a 126 sekcí.
20. Finální kontrola čistého Git stromu na PC2.
21. Příprava denního zápisu `MM-DL-20260714`.
22. Příprava tohoto dokumentu NAVÁZÁNÍ.

## 5. Co zůstává rozpracováno

- `MM-DL-20260714` čeká na A17, schválení, Git a databázovou publikaci.
- `MM-NAV-20260714-01` čeká na A17, schválení, Git a databázovou publikaci.
- Přesný HEAD PC2 má být při nejbližší Git diagnostice jednou explicitně potvrzen.
- `MM-DB-002` ještě nebyl zahájen.
- A33 auditní nálezy zatím nebyly převedeny do úplného objektového katalogu.
- Odolnost panelu při nedostupné DB může být později vylepšena krátkým connection timeoutem a nesynchronním startem dashboardů.

## 6. OPEN QUESTIONS / otevřené úkoly

1. Projde `MM-DL-20260714` A17 bez potřeby A18?
2. Projde `MM-NAV-20260714-01` A17 bez potřeby A18?
3. Jaký přesný hash vrátí `git rev-parse HEAD` v hlavním repozitáři PC2?
4. Má být panelový DB connect timeout zkrácen, aby výpadek databáze nezablokoval celé GUI?
5. Které z 1 115 databázových objektů budou v `MM-DB-002` označeny jako canonical, staging, operational, documentation, work, legacy nebo review required?
6. Které z 226 A33 nálezů představují skutečné vady a které pouze legitimní architektonické výjimky?
7. Které legacy `api_*` objekty jsou stále používány workery nebo panelem?

## 7. Rizika a upozornění

1. Windows PostgreSQL 18 nesmí být spuštěn souběžně s Docker PostgreSQL na portu 5432.
2. Při nefunkčním panelu se nesmí automaticky předpokládat chyba Python doplňků.
3. `pythonw.exe` skrývá traceback; pro diagnostiku se používá konzolový `python.exe`.
4. A24 zůstává blokováno při nečistém Git stromu.
5. A33 auditní nález není automatický pokyn k odstranění objektu.
6. Před mazáním nebo přejmenováním DB objektu je povinný dependency audit.
7. Dokument `MM-DB-001` se nemá znovu vytvářet; budoucí změny mají zvyšovat jeho verzi.
8. Aktivní A20 se nesmí přejmenovat na verzi v názvu aktivního souboru.
9. Historická A20 V6 se nesmí vracet do aktivní složky.
10. Testovací dokumenty ve workspace nejsou automaticky kanonické.
11. Denní zápis a NAV se nesmí importovat před uživatelským schválením.
12. Při pokračování se má postupovat pouze po jednom jasném kroku.

## 8. Přijatá rozhodnutí a platná pravidla

- Docker `matchmatrix_postgres` je produkční PostgreSQL MatchMatrix.
- Windows `postgresql-x64-18` zůstává vypnutý a zakázaný.
- Hlavním Git zdrojem pravdy je PC2.
- VS Code terminál `SSH: PC2` lze použít místo fyzického přechodu k PC2.
- A24 se spouští pouze nad čistým Git stromem.
- `MM-DB-001` je dokončený základ databázové dokumentace.
- `MM-DB-002` je následující odborný dokument.
- A33 zůstává read-only auditním zdrojem.
- Legacy objekt se nemaže jen proto, že jej A33 označil jako rizikový.
- A20 V7 je aktivní standardizační builder.
- A20 V6 je historická verze.
- Obsah denních zápisů a NAV vytváří ChatGPT z celé komunikace.
- Oficiální strukturu určují MM-TPL-002 a MM-TPL-001.
- Uživatel provádí jednotlivé technické kroky a posílá jejich výsledek.
- Práce v novém chatu začne dokončením historických dokumentů, nikoli opakováním databázové diagnostiky.

## 9. Ověřené zdroje, soubory a commity

### Hlavní dokumenty

```text
docs/04_DATABASE/MM-DB-001_ARCHITEKTURA_DATABAZE_MATCHMATRIX.md
docs/04_DATABASE/MM-DB-1000_INDEX_DATABAZOVE_DOKUMENTACE_MATCHMATRIX.md
docs/00_DOCUMENTATION/MM-DOC-001_MAPA_DOKUMENTACNICH_OBLASTI_MATCHMATRIX.md
```

### Aktivní nástroje

```text
tools/matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py
tools/documentation/25_1_A_17_AUDIT_DOCUMENT_STANDARD_COMPLIANCE_V1.py
tools/documentation/25_1_A_18_BUILD_DOCUMENT_STANDARDIZATION_PROPOSAL_V1.py
tools/documentation/25_1_A_19_REVIEW_DOCUMENT_STANDARDIZATION_MAPPING_V1.py
tools/documentation/25_1_A_20_BUILD_STANDARDIZED_DOCUMENT_FROM_REVIEW_V1.py
tools/documentation/25_1_A_24_IMPORT_HISTORY_DOCUMENTS_TO_DB_V1.py
tools/documentation/25_1_A_7_VERIFY_DOCUMENTATION_IMPORT_V1.py
tools/documentation/25_1_A_33_EXPORT_DATABASE_STRUCTURE_AUDIT_V1.py
```

### Historické nástroje

```text
tools/histori/25_1_A_20_BUILD_STANDARDIZED_DOCUMENT_FROM_REVIEW_V6.py
```

### Auditní artefakty

```text
reports/documentation/database_audit/database_structure_audit_20260714_111917.json
reports/documentation/database_audit/database_structure_audit_20260714_111917.md
reports/documentation/database_audit/database_structure_schemas_20260714_111917.csv
reports/documentation/database_audit/database_structure_objects_20260714_111917.csv
```

### Důležité commity

```text
6243355 fix(documentation): support structural standardization builds
528507b MM-DB-1000 – databázová dokumentace
396e9e3 feat(documentation): add A33 database structure audit
c8478f7 fix(documentation): recover unresolved review findings in A20
a6198226e38269937c1fb3cca14a3f7b226c77f4  panelový commit uvedený při dokončení MM-DB-001
```

### Databázové prostředí

```text
PC2: 192.168.3.119
DB target: matchmatrix
Docker PostgreSQL: matchmatrix_postgres / postgres:16
Docker Redis: matchmatrix_redis / redis:7
Windows PostgreSQL: postgresql-x64-18 / Stopped / Disabled
```

## 10. AI CONTEXT

Při pokračování musí AI:

1. Začít dokumentem `MM-DL-20260714`.
2. Použít právě připravený kompletní Markdown, nikoli znovu vytvářet obsah od nuly.
3. Spustit nejprve pouze A17.
4. Podle výsledku A17 rozhodnout, zda je nutné A18/A19/A20.
5. Nezpracovávat současně denní zápis a NAV.
6. Po schválení denního zápisu pokračovat přes kanonický A17, Git, A24 VALIDATE_ONLY, A24 APPLY a A7.
7. Teprve potom stejným způsobem dokončit `MM-NAV-20260714-01`.
8. Používat PC2 jako Git a databázový zdroj pravdy.
9. Příkazy na PC2 spouštět přes `SSH: PC2`, pokud je uživatel na PC1.
10. Při DB problému ověřit nejprve Docker Desktop a `docker ps -a`.
11. Nespouštět Windows službu `postgresql-x64-18`.
12. Zachovat porty 5432 a 6379 beze změny.
13. Neměnit ani znovu importovat `MM-DB-001` bez nové verze.
14. Po dokončení historických dokumentů přejít k `MM-DB-002`.
15. Při tvorbě `MM-DB-002` vycházet z A33 JSON/CSV, governance registru a skutečných Git závislostí.
16. Nemaže žádné DB objekty na základě samotného A33 nálezu.
17. Postupovat vždy po jednom příkazu nebo jednom jasném úkonu.
18. Při nejbližší Git diagnostice jednou vypsat `git rev-parse HEAD`, ale nezdržovat tím aktuální A17, pokud není Git měněn.

## 11. PROJECT SNAPSHOT

| Oblast | Ověřený stav |
|---|---|
| Projekt | MatchMatrix-platform |
| Aktivní pracovní oblast | Databázová dokumentace |
| Poslední hlavní dokument | `MM-DB-001 – Architektura databáze MatchMatrix` |
| Stav MM-DB-001 | dokončen, Git, A24 APPLY, A7 VERIFIED |
| Aktivní panel | `tools/matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py` |
| Aktivní A20 | V7 unresolved review recovery |
| Aktivní databázový audit | A33 read-only audit |
| Produkční databáze | Docker PostgreSQL 16 na PC2 |
| Dokumentační DB | 329 dokumentů, 334 verzí, 3 981 sekcí, 179 vazeb |
| Git | PC2, `main`, čistý, origin aktuální |
| Ověřený automatický Git snapshot | `c8478f7f7dcd` |
| Panelový commit MM-DB-001 | `a6198226e38269937c1fb3cca14a3f7b226c77f4` |
| Nejbližší procesní krok | A17 nad `MM-DL-20260714` |
| Následující odborný dokument | `MM-DB-002 – Katalog schémat a databázových objektů` |
| Dlouhodobý cíl | Úplná databázová dokumentace propojená s Git, PostgreSQL, audity a dokumentační databází |

## 12. DATABASE SNAPSHOT

| Ukazatel | Hodnota |
|---|---:|
| Dokumenty | 329 |
| Verze dokumentů | 334 |
| Aktuální verze | 329 |
| Sekce | 3 981 |
| Vazby | 179 |
| Historie stavů | 334 |
| Importní běhy | 21 |
| Aktivní dokumenty | 329 |

```text
Snapshot: 2026-07-15T15:46:43+02:00
Execution host: PC2 (192.168.3.119)
DB target: matchmatrix
Produkční instance: Docker matchmatrix_postgres / PostgreSQL 16
Poslední import: MM-DB-001
A24: HISTORY_DOCUMENT_IMPORT_APPLIED_AND_VERIFIED
A7: VERIFIED
```

## 13. NEXT STEP – jeden hlavní další krok

**V Q3 panelu spustit pouze A17 nad kompletním dokumentem `MM-DL-20260714`.**

Použít workspace:

```text
\\192.168.3.119\matchmatrix\reports\documentation\standardization\panel_workspaces\20260715_154656_MM_DL_20260714_MATCHMATRIX_DENNI_ZAPIS
```

Před spuštěním zkontrolovat pouze to, že source dokument neobsahuje žádný nevyplněný placeholder.

## 14. Technická dohledatelnost a uzavření

| Položka | Hodnota |
|---|---|
| Datum a čas uzavření | 2026-07-15T15:46:43+02:00 |
| Zdrojový denní zápis | `MM-DL-20260714_MATCHMATRIX_DENNI_ZAPIS.md` |
| Git větev | `main` |
| Ověřený Git snapshot PC2 | `c8478f7f7dcd` |
| Panelový commit MM-DB-001 | `a6198226e38269937c1fb3cca14a3f7b226c77f4` |
| Git push | `Everything up-to-date` |
| Git pracovní strom | ČISTÝ |
| Poslední A24 | `HISTORY_DOCUMENT_IMPORT_APPLIED_AND_VERIFIED` |
| Poslední A7 | `VERIFIED` |
| Produkční PostgreSQL | Docker `matchmatrix_postgres`, PostgreSQL 16 |
| Windows PostgreSQL | `postgresql-x64-18`, Stopped / Disabled |
| Kanonické umístění NAV | `docs/09_HISTORY/NAVÁZÁNÍ_NA_CHAT/MM-NAV-20260714-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md` |

## Schválení dokumentu

- [x] Dokument obsahuje výchozí kontext.
- [x] Dokument obsahuje CURRENT STATUS.
- [x] Dokument obsahuje dokončené a rozpracované práce.
- [x] Dokument obsahuje OPEN QUESTIONS.
- [x] Dokument obsahuje rizika a platná rozhodnutí.
- [x] Dokument obsahuje ověřené zdroje a technickou dohledatelnost.
- [x] Dokument obsahuje AI CONTEXT.
- [x] Dokument obsahuje PROJECT SNAPSHOT.
- [x] Dokument obsahuje DATABASE SNAPSHOT.
- [x] NEXT STEP obsahuje právě jeden hlavní krok.
- [x] V dokumentu nejsou žádné nevyplněné proměnné šablony.
- [ ] Byla dokončena terminologická kontrola.
- [ ] Byl spuštěn A17.
- [ ] A17 neobsahuje žádný FAIL ani PARTIAL.
- [ ] Uživatel schválil kanonickou verzi.
- [ ] Dokument byl commitnut a pushnut.
- [ ] A24 VALIDATE_ONLY proběhl úspěšně.
- [ ] A24 APPLY a A7 byly dokončeny.
