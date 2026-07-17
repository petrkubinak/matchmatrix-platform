# MatchMatrix – navázání do nového chatu – 2026-07-16

## Informace o dokumentu

| Položka               | Hodnota                                                                                |
|-----------------------|----------------------------------------------------------------------------------------|
| Document ID           | MM-NAV-20260716-01                                                                     |
| Název dokumentu       | MatchMatrix – navázání do nového chatu – 2026-07-16                                    |
| Typ dokumentu         | CHAT_CONTINUATION                                                                      |
| Verze                 | 1.0                                                                                    |
| Stav | APPROVED |
| Původní stav zdrojového dokumentu | DRAFT – NEEDS_USER_APPROVAL                                                |
| Datum      | 2026-07-16 |
| Autor                 | Petr                                                                                   |
| Technická spolupráce  | OpenAI ChatGPT                                                                         |
| Pracovní oblast       | Terminologické workflow A23, české popisky panelu a oprava návrhů MM-REF               |
| Primární formát       | Markdown (.md)                                                                         |
| Kanonické umístění    | `docs/09_HISTORY/NAVÁZÁNÍ_NA_CHAT/MM-NAV-20260716-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md` |
| Zdrojový denní zápis  | `MM-DL-20260716_MATCHMATRIX_DENNI_ZAPIS.md`                                            |
| Předchozí navázání    | `MM-NAV-20260714-01`                                                                   |

---

## 1. Identifikace navázání

Tento dokument předává úplný kontext po dokončení `MM-DB-003_DATOVY_SLOVNIK_TABULEK_A_SLOUPCU_MATCHMATRIX.md`, prvním praktickém nasazení A23 a přípravě české prezentační vrstvy dokumentačního panelu.

Dokument je určen pro okamžité pokračování v novém chatu bez opakování dokončených kroků a bez použití poškozeného proposal souboru.

---

## 2. Výchozí kontext

Před zahájením terminologického workflow byly dokončeny a publikovány:

```text
MM-DB-001_ARCHITEKTURA_DATABAZE_MATCHMATRIX.md
MM-DB-002_KATALOG_SCHEMAT_A_DATABAZOVYCH_OBJEKTU_MATCHMATRIX.md
MM-DB-003_DATOVY_SLOVNIK_TABULEK_A_SLOUPCU_MATCHMATRIX.md
```

`MM-DB-003` byl vytvořen z aktuálního read-only databázového auditu A33 a obsahuje 12 257 sloupců, 879 objektů se sloupci a 5 schémat.

Po publikaci MM-DB-003 bylo otevřeno řízené terminologické workflow:

```text
A17
→ A23 read-only analýza
→ výběr kandidátů
→ pracovní proposal
→ uživatelská kontrola
→ A17
→ schválení
→ Git
→ A24
→ A7
```

---

## 3. CURRENT STATUS

| Oblast | Aktuální stav |
|---|---|
| MM-DB-001 | DOKONČENO A PUBLIKOVÁNO |
| MM-DB-002 | DOKONČENO A PUBLIKOVÁNO |
| MM-DB-003 | DOKONČENO A PUBLIKOVÁNO |
| A17 MM-DB-003 | 96,00 %, FAIL 0, PARTIAL 0 |
| Git commit MM-DB-003 | `ec54b3357fe1952b25923d4ab81b8edc2494a330` |
| Git push | DOKONČEN |
| A24 | HISTORY_DOCUMENT_IMPORT_APPLIED_AND_VERIFIED |
| A7 | VERIFIED |
| A23 read-only analýza | FUNKČNÍ |
| Terminologičtí kandidáti | 15 NEW |
| Výběr kandidátů | FUNKČNÍ |
| Tvorba proposal souborů | TECHNICKY FUNKČNÍ |
| Otevírání proposal souborů | STEP 26 FIX 3, čeká na definitivní retest |
| MM-REF-001 proposal | POŠKOZENÝ, NESMÍ BÝT PUBLIKOVÁN |
| MM-REF-002 proposal | VYŽADUJE DETAILNÍ KONTROLU |
| Kanonické slovníky | BEZE ZMĚNY |
| STEP 27 | ULOŽEN, čeká na praktické ověření |
| Nejbližší pracovní priorita | Ověřit české popisky panelu |

---

## 4. Co bylo dokončeno

### 4.1 MM-DB-003

Dokument `MM-DB-003_DATOVY_SLOVNIK_TABULEK_A_SLOUPCU_MATCHMATRIX.md` byl:

1. vytvořen;
2. auditován;
3. schválen jako verze 0.9;
4. commitnut;
5. pushnut;
6. importován pomocí A24;
7. ověřen pomocí A7.

### 4.2 A23 read-only analýza

A23 správně:

- načetl explicitní kandidáty;
- porovnal je s `MM-REF-001` a `MM-REF-002`;
- vytvořil JSON a Markdown report;
- označil 15 položek jako `NEW`;
- nezměnil kanonické soubory;
- nezměnil Git;
- nezměnil databázi.

### 4.3 Bezpečný proposal režim

Panel umí vybrat terminologické kandidáty a vytvořit pracovní návrhy pouze v:

```text
reports\documentation\standardization\panel_workspaces\
<workspace_MM_DB_003>\a23\proposals\
```

Bezpečnostní kontrola potvrdila:

```text
CANONICAL_FILES_MODIFIED=False
DATABASE_MODIFIED=False
GIT_MODIFIED=False
```

### 4.4 Opravy cest a otevírání

Byly připraveny opravy:

- potlačení CLIXML progress streamu;
- ověření JSON výsledku;
- převod lokální cesty PC2 na UNC cestu;
- otevření proposal souborů místo kanonických slovníků;
- dohledání proposal souboru přímo v aktuálním workspace.

### 4.5 STEP 27

Byla připravena aktivní panelová verze:

```text
C:\MatchMatrix-platform\tools\
matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py
```

Verze zavádí české názvy dokumentačních sloupců, české stavové hodnoty a české popisky kandidátů A23 při zachování interních databázových názvů.

---

## 5. Co zůstává rozpracováno

1. Praktické ověření všech českých popisků v části DOKUMENTACE.
2. Přesný seznam zbývajících anglických výrazů v uživatelském rozhraní.
3. Definitivní retest otevírání návrhů pomocí STEP 26 FIX 3.
4. Oprava proposal builderu pro `MM-REF-001`.
5. Vytvoření čistého návrhu `MM-REF-001` v1.6.
6. Oprava generování klikacího rejstříku a anchorů `MM-REF-002`.
7. Vytvoření čistého návrhu `MM-REF-002` v1.2.
8. Samostatná kontrola A17 obou opravených návrhů.
9. Uživatelské schválení jednotlivých překladů a výkladů.
10. Publikace slovníků přes Git, A24 a A7 až po úspěšném schválení.

---

## 6. OPEN QUESTIONS / otevřené úkoly

1. Které uživatelské popisky panelu zůstaly po STEP 27 anglicky?
2. Překládají se správně stavové hodnoty `APPROVED`, `HYBRID`, `REVIEW`, `PARTIAL`, `CRITICAL`, `HIGH`, `MEDIUM` a `LOW`?
3. Otevírá STEP 26 FIX 3 správný proposal z aktuálního workspace?
4. Jak opravit změnu stavu bez doslovného zápisu `\1` a `\3`?
5. Jak vložit nové položky přesně do hlavní tabulky `MM-REF-001`?
6. Jak aktualizovat verzi, souhrn a historii verzí `MM-REF-001`?
7. Jak doplnit klikací rejstřík, jedinečné anchors a detailní výklady `MM-REF-002`?
8. Jak bude panel zobrazovat rozdíl mezi kanonickým a navrženým slovníkem?
9. Jak bude uživatel potvrzovat nebo odmítat jednotlivé pojmy?
10. Jak bude panel řešit konflikt s již existující schválenou položkou?

---

## 7. Rizika a upozornění

- Poškozený návrh `MM-REF-001` se nesmí schválit, commitnout ani importovat.
- A23 nesmí připojovat nové položky za závěr dokumentu.
- Regexová náhrada nesmí zapisovat doslovné backreference `\1` a `\3`.
- Návrh `MM-REF-001` musí mít verzi 1.6 a stav `DRAFT – NEEDS_USER_APPROVAL`.
- Návrh `MM-REF-002` musí mít verzi 1.2 a stav `DRAFT – NEEDS_USER_APPROVAL`.
- Nové položky `MM-REF-001` musí být vloženy do hlavní překladové tabulky.
- `MM-REF-002` musí obsahovat klikací rejstřík, jedinečné anchors, výklad, zdrojový dokument a kapitolu.
- Kanonické slovníky musí zůstat beze změny až do uživatelského schválení.
- Interní databázové názvy se nesmí kvůli českému UI přejmenovávat.
- A24 se smí spustit pouze nad schváleným kanonickým dokumentem a při čistém Git stromu.

---

## 8. Přijatá rozhodnutí

1. `MM-DB-003` je dokončený dokument a bez nového důvodu se neupravuje.
2. Terminologický proces musí oddělovat analýzu, návrh, kontrolu, schválení a publikaci.
3. Žádný nový pojem se nesmí automaticky kanonicky uložit bez uživatelského schválení.
4. `MM-REF-001` je stručný překladový slovník.
5. `MM-REF-002` je podrobný výkladový rejstřík.
6. Originální technické výrazy a databázové identifikátory zůstávají v dokumentech.
7. Uživatelské popisky panelu musí být v češtině.
8. Interní SQL a databázové názvy zůstávají beze změny.
9. Proposal soubory jsou pracovní kandidáti.
10. Poškozený proposal nesmí projít do A17, Gitu ani A24.
11. Další oprava musí používat skutečnou strukturu kanonických referenčních dokumentů.
12. Práce pokračuje vždy po jednom jasném kroku.

---

## 9. Ověřené zdroje a odkazy

### Aktivní panel

```text
C:\MatchMatrix-platform\tools\
matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py
```

### Terminologický nástroj A23

```text
C:\MatchMatrix-platform\tools\documentation\
25_1_A_23_REVIEW_TERMINOLOGY_CANDIDATES_V1.py
```

### Databázový audit A33

```text
C:\MatchMatrix-platform\tools\documentation\
25_1_A_33_EXPORT_DATABASE_STRUCTURE_AUDIT_V1.py
```

### Zdrojový dokument

```text
C:\MatchMatrix-platform\docs\04_DATABASE\
MM-DB-003_DATOVY_SLOVNIK_TABULEK_A_SLOUPCU_MATCHMATRIX.md
```

### Referenční dokumenty

```text
C:\MatchMatrix-platform\docs\10_REFERENCE\
MM-REF-001_SLOVNIK_CIZICH_POJMU_MATCHMATRIX.md

C:\MatchMatrix-platform\docs\10_REFERENCE\
MM-REF-002_VYKLADOVY_REJSTRIK_POJMU_MATCHMATRIX.md
```

### Ověřený Git commit

```text
ec54b3357fe1952b25923d4ab81b8edc2494a330
```

---

## 10. AI CONTEXT

Při pokračování musí AI:

1. respektovat, že `MM-DB-003` je dokončený a publikovaný;
2. nejprve ověřit pouze české popisky panelu;
3. postupovat po jednom jasném kroku;
4. nepožadovat nové spuštění A23 před dokončením UI kontroly;
5. po snímku panelu zapsat přesný seznam nepřeložených popisků;
6. následně opravit A23 proposal builder pro `MM-REF-001`;
7. použít skutečnou strukturu kanonického `MM-REF-001` v1.5;
8. vytvořit nový čistý návrh `MM-REF-001` v1.6;
9. opravit generování `MM-REF-002` podle kanonické verze 1.1;
10. vytvořit nový čistý návrh `MM-REF-002` v1.2;
11. zachovat kanonické slovníky, Git a databázi beze změny až do schválení;
12. po schválení pokračovat přes A17, Git, A24 a A7.

---

## 11. PROJECT SNAPSHOT

| Oblast | Ověřený stav |
|---|---|
| Aktivní větev | `main` |
| Produkční projekt | `C:\MatchMatrix-platform` na PC2 |
| Produkční databáze | `matchmatrix` |
| PostgreSQL | Docker kontejner `matchmatrix_postgres` |
| Poslední dokumentační commit | `ec54b3357fe1952b25923d4ab81b8edc2494a330` |
| Poslední dokončený dokument | MM-DB-003 |
| Aktivní panelový krok | STEP 27 |
| Terminologický nástroj | A23 proposal workflow |
| Nové kandidátní pojmy | 15 |
| Kanonické slovníky | MM-REF-001 v1.5, MM-REF-002 v1.1 |
| Cílové návrhové verze | MM-REF-001 v1.6, MM-REF-002 v1.2 |
| Největší riziko | Poškozená struktura proposal dokumentu |
| Nejbližší cíl | Ověřit české popisky panelu |

---

## 12. DATABASE SNAPSHOT

Stav dokumentační databáze po importu `MM-DB-003`:

| Ukazatel | Hodnota |
|---|---:|
| Dokumenty | 333 |
| Verze celkem | 338 |
| Aktuální verze | 333 |
| Sekce | 5 097 |
| Vazby | 216 |
| Historie stavů | 338 |
| Importní běhy | 25 |
| Aktivní dokumenty | 333 |

Produkční prostředí:

```text
Host: PC2
Databázový host pro panel: localhost na PC2
Databáze: matchmatrix
PostgreSQL: Docker kontejner matchmatrix_postgres
Windows služba postgresql-x64-18: Stopped / Disabled
```

Terminologické proposal běhy tento stav nezměnily.

---

## 13. NEXT STEP

**Spustit aktivní panel, otevřít část DOKUMENTACE a ověřit české názvy sloupců, stavové hodnoty a uživatelské akce.**

V tomto kroku:

- nevytvářet nové proposal soubory;
- nespouštět A24;
- nepublikovat slovníky;
- poslat jeden celý snímek dokumentační části panelu.

Po vyhodnocení snímku bude následovat jediný další krok:

```text
oprava A23 proposal builderu pro MM-REF-001
```

---

## 14. Závěr dokumentu

Navázání zachovává úplný technický, rozhodovací a bezpečnostní kontext po dokončení MM-DB-003 a prvním praktickém nasazení A23.

Dokončený databázový dokument se již neupravuje. Prioritou je nejprve dokončit českou prezentační vrstvu panelu a teprve potom opravit generování pracovních návrhů referenčních slovníků.

---

## 15. Historie verzí

| Verze | Datum | Popis |
|---|---|---|
| 1.0 | 2026-07-16 | Navázání po dokončení MM-DB-003, implementaci A23 STEP 25–26 a přípravě STEP 27. |
