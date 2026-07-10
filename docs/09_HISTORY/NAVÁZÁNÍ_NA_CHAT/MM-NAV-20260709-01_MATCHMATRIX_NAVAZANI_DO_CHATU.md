# MatchMatrix – navázání do nového chatu – A17/A18 dokumentační workflow

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Document ID | MM-NAV-20260709-01 |
| Název dokumentu | MatchMatrix – navázání do nového chatu – A17/A18 dokumentační workflow |
| Typ dokumentu | CHAT_CONTINUATION |
| Verze | 1.0 |
| Stav | APPROVED |
| Datum | 2026-07-09 |
| Autor | Petr |
| Pracovní oblast | Dokumentační workflow / A17 / A18 / Q3 panel |
| Původní soubor | `\\192.168.3.119\matchmatrix\reports\documentation\standardization\panel_workspaces\20260710_220710_MM_NAV_20260709_01_MATCHMATRIX_NAVAZANI_DO_CHATU\source\MM-NAV-20260709-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md` |
| SHA-256 původního souboru | `be69298c6242fe40397c267504f288a95bec0987f9863a572d8da53e116dd688` |
| Potvrzená revize A19 | `C:\MatchMatrix-platform\reports\documentation\standardization\panel_workspaces\20260710_220710_MM_NAV_20260709_01_MATCHMATRIX_NAVAZANI_DO_CHATU\a19\document_standardization_panel_review_latest.json` |
| Mapování schválil | Petr |
| Kandidát sestaven | 2026-07-10T20:09:10.666367+00:00 |
| Build engine | A20_STANDARDIZED_DOCUMENT_BUILDER_V3_PLACEHOLDER_COUNT |

> **Bezpečnostní stav:** Toto je nově sestavený kandidát. Původní dokument nebyl změněn.
> Mapování obsahu bylo potvrzeno v A19. Před kanonickým uložením musí následovat audit A17.

## 1. Identifikace navázání

<!-- MM-SOURCE piece_id=BLK-0001; block_id=BLK-0001; lines=9-26; decision=NOT_REQUIRED/AUTO_ACCEPT -->
| Položka | Hodnota |
|---|---|
| Dokument | MM-NAV-20260709-01 |
| Název dokumentu | MatchMatrix – navázání do nového chatu – A17/A18 dokumentační workflow |
| Typ dokumentu | CHAT_CONTINUATION |
| Edice | HISTORY |
| Verze | 1.0 |
| Původní stav zdrojového dokumentu | REVIEW |
| Datum | 2026-07-09 |
| Pořadí v rámci dne | 01 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Projekt | MatchMatrix-platform |
| Pracovní oblast | Dokumentační workflow / A17 / A18 / Q3 panel |
| Zdrojový denní zápis | MM-DL-20260709 |
| Primární prostředí | PC1 `MATCHMATRIX-OPS` / PC2 `MatchMatrix` |
| Cílové umístění | `docs/09_HISTORY/NAVÁZÁNÍ_NA_CHAT/MM-NAV-20260709-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md` |
| Primární formát | Markdown (.md) |

## 2. Výchozí kontext

<!-- MM-SOURCE piece_id=BLK-0002; block_id=BLK-0002; lines=32-46; decision=NOT_REQUIRED/AUTO_ACCEPT -->
Tento dokument předává přesný stav práce po rozšíření dokumentačního workflow MatchMatrix o bezpečný návrh opravy dokumentu.

Nový chat nemá znovu řešit:

- proč se tlačítko A18 původně nezobrazilo,
- přidávání tlačítka `NÁVRH OPRAVY`,
- základní vzdálené spuštění A18,
- první analýzu 111 bloků,
- návrh A18 V3 a V4.

Nový chat musí nejprve pouze ověřit, zda je na PC2 skutečně aktivní A18 V5 a zda poslední otevřený návrh pochází z nového běhu.

Platné pracovní pravidlo:

> Vždy pouze jeden příkaz nebo jeden jasný úkon. Po výsledku následuje další krok.

## 3. CURRENT STATUS

<!-- MM-SOURCE piece_id=BLK-0003; block_id=BLK-0003; lines=54-72; decision=NOT_REQUIRED/AUTO_ACCEPT -->
```text
REFERENCE_DOCUMENT podporován
MM-REF-001: 0 FAIL / 0 PARTIAL
MM-REF-002: 0 FAIL / 0 PARTIAL
Zbývá pouze COMMON-TERMINOLOGY MANUAL_REVIEW
```

Aktivní skript:

```text
\\192.168.3.119\matchmatrix\tools\documentation\
25_1_A_17_AUDIT_DOCUMENT_STANDARD_COMPLIANCE_V1.py
```

Engine:

```text
A17_STANDARD_COMPLIANCE_V1_3_REFERENCE_DOCUMENT_TYPE
```

<!-- MM-SOURCE piece_id=BLK-0004; block_id=BLK-0004; lines=76-84; decision=NOT_REQUIRED/AUTO_ACCEPT -->
Panel obsahuje:

```text
VYBRAT DOKUMENT
A17 AUDIT
A17 NÁLEZY
NÁVRH OPRAVY
OTEVŘÍT REPORT
```

<!-- MM-SOURCE piece_id=BLK-0005; block_id=BLK-0005; lines=88-104; decision=NOT_REQUIRED/AUTO_ACCEPT -->
```text
\\192.168.3.119\matchmatrix\tools\
matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py
```

Spouštěná lokální kopie na PC1:

```text
C:\MatchMatrix-Platform\tools\
matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py
```

Obě kopie byly synchronizovány a měly SHA-256:

```text
CAD39E462DCF2E918E4F7734E770B2D5E42D0ED4D360B60D00BFBFB2D304C906
```

<!-- MM-SOURCE piece_id=BLK-0006; block_id=BLK-0006; lines=108-133; decision=NOT_REQUIRED/AUTO_ACCEPT -->
Cílový aktivní skript:

```text
\\192.168.3.119\matchmatrix\tools\documentation\
25_1_A_18_BUILD_DOCUMENT_STANDARDIZATION_PROPOSAL_V1.py
```

Poslední připravený engine:

```text
A18_CONTEXTUAL_MAPPING_V5_HIERARCHICAL_SEMANTIC_ROUTING
```

Stav jeho aktivní instalace na PC2 není na konci chatu potvrzen.

Poslední zobrazený návrh stále uváděl:

```text
A18_CONTEXTUAL_MAPPING_V3_SECTION_FIRST
```

a pocházel ze starého workspace:

```text
20260709_142741_MM_NAV_20260702_01_MATCHMATRIX_NAVAZANI_DO_CHATU
```

## 4. Co bylo dokončeno

<!-- MM-SOURCE piece_id=BLK-0007; block_id=BLK-0007; lines=141-147; decision=NOT_REQUIRED/AUTO_ACCEPT -->
A17 byl doplněn o samostatný typ:

```text
REFERENCE_DOCUMENT
```

MM-REF-001 a MM-REF-002 již nejsou posuzovány jako hlavní dokument nebo Project Snapshot.

<!-- MM-SOURCE piece_id=BLK-0008; block_id=BLK-0008; lines=151-162; decision=NOT_REQUIRED/AUTO_ACCEPT -->
Denní zápis byl upraven na kanonický nadpis `Plán pokračování`.

NAVÁZÁNÍ dostalo normalizované povinné sekce a `DATABASE SNAPSHOT`.

A17 nad NAVÁZÁNÍM dosáhl:

```text
97.78 %
0 FAIL
0 PARTIAL
1 MANUAL_REVIEW
```

<!-- MM-SOURCE piece_id=BLK-0009; block_id=BLK-0009; lines=166-180; decision=NOT_REQUIRED/AUTO_ACCEPT -->
Do Q3 panelu bylo doplněno tlačítko:

```text
🛠 NÁVRH OPRAVY
```

Panel:

- spouští A18 na PC2,
- používá A17 audit z aktuálního workspace,
- validuje návratový kód,
- načítá výsledné mapování,
- nabízí otevření návrhu,
- nemění zdrojový dokument,
- nemění databázi.

<!-- MM-SOURCE piece_id=BLK-0010; block_id=BLK-0010; lines=184-186; decision=NOT_REQUIRED/AUTO_ACCEPT -->
Bylo zjištěno, že panel běžel z lokální kopie na PC1.

Aktivní soubor z PC2 byl zkopírován na PC1 a oba hashe byly shodné.

<!-- MM-SOURCE piece_id=BLK-0011; block_id=BLK-0011; lines=190-203; decision=NOT_REQUIRED/AUTO_ACCEPT -->
A18 z panelu úspěšně vytvořil návrh pro:

```text
MM-NAV-20260701-02
```

Výsledek:

```text
DOCUMENT_STANDARDIZATION_PROPOSAL_READY
100 % content coverage
SOURCE MODIFIED: False
DATABASE MODIFIED: False
```

<!-- MM-SOURCE piece_id=BLK-0012; block_id=BLK-0012; lines=207-220; decision=NOT_REQUIRED/AUTO_ACCEPT -->
Engine:

```text
A18_CONTEXTUAL_MAPPING_V3_SECTION_FIRST
```

Nejlepší ověřený výsledek:

```text
33 bloků
32 automatických
1 ruční
0 placeholderů
```

<!-- MM-SOURCE piece_id=BLK-0013; block_id=BLK-0013; lines=224-237; decision=NOT_REQUIRED/AUTO_ACCEPT -->
Engine:

```text
A18_CONTEXTUAL_MAPPING_V4_SEMANTIC_HEADING_ROUTING
```

Doplnil významové směrování nadpisů, ale test nad `MM-NAV-20260705-01` stále skončil:

```text
17 bloků
5 automatických
12 ručních
8 placeholderů
```

<!-- MM-SOURCE piece_id=BLK-0014; block_id=BLK-0014; lines=241-257; decision=NOT_REQUIRED/AUTO_ACCEPT -->
Engine:

```text
A18_CONTEXTUAL_MAPPING_V5_HIERARCHICAL_SEMANTIC_ROUTING
```

V5 doplňuje:

- hierarchické dědění kategorie,
- ochranu proti falešným nadpisům,
- významové směrování checkpointů,
- směrování pravidel do rozhodnutí,
- směrování zákazů do rizik,
- směrování pracovního pořadí do rozpracovaných úkolů,
- směrování `První a jediný další krok` do `NEXT STEP`.

Soubor byl připraven a předán, ale jeho aktivní nasazení nebylo dosud ověřeno skutečným novým během.

<!-- MM-SOURCE piece_id=BLK-0030:PART-01; block_id=BLK-0030; lines=482-486; decision=SPLIT_CONFIRMED/SPLIT -->
Dokumentační panel již prakticky propojuje A17 a A18 a bezpečně vytváří návrhy ve workspace na PC2.

## 5. Co zůstává rozpracováno

<!-- MM-SOURCE piece_id=BLK-0015; block_id=BLK-0015; lines=263-268; decision=NOT_REQUIRED/AUTO_ACCEPT -->
- ověření `ENGINE_VERSION` aktivního A18 na PC2,
- ověření cesty a času nejnovějšího návrhu,
- potvrzení, že nejnovější návrh používá engine V5,
- nový test V5 nad problematickým dokumentem,
- kontrola výsledného panelového mapovacího JSON,
- rozhodnutí, zda je A18 dostatečně stabilní pro A19.

<!-- MM-SOURCE piece_id=BLK-0029; block_id=BLK-0029; lines=460-476; decision=CONFIRMED/MOVE -->
Pokud aktivní soubor i nejnovější návrh uvádějí V5:

1. znovu vybrat jeden problematický dokument,
2. spustit A17,
3. spustit `NÁVRH OPRAVY`,
4. otevřít nový návrh,
5. poslat nový `document_standardization_panel_mapping_latest.json`,
6. vyhodnotit počet ručních bloků a placeholderů,
7. teprve poté rozhodnout o A19.

Pokud aktivní soubor neuvádí V5:

1. nepokračovat v testu,
2. ověřit aktivní cestu na PC2,
3. nahradit pouze aktivní A18,
4. předchozí verzi uložit do `tools/histori/`,
5. znovu provést diagnostiku.

<!-- MM-SOURCE piece_id=BLK-0030:PART-02; block_id=BLK-0030; lines=482-486; decision=SPLIT_CONFIRMED/SPLIT -->


Hlavním otevřeným bodem není samotné spuštění A18, ale potvrzení, že poslední připravená klasifikační logika V5 je skutečně aktivní a že nový návrh nepochází ze starého workspace.

## 6. OPEN QUESTIONS / otevřené úkoly

<!-- MM-SOURCE piece_id=BLK-0016; block_id=BLK-0016; lines=274-280; decision=NOT_REQUIRED/AUTO_ACCEPT -->
1. Je V5 skutečně uložen v aktivní složce `tools/documentation/`?
2. Byl po instalaci V5 spuštěn nový A18 běh?
3. Otevřel panel nový návrh, nebo starý `latest` soubor ze starého workspace?
4. Kolik ručních bloků vytvoří V5 nad `MM-NAV-20260702-01`?
5. Kolik ručních bloků vytvoří V5 nad `MM-NAV-20260705-01`?
6. Zůstane k ručnímu rozhodnutí pouze smíšený `Závěr`?
7. Má A19 řešit pouze potvrzení a přesun, nebo také rozdělení smíšeného bloku?

## 7. Rizika a upozornění

<!-- MM-SOURCE piece_id=BLK-0017; block_id=BLK-0017; lines=286-293; decision=NOT_REQUIRED/AUTO_ACCEPT -->
- Nesmí se považovat starý návrh za výsledek nové verze engine.
- Nesmí se spustit A19 před ověřením A18 V5.
- Nesmí se spustit A20 nad neověřeným mapováním.
- Nesmí se přepsat zdrojový dokument návrhem A18.
- Nesmí se ručně přepsat aktivní skript bez zachování předchozí verze v `tools/histori/`.
- Nesmí se zaměnit PC1 lokální kopie panelu za zdroj pravdy backendových skriptů.
- Hodnota `100 % coverage` neznamená automaticky správné významové mapování.
- Formální schválení MM-REF-001, MM-REF-002 ani testovaných návrhů nebylo uděleno.

## 8. Přijatá rozhodnutí a platná pravidla

<!-- MM-SOURCE piece_id=BLK-0018; block_id=BLK-0018; lines=299-308; decision=NOT_REQUIRED/AUTO_ACCEPT -->
1. PC2 je zdroj pravdy pro skripty, dokumenty, reporty a databázi.
2. PC1 je ovládací pracoviště a používá lokální kopii panelu.
3. A18 vytváří pouze návrh.
4. A18 nesmí měnit zdroj ani databázi.
5. Význam nadpisu má přednost před technickými tokeny v obsahu.
6. Podkapitola může dědit význam nadřazené kapitoly.
7. Dlouhá instrukční věta se nesmí považovat za nadpis jen proto, že obsahuje známý název sekce.
8. A19 se připojí až po stabilizaci A18.
9. A20 se nespouští, dokud není mapování potvrzeno.
10. Technická práce pokračuje vždy jen jedním krokem.

## 9. Ověřené zdroje, soubory a příkazy

<!-- MM-SOURCE piece_id=BLK-0019; block_id=BLK-0019; lines=316-324; decision=NOT_REQUIRED/AUTO_ACCEPT -->
```text
\\192.168.3.119\matchmatrix\tools\
matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py
```

```text
C:\MatchMatrix-Platform\tools\
matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py
```

<!-- MM-SOURCE piece_id=BLK-0020; block_id=BLK-0020; lines=328-331; decision=NOT_REQUIRED/AUTO_ACCEPT -->
```text
\\192.168.3.119\matchmatrix\tools\documentation\
25_1_A_17_AUDIT_DOCUMENT_STANDARD_COMPLIANCE_V1.py
```

<!-- MM-SOURCE piece_id=BLK-0021; block_id=BLK-0021; lines=335-338; decision=NOT_REQUIRED/AUTO_ACCEPT -->
```text
\\192.168.3.119\matchmatrix\tools\documentation\
25_1_A_18_BUILD_DOCUMENT_STANDARDIZATION_PROPOSAL_V1.py
```

<!-- MM-SOURCE piece_id=BLK-0022; block_id=BLK-0022; lines=342-344; decision=NOT_REQUIRED/AUTO_ACCEPT -->
```text
\\192.168.3.119\matchmatrix\reports\documentation\standardization\panel_workspaces
```

<!-- MM-SOURCE piece_id=BLK-0023; block_id=BLK-0023; lines=348-352; decision=NOT_REQUIRED/AUTO_ACCEPT -->
```text
MM-NAV-20260701-02
MM-NAV-20260702-01
MM-NAV-20260705-01
```

<!-- MM-SOURCE piece_id=BLK-0024; block_id=BLK-0024; lines=356-363; decision=NOT_REQUIRED/AUTO_ACCEPT -->
```text
document_standardization_proposal_latest.md
document_standardization_diff_latest.diff
document_standardization_mapping_latest.json
document_standardization_panel_mapping_latest.json
document_standardization_panel_mapping_latest.csv
document_standardization_panel_mapping_latest.md
```

## 10. AI CONTEXT

<!-- MM-SOURCE piece_id=BLK-0025; block_id=BLK-0025; lines=369-384; decision=NOT_REQUIRED/AUTO_ACCEPT -->
Role nového chatu:

- pokračovat v technickém ověření aktivního A18 V5,
- neopakovat již dokončenou analýzu V3 a V4,
- neposílat několik technických příkazů najednou,
- nerozšiřovat workflow o A19, dokud není potvrzen výsledek V5,
- zachovat bezpečnostní princip read-only zdroje a nulových databázových změn.

Kritická informace:

```text
Poslední zobrazený návrh nebyl důkazem V5.
Uváděl V3 a starý workspace.
```

První povinný krok je pouze diagnostika aktivního engine a nejnovějšího návrhu.

## 11. PROJECT SNAPSHOT

<!-- MM-SOURCE piece_id=BLK-0026; block_id=BLK-0026; lines=390-403; decision=NOT_REQUIRED/AUTO_ACCEPT -->
```text
Project                 : MatchMatrix-platform
Documentation workflow  : A17 audit + A18 proposal
Panel branch             : V20.1.Q3 STEP 10
A17 reference support    : IMPLEMENTED_AND_TESTED
A18 panel execution      : IMPLEMENTED_AND_TESTED
A18 V3                   : TESTED
A18 V4                   : TESTED_WITH_LIMITATIONS
A18 V5                   : PREPARED_NOT_YET_CONFIRMED_ACTIVE
A19 panel integration    : NOT_STARTED
A20 execution            : BLOCKED_UNTIL_MAPPING_APPROVAL
Source document writes   : DISABLED
Database writes by A18   : DISABLED
```

## 12. DATABASE SNAPSHOT

<!-- MM-SOURCE piece_id=BLK-0027; block_id=BLK-0027; lines=409-418; decision=NOT_REQUIRED/AUTO_ACCEPT -->
Dne 2026-07-09 nebyla dokumentační databáze měněna ani nově přepočítávána.

```text
A18 DATABASE WRITES : DISABLED
IMPORT              : NOT RUN
APPLY               : NOT RUN
DATABASE MODIFIED   : False
```

Databázové počty zobrazené v panelu nebyly v tomto pracovním bloku použity jako nový ověřený snapshot.

## 13. NEXT STEP

<!-- MM-SOURCE piece_id=BLK-0028; block_id=BLK-0028; lines=424-454; decision=NOT_REQUIRED/AUTO_ACCEPT -->
Na PC1 spusť pouze tento diagnostický blok:

```powershell
$A18='\\192.168.3.119\matchmatrix\tools\documentation\25_1_A_18_BUILD_DOCUMENT_STANDARDIZATION_PROPOSAL_V1.py'
$Root='\\192.168.3.119\matchmatrix\reports\documentation\standardization\panel_workspaces'

'===== AKTIVNÍ ENGINE A18 NA PC2 ====='
Select-String -LiteralPath $A18 `
    -Pattern '^ENGINE_VERSION\s*=' |
    Select-Object LineNumber,Line

'===== NEJNOVĚJŠÍ VYTVOŘENÝ NÁVRH A18 ====='
$Latest = Get-ChildItem -LiteralPath $Root -Recurse -File `
    -Filter 'document_standardization_proposal_*.md' |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

$Latest | Select-Object FullName,LastWriteTime

'===== ENGINE UVEDENÝ V NEJNOVĚJŠÍM NÁVRHU ====='
Select-String -LiteralPath $Latest.FullName `
    -Pattern 'Klasifikační engine'
```

Očekávaný aktivní engine:

```text
A18_CONTEXTUAL_MAPPING_V5_HIERARCHICAL_SEMANTIC_ROUTING
```

Pošli celý výstup. Do jeho vyhodnocení nespouštěj A19 ani A20 a neměň další skript.

<!-- MM-SOURCE piece_id=BLK-0030:PART-03; block_id=BLK-0030; lines=482-486; decision=SPLIT_CONFIRMED/SPLIT -->


Nový chat proto nezačíná další úpravou kódu. Začíná jedinou diagnostikou aktivního engine a nejnovějšího návrhu.

## Schválení standardizovaného kandidáta

- [ ] Byla zkontrolována správnost všech kapitol.
- [ ] Byla doplněna všechna pole `DOPLNIT UŽIVATELEM`.
- [ ] Byla ověřena terminologie podle MM-REF-001.
- [ ] Byl spuštěn audit A17 nad tímto kandidátem.
- [ ] Audit A17 dosáhl požadovaného stavu.
- [ ] Uživatel schválil vytvoření nové kanonické verze.
