# MATCHMATRIX – NAVÁZÁNÍ DO NOVÉHO CHATU – 2026-07-01

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Document ID | MM-NAV-20260701-01 |
| Název dokumentu | MATCHMATRIX – NAVÁZÁNÍ DO NOVÉHO CHATU – 2026-07-01 |
| Typ dokumentu | CHAT_CONTINUATION |
| Edice | HISTORY |
| Verze | 1.0 |
| Stav | REVIEW |
| Datum | 2026-07-01 |
| Pořadí v rámci dne | 01 |
| Autor | Petr Kubinák |
| Technická spolupráce | OpenAI ChatGPT |
| Projekt | MatchMatrix-platform |
| Pracovní oblast | Documentation Management, Database Governance, Operator Panel |
| Předchozí NAVÁZÁNÍ | MM-NAV-20260630-01 |
| Primární prostředí | PC2 – `C:\MatchMatrix-platform` |
| Ovládací pracoviště | PC1 |
| Cílové umístění | `docs/09_HISTORY/NAVÁZÁNÍ_NA_CHAT/MM-NAV-20260701-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md` |
| Primární formát | Markdown (`.md`) |

> Tento dokument předává stav po úspěšném uložení historických dokumentů do GitHubu a databáze. Hlavním cílem následující etapy je opravit přírůstkové ověřování A7 a začít převádět dokumentační workflow do hlavního ovládacího panelu MatchMatrix.

---

# 1. Identifikace navázání

| Položka | Hodnota |
|---|---|
| Datum uzavření etapy | 2026-07-01 |
| Název etapy | První produkční import datumových dokumentů MM-DL a MM-NAV |
| Hlavní výsledek | Dokumenty jsou v GitHubu i databázi |
| Aktuální blokace | A7 neumí korektně ověřit přírůstkový manifest proti celé DB |
| Hlavní další směr | Dokumentační workflow na několik kliknutí v panelu |
| Režim další práce | Vždy jeden krok a jeden příkaz |
| Platnost navázání | Výchozí bod nového chatu |

---

# 2. Výchozí kontext

V předchozí etapě byl vytvořen a otestován dokumentační řetězec A17 až A25.

Jeho úkolem bylo:

- standardizovat historické denní zápisy,
- standardizovat dokumenty NAVÁZÁNÍ,
- přidělit datumové identifikátory,
- kontrolovat strukturu a terminologii,
- ukládat dokumenty do Git historie,
- importovat dokumenty do databáze,
- ověřovat verze, sekce a vazby.

Současný proces je funkční, ale stále příliš technický a zdlouhavý pro běžnou každodenní práci. Cílový stav je ovládání z panelu na několik kliknutí.

---

# 3. CURRENT STATUS

## 3.1 GitHub

Poslední potvrzený commit:

```text
cf5a993
db: align documentation history constraints with MM-STD-007
```

Předchozí důležitý commit:

```text
0bf7544
docs: standardize chat continuation and add A20 builder
```

Aktuální stav:

```text
BRANCH      : main
ORIGIN      : origin/main
GIT STATUS  : CLEAN
```

## 3.2 Databázové constrainty

Tabulka:

```text
documentation.documents
```

Constrainty byly úspěšně synchronizovány s MM-STD-007:

```text
ck_documentation_documents_id
ck_documentation_documents_type
```

Oba mají:

```text
is_validated = true
```

Podporované nové identifikátory:

```text
MM-DL-YYYYMMDD
MM-NAV-YYYYMMDD-PP
```

Podporované nové typy:

```text
DL
NAV
```

## 3.3 Importované dokumenty

V databázi jsou aktuálně potvrzeny:

```text
MM-DL-20260630
document_type       : DL
version             : 1.0
status              : REVIEW
is_current          : true
section_count       : 56
source_git_commit   : cf5a99363df39a1144a66ad3363d47630186b3fc
relation_count      : 1
```

```text
MM-NAV-20260630-01
document_type       : NAV
version             : 1.1
status              : REVIEW
is_current          : true
section_count       : 43
source_git_commit   : cf5a99363df39a1144a66ad3363d47630186b3fc
relation_count      : 1
```

## 3.4 Databázový import A24

Dry run:

```text
FINAL STATUS : HISTORY_DOCUMENT_IMPORT_DRY_RUN_READY
```

Apply:

```text
DOCUMENT_IMPORT_APPLIED
documents_inserted         : 2
versions_inserted          : 2
sections_inserted          : 99
relations_inserted         : 2
status_history_inserted    : 2
warnings                   : 0
```

Dokumenty byly skutečně vloženy správně.

## 3.5 Ověření A7

A7 potvrdil oba jednotlivé dokumenty:

```text
MM-DL-20260630      : OK, v1.0, sections 56/56, relations 1/1
MM-NAV-20260630-01  : OK, v1.1, sections 43/43, relations 1/1
```

Potom však celý audit skončil chybou, protože porovnal dvoudokumentový přírůstkový manifest s celou databází obsahující 23 dokumentů.

Falešné blokátory:

```text
DATABASE_DOCUMENT_SET_MISMATCH
TOTAL_SECTION_COUNT_MISMATCH
DOCUMENT_RELATIONS_EXTRA
```

Nejde o chybu importovaných dokumentů. Jde o chybný režim globálního porovnání v A7.

---

# 4. Co bylo dokončeno

## 4.1 Standard identifikace

MM-STD-007 nyní definuje a databáze přijímá:

```text
MM-DL-YYYYMMDD
MM-NAV-YYYYMMDD-PP
```

## 4.2 Dokumentační skripty

Aktuální řetězec:

```text
A17 – audit shody dokumentu
A20 – sestavení standardizovaného kandidáta
A21 – redakční dočištění
A22 – příprava kanonického kandidáta
A23 – terminologická revize
A24 – import historických dokumentů do DB
A25 – synchronizace DB constraintů s MM-STD-007
```

## 4.3 Historické dokumenty

Správné složky:

```text
docs/09_HISTORY/DENNÍ_ZÁPISY/
docs/09_HISTORY/NAVÁZÁNÍ_NA_CHAT/
```

## 4.4 Git a DB auditní stopa

Dokumenty jsou propojeny s:

- verzí dokumentu,
- SHA-256 obsahu,
- zdrojovým souborem,
- zdrojovou cestou,
- Git commitem,
- sekcemi,
- vazbami,
- historií stavu,
- importním během.

## 4.5 Pracovní pravidlo

Další technická práce probíhá zásadně:

```text
jeden krok
→ jeden příkaz
→ výsledek uživatele
→ vyhodnocení
→ další krok
```

Dlouhé bloky deseti příkazů se neposílají.

## 4.6 Pravidlo pro předávání skriptů

```text
Python:
hotový soubor ke stažení

SQL:
text přímo v chatu ke kopírování do DBeaveru
```

Uživatel SQL po ověření ukládá do odpovídající složky projektu.

## 4.7 Přijatá rozhodnutí

V této etapě byla potvrzena následující rozhodnutí:

- datumové identifikátory `MM-DL-YYYYMMDD` a `MM-NAV-YYYYMMDD-PP` představují oficiální formát historických dokumentů,
- dokumentační řetězec A17 až A25 zůstává backendem budoucího dokumentačního modulu panelu,
- A7 musí rozlišovat úplný audit a přírůstkový audit,
- přírůstkový audit ověřuje pouze dokumenty uvedené v manifestu,
- publikování dokumentů musí vždy vyžadovat viditelné schválení uživatelem,
- generované reporty se standardně necommitují do Git repozitáře,
- další technická práce probíhá po jednom kroku a jednom příkazu,
- PC1 zůstává ovládacím pracovištěm a PC2 procesní stanicí.

---

# 5. Co zůstává rozpracováno

## 5.1 Oprava A7

A7 musí rozlišovat dva režimy:

```text
FULL SNAPSHOT
INCREMENTAL MANIFEST
```

Pro přírůstkový manifest nesmí vyžadovat, aby:

- množina všech dokumentů v DB odpovídala pouze manifestu,
- celkový počet všech sekcí v DB odpovídal pouze manifestu,
- všechny ostatní historické vazby byly považovány za chybu.

Přírůstková kontrola musí ověřovat pouze dokumenty uvedené v manifestu.

## 5.2 SyntaxWarning v A24

A24 vypisuje:

```text
SyntaxWarning: "\d" is an invalid escape sequence
```

Varování je v textové nápovědě skriptu, nikoli v importní logice. Při další revizi se opraví použitím raw docstringu nebo escapovaného `\\d`.

## 5.3 Terminologická revize A23

Stav zůstává:

```text
CONFIRMED : 0
PENDING   : 67
```

MM-REF-001 zatím nebyl změněn.

## 5.4 Kanonické publikování MM-DL-20260624

Historický kandidát `MM-DL-20260624` je strukturálně připravený, ale zůstává blokován terminologickou revizí.

## 5.5 Dokumentační panel

Dokumentační proces zatím vyžaduje příliš mnoho ručních kroků. Musí být převeden do panelu.

---

# 6. OPEN QUESTIONS / otevřené úkoly

| Priorita | Úkol | Stav | Kritérium dokončení |
|---|---|---|---|
| CRITICAL | Opravit A7 pro přírůstkový manifest | OPEN | A7 ověří nové dokumenty bez falešných globálních blokátorů |
| HIGH | Navrhnout dokumentační modul panelu | OPEN | Schválené obrazovky a tlačítka |
| HIGH | Vytvořit řízený publikační orchestrátor | PLANNED | Jeden proces audit → Git → DB → verify |
| HIGH | Dokončit A23 terminologickou revizi | OPEN | `CONFIRMED 67`, `PENDING 0` |
| MEDIUM | Opravit SyntaxWarning A24 | OPEN | Bez varování při spuštění |
| MEDIUM | Doplnit stav dokumentace do panelu | PLANNED | KPI a tabulka dokumentů |
| MEDIUM | Připravit automatické NAVÁZÁNÍ | PLANNED | Vygenerovaný dokument na jedno kliknutí |

---

# 7. Cílové workflow na několik kliknutí

## 7.1 Hlavní princip

Uživatel nemá běžně spouštět A17 až A25 ručně.

Panel má nabídnout řízený postup:

```text
1. PŘIPRAVIT DOKUMENT
2. ZKONTROLOVAT / OPRAVIT
3. POTVRDIT NOVÉ POJMY
4. SCHVÁLIT A PUBLIKOVAT
```

## 7.2 Běžný případ bez nových pojmů

Cílově dva hlavní kliky:

```text
PŘIPRAVIT DOKUMENT
SCHVÁLIT A PUBLIKOVAT
```

## 7.3 Případ s novými pojmy

```text
PŘIPRAVIT DOKUMENT
POTVRDIT POJMY
SCHVÁLIT A PUBLIKOVAT
```

## 7.4 Automatické činnosti panelu

Panel má automaticky provést:

- určení typu dokumentu,
- přidělení `Document ID`,
- určení správné složky,
- kontrolu názvu souboru,
- kontrolu metadat,
- audit A17,
- bezpečné opravy,
- terminologickou předklasifikaci,
- zobrazení pouze skutečně nejasných pojmů,
- vytvoření diffu,
- Git commit,
- Git push,
- databázový dry run,
- databázový apply,
- přírůstkové ověření,
- zobrazení výsledku.

Tlačítko publikování nesmí být aktivní, dokud neprojdou všechny povinné kontroly.

---

# 8. Návrh integrace do MatchMatrix Control Panel

Zdrojový panel:

```text
matchmatrix_control_panel_V20_1_P4_FIX_PROVIDER_DISCOVERY_BUTTON.py
```

## 8.1 Nová položka levé navigace

Doplnit novou záložku:

```text
DOKUMENTACE
```

Technický kód:

```text
DOCUMENTATION
```

Umístění v navigaci ideálně pod `DENNÍ PRÁCE` nebo vedle `GOVERNANCE`.

## 8.2 Hlavní obrazovka DOKUMENTACE

Horní karty:

```text
DOKUMENTY V DB
ČEKAJÍCÍ REVIZE
NEZNÁMÉ POJMY
POSLEDNÍ PUBLIKACE
GIT STAV
DB STAV
```

Hlavní pracovní tabulky:

```text
DOKUMENTY K AKCI
POSLEDNÍ DOKUMENTY
TERMINOLOGICKÁ REVIZE
PUBLIKAČNÍ HISTORIE
CHYBY A BLOKACE
```

## 8.3 Pravá akční lišta

Akce nad vybraným dokumentem:

```text
📝 VYTVOŘIT DENNÍ ZÁPIS
🔗 VYTVOŘIT NAVÁZÁNÍ
🔍 ZKONTROLOVAT
🛠 AUTOMATICKY OPRAVIT
📚 POTVRDIT POJMY
👁 ZOBRAZIT DIFF
✅ SCHVÁLIT A PUBLIKOVAT
↻ OBNOVIT
```

## 8.4 Rychlá akce z DENNÍ PRÁCE

Do globálních rychlých akcí přidat:

```text
📄 UZAVŘÍT PRACOVNÍ ETAPU
```

Tato akce nabídne:

```text
Vytvořit pouze denní zápis
Vytvořit pouze NAVÁZÁNÍ
Vytvořit oba dokumenty
```

## 8.5 Bezpečnost panelu

Panel nesmí automaticky pokračovat po chybě.

Povinné stavy:

```text
STRUCTURE CHECK       : PASS
TERMINOLOGY CHECK     : PASS / USER CONFIRMED
GIT READINESS         : PASS
DATABASE SCHEMA       : PASS
DATABASE DRY RUN      : PASS
PUBLISH               : ENABLED
POST-IMPORT VERIFY    : PASS
```

Při chybě:

```text
PUBLISH = DISABLED
```

## 8.6 Odpovědnost existujících skriptů

Panel nebude duplikovat logiku skriptů.

Bude je řídit jako backend:

```text
A17  audit
A20  standardizace
A21  polish
A22  příprava kandidáta
A23  terminologie
A24  import
A7   ověření
```

Později je vhodné vytvořit jeden nadřazený orchestrátor, který panel spustí jedním tlačítkem.

---

# 9. Rizika a upozornění

## 9.1 A7 se nesmí považovat za úspěšný

Aktuální import byl ověřen ručními SQL dotazy a jednotlivé dokumenty jsou správně.

A7 však stále vrací nenulový kód kvůli chybnému globálnímu porovnání.

## 9.2 A24 znovu nespouštět nad stejným obsahem bez potřeby

Dokumenty jsou již v DB.

Další běh by měl být proveden až po opravě A7 nebo při nové verzi dokumentů.

## 9.3 Generované reporty necommitovat

Do Git patří:

- produkční skripty,
- standardy,
- schválené dokumenty,
- SQL migrace.

Do Git standardně nepatří:

```text
reports/documentation/
```

## 9.4 SQL zůstává textem pro DBeaver

SQL nebude posílán jako Python ani jako automaticky spouštěný soubor.

## 9.5 Nový panel nesmí obcházet uživatelské schválení

Automatizace může připravit návrh, ale:

- nové pojmy,
- zásadní opravy,
- publikování,

musí být viditelně schváleny uživatelem.

---

# 10. Ověřené zdroje a soubory

## 10.1 Dokumenty

```text
docs/09_HISTORY/DENNÍ_ZÁPISY/
MM-DL-20260630_MATCHMATRIX_DENNI_ZAPIS.md

docs/09_HISTORY/NAVÁZÁNÍ_NA_CHAT/
MM-NAV-20260630-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md
```

## 10.2 Produkční skripty

```text
tools/documentation/
25_1_A_17_AUDIT_DOCUMENT_STANDARD_COMPLIANCE_V1.py

tools/documentation/
25_1_A_20_BUILD_STANDARDIZED_DOCUMENT_FROM_REVIEW_V1.py

tools/documentation/
25_1_A_21_POLISH_STANDARDIZED_DOCUMENT_CANDIDATE_V1.py

tools/documentation/
25_1_A_22_PREPARE_DAILY_LOG_CANONICAL_APPROVAL_V1.py

tools/documentation/
25_1_A_23_REVIEW_TERMINOLOGY_CANDIDATES_V1.py

tools/documentation/
25_1_A_24_IMPORT_HISTORY_DOCUMENTS_TO_DB_V1.py
```

## 10.3 SQL migrace

```text
db/25_DOCUMENTATION/
25_1_A_25_EXTEND_DOCUMENTATION_HISTORY_CONSTRAINTS_V1.sql
```

## 10.4 Panel

```text
matchmatrix_control_panel_V20_1_P4_FIX_PROVIDER_DISCOVERY_BUTTON.py
```

## 10.5 Databázové objekty

```text
documentation.documents
documentation.document_versions
documentation.document_sections
documentation.document_relations
documentation.document_status_history
documentation.import_runs
```

---

# 11. AI CONTEXT

Následující AI musí dodržet:

1. Začít opravou A7 pro přírůstkový manifest.
2. Neimportovat znovu již potvrzené dokumenty bez důvodu.
3. Považovat oba dokumenty za správně uložené v GitHubu a DB.
4. Považovat Git strom za čistý.
5. Pracovat vždy po jednom kroku.
6. Poslat vždy jen jeden příkaz nebo jeden jasný úkon.
7. Python předávat jako soubor ke stažení.
8. SQL předávat přímo v chatu pro DBeaver.
9. Generované reporty standardně necommitovat.
10. Po opravě A7 zahájit návrh dokumentační záložky panelu.
11. Zachovat architekturu PC1 jako ovládání a PC2 jako procesní stanici.
12. Nezapisovat tokeny nebo hesla do dokumentace.
13. Neprovádět publikování bez uživatelského schválení.
14. Cílem je workflow na dva až tři kliky.

---

# 12. PROJECT SNAPSHOT

```text
Projekt                         : MatchMatrix-platform
Dokumentační framework          : ACTIVE DEVELOPMENT
Datumové MM-DL                  : IMPLEMENTED
Datumové MM-NAV                 : IMPLEMENTED
DB constrainty                  : SYNCHRONIZED
A17 compliance audit            : WORKING
A20 standardized builder        : AVAILABLE
A21 document polisher           : WORKING
A22 canonical preparation       : WORKING
A23 terminology review          : WEB READY / USER REVIEW PENDING
A24 history importer            : WORKING
A25 DB constraint migration     : APPLIED
MM-DL-20260630                   : IN GIT AND DB
MM-NAV-20260630-01              : IN GIT AND DB
A7 incremental verification     : REQUIRES FIX
Documentation panel             : NEXT DEVELOPMENT TARGET
Git tree                        : CLEAN
```

---

# 13. DATABASE SNAPSHOT

```text
documentation.documents              : 23
documentation.document_versions      : 23
documentation.current_versions       : 23
documentation.document_sections      : 882
documentation.document_relations     : 93
documentation.document_status_history: 23
```

Nové dokumenty:

```text
MM-DL-20260630
DL / v1.0 / REVIEW / 56 sekcí / 1 vazba

MM-NAV-20260630-01
NAV / v1.1 / REVIEW / 43 sekcí / 1 vazba
```

Importní běh:

```text
IMPORT RUN ID : 13
IMPORT RESULT : DOCUMENT_IMPORT_APPLIED
```

A7 post-import audit:

```text
INDIVIDUAL DOCUMENT CHECKS : PASS
GLOBAL INCREMENTAL MODE     : INCORRECT
FINAL A7 STATUS             : FAILED DUE TO FALSE GLOBAL BLOCKERS
```

---

# 14. NEXT STEP

> **Opravit A7 tak, aby při přírůstkovém manifestu ověřoval pouze dokumenty uvedené v manifestu a nepovažoval ostatní dokumenty, sekce a vazby databáze za chybu.**

Po opravě A7:

1. spustit read-only ověření nad posledním manifestem,
2. potvrdit nulový počet blokátorů,
3. připravit návrh nové záložky `DOKUMENTACE`,
4. integrovat první tlačítko `VYTVOŘIT NAVÁZÁNÍ`,
5. postupně přidat celý publikační workflow.

Práce musí pokračovat po jednom kroku.

---

# 15. Závěr

První skutečný datumový denní zápis a první datumové NAVÁZÁNÍ byly úspěšně:

```text
standardizovány
auditovány
uloženy do GitHubu
importovány do databáze
ověřeny podle verzí, sekcí a vazeb
```

Nalezená chyba A7 nepoškodila import. Odhalila pouze chybějící rozlišení mezi úplným a přírůstkovým auditem.

Další vývoj už nemá rozšiřovat počet ručních příkazů. Má převést ověřený backend do panelu MatchMatrix tak, aby vznikl praktický dokumentační modul ovládaný na několik kliknutí.

---

## Historie verzí

| Verze | Datum | Stav | Popis |
|---|---|---|---|
| 1.0 | 2026-07-01 | REVIEW | Navázání po prvním produkčním importu MM-DL a MM-NAV; stanovuje opravu A7 a integraci dokumentačního workflow do panelu jako další etapu. |
