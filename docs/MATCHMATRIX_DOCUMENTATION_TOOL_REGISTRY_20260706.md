# MATCHMATRIX – REGISTR DOKUMENTAČNÍCH NÁSTROJŮ – 2026-07-06

## Informace o registru

| Položka | Hodnota |
|---|---|
| Účel | Přehled aktivních, databázových, historických a panelových nástrojů dokumentačního systému |
| Zdroj | Inventář 33 souborů, denní zápisy a dokumenty NAVÁZÁNÍ |
| Stav | PRACOVNÍ TECHNICKÝ REGISTR |
| Počet položek | 33 |
| Primární prostředí | PC2 – `C:\MatchMatrix-Platform` |
| Ovládání | PC1 |

# 1. Hlavní závěr

Dokumentační backend MatchMatrix již není soubor několika izolovaných skriptů. Tvoří několik samostatných, ale navazujících vrstev:

```text
DB základ a panelové pohledy
→ inventura a synchronizace
→ standardizace a uživatelská revize
→ publikování dokumentů
→ post-import ověření
→ status snapshot a KPI panel
```

Do hlavního panelu se nemá přenášet logika skriptů. Panel je má řídit přes stabilní technické akce, číst jejich reporty a povolit další krok pouze při očekávaném `FINAL STATUS`.

# 2. Kritická zjištění

## 2.1 Project Snapshot zatím nemá kompletní publikační cestu

- databázová migrace A26 SQL již povoluje `MM-PS-YYYYMMDD` a typ `PS`,
- A6 a A7 používají obecnější identifikátory a jsou pro `MM-PS` technicky použitelné,
- A17 nepřijímá osmimístný identifikátor `MM-PS-YYYYMMDD`,
- A24 přijímá pouze `MM-DL-YYYYMMDD` a `MM-NAV-YYYYMMDD-PP`,
- proto `MM-PS-20260331` nesmí být importován přes současné A24 bez úpravy.

**Doporučení:** rozšířit A17 o typ `PROJECT_SNAPSHOT` podle MM-STD-009 a rozšířit A24 o bezpečnou podporu `MM-PS`. Před úpravou archivovat aktivní verze do `tools/histori/`.

## 2.2 Přečíslování databázové migrace na A26

Původní kolize označení A25 byla odstraněna přečíslováním databázové migrace na A26:

- `A26 SQL` – rozšíření databázových constraintů,
- `A25 Python` – import historického korpusu.

Panel ani registr nesmí používat samotný popisek `A25`. Použijí se technická ID:

```text
DOC_DB_EXTEND_HISTORY_CONSTRAINTS
DOC_HISTORY_CORPUS_IMPORT
```

## 2.3 Bezpečnost panelu

Panel V20.1.Q obsahuje databázové přihlašovací údaje přímo ve zdrojovém kódu. Před přidáním zapisujících tlačítek musí být připojení přesunuto do `.env` nebo bezpečné konfigurační vrstvy. Registr záměrně žádné konkrétní přihlašovací údaje neuvádí.

## 2.4 A5 je statický manifest prvního kanonického importu

Komentář A5 stále uvádí 21 kandidátů, zatímco kód očekává 22. A5 navíc používá pevný seznam souborů. Nesmí proto sloužit jako univerzální manifest pro libovolný nový historický dokument nebo nový Project Snapshot bez úpravy.

## 2.5 A19 je lokální Tkinter nástroj

A19 je funkční editor mapování, ale v architektuře PC1 → PC2 je méně vhodný. Dlouhodobě má být převeden na webový režim podobně jako A23 nebo začleněn přímo do Dokumentačního centra.

# 3. Doporučené uživatelské workflow panelu

## 3.1 Běžná kontrola existujícího dokumentu

```text
1. ZKONTROLOVAT
   A17

2. PŘIPRAVIT OPRAVU
   A18

3. POTVRDIT MAPOVÁNÍ
   A19

4. SESTAVIT A DOČISTIT
   A20 → A21 → A17
```

## 3.2 Denní zápis

```text
1. PŘIPRAVIT DENNÍ ZÁPIS
   A20 → A21 → A22

2. POTVRDIT POJMY
   A23

3. PROVĚŘIT PUBLIKACI
   A24 DRY RUN → A6 rollback

4. PUBLIKOVAT
   Git → A24 APPLY → A6 → A7
```

## 3.3 Project Snapshot

```text
AKTUÁLNĚ BLOKOVÁNO:
A17 a A24 ještě nepodporují MM-PS v celém workflow.

CÍLOVĚ:
ZKONTROLOVAT PS
→ PROVĚŘIT PUBLIKACI
→ SCHVÁLIT A PUBLIKOVAT
→ A7 incremental verify
```

## 3.4 Historický korpus

```text
VALIDATE CORPUS
→ SECURITY REVIEW
→ DATABASE DRY RUN
→ UŽIVATELSKÉ SCHVÁLENÍ
→ APPLY
→ POST-IMPORT AUDIT
```

Historický korpus musí mít samostatnou administrátorskou obrazovku a nesmí používat stejné tlačítko jako publikování jednoho dokumentu.

# 4. Rozdělení panelových akcí

## 4.1 Běžně viditelná tlačítka

- `ZKONTROLOVAT DOKUMENT` – A17
- `PŘIPRAVIT OPRAVU` – A18
- `POTVRDIT MAPOVÁNÍ` – A19 nebo budoucí webová varianta
- `DOČISTIT DOKUMENT` – A20 + A21
- `PŘIPRAVIT DENNÍ ZÁPIS` – A22
- `POTVRDIT POJMY` – A23 web
- `PROVĚŘIT PUBLIKACI` – A24 bez `--apply`
- `SCHVÁLIT A PUBLIKOVAT` – A24 `--apply` až po zeleném dry runu
- `OVĚŘIT IMPORT` – A7
- `OBNOVIT STAV DOKUMENTACE` – A14

## 4.2 Skrytý backend

- A5, A6, A8, A9, A10 a A13,
- SQL A15 a A16 jako datový kontrakt,
- parsování reportů a řízení stavů.

## 4.3 Pouze administrátor

- SQL A0, A1, A11, A12, A15, A16 a A25,
- A2, A3 a A4,
- A25 Python – historický korpus.

## 4.4 Nikdy nezobrazovat jako spouštěcí akce

- všechny soubory v `tools/histori/`.

# 5. Bezpečnostní pravidla pro dvě kliknutí

První kliknutí vždy pouze připraví nebo prověří akci:

```text
VALIDACE
→ MANIFEST
→ SHA-256
→ GIT STAV
→ DB DRY RUN / ROLLBACK
→ PŘEHLED ZMĚN
```

Druhé kliknutí je povoleno pouze při zeleném výsledku:

```text
UŽIVATELSKÉ POTVRZENÍ
→ APPLY
→ POST-IMPORT VERIFY
→ VÝSLEDEK
```

Při stavu `HISTORY_DOCUMENT_IMPORT_APPLIED_VERIFICATION_FAILED` nesmí panel nabídnout opakovaný import. Musí nabídnout pouze read-only kontrolu A7 a diagnostiku již provedeného zápisu.

# 6. Souhrn registru

- položek celkem: **33**
- aktivní databázové SQL vrstvy: **7**
- aktivní Python nástroje: **20**
- historické Python verze: **5**
- panelové aplikace: **1**

Rizikové rozdělení:

- CRITICAL: **10**
- HIGH: **6**
- MEDIUM: **7**
- LOW: **10**

# 7. Kompaktní registr všech 33 položek

| Technické ID | Označení | Vrstva | Role v panelu | Stav | Riziko |
|---|---|---|---|---|---|
| `DOC_DB_AUDIT_EXISTING` | A0 SQL | DB základ | ADMIN / diagnostika | AVAILABLE | LOW |
| `DOC_DB_CREATE_CORE` | A1 SQL | DB základ | ADMIN / instalace | IMPLEMENTED | CRITICAL |
| `DOC_STATUS_DB_AUDIT` | A11 SQL | Status/KPI | ADMIN / diagnostika | AVAILABLE | LOW |
| `DOC_STATUS_DB_CREATE` | A12 SQL | Status/KPI | ADMIN / instalace | IMPLEMENTED | CRITICAL |
| `DOC_STATUS_DASHBOARD_VIEWS` | A15 SQL | Status/KPI | ADMIN / instalace | IMPLEMENTED | HIGH |
| `DOC_PANEL_PAYLOAD_VIEW` | A16 SQL | Panel kontrakt | SKRYTÝ BACKEND PANELU | IMPLEMENTED | HIGH |
| `DOC_DB_EXTEND_HISTORY_CONSTRAINTS` | A26 SQL | DB migrace | ADMIN / migrace | APPLIED_AND_VERIFIED | CRITICAL |
| `DOC_FILES_AUDIT` | A2 | Inventura | DIAGNOSTIKA / předkontrola | IMPLEMENTED | LOW |
| `DOC_IDS_NORMALIZE` | A3 | Údržba dokumentů | ADMIN / oprava ID | IMPLEMENTED | HIGH |
| `DOC_METADATA_NORMALIZE` | A4 | Údržba dokumentů | ADMIN / historická oprava | IMPLEMENTED_SPECIALIZED | HIGH |
| `DOC_CANONICAL_MANIFEST_BUILD` | A5 | Kanonický import | SKRYTÝ BACKEND | OPERATIONAL_WITH_REVIEW | MEDIUM |
| `DOC_CANONICAL_DB_IMPORT` | A6 | Kanonický import | SKRYTÝ BACKEND PUBLIKACE | VERIFIED_OPERATIONAL | CRITICAL |
| `DOC_DB_IMPORT_VERIFY` | A7 | Integrita | TLAČÍTKO OVĚŘIT / automaticky po importu | VERIFIED_OPERATIONAL | LOW |
| `DOC_SYNC_PLAN_BUILD` | A8 | Synchronizace | TLAČÍTKO ZJISTIT ROZDÍLY / skrytý backend | IMPLEMENTED | LOW |
| `DOC_CONTROL_CYCLE_RUN` | A9 | Orchestrace | TLAČÍTKO CELKOVÁ KONTROLA | IMPLEMENTED | LOW |
| `DOC_STATUS_SNAPSHOT_BUILD` | A10 | Status/KPI | SKRYTÝ BACKEND KPI | IMPLEMENTED_NEEDS_CURRENT_TEST | LOW |
| `DOC_STATUS_SNAPSHOT_IMPORT` | A13 | Status/KPI | SKRYTÝ BACKEND KPI | IMPLEMENTED_NEEDS_CURRENT_TEST | HIGH |
| `DOC_STATUS_PIPELINE_RUN` | A14 | Orchestrace statusu | TLAČÍTKO OBNOVIT STAV DOKUMENTACE | IMPLEMENTED_NEEDS_CURRENT_TEST | HIGH |
| `DOC_STANDARD_AUDIT` | A17 | Standardizace | TLAČÍTKO ZKONTROLOVAT | VERIFIED_FOR_DL_NAV | LOW |
| `DOC_STANDARD_PROPOSAL_BUILD` | A18 | Standardizace | TLAČÍTKO PŘIPRAVIT OPRAVU | IMPLEMENTED | MEDIUM |
| `DOC_STANDARD_MAPPING_REVIEW` | A19 | Uživatelská revize | SPECIALIZOVANÉ REVIEW OKNO | IMPLEMENTED_LOCAL_GUI | MEDIUM |
| `DOC_STANDARD_CANDIDATE_BUILD` | A20 | Standardizace | SKRYTÝ BACKEND PO SCHVÁLENÍ | VERIFIED_OPERATIONAL | MEDIUM |
| `DOC_STANDARD_CANDIDATE_POLISH` | A21 | Standardizace | TLAČÍTKO DOČISTIT / automatický krok | VERIFIED_OPERATIONAL | MEDIUM |
| `DOC_DAILY_LOG_CANONICAL_PREPARE` | A22 | Denní zápis | TLAČÍTKO PŘIPRAVIT DENNÍ ZÁPIS | VERIFIED_OPERATIONAL | MEDIUM |
| `DOC_TERMINOLOGY_REVIEW` | A23 | Terminologie | TLAČÍTKO POTVRDIT POJMY / otevřít web | VERIFIED_WEB_READY | MEDIUM |
| `DOC_HISTORY_DOCUMENT_PUBLISH` | A24 | Historické dokumenty | DVOJKROK: PROVĚŘIT → PUBLIKOVAT | VERIFIED_FOR_DL_NAV | CRITICAL |
| `DOC_HISTORY_CORPUS_IMPORT` | A25 Python | Historický korpus | SAMOSTATNÁ ADMIN SEKCE KORPUS | OPERATIONAL_USED_AS_EVIDENCE | CRITICAL |
| `HIST_A24_V1` | A24 historická V1 | Historie skriptů | NEZOBRAZOVAT V PANELU | HISTORICAL_ONLY | CRITICAL |
| `HIST_A24_V2` | A24 historická V2 | Historie skriptů | NEZOBRAZOVAT V PANELU | HISTORICAL_ONLY | CRITICAL |
| `HIST_A6_V1` | A6 historická | Historie skriptů | NEZOBRAZOVAT V PANELU | HISTORICAL_ONLY | CRITICAL |
| `HIST_A7_V1` | A7 historická V1 | Historie skriptů | NEZOBRAZOVAT V PANELU | HISTORICAL_ONLY | LOW |
| `HIST_A7_V2` | A7 historická V2 | Historie skriptů | NEZOBRAZOVAT V PANELU | HISTORICAL_ONLY | LOW |
| `DOC_PANEL_Q` | V20.1.Q | Panel | HLAVNÍ UŽIVATELSKÁ VRSTVA | IMPLEMENTED_READ_ONLY | CRITICAL |

# 8. Podrobný registr

## DOC_DB_AUDIT_EXISTING – A0 SQL

- **Soubor:** `C:\MatchMatrix-Platform\db\25_DOCUMENTATION\25_1_A_0_AUDIT_EXISTING_DOCUMENTATION_OBJECTS_V1.sql`
- **Vrstva:** DB základ
- **Účel:** Read-only inventura existujících dokumentačních a znalostních objektů.
- **Režimy:** `READ_ONLY`
- **Zápis souborů:** NE
- **Zápis databáze:** NE
- **Role v panelu:** ADMIN / diagnostika
- **Doložený stav:** `AVAILABLE`
- **Riziko:** `LOW`
- **Předpoklady:** Připojení k matchmatrix
- **Následuje:** A1 SQL nebo rozhodnutí bez změny
- **Poznámka:** Pouze SELECT.
- **Velikost:** 10218 B
- **Poslední změna:** 2026-06-30 09:14:23

## DOC_DB_CREATE_CORE – A1 SQL

- **Soubor:** `C:\MatchMatrix-Platform\db\25_DOCUMENTATION\25_1_A_1_CREATE_DOCUMENTATION_CORE_V1.sql`
- **Vrstva:** DB základ
- **Účel:** Vytvoření základního schématu documentation, tabulek, verzí, sekcí, vazeb, historie a importních běhů.
- **Režimy:** `APPLY`
- **Zápis souborů:** NE
- **Zápis databáze:** ANO – DDL
- **Role v panelu:** ADMIN / instalace
- **Doložený stav:** `IMPLEMENTED`
- **Riziko:** `CRITICAL`
- **Předpoklady:** A0 audit a záloha DB
- **Následuje:** A5/A6 nebo další DB vrstvy
- **Poznámka:** Nespouštět jako běžnou denní akci.
- **Velikost:** 25356 B
- **Poslední změna:** 2026-07-05 23:26:48

## DOC_STATUS_DB_AUDIT – A11 SQL

- **Soubor:** `C:\MatchMatrix-Platform\db\25_DOCUMENTATION\25_1_A_11_AUDIT_DOCUMENTATION_STATUS_STORAGE_V1.sql`
- **Vrstva:** Status/KPI
- **Účel:** Read-only audit objektů vhodných pro ukládání stavových snapshotů.
- **Režimy:** `READ_ONLY`
- **Zápis souborů:** NE
- **Zápis databáze:** NE
- **Role v panelu:** ADMIN / diagnostika
- **Doložený stav:** `AVAILABLE`
- **Riziko:** `LOW`
- **Předpoklady:** Základní documentation schema
- **Následuje:** A12 SQL
- **Poznámka:** Pouze SELECT.
- **Velikost:** 11782 B
- **Poslední změna:** 2026-06-30 12:05:59

## DOC_STATUS_DB_CREATE – A12 SQL

- **Soubor:** `C:\MatchMatrix-Platform\db\25_DOCUMENTATION\25_1_A_12_CREATE_DOCUMENTATION_STATUS_STORAGE_V1.sql`
- **Vrstva:** Status/KPI
- **Účel:** Vytvoření tabulky status_snapshots a navazujících pohledů.
- **Režimy:** `APPLY`
- **Zápis souborů:** NE
- **Zápis databáze:** ANO – DDL
- **Role v panelu:** ADMIN / instalace
- **Doložený stav:** `IMPLEMENTED`
- **Riziko:** `CRITICAL`
- **Předpoklady:** A11 audit
- **Následuje:** A13, A15
- **Poznámka:** Jednorázová či migrační akce.
- **Velikost:** 14140 B
- **Poslední změna:** 2026-06-30 12:19:32

## DOC_STATUS_DASHBOARD_VIEWS – A15 SQL

- **Soubor:** `C:\MatchMatrix-Platform\db\25_DOCUMENTATION\25_1_A_15_CREATE_DOCUMENTATION_OPS_DASHBOARD_V1.sql`
- **Vrstva:** Status/KPI
- **Účel:** Vytvoření OPS dashboard pohledů, KPI a historie.
- **Režimy:** `APPLY`
- **Zápis souborů:** NE
- **Zápis databáze:** ANO – VIEW DDL
- **Role v panelu:** ADMIN / instalace
- **Doložený stav:** `IMPLEMENTED`
- **Riziko:** `HIGH`
- **Předpoklady:** A12 a data status snapshotů
- **Následuje:** A16
- **Poznámka:** Read-only vůči obsahu, ale mění DB objekty.
- **Velikost:** 14684 B
- **Poslední změna:** 2026-06-30 12:32:10

## DOC_PANEL_PAYLOAD_VIEW – A16 SQL

- **Soubor:** `C:\MatchMatrix-Platform\db\25_DOCUMENTATION\25_1_A_16_CREATE_DOCUMENTATION_PANEL_PAYLOAD_V1.sql`
- **Vrstva:** Panel kontrakt
- **Účel:** Vytvoření jednotného JSONB a technického kontraktu pro Python panel.
- **Režimy:** `APPLY`
- **Zápis souborů:** NE
- **Zápis databáze:** ANO – VIEW DDL
- **Role v panelu:** SKRYTÝ BACKEND PANELU
- **Doložený stav:** `IMPLEMENTED`
- **Riziko:** `HIGH`
- **Předpoklady:** A15
- **Následuje:** Documentation Center
- **Poznámka:** Stabilní datový kontrakt panelu.
- **Velikost:** 11727 B
- **Poslední změna:** 2026-06-30 12:34:54

## DOC_DB_EXTEND_HISTORY_CONSTRAINTS – A26 SQL

- **Soubor:** `C:\MatchMatrix-Platform\db\25_DOCUMENTATION\25_1_A_26_EXTEND_DOCUMENTATION_HISTORY_CONSTRAINTS_V1.sql`
- **Vrstva:** DB migrace
- **Účel:** Rozšíření constraintů pro MM-DL, MM-NAV a MM-PS a typy DL, NAV, PS.
- **Režimy:** `APPLY / TRANSACTION`
- **Zápis souborů:** NE
- **Zápis databáze:** ANO – ALTER CONSTRAINT
- **Role v panelu:** ADMIN / migrace
- **Doložený stav:** `APPLIED_AND_VERIFIED`
- **Riziko:** `CRITICAL`
- **Předpoklady:** Záloha, čistý Git, validní stávající data
- **Následuje:** A24 nebo PS import
- **Poznámka:** Kolize označení A25 s Python importérem korpusu.
- **Velikost:** 13570 B
- **Poslední změna:** 2026-07-05 23:17:46

## DOC_FILES_AUDIT – A2

- **Soubor:** `C:\MatchMatrix-Platform\tools\documentation\25_1_A_2_AUDIT_DOCUMENTATION_FILES_V1.py`
- **Vrstva:** Inventura
- **Účel:** Audit aktivních Markdown souborů, ID, duplicit a kandidátů importu.
- **Režimy:** `READ_ONLY`
- **Zápis souborů:** ANO – reporty
- **Zápis databáze:** NE
- **Role v panelu:** DIAGNOSTIKA / předkontrola
- **Doložený stav:** `IMPLEMENTED`
- **Riziko:** `LOW`
- **Předpoklady:** Repo s docs
- **Následuje:** A3/A4/A5
- **Poznámka:** Vhodné jako skrytá předkontrola.
- **Velikost:** 18692 B
- **Poslední změna:** 2026-07-05 14:38:53

## DOC_IDS_NORMALIZE – A3

- **Soubor:** `C:\MatchMatrix-Platform\tools\documentation\25_1_A_3_NORMALIZE_ACTIVE_DOCUMENT_IDS_V1.py`
- **Vrstva:** Údržba dokumentů
- **Účel:** Řízená normalizace vybraných Document ID a aktivních odkazů.
- **Režimy:** `DRY_RUN / APPLY`
- **Zápis souborů:** ANO – docs + report
- **Zápis databáze:** NE
- **Role v panelu:** ADMIN / oprava ID
- **Doložený stav:** `IMPLEMENTED`
- **Riziko:** `HIGH`
- **Předpoklady:** Čistý Git, přesné počty výskytů
- **Následuje:** A17/A5
- **Poznámka:** Specifická pravidla, ne univerzální normalizátor.
- **Velikost:** 17582 B
- **Poslední změna:** 2026-06-30 09:51:30

## DOC_METADATA_NORMALIZE – A4

- **Soubor:** `C:\MatchMatrix-Platform\tools\documentation\25_1_A_4_NORMALIZE_DOCUMENT_METADATA_V1.py`
- **Vrstva:** Údržba dokumentů
- **Účel:** Normalizace metadat tří konkrétních kanonických dokumentů.
- **Režimy:** `DRY_RUN / APPLY`
- **Zápis souborů:** ANO – 3 docs + report
- **Zápis databáze:** NE
- **Role v panelu:** ADMIN / historická oprava
- **Doložený stav:** `IMPLEMENTED_SPECIALIZED`
- **Riziko:** `HIGH`
- **Předpoklady:** Konkrétní soubory musí existovat
- **Následuje:** A5/A17
- **Poznámka:** Není obecný nástroj pro libovolný dokument.
- **Velikost:** 8712 B
- **Poslední změna:** 2026-07-02 21:15:59

## DOC_CANONICAL_MANIFEST_BUILD – A5

- **Soubor:** `C:\MatchMatrix-Platform\tools\documentation\25_1_A_5_BUILD_DOCUMENT_IMPORT_MANIFEST_V1.py`
- **Vrstva:** Kanonický import
- **Účel:** Deterministické sestavení manifestu vybraných kanonických dokumentů a hashů.
- **Režimy:** `BUILD`
- **Zápis souborů:** ANO – JSON/CSV report
- **Zápis databáze:** NE
- **Role v panelu:** SKRYTÝ BACKEND
- **Doložený stav:** `OPERATIONAL_WITH_REVIEW`
- **Riziko:** `MEDIUM`
- **Předpoklady:** Přesný statický seznam kandidátů
- **Následuje:** A6/A7/A9
- **Poznámka:** Hlavička uvádí 21 kandidátů, kód očekává 22; statický první-import manifest.
- **Velikost:** 25652 B
- **Poslední změna:** 2026-07-05 16:58:20

## DOC_CANONICAL_DB_IMPORT – A6

- **Soubor:** `C:\MatchMatrix-Platform\tools\documentation\25_1_A_6_IMPORT_CANONICAL_DOCUMENTS_TO_DB_V1.py`
- **Vrstva:** Kanonický import
- **Účel:** Import dokumentů, verzí, sekcí, vazeb a historie stavu z manifestu.
- **Režimy:** `DRY_RUN / APPLY`
- **Zápis souborů:** ANO – report
- **Zápis databáze:** ANO – DML při APPLY
- **Role v panelu:** SKRYTÝ BACKEND PUBLIKACE
- **Doložený stav:** `VERIFIED_OPERATIONAL`
- **Riziko:** `CRITICAL`
- **Předpoklady:** Platný manifest, DB schema, při APPLY čistý Git
- **Následuje:** A7
- **Poznámka:** Podporuje full i incremental a vazby na existující DB dokumenty.
- **Velikost:** 70218 B
- **Poslední změna:** 2026-07-02 21:40:02

## DOC_DB_IMPORT_VERIFY – A7

- **Soubor:** `C:\MatchMatrix-Platform\tools\documentation\25_1_A_7_VERIFY_DOCUMENTATION_IMPORT_V1.py`
- **Vrstva:** Integrita
- **Účel:** Read-only úplné nebo přírůstkové ověření DB proti manifestu a souborům.
- **Režimy:** `AUTO / FULL / INCREMENTAL`
- **Zápis souborů:** ANO – JSON/CSV report
- **Zápis databáze:** NE
- **Role v panelu:** TLAČÍTKO OVĚŘIT / automaticky po importu
- **Doložený stav:** `VERIFIED_OPERATIONAL`
- **Riziko:** `LOW`
- **Předpoklady:** Manifest, DB
- **Následuje:** A8/A9 nebo výsledek panelu
- **Poznámka:** Opraveno pro incremental scope.
- **Velikost:** 71802 B
- **Poslední změna:** 2026-07-01 18:04:52

## DOC_SYNC_PLAN_BUILD – A8

- **Soubor:** `C:\MatchMatrix-Platform\tools\documentation\25_1_A_8_BUILD_DOCUMENT_SYNC_PLAN_V1.py`
- **Vrstva:** Synchronizace
- **Účel:** Read-only plán souladu souborů, manifestu a DB; detekuje nové verze a blokace.
- **Režimy:** `READ_ONLY`
- **Zápis souborů:** ANO – JSON/CSV report
- **Zápis databáze:** NE
- **Role v panelu:** TLAČÍTKO ZJISTIT ROZDÍLY / skrytý backend
- **Doložený stav:** `IMPLEMENTED`
- **Riziko:** `LOW`
- **Předpoklady:** Manifest a DB
- **Následuje:** A9 nebo operátorská akce
- **Poznámka:** Vrací akční a blokující stavy.
- **Velikost:** 31221 B
- **Poslední změna:** 2026-06-30 11:33:46

## DOC_CONTROL_CYCLE_RUN – A9

- **Soubor:** `C:\MatchMatrix-Platform\tools\documentation\25_1_A_9_RUN_DOCUMENTATION_CONTROL_CYCLE_V1.py`
- **Vrstva:** Orchestrace
- **Účel:** Spustí A5 → A7 → A8 a ověří jejich FINAL STATUS.
- **Režimy:** `READ_ONLY ORCHESTRATION`
- **Zápis souborů:** ANO – souhrnný report
- **Zápis databáze:** NE
- **Role v panelu:** TLAČÍTKO CELKOVÁ KONTROLA
- **Doložený stav:** `IMPLEMENTED`
- **Riziko:** `LOW`
- **Předpoklady:** Funkční A5, A7, A8
- **Následuje:** A10/A14
- **Poznámka:** Pozor: A5 obnovuje statický kanonický manifest.
- **Velikost:** 15980 B
- **Poslední změna:** 2026-06-30 11:57:32

## DOC_STATUS_SNAPSHOT_BUILD – A10

- **Soubor:** `C:\MatchMatrix-Platform\tools\documentation\25_1_A_10_BUILD_DOCUMENTATION_STATUS_SNAPSHOT_V1.py`
- **Vrstva:** Status/KPI
- **Účel:** Sjednotí reporty A5, A7, A8 a A9 do stavového snapshotu READY/WARNING/BLOCKED.
- **Režimy:** `BUILD`
- **Zápis souborů:** ANO – JSON/CSV/MD
- **Zápis databáze:** NE
- **Role v panelu:** SKRYTÝ BACKEND KPI
- **Doložený stav:** `IMPLEMENTED_NEEDS_CURRENT_TEST`
- **Riziko:** `LOW`
- **Předpoklady:** Aktuální latest reporty A5,A7,A8,A9
- **Následuje:** A13/A14
- **Poznámka:** Dirty Git standardně vede k WARNING.
- **Velikost:** 21185 B
- **Poslední změna:** 2026-06-30 12:00:37

## DOC_STATUS_SNAPSHOT_IMPORT – A13

- **Soubor:** `C:\MatchMatrix-Platform\tools\documentation\25_1_A_13_IMPORT_DOCUMENTATION_STATUS_SNAPSHOT_V1.py`
- **Vrstva:** Status/KPI
- **Účel:** Idempotentní import status snapshotu do DB.
- **Režimy:** `DRY_RUN / APPLY`
- **Zápis souborů:** ANO – report
- **Zápis databáze:** ANO – status_snapshots při APPLY
- **Role v panelu:** SKRYTÝ BACKEND KPI
- **Doložený stav:** `IMPLEMENTED_NEEDS_CURRENT_TEST`
- **Riziko:** `HIGH`
- **Předpoklady:** A10 snapshot, A12 storage
- **Následuje:** A14/A15
- **Poznámka:** Neimportuje dokumenty, pouze provozní stav.
- **Velikost:** 28158 B
- **Poslední změna:** 2026-06-30 12:21:02

## DOC_STATUS_PIPELINE_RUN – A14

- **Soubor:** `C:\MatchMatrix-Platform\tools\documentation\25_1_A_14_RUN_DOCUMENTATION_STATUS_PIPELINE_V1.py`
- **Vrstva:** Orchestrace statusu
- **Účel:** Spustí A9 → A10 → A13 a zastaví se při prvním neúspěchu.
- **Režimy:** `DRY_RUN / APPLY`
- **Zápis souborů:** ANO – souhrnný report
- **Zápis databáze:** VOLITELNĚ status snapshot
- **Role v panelu:** TLAČÍTKO OBNOVIT STAV DOKUMENTACE
- **Doložený stav:** `IMPLEMENTED_NEEDS_CURRENT_TEST`
- **Riziko:** `HIGH`
- **Předpoklady:** A9,A10,A13 a DB storage
- **Následuje:** A15/A16/panel
- **Poznámka:** Nejde o publikaci dokumentů.
- **Velikost:** 14096 B
- **Poslední změna:** 2026-06-30 12:25:25

## DOC_STANDARD_AUDIT – A17

- **Soubor:** `C:\MatchMatrix-Platform\tools\documentation\25_1_A_17_AUDIT_DOCUMENT_STANDARD_COMPLIANCE_V1.py`
- **Vrstva:** Standardizace
- **Účel:** Read-only audit Markdown dokumentu proti standardům, metadatům a struktuře.
- **Režimy:** `READ_ONLY`
- **Zápis souborů:** ANO – JSON/MD report
- **Zápis databáze:** NE
- **Role v panelu:** TLAČÍTKO ZKONTROLOVAT
- **Doložený stav:** `VERIFIED_FOR_DL_NAV`
- **Riziko:** `LOW`
- **Předpoklady:** Markdown dokument
- **Následuje:** A18 nebo přímé schválení
- **Poznámka:** Aktuální regex nepřijímá MM-PS-YYYYMMDD.
- **Velikost:** 42154 B
- **Poslední změna:** 2026-06-30 21:58:23

## DOC_STANDARD_PROPOSAL_BUILD – A18

- **Soubor:** `C:\MatchMatrix-Platform\tools\documentation\25_1_A_18_BUILD_DOCUMENT_STANDARDIZATION_PROPOSAL_V1.py`
- **Vrstva:** Standardizace
- **Účel:** Vytvoří návrh restrukturalizace, diff a mapovací kontrakt.
- **Režimy:** `BUILD`
- **Zápis souborů:** ANO – kandidát/reporty
- **Zápis databáze:** NE
- **Role v panelu:** TLAČÍTKO PŘIPRAVIT OPRAVU
- **Doložený stav:** `IMPLEMENTED`
- **Riziko:** `MEDIUM`
- **Předpoklady:** Úspěšný A17 a shodný SHA-256
- **Následuje:** A19
- **Poznámka:** Podporuje DAILY_LOG a CHAT_CONTINUATION.
- **Velikost:** 77778 B
- **Poslední změna:** 2026-06-30 14:12:05

## DOC_STANDARD_MAPPING_REVIEW – A19

- **Soubor:** `C:\MatchMatrix-Platform\tools\documentation\25_1_A_19_REVIEW_DOCUMENT_STANDARDIZATION_MAPPING_V1.py`
- **Vrstva:** Uživatelská revize
- **Účel:** Tkinter editor pro potvrzení, přesun, rozdělení nebo vyloučení bloků A18.
- **Režimy:** `VALIDATE / GUI`
- **Zápis souborů:** ANO – review state/reporty
- **Zápis databáze:** NE
- **Role v panelu:** SPECIALIZOVANÉ REVIEW OKNO
- **Doložený stav:** `IMPLEMENTED_LOCAL_GUI`
- **Riziko:** `MEDIUM`
- **Předpoklady:** A18 panel mapping
- **Následuje:** A20
- **Poznámka:** Na PC1/PC2 architektuře je lokální Tkinter méně vhodný než web.
- **Velikost:** 59865 B
- **Poslední změna:** 2026-06-30 14:52:20

## DOC_STANDARD_CANDIDATE_BUILD – A20

- **Soubor:** `C:\MatchMatrix-Platform\tools\documentation\25_1_A_20_BUILD_STANDARDIZED_DOCUMENT_FROM_REVIEW_V1.py`
- **Vrstva:** Standardizace
- **Účel:** Sestaví standardizovaný Markdown kandidát z potvrzeného mapování A19.
- **Režimy:** `VALIDATE / BUILD`
- **Zápis souborů:** ANO – kandidát/diff/report
- **Zápis databáze:** NE
- **Role v panelu:** SKRYTÝ BACKEND PO SCHVÁLENÍ
- **Doložený stav:** `VERIFIED_OPERATIONAL`
- **Riziko:** `MEDIUM`
- **Předpoklady:** A19 MAPPING_CONFIRMED
- **Následuje:** A21/A17
- **Poznámka:** Podporuje DAILY_LOG a CHAT_CONTINUATION.
- **Velikost:** 40120 B
- **Poslední změna:** 2026-06-30 15:36:39

## DOC_STANDARD_CANDIDATE_POLISH – A21

- **Soubor:** `C:\MatchMatrix-Platform\tools\documentation\25_1_A_21_POLISH_STANDARDIZED_DOCUMENT_CANDIDATE_V1.py`
- **Vrstva:** Standardizace
- **Účel:** Redakční a sémantické dočištění kandidáta A20 s auditní stopou.
- **Režimy:** `VALIDATE / BUILD`
- **Zápis souborů:** ANO – polished kandidát/reporty
- **Zápis databáze:** NE
- **Role v panelu:** TLAČÍTKO DOČISTIT / automatický krok
- **Doložený stav:** `VERIFIED_OPERATIONAL`
- **Riziko:** `MEDIUM`
- **Předpoklady:** Platný A20 build a hash
- **Následuje:** A17/A22
- **Poznámka:** Nevytváří kanonickou verzi.
- **Velikost:** 70567 B
- **Poslední změna:** 2026-06-30 22:12:04

## DOC_DAILY_LOG_CANONICAL_PREPARE – A22

- **Soubor:** `C:\MatchMatrix-Platform\tools\documentation\25_1_A_22_PREPARE_DAILY_LOG_CANONICAL_APPROVAL_V1.py`
- **Vrstva:** Denní zápis
- **Účel:** Příprava kanonického MM-DL kandidáta, ID, metadat, terminologického reportu a A17 auditu.
- **Režimy:** `VALIDATE / BUILD`
- **Zápis souborů:** ANO – kandidát a reporty
- **Zápis databáze:** NE
- **Role v panelu:** TLAČÍTKO PŘIPRAVIT DENNÍ ZÁPIS
- **Doložený stav:** `VERIFIED_OPERATIONAL`
- **Riziko:** `MEDIUM`
- **Předpoklady:** A21 polished DAILY_LOG
- **Následuje:** A23
- **Poznámka:** Pouze DAILY_LOG; není pro NAV ani PS.
- **Velikost:** 46263 B
- **Poslední změna:** 2026-07-02 21:21:28

## DOC_TERMINOLOGY_REVIEW – A23

- **Soubor:** `C:\MatchMatrix-Platform\tools\documentation\25_1_A_23_REVIEW_TERMINOLOGY_CANDIDATES_V1.py`
- **Vrstva:** Terminologie
- **Účel:** Čištění, klasifikace a uživatelské potvrzení termínů; GUI nebo web PC1→PC2.
- **Režimy:** `VALIDATE / AUTO / GUI / WEB`
- **Zápis souborů:** ANO – review state/proposal
- **Zápis databáze:** NE
- **Role v panelu:** TLAČÍTKO POTVRDIT POJMY / otevřít web
- **Doložený stav:** `VERIFIED_WEB_READY`
- **Riziko:** `MEDIUM`
- **Předpoklady:** A22 terminology report
- **Následuje:** Samostatný schválený aplikační krok slovníku
- **Poznámka:** MM-REF-001 automaticky nemění.
- **Velikost:** 80144 B
- **Poslední změna:** 2026-06-30 23:08:56

## DOC_HISTORY_DOCUMENT_PUBLISH – A24

- **Soubor:** `C:\MatchMatrix-Platform\tools\documentation\25_1_A_24_IMPORT_HISTORY_DOCUMENTS_TO_DB_V1.py`
- **Vrstva:** Historické dokumenty
- **Účel:** Orchestrátor validace, manifestu, dry runu, APPLY přes A6 a následného A7 pro datumové dokumenty.
- **Režimy:** `VALIDATE / DRY_RUN / APPLY`
- **Zápis souborů:** ANO – manifest/report
- **Zápis databáze:** ANO – přes A6 při APPLY
- **Role v panelu:** DVOJKROK: PROVĚŘIT → PUBLIKOVAT
- **Doložený stav:** `VERIFIED_FOR_DL_NAV`
- **Riziko:** `CRITICAL`
- **Předpoklady:** Podporovaný typ, čistý Git při APPLY, DB schema
- **Následuje:** A7 automaticky
- **Poznámka:** Aktuálně podporuje jen MM-DL a MM-NAV, nikoli MM-PS.
- **Velikost:** 24241 B
- **Poslední změna:** 2026-07-01 20:28:57

## DOC_HISTORY_CORPUS_IMPORT – A25 Python

- **Soubor:** `C:\MatchMatrix-Platform\tools\documentation\25_1_A_25_IMPORT_HISTORY_CORPUS_TO_DB_V1.py`
- **Vrstva:** Historický korpus
- **Účel:** Importér nekanonického archivu různých formátů, deduplikace, MM-HIS, sekce a citlivé výjimky.
- **Režimy:** `VALIDATE_ONLY / DRY_RUN / APPLY`
- **Zápis souborů:** ANO – manifest/report/ID registry
- **Zápis databáze:** ANO – DML při APPLY
- **Role v panelu:** SAMOSTATNÁ ADMIN SEKCE KORPUS
- **Doložený stav:** `OPERATIONAL_USED_AS_EVIDENCE`
- **Riziko:** `CRITICAL`
- **Předpoklady:** Bezpečnostní výjimky, stabilní ID registry, DB
- **Následuje:** Post-import audit
- **Poznámka:** Nesmí být zaměněn s A26 SQL.
- **Velikost:** 40607 B
- **Poslední změna:** 2026-07-03 22:02:27

## HIST_A24_V1 – A24 historická V1

- **Soubor:** `C:\MatchMatrix-Platform\tools\histori\25_1_A_24_IMPORT_HISTORY_DOCUMENTS_TO_DB_V1.py`
- **Vrstva:** Historie skriptů
- **Účel:** Archivní předchozí verze A24.
- **Režimy:** `NEPOUŠTĚT`
- **Zápis souborů:** NE
- **Zápis databáze:** MOŽNÝ ZÁPIS – historický kód
- **Role v panelu:** NEZOBRAZOVAT V PANELU
- **Doložený stav:** `HISTORICAL_ONLY`
- **Riziko:** `CRITICAL`
- **Předpoklady:** Pouze pro audit/rollback kódu
- **Následuje:** Aktivní A24
- **Poznámka:** Nemá nový stav APPLIED_VERIFICATION_FAILED.
- **Velikost:** 22967 B
- **Poslední změna:** 2026-07-01 18:28:23

## HIST_A24_V2 – A24 historická V2

- **Soubor:** `C:\MatchMatrix-Platform\tools\histori\25_1_A_24_IMPORT_HISTORY_DOCUMENTS_TO_DB_V2.py`
- **Vrstva:** Historie skriptů
- **Účel:** Archivní meziverze A24.
- **Režimy:** `NEPOUŠTĚT`
- **Zápis souborů:** NE
- **Zápis databáze:** MOŽNÝ ZÁPIS – historický kód
- **Role v panelu:** NEZOBRAZOVAT V PANELU
- **Doložený stav:** `HISTORICAL_ONLY`
- **Riziko:** `CRITICAL`
- **Předpoklady:** Pouze pro audit/rollback kódu
- **Následuje:** Aktivní A24
- **Poznámka:** Historická meziverze.
- **Velikost:** 22993 B
- **Poslední změna:** 2026-07-01 20:18:18

## HIST_A6_V1 – A6 historická

- **Soubor:** `C:\MatchMatrix-Platform\tools\histori\25_1_A_6_IMPORT_CANONICAL_DOCUMENTS_TO_DB_V1.py`
- **Vrstva:** Historie skriptů
- **Účel:** Původní importer s pevným rozsahem a bez plné incremental podpory.
- **Režimy:** `NEPOUŠTĚT`
- **Zápis souborů:** NE
- **Zápis databáze:** ANO při APPLY
- **Role v panelu:** NEZOBRAZOVAT V PANELU
- **Doložený stav:** `HISTORICAL_ONLY`
- **Riziko:** `CRITICAL`
- **Předpoklady:** Pouze audit
- **Následuje:** Aktivní A6
- **Poznámka:** Pevný EXPECTED_DOCUMENTS=21.
- **Velikost:** 62476 B
- **Poslední změna:** 2026-06-30 11:08:58

## HIST_A7_V1 – A7 historická V1

- **Soubor:** `C:\MatchMatrix-Platform\tools\histori\25_1_A_7_VERIFY_DOCUMENTATION_IMPORT_V1.py`
- **Vrstva:** Historie skriptů
- **Účel:** Původní full-snapshot verifier.
- **Režimy:** `NEPOUŠTĚT`
- **Zápis souborů:** ANO – report
- **Zápis databáze:** NE
- **Role v panelu:** NEZOBRAZOVAT V PANELU
- **Doložený stav:** `HISTORICAL_ONLY`
- **Riziko:** `LOW`
- **Předpoklady:** Pouze audit
- **Následuje:** Aktivní A7
- **Poznámka:** Vytvářel falešné blokátory při incremental manifestu.
- **Velikost:** 60662 B
- **Poslední změna:** 2026-06-30 11:29:35

## HIST_A7_V2 – A7 historická V2

- **Soubor:** `C:\MatchMatrix-Platform\tools\histori\25_1_A_7_VERIFY_DOCUMENTATION_IMPORT_V2.py`
- **Vrstva:** Historie skriptů
- **Účel:** Meziverze verifieru s incremental režimem před finálními opravami.
- **Režimy:** `NEPOUŠTĚT`
- **Zápis souborů:** ANO – report
- **Zápis databáze:** NE
- **Role v panelu:** NEZOBRAZOVAT V PANELU
- **Doložený stav:** `HISTORICAL_ONLY`
- **Riziko:** `LOW`
- **Předpoklady:** Pouze audit
- **Následuje:** Aktivní A7
- **Poznámka:** Historická meziverze.
- **Velikost:** 67120 B
- **Poslední změna:** 2026-07-01 14:40:38

## DOC_PANEL_Q – V20.1.Q

- **Soubor:** `C:\MatchMatrix-Platform\tools\panels\matchmatrix_control_panel_V20_1_Q_DOCUMENTATION_CENTER.py`
- **Vrstva:** Panel
- **Účel:** Read-only Dokumentační centrum: DB dokumenty, vazby, status history, import runs a rychlé otevření souborů.
- **Režimy:** `GUI`
- **Zápis souborů:** NE
- **Zápis databáze:** ČTENÍ DB
- **Role v panelu:** HLAVNÍ UŽIVATELSKÁ VRSTVA
- **Doložený stav:** `IMPLEMENTED_READ_ONLY`
- **Riziko:** `CRITICAL`
- **Předpoklady:** DB, cesty PC2/PC1
- **Následuje:** Rozšíření o registry a bezpečná tlačítka
- **Poznámka:** Obsahuje přihlašovací údaje DB přímo ve zdrojovém kódu; před dalším rozvojem odstranit do .env. PYTHON_EXE je obecné 'python', ne explicitní C:\Python314\python.exe.
- **Velikost:** 392372 B
- **Poslední změna:** 2026-07-02 12:09:18

# 9. Doporučené pořadí dalšího vývoje

1. Zabezpečit panel V20.1.Q – odstranit přihlašovací údaje ze zdrojového kódu a sjednotit Python na `C:\Python314\python.exe`.
2. Doplnit podporu Project Snapshot do A17.
3. Archivovat aktivní A24 a doplnit do něj bezpečnou podporu `MM-PS-YYYYMMDD`.
4. Pro `MM-PS-20260331` provést validate-only a databázový dry run.
5. Teprve po úspěšném výsledku přidat dvě panelové akce `PROVĚŘIT PUBLIKACI` a `SCHVÁLIT A PUBLIKOVAT`.
6. Připojit registr nástrojů jako konfigurační zdroj panelu, aby příkazy nebyly rozeseté přímo v GUI kódu.
7. Později převést A19 na webový režim nebo panelový editor.

# 10. Přesný další technický cíl

Nejbližší vývojová změna nemá být samotný import březnového snapshotu. Nejdříve musí vzniknout bezpečná podpora typu `PROJECT_SNAPSHOT` v A17 a A24. Teprve potom lze dokončit publikování `MM-PS-20260331` a pokračovat dubnovou rekonstrukcí.

# Závěr

Inventář potvrdil, že většina potřebné logiky již existuje. Hlavní úkol není psát celý dokumentační systém znovu, ale vytvořit nad existujícími nástroji bezpečný registr, orchestraci a panelové stavy. Současně byly odhaleny tři blokátory, které je nutné vyřešit před zapisující integrací panelu: chybějící plná podpora `MM-PS`, kolize označení A25 a přihlašovací údaje uložené přímo ve zdrojovém kódu panelu.