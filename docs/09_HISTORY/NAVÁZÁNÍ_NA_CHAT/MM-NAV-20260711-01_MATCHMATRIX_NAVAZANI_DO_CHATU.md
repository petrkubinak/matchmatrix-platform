# MM-NAV-20260711-01

# MATCHMATRIX – NAVÁZÁNÍ DO NOVÉHO CHATU – 2026-07-11

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Document ID | MM-NAV-20260711-01 |
| Název dokumentu | MatchMatrix – navázání do nového chatu – 2026-07-11 |
| Typ dokumentu | CHAT_CONTINUATION |
| Verze | 1.0 |
| Stav | APPROVED |
| Datum | 2026-07-11 |
| Autor | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Pracovní oblast | Dokumentační workflow Q3 a dokončení dokumentační etapy |
| Primární formát | Markdown (.md) |
| Kanonické umístění | `docs/09_HISTORY/NAVÁZÁNÍ_NA_CHAT/MM-NAV-20260711-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md` |
| Zdrojový denní zápis | `MM-DL-20260711_MATCHMATRIX_DENNI_ZAPIS.md` |

---

## 1. Účel dokumentu

Tento dokument umožňuje okamžitě pokračovat v projektu MatchMatrix v novém chatu bez opakovaného hledání souvislostí.

Navazuje na dokončení a ověření dokumentačního workflow Q3, databázový import dokumentů `MM-DL-20260710` a `MM-NAV-20260710-01`, integritní audit A7 a společný Git commit aktivních i historických souborů.

---

## 2. Aktuální ověřený stav

### 2.1 Dokumentační workflow Q3

Aktivní panel:

`C:\MatchMatrix-Platform\tools\matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py`

Spouštěcí soubor:

`MatchMatrix_Q3_Documentation_Workflow.vbs`

Panel je rozdělen do čtyř hlavních fází:

1. **VYBRAT A ANALYZOVAT**,
2. **OPRAVIT A ZKONTROLOVAT**,
3. **VYTVOŘIT A SCHVÁLIT**,
4. **PUBLIKOVAT**.

Fáze 1–3 a základní Git část fáze 4 jsou prakticky ověřené na skutečných dokumentech.

### 2.2 Databázový import

Na PC2 proběhl úspěšný import:

- `MM-DL-20260710`,
- `MM-NAV-20260710-01`.

Výsledky:

```text
DOCUMENT_IMPORT_APPLIED
DOCUMENTATION_IMPORT_VERIFIED
HISTORY_DOCUMENT_IMPORT_APPLIED_AND_VERIFIED
```

A7:

- 74/74 kontrol PASS,
- 0 varování,
- 0 blokátorů.

### 2.3 Stav dokumentační databáze

| Ukazatel | Hodnota |
|---|---:|
| Dokumenty | 320 |
| Verze dokumentů | 322 |
| Aktuální verze | 320 |
| Sekce | 3 318 |
| Vazby | 138 |
| Historie stavů | 322 |
| Importní běhy | 10 |

### 2.4 Git

Aktivní a historické soubory byly společně commitnuty. Pracovní strom byl po commitu ověřen jako čistý.

Platné pravidlo:

- soubor v aktivní složce je dokončená aktuální verze,
- starší verze se ihned ukládají do `tools/histori/` nebo `docs/99_ARCHIVE/`,
- aktivní i historické přesuny jsou zamýšlenou součástí commitu,
- běžně se před commitem nepoužívá stash.

### 2.5 Důležité technické zjištění

Databázové skripty používají `localhost`.

Proto:

```text
spuštění na PC1 → localhost označuje PC1
spuštění na PC2 → localhost označuje PC2 a správnou databázi
```

Databázový import z panelu proto musí být spuštěn vzdáleně na PC2.

---

## 3. Hlavní cíl nové etapy

Dokončit dokumentační workflow tak, aby na několik kliknutí zajistilo:

```text
výběr dokumentu
→ audit
→ návrh oprav
→ uživatelské schválení
→ kanonické uložení
→ Git publikaci
→ databázový import na PC2
→ integritní audit
→ aktualizaci přehledu dokumentace
→ zachycení nových pojmů do slovníku
```

Poté dokončit historické Project Snapshoty a uzavřít dokumentační etapu celého projektu.

---

## 4. První pracovní blok – rozšíření fáze 4 PUBLIKOVAT

### 4.1 Co je potřeba doplnit

Fáze **4 – PUBLIKOVAT** musí po kanonickém uložení a Git kontrole:

1. připravit seznam schválených dokumentů určených k importu,
2. vzdáleně spustit A24 na PC2 v režimu `VALIDATE_ONLY`,
3. vyhodnotit validační report,
4. po úspěchu spustit A24 v režimu `APPLY`,
5. převzít výsledek A6,
6. převzít výsledek A7,
7. zobrazit konečný stav importu,
8. obnovit databázová KPI,
9. uložit denní databázový snapshot,
10. porovnat dnešní stav s posledním předchozím snapshotem.

### 4.2 Požadované informace v panelu

Panel musí jasně zobrazovat:

| Položka | Příklad |
|---|---|
| Execution host | PC2 |
| DB host | localhost na PC2 |
| DB target | matchmatrix |
| Režim | VALIDATE_ONLY / APPLY |
| Dokumenty k importu | počet a Document ID |
| A24 stav | VALIDATED / APPLIED / BLOCKED |
| A7 stav | VERIFIED / WARNING / BLOCKED |
| Nové dokumenty | počet |
| Aktualizované dokumenty | počet |
| Beze změny | počet |
| Varování | počet |
| Blokátory | počet |

### 4.3 Přehled Včera / Dnes / Rozdíl

Sekce **STAV DOKUMENTAČNÍ DATABÁZE** má obsahovat tabulku:

| Ukazatel | Včera | Dnes | Rozdíl | Stav |
|---|---:|---:|---:|---|
| Dokumenty celkem |  |  |  |  |
| Aktuální verze |  |  |  |  |
| Verze celkem |  |  |  |  |
| Sekce |  |  |  |  |
| Vazby |  |  |  |  |
| Schválené dokumenty |  |  |  |  |
| Čeká na kontrolu |  |  |  |  |
| Chybné nebo blokované |  |  |  |  |
| Neúspěšné importy |  |  |  |  |

Stavové kategorie:

- **OK**,
- **ČEKÁ**,
- **ROZPRACOVÁNO**,
- **CHYBA**,
- **BEZ ZMĚN**,
- **NOVĚ PŘIDÁNO**,
- **AKTUALIZOVÁNO**.

### 4.4 Bezpečnostní pravidla

- APPLY se nespustí, pokud VALIDATE_ONLY neprojde.
- Panel nesmí skrýt chybový výstup A24, A6 ani A7.
- Při blokaci se databáze nesmí částečně změnit.
- Panel musí rozlišit chybu dokumentu, chybu Git stavu, chybu vzdáleného spuštění a chybu databáze.
- Automatický stash se nemá používat jako standardní řešení.

---

## 5. Druhý pracovní blok – automatické doplňování slovníku

Po dokončení publikační fáze se workflow rozšíří o terminologický krok.

### 5.1 Cíl

Při auditu každého dokumentu automaticky nalézt:

- cizí slova,
- anglické technické termíny,
- zkratky,
- nové interní pojmy MatchMatrix,
- pojmy bez českého překladu,
- pojmy bez podrobného vysvětlení,
- terminologické varianty a možné duplicity.

### 5.2 Rozdělení výstupů

**MM-REF-001** bude nadále sloužit jako stručný překladový slovník:

```text
cizí nebo anglický pojem → český význam
```

**MM-REF-002** bude obsahovat podrobný výklad:

- definici,
- použití v MatchMatrix,
- související pojmy,
- zdrojový dokument a kapitolu,
- doporučenou terminologii,
- případné zakázané nebo nevhodné varianty.

### 5.3 Schvalovací workflow

```text
nalezený pojem
→ porovnání se slovníky
→ automatický návrh překladu a výkladu
→ uživatelské potvrzení
→ aktualizace MM-REF-001 a/nebo MM-REF-002
→ audit
→ Git
→ databáze
```

Uživatel má dostávat pouze krátký seznam skutečně nových nebo sporných pojmů, nikoliv opakované dotazy na již schválenou terminologii.

---

## 6. Třetí pracovní blok – historické Project Snapshoty

### 6.1 Cíl

Dokončit souvislou historickou rekonstrukci vývoje MatchMatrix tak, aby bylo možné zjistit stav projektu v důležitých okamžicích a sledovat, jak se měnila architektura, databáze, providery, panely, dokumentace a pracovní priority.

### 6.2 Aktivní nástroje

V projektu jsou připraveny nebo rozpracovány zejména:

- `25_1_A_27_EXPORT_HISTORY_PERIOD_REVIEW_CORPUS_V1.py`,
- `25_1_A_28_EXPORT_UNDATED_HISTORY_REVIEW_CORPUS_V1.py`,
- `25_1_A_29_BUILD_HISTORY_DATE_CLASSIFICATION_MAP_V1.py`,
- `25_1_A_30_EXPORT_COMPLETE_CLASSIFIED_HISTORY_MONTH_CORPUS_V1.py`,
- `25_1_A_31_EXPORT_HISTORY_RECONSTRUCTION_SOURCE_BLOCK_V1.py`,
- `25_1_A_32_BUILD_HISTORY_RECONSTRUCTION_WORKING_REPORT_V1.py`.

### 6.3 Požadovaný výsledek

- klasifikované historické zdroje,
- přiřazená období a data,
- odstraněné duplicity,
- vytvořené chybějící Project Snapshoty,
- provázání snapshotů s denními zápisy a NAVÁZÁNÍ,
- import snapshotů do databáze,
- ověřená chronologická kontinuita.

---

## 7. Čtvrtý pracovní blok – dokončení dokumentace celého projektu

Po dokončení snapshotů je potřeba aktualizovat hlavní dokumenty podle skutečně ověřeného stavu.

Prioritně:

- MatchMatrix Master,
- Governance,
- Architecture,
- Development Handbook,
- databázová dokumentace,
- datový ingest a provider management,
- People, Media, Odds a Ticket Engine,
- panely a denní provoz,
- infrastruktura PC1/PC2,
- bezpečnost, zálohování a provozní obnova,
- sportovní moduly a jejich připravenost.

Výsledkem musí být jasný celkový audit:

| Stav | Význam |
|---|---|
| DOKONČENO | ověřeno a produkčně použitelné |
| ČÁSTEČNÉ | funkční, ale neúplné |
| ČEKÁ | připraveno k provedení |
| BLOKOVÁNO | vyžaduje externí podmínku nebo rozhodnutí |
| CHYBÍ | dosud nevytvořeno |

---

## 8. Pátý pracovní blok – další rozvoj celého projektu

Až dokumentace přesně popíše skutečný stav, bude možné vytvořit realistický plán celé platformy.

### 8.1 Databáze a data

- dokončení datového modelu,
- kompletní historická data,
- automatický harvest,
- kvalita, deduplikace a identity management,
- monitoring providerů,
- zálohování a obnova,
- produkční databázová infrastruktura.

### 8.2 Analytika a produkt

- ratings,
- predikce,
- Ticket Engine,
- risk management,
- vysvětlitelnost doporučení,
- uživatelské strategie a profily.

### 8.3 Webová platforma

- veřejný prezentační web,
- webová aplikace MatchMatrix,
- uživatelské účty,
- předplatné,
- sportovní přehledy,
- tikety a doporučení,
- administrační a operátorský panel.

### 8.4 Mobilní aplikace

- návrh funkcí pro Android a iOS,
- notifikace,
- sledované soutěže a týmy,
- tikety,
- personalizované predikce,
- synchronizace s webovou platformou.

### 8.5 Propagace a obchodní rozvoj

- jednotná značka MatchMatrix,
- obsahová a komunikační strategie,
- sociální sítě,
- partnerské spolupráce,
- demonstrační materiály,
- investiční a obchodní prezentace,
- cenový a předplatitelský model,
- právní a regulatorní rámec.

---

## 9. Pravidla pokračování

- Postupovat vždy po jednom jasném technickém kroku.
- Uživatel provede krok, pošle výsledek a až potom následuje další.
- U každého skriptu uvést přesnou složku, název a účel.
- Při opravě posílat pouze nový aktivní soubor; historickou verzi uživatel přesune sám.
- Aktivní i historické dokončené soubory jsou určeny ke commitu.
- Nevytvářet ZIP s aktivní a historickou kopií, pokud není výslovně požadován.
- Panel má používat české, srozumitelné popisky a jasně ukazovat, co se děje a co bude následovat.
- Databázové operace musí běžet na PC2.

---

## 10. Přesný první krok v novém chatu

**Otevřít aktivní panelový skript a zmapovat současnou implementaci fáze 4 – PUBLIKOVAT, zejména metody pro Git publikaci, vzdálené spouštění příkazů na PC2 a obnovu sekce STAV DOKUMENTAČNÍ DATABÁZE.**

Nejprve se nemá nic měnit. Prvním krokem má být pouze bezpečný technický výpis názvů relevantních metod a jejich umístění v souboru, aby bylo možné navrhnout přesný zásah bez narušení již funkčních částí panelu.

---

## 11. Cílový stav této etapy

Tato etapa je dokončena teprve tehdy, když:

- dokument projde auditem a schválením,
- je uložen kanonicky,
- je commitnut,
- je automaticky importován na PC2,
- A7 potvrdí jeho integritu,
- databázové KPI se okamžitě obnoví,
- panel ukáže denní rozdíl a případné problémy,
- nové termíny projdou řízeným schválením do slovníků,
- historické snapshoty vytvoří souvislou časovou osu,
- hlavní dokumentace odpovídá skutečnému stavu celé platformy.

Poté bude možné opustit převážně dokumentační etapu a navázat řízeným rozvojem databáze, datových pipeline, predikčního produktu, webové platformy, mobilní aplikace a propagace celého projektu MatchMatrix.
