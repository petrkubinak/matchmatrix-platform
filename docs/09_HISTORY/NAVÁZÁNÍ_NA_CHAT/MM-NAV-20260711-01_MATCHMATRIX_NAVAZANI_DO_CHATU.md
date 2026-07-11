# MatchMatrix – navázání do nového chatu – 2026-07-11

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
| Pracovní oblast | Dokumentační workflow Q3 a dokončení dokumentační etapy |
| Původní soubor | `\\192.168.3.119\matchmatrix\reports\documentation\standardization\panel_workspaces\20260711_101856_MM_NAV_20260711_01_MATCHMATRIX_NAVAZANI_DO_CHATU\source\MM-NAV-20260711-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md` |
| SHA-256 původního souboru | `a757ff477372570e272c3580bd93fb366f78396dfd8cada0459a15bbd1fa179e` |
| Potvrzená revize A19 | `C:\MatchMatrix-platform\reports\documentation\standardization\panel_workspaces\20260711_101856_MM_NAV_20260711_01_MATCHMATRIX_NAVAZANI_DO_CHATU\a19\document_standardization_panel_review_latest.json` |
| Mapování schválil | Petr |
| Kandidát sestaven | 2026-07-11T08:34:14.212885+00:00 |
| Build engine | A20_STANDARDIZED_DOCUMENT_BUILDER_V3_PLACEHOLDER_COUNT |

> **Bezpečnostní stav:** Toto je nově sestavený kandidát. Původní dokument nebyl změněn.
> Mapování obsahu bylo potvrzeno v A19. Před kanonickým uložením musí následovat audit A17.

## 1. Identifikace navázání

<!-- MM-SOURCE piece_id=BLK-0001; block_id=BLK-0001; lines=9-22; decision=NOT_REQUIRED/AUTO_ACCEPT -->
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

## 2. Výchozí kontext

<!-- MM-SOURCE piece_id=BLK-0002; block_id=BLK-0002; lines=28-30; decision=CONFIRMED/MOVE -->
Tento dokument umožňuje okamžitě pokračovat v projektu MatchMatrix v novém chatu bez opakovaného hledání souvislostí.

Navazuje na dokončení a ověření dokumentačního workflow Q3, databázový import dokumentů `MM-DL-20260710` a `MM-NAV-20260710-01`, integritní audit A7 a společný Git commit aktivních i historických souborů.

## 3. CURRENT STATUS

<!-- MM-SOURCE piece_id=BLK-0003; block_id=BLK-0003; lines=38-53; decision=CONFIRMED/MOVE -->
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

<!-- MM-SOURCE piece_id=BLK-0007; block_id=BLK-0007; lines=90-97; decision=NOT_REQUIRED/AUTO_ACCEPT -->
Aktivní a historické soubory byly společně commitnuty. Pracovní strom byl po commitu ověřen jako čistý.

Platné pravidlo:

- soubor v aktivní složce je dokončená aktuální verze,
- starší verze se ihned ukládají do `tools/histori/` nebo `docs/99_ARCHIVE/`,
- aktivní i historické přesuny jsou zamýšlenou součástí commitu,
- běžně se před commitem nepoužívá stash.

## 4. Co bylo dokončeno

<!-- MM-SOURCE piece_id=BLK-0004; block_id=BLK-0004; lines=57-68; decision=CONFIRMED/MOVE -->
Na PC2 proběhl úspěšný import:

- `MM-DL-20260710`,
- `MM-NAV-20260710-01`.

Výsledky:

```text
DOCUMENT_IMPORT_APPLIED
DOCUMENTATION_IMPORT_VERIFIED
HISTORY_DOCUMENT_IMPORT_APPLIED_AND_VERIFIED
```

<!-- MM-SOURCE piece_id=BLK-0005; block_id=BLK-0005; lines=72-74; decision=NOT_REQUIRED/AUTO_ACCEPT -->
- 74/74 kontrol PASS,
- 0 varování,
- 0 blokátorů.

## 5. Co zůstává rozpracováno

<!-- MM-SOURCE piece_id=BLK-0009; block_id=BLK-0009; lines=116-131; decision=CONFIRMED/MOVE -->
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

<!-- MM-SOURCE piece_id=BLK-0014; block_id=BLK-0014; lines=209-209; decision=CONFIRMED/MOVE -->
Po dokončení publikační fáze se workflow rozšíří o terminologický krok.

<!-- MM-SOURCE piece_id=BLK-0018; block_id=BLK-0018; lines=261-261; decision=CONFIRMED/MOVE -->
Dokončit souvislou historickou rekonstrukci vývoje MatchMatrix tak, aby bylo možné zjistit stav projektu v důležitých okamžicích a sledovat, jak se měnila architektura, databáze, providery, panely, dokumentace a pracovní priority.

<!-- MM-SOURCE piece_id=BLK-0021; block_id=BLK-0021; lines=288-312; decision=CONFIRMED/MOVE -->
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

<!-- MM-SOURCE piece_id=BLK-0022; block_id=BLK-0022; lines=318-318; decision=CONFIRMED/MOVE -->
Až dokumentace přesně popíše skutečný stav, bude možné vytvořit realistický plán celé platformy.

<!-- MM-SOURCE piece_id=BLK-0030; block_id=BLK-0030; lines=394-407; decision=CONFIRMED/MOVE -->
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

## 6. OPEN QUESTIONS / otevřené úkoly

<!-- MM-SOURCE piece_id=BLK-0010; block_id=BLK-0010; lines=139-150; decision=CONFIRMED/MOVE -->
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

<!-- MM-SOURCE piece_id=BLK-0011; block_id=BLK-0011; lines=154-169; decision=CONFIRMED/MOVE -->
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

<!-- MM-SOURCE piece_id=BLK-0012; block_id=BLK-0012; lines=173-195; decision=CONFIRMED/MOVE -->
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

<!-- MM-SOURCE piece_id=BLK-0015; block_id=BLK-0015; lines=213-221; decision=CONFIRMED/MOVE -->
Při auditu každého dokumentu automaticky nalézt:

- cizí slova,
- anglické technické termíny,
- zkratky,
- nové interní pojmy MatchMatrix,
- pojmy bez českého překladu,
- pojmy bez podrobného vysvětlení,
- terminologické varianty a možné duplicity.

<!-- MM-SOURCE piece_id=BLK-0020; block_id=BLK-0020; lines=276-282; decision=CONFIRMED/MOVE -->
- klasifikované historické zdroje,
- přiřazená období a data,
- odstraněné duplicity,
- vytvořené chybějící Project Snapshoty,
- provázání snapshotů s denními zápisy a NAVÁZÁNÍ,
- import snapshotů do databáze,
- ověřená chronologická kontinuita.

<!-- MM-SOURCE piece_id=BLK-0023; block_id=BLK-0023; lines=322-328; decision=CONFIRMED/MOVE -->
- dokončení datového modelu,
- kompletní historická data,
- automatický harvest,
- kvalita, deduplikace a identity management,
- monitoring providerů,
- zálohování a obnova,
- produkční databázová infrastruktura.

<!-- MM-SOURCE piece_id=BLK-0024; block_id=BLK-0024; lines=332-337; decision=CONFIRMED/MOVE -->
- ratings,
- predikce,
- Ticket Engine,
- risk management,
- vysvětlitelnost doporučení,
- uživatelské strategie a profily.

<!-- MM-SOURCE piece_id=BLK-0025; block_id=BLK-0025; lines=341-347; decision=CONFIRMED/MOVE -->
- veřejný prezentační web,
- webová aplikace MatchMatrix,
- uživatelské účty,
- předplatné,
- sportovní přehledy,
- tikety a doporučení,
- administrační a operátorský panel.

<!-- MM-SOURCE piece_id=BLK-0026; block_id=BLK-0026; lines=351-356; decision=CONFIRMED/MOVE -->
- návrh funkcí pro Android a iOS,
- notifikace,
- sledované soutěže a týmy,
- tikety,
- personalizované predikce,
- synchronizace s webovou platformou.

<!-- MM-SOURCE piece_id=BLK-0027; block_id=BLK-0027; lines=360-367; decision=CONFIRMED/MOVE -->
- jednotná značka MatchMatrix,
- obsahová a komunikační strategie,
- sociální sítě,
- partnerské spolupráce,
- demonstrační materiály,
- investiční a obchodní prezentace,
- cenový a předplatitelský model,
- právní a regulatorní rámec.

## 7. Rizika a upozornění

<!-- MM-SOURCE piece_id=BLK-0008; block_id=BLK-0008; lines=101-110; decision=CONFIRMED/MOVE -->
Databázové skripty používají `localhost`.

Proto:

```text
spuštění na PC1 → localhost označuje PC1
spuštění na PC2 → localhost označuje PC2 a správnou databázi
```

Databázový import z panelu proto musí být spuštěn vzdáleně na PC2.

## 8. Přijatá rozhodnutí a platná pravidla

<!-- MM-SOURCE piece_id=BLK-0013; block_id=BLK-0013; lines=199-203; decision=NOT_REQUIRED/AUTO_ACCEPT -->
- APPLY se nespustí, pokud VALIDATE_ONLY neprojde.
- Panel nesmí skrýt chybový výstup A24, A6 ani A7.
- Při blokaci se databáze nesmí částečně změnit.
- Panel musí rozlišit chybu dokumentu, chybu Git stavu, chybu vzdáleného spuštění a chybu databáze.
- Automatický stash se nemá používat jako standardní řešení.

<!-- MM-SOURCE piece_id=BLK-0016; block_id=BLK-0016; lines=225-238; decision=CONFIRMED/MOVE -->
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

<!-- MM-SOURCE piece_id=BLK-0017; block_id=BLK-0017; lines=242-253; decision=CONFIRMED/MOVE -->
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

<!-- MM-SOURCE piece_id=BLK-0028; block_id=BLK-0028; lines=373-380; decision=NOT_REQUIRED/AUTO_ACCEPT -->
- Postupovat vždy po jednom jasném technickém kroku.
- Uživatel provede krok, pošle výsledek a až potom následuje další.
- U každého skriptu uvést přesnou složku, název a účel.
- Při opravě posílat pouze nový aktivní soubor; historickou verzi uživatel přesune sám.
- Aktivní i historické dokončené soubory jsou určeny ke commitu.
- Nevytvářet ZIP s aktivní a historickou kopií, pokud není výslovně požadován.
- Panel má používat české, srozumitelné popisky a jasně ukazovat, co se děje a co bude následovat.
- Databázové operace musí běžet na PC2.

## 9. Ověřené zdroje, soubory a příkazy

<!-- MM-SOURCE piece_id=BLK-0019; block_id=BLK-0019; lines=265-272; decision=CONFIRMED/MOVE -->
V projektu jsou připraveny nebo rozpracovány zejména:

- `25_1_A_27_EXPORT_HISTORY_PERIOD_REVIEW_CORPUS_V1.py`,
- `25_1_A_28_EXPORT_UNDATED_HISTORY_REVIEW_CORPUS_V1.py`,
- `25_1_A_29_BUILD_HISTORY_DATE_CLASSIFICATION_MAP_V1.py`,
- `25_1_A_30_EXPORT_COMPLETE_CLASSIFIED_HISTORY_MONTH_CORPUS_V1.py`,
- `25_1_A_31_EXPORT_HISTORY_RECONSTRUCTION_SOURCE_BLOCK_V1.py`,
- `25_1_A_32_BUILD_HISTORY_RECONSTRUCTION_WORKING_REPORT_V1.py`.

## 10. AI CONTEXT

Tento navazovací dokument má umožnit bezpečné pokračování práce bez opakovaného hledání souvislostí. AI má při dalším postupu respektovat následující provozní a pracovní pravidla:

- hlavním cílem je dokončit dokumentační workflow Q3, zejména fázi **4 – PUBLIKOVAT**,
- nemá vznikat nový paralelní proces; mají se využít a propojit existující nástroje A17 až A24, A6 a A7,
- panel je udržován na PC1 i PC2 a může být spuštěn lokálně z kteréhokoli z těchto počítačů,
- společné dokumenty, workspace a výstupy jsou uloženy na PC2 a zpřístupněny přes `\\192.168.3.119\matchmatrix`,
- databázové operace používající `localhost` musí proběhnout na PC2, aby vždy pracovaly se správnou databází `matchmatrix`,
- při technických změnách se postupuje vždy po jednom jasném kroku; po každém kroku se nejprve vyhodnotí skutečný výsledek,
- aktivní soubory představují dokončené aktuální verze a starší verze se ukládají do historických složek,
- automatický stash se nepoužívá jako standardní řešení,
- chybové výstupy A24, A6 a A7 se nesmí skrývat ani převádět na obecnou úspěšnou hlášku,
- APPLY nesmí být spuštěn, pokud VALIDATE_ONLY neskončí úspěšně.

Při pokračování se má vycházet z kapitoly **13. NEXT STEP** a před každou změnou ověřit, že zásah nenaruší již funkční fáze 1 až 3.


## 11. PROJECT SNAPSHOT

| Oblast | Ověřený stav k 2026-07-11 |
|---|---|
| Aktivní panel | `matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py` |
| Dokumentační workflow | Fáze 1 až 3 prakticky ověřeny; základní Git část fáze 4 ověřena |
| Databázový import | `MM-DL-20260710` a `MM-NAV-20260710-01` úspěšně importovány na PC2 |
| Integritní audit | A7 dokončen výsledkem 74/74 PASS |
| Varování a blokátory | 0 varování, 0 blokátorů |
| Git stav | Aktivní i historické soubory společně commitnuty; pracovní strom po commitu čistý |
| Dokumentační databáze | 320 dokumentů, 322 verzí, 320 aktuálních verzí, 3 318 sekcí, 138 vazeb, 322 stavových záznamů a 10 importních běhů |
| Hlavní rozpracovaný blok | Dokončení fáze 4 – PUBLIKOVAT včetně A24 VALIDATE_ONLY, A24 APPLY, A6, A7 a obnovy KPI |
| Následující dokumentační blok | Automatické doplňování terminologie do MM-REF-001 a MM-REF-002 |
| Následující historický blok | Dokončení historických Project Snapshotů a chronologické rekonstrukce projektu |
| Dlouhodobý cíl | Uzavřít dokumentační etapu a pokračovat řízeným rozvojem databáze, pipeline, predikčního produktu, webu a mobilní aplikace |

Tento snapshot zachycuje stav, ze kterého má nový chat pokračovat. Nejde o náhradu živých databázových KPI; při pokračování musí být aktuální stav znovu ověřen panelem a databází na PC2.


## 12. DATABASE SNAPSHOT

<!-- MM-SOURCE piece_id=BLK-0006; block_id=BLK-0006; lines=78-86; decision=CONFIRMED/MOVE -->
| Ukazatel | Hodnota |
|---|---:|
| Dokumenty | 320 |
| Verze dokumentů | 322 |
| Aktuální verze | 320 |
| Sekce | 3 318 |
| Vazby | 138 |
| Historie stavů | 322 |
| Importní běhy | 10 |

## 13. NEXT STEP

<!-- MM-SOURCE piece_id=BLK-0029; block_id=BLK-0029; lines=386-388; decision=CONFIRMED/MOVE -->
**Otevřít aktivní panelový skript a zmapovat současnou implementaci fáze 4 – PUBLIKOVAT, zejména metody pro Git publikaci, vzdálené spouštění příkazů na PC2 a obnovu sekce STAV DOKUMENTAČNÍ DATABÁZE.**

Nejprve se nemá nic měnit. Prvním krokem má být pouze bezpečný technický výpis názvů relevantních metod a jejich umístění v souboru, aby bylo možné navrhnout přesný zásah bez narušení již funkčních částí panelu.

## Schválení standardizovaného kandidáta

- [ ] Byla zkontrolována správnost všech kapitol.
- [ ] Byla doplněna všechna pole `DOPLNIT UŽIVATELEM`.
- [ ] Byla ověřena terminologie podle MM-REF-001.
- [ ] Byl spuštěn audit A17 nad tímto kandidátem.
- [ ] Audit A17 dosáhl požadovaného stavu.
- [ ] Uživatel schválil vytvoření nové kanonické verze.
