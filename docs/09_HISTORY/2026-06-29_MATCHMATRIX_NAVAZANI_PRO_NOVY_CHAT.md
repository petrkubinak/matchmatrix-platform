# MATCHMATRIX – NAVÁZÁNÍ PRO NOVÝ CHAT

## Informace o navázání
| Položka | Hodnota |
|---|---|
| Datum | 2026-06-29 |
| Oblast | Dokumentace / přechod od metodiky k reálnému obsahu |
| Typ dokumentu | Konkrétní navazovací zápis |
| Stav | AKTIVNÍ VÝCHOZÍ BOD |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Primární formát | Markdown (.md) |

# 1. AI CONTEXT
Pokračujeme v projektu MatchMatrix po dokončení REVIEW dokumentů:
- MM-DOC-901 – MatchMatrix Navázání,
- MM-DOC-902 – MatchMatrix Changelog,
- MM-DOC-903 – MatchMatrix Architectural Decisions.

Tyto dokumenty byly přečíslovány ze starých označení MM-DOC-006 až MM-DOC-008, sjednoceny podle dokumentačních standardů a doplněny o AI CONTEXT, PROJECT SNAPSHOT, DATABASE SNAPSHOT, CURRENT STATUS, OPEN QUESTIONS a NEXT STEP.

Zásadní zjištění: dokumenty jsou kvalitně zpracované jako metodika, ale zatím převážně popisují, co by měly obsahovat. Nyní je nutné přejít k tvorbě konkrétních dokumentů založených na skutečném vývoji MatchMatrix.

V novém chatu nesmí vzniknout další obecný popis metodiky. Úkolem je vytvářet reálný obsah projektu.

# 2. DOKONČENÉ VÝSTUPY
Ke stažení byly vytvořeny:
- `MM-DOC-901_MATCHMATRIX_NAVAZANI_TECH_REVIEW.md`
- `MM-DOC-902_MATCHMATRIX_CHANGELOG_TECH_REVIEW.md`
- `MM-DOC-903_MATCHMATRIX_ARCHITECTURAL_DECISIONS_TECH_REVIEW.md`

Současně byly vytvořeny první konkrétní provozní dokumenty:
- denní zápis za 2026-06-29,
- toto NAVÁZÁNÍ pro nový chat.

# 3. PŘIJATÁ PRAVIDLA
1. „Stažení“ znamená vytvořit celý hotový soubor a poslat odkaz.
2. „Zkopírování“ znamená vložit text přímo do chatu.
3. Dokumenty mají být obsahově dostatečně podrobné, ale kompaktní.
4. Nepoužívat nadměrné mezery, zbytečné prázdné řádky ani umělé natahování textu.
5. Zachovat odborný obsah, ale doplňovat skutečné údaje projektu.
6. Každý konkrétní údaj musí vycházet z dostupného zdroje nebo být jasně označen jako stav k ověření.
7. Nevytvářet další teorii tam, kde již existuje metodický dokument.

# 4. PROJECT SNAPSHOT
MatchMatrix je rozsáhlá multisportovní datová platforma s vrstvami:
- Core Layer,
- People Layer,
- Media Layer,
- Odds Layer,
- Source Intelligence Layer,
- Governance,
- OPS / Runtime,
- budoucí AI a produktové služby.

Aktuální dokumentační systém obsahuje:
- MM-DOC-000 – Documentation Framework,
- MM-DOC-100 – Master,
- MM-DOC-200 – Governance,
- MM-DOC-300 – Architecture,
- MM-DOC-800 – Development Handbook,
- MM-DOC-900 – Denní zápisy,
- MM-DOC-901 – Navázání,
- MM-DOC-902 – Changelog,
- MM-DOC-903 – Architectural Decisions,
- standardy MM-STD,
- referenční slovník MM-REF-001.

Dokumentační metodika je připravena. Chybí její systematické naplnění reálnými událostmi, milníky, rozhodnutími, datovými snapshoty a odkazy na implementaci.

# 5. CURRENT STATUS
| Oblast | Stav |
|---|---|
| REVIEW MM-DOC-901 | DOKONČENO |
| REVIEW MM-DOC-902 | DOKONČENO |
| REVIEW MM-DOC-903 | DOKONČENO |
| Metodika denních zápisů | REVIEW |
| Metodika NAVÁZÁNÍ | REVIEW |
| Metodika CHANGELOGU | REVIEW |
| Metodika ADR / AD-xxxx | REVIEW |
| Skutečné denní zápisy | ZAHÁJENO |
| Skutečná navázání | ZAHÁJENO |
| Skutečný CHANGELOG projektu | NEVYTVOŘEN / DALŠÍ PRIORITA |
| Skutečný registr AD-xxxx | NEVYTVOŘEN / NÁSLEDUJÍCÍ PRIORITA |
| Automatický PROJECT SNAPSHOT | PLÁNOVÁNO |
| Automatický DATABASE SNAPSHOT | PLÁNOVÁNO |

# 6. HLAVNÍ PROBLÉM
Dosavadní dokumenty dobře popisují pravidla, ale nevytvářejí dostatečně konkrétní obraz toho:
- co bylo v MatchMatrix skutečně vybudováno,
- kdy vznikly hlavní vrstvy a mechanismy,
- proč byla přijata klíčová architektonická rozhodnutí,
- jaké databázové objekty, skripty a workery tato rozhodnutí realizují,
- jaký je ověřený současný stav databáze a jednotlivých sportů,
- které úkoly jsou skutečně otevřené.

# 7. NEXT STEP
Prvním úkolem nového chatu je vytvořit **skutečný chronologický CHANGELOG projektu MatchMatrix**, nikoliv další metodický dokument.

## Požadovaný postup
1. Projít dostupné denní zápisy, navazovací dokumenty, projektové snapshoty a hlavní dokumenty.
2. Vytáhnout pouze skutečné významné milníky.
3. U každého milníku uvést:
   - datum nebo ověřené období,
   - název změny,
   - oblast,
   - co se skutečně změnilo,
   - proč se změna provedla,
   - skutečný dopad na projekt,
   - související dokumenty, skripty, databázové objekty nebo audity, pokud jsou známé.
4. Oddělit ověřená data od odhadů.
5. Seřadit záznamy chronologicky.
6. Vytvořit jeden kompletní `.md` soubor ke stažení.
7. Nepřepisovat znovu pravidla MM-DOC-902; použít je pouze jako šablonu.

# 8. NÁSLEDUJÍCÍ ETAPA
Po vytvoření skutečného CHANGELOGU vytvořit první katalog architektonických rozhodnutí `AD-xxxx`.

## První kandidáti
- AD-0001 – Přechod na sjednocenou staging architekturu `stg_*`.
- AD-0002 – Víceproviderová architektura a nezávislost na jediném providerovi.
- AD-0003 – Canonical Entity Model.
- AD-0004 – Rozdělení databáze na `staging`, `public`, `ops` a `runtime`.
- AD-0005 – Governance First.
- AD-0006 – Rozdělení rolí PC1 / PC2 a přesun hlavních dat a harvestu na PC2.
- AD-0007 – Priorita harvestu CORE HISTORY → CURRENT → PEOPLE → MEDIA → ODDS.
- AD-0008 – Source Intelligence Layer.
- AD-0009 – Operator / Denní práce jako akční panel.
- AD-0010 – Dokumentace jako řízená znalostní vrstva platformy.

Každé rozhodnutí musí vycházet z reálné historie projektu, obsahovat posuzovaný problém, alternativy, přijaté řešení, důvod, dopad a odkazy na skutečnou implementaci.

# 9. OTEVŘENÉ OTÁZKY
- Jaký časový rozsah má první skutečný CHANGELOG pokrýt: celý projekt, nebo nejprve období roku 2026?
- Které historické denní zápisy představují hlavní referenční zdroj?
- Která data jsou již potvrzena Git historií a která pouze pracovními zápisy?
- Budou jednotlivé záznamy `AD-xxxx` samostatné soubory, nebo bude nejprve vytvořen jeden společný katalog?
- Jak přesně budou konkrétní denní zápisy a navázání označovány, aniž by opakovaně používaly Document ID řídicích dokumentů MM-DOC-900 a MM-DOC-901?

Tyto otázky nesmí zastavit práci. Při nejasnosti použít nejlepší dostupné zdroje, stav označit a připravit výstup k review.

# 10. PRVNÍ POKYN PRO NOVÝ CHAT
> Navazujeme na dokončené REVIEW dokumentů MM-DOC-901 až MM-DOC-903. Nechci další obecnou teorii. Vytvoř skutečný chronologický CHANGELOG projektu MatchMatrix z dostupných projektových zdrojů. Použij strukturu MM-DOC-902, čerpej z denních zápisů, navázání, projektových snapshotů, databázových auditů a skutečných výsledků. Odděl ověřené údaje od neověřených. Výstup pošli jako jeden kompletní kompaktní `.md` soubor ke stažení.
