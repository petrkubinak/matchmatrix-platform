# MM-DL-20260709

# MATCHMATRIX – DENNÍ ZÁPIS – 2026-07-09

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-DL-20260709 |
| Název dokumentu | MatchMatrix – denní zápis – 2026-07-09 |
| Typ dokumentu | DAILY_LOG |
| Edice | HISTORY |
| Verze | 1.0 |
| Původní stav zdrojového dokumentu | REVIEW |
| Datum | 2026-07-09 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Projekt | MatchMatrix-platform |
| Hlavní oblast | A17 audit dokumentů, A18 bezpečný návrh oprav a napojení dokumentačního workflow do Q3 panelu |
| Primární prostředí | PC1 `MATCHMATRIX-OPS` / PC2 `MatchMatrix` |
| Předchozí denní zápis | MM-DL-20260708 |
| Navazující dokument | MM-NAV-20260709-01 |
| Primární formát | Markdown (.md) |
| Cílové umístění | `docs/09_HISTORY/DENNÍ_ZÁPISY/MM-DL-20260709_MATCHMATRIX_DENNI_ZAPIS.md` |

---

# 1. Identifikace denního zápisu

Tento zápis zachycuje pracovní blok dne 2026-07-09 zaměřený na rozšíření řízeného dokumentačního workflow MatchMatrix.

Hlavními tématy byly:

- oprava klasifikace referenčních dokumentů v A17,
- ověření A17 nad MM-REF-001, MM-REF-002, denním zápisem a NAVÁZÁNÍM,
- doplnění tlačítka `NÁVRH OPRAVY` do hlavního Q3 panelu,
- diagnostika rozdílu mezi aktivním panelem na PC2 a spuštěnou lokální kopií na PC1,
- první úspěšné vzdálené spuštění A18 z panelu,
- postupné opravy klasifikační logiky A18 ve verzích V3, V4 a V5,
- testování A18 na několika různě strukturovaných historických navazovacích dokumentech,
- potvrzení, že A18 musí vytvářet pouze bezpečný návrh a nikdy nesmí přímo přepsat zdrojový dokument.

Práce byla vedena podle platného pravidla:

> Vždy pouze jeden příkaz nebo jeden jasný úkon. Po výsledku následuje další krok.

---

# 2. Výchozí stav

Na začátku pracovního dne platilo:

- A17 nesprávně určoval typ dokumentu MM-REF-001 jako `MAIN_DOCUMENT`,
- A17 nesprávně určoval typ dokumentu MM-REF-002 jako `PROJECT_SNAPSHOT`,
- panel Q3 uměl vybrat dokument, spustit A17, zobrazit nálezy a otevřít report,
- panel ještě neměl uživatelské spuštění A18,
- A18 existoval jako samostatný backendový skript, ale nebyl prakticky použitelný z panelu,
- A18 podporoval pouze typy `DAILY_LOG` a `CHAT_CONTINUATION`,
- zdrojový dokument se v A18 nesměl přepisovat,
- A19, A20 a následující kroky zatím nebyly zapojeny do panelového workflow.

Cílem dne bylo vytvořit bezpečný a prakticky použitelný první krok automatické opravy dokumentu:

```text
A17 AUDIT
→ A18 NÁVRH OPRAVY
→ budoucí A19 kontrola mapování
→ budoucí A20 vytvoření kandidáta
```

---

# 3. Cíl pracovního dne

Hlavním cílem bylo:

1. opravit A17 tak, aby referenční dokumenty měly vlastní správný typ,
2. připojit A18 do hlavního panelu,
3. ověřit, že A18 vytváří návrh na PC2 bez změny zdroje,
4. snížit počet ručně kontrolovaných mapovacích bloků na rozumné minimum,
5. připravit stabilní základ pro pozdější A19.

Cílový uživatelský princip zůstal:

```text
Vybrat dokument
→ spustit audit
→ vytvořit bezpečný návrh opravy
→ zkontrolovat jen skutečně nejednoznačné části
```

---

# 4. Provedené práce

## 4.1 Oprava klasifikace referenčních dokumentů v A17

Aktivní skript:

```text
\\192.168.3.119\matchmatrix\tools\documentation\
25_1_A_17_AUDIT_DOCUMENT_STANDARD_COMPLIANCE_V1.py
```

Do A17 byl doplněn samostatný typ:

```text
REFERENCE_DOCUMENT
```

Současně byla upravena:

- priorita rozpoznávání dokumentů `MM-REF-*`,
- sada podporovaných typů,
- pravidla povinných sekcí,
- engine identifikace A17.

Výsledný engine:

```text
A17_STANDARD_COMPLIANCE_V1_3_REFERENCE_DOCUMENT_TYPE
```

Referenční dokumenty již nejsou nuceny do struktury hlavního dokumentu ani Project Snapshotu.

## 4.2 Ověření A17 nad referenčními dokumenty

Po opravě A17 byly znovu zkontrolovány:

```text
MM-REF-001
MM-REF-002
```

Oba dokumenty měly:

```text
8 kontrol
0 FAIL
0 PARTIAL
1 MANUAL_REVIEW
```

Jediným otevřeným bodem zůstal:

```text
COMMON-TERMINOLOGY
```

Tento výsledek je očekávaný, protože automatický audit zatím neumí spolehlivě posoudit význam všech odborných pojmů.

Dokumenty nebyly tímto automaticky schváleny. Formální uživatelské schválení neproběhlo.

## 4.3 Oprava denního zápisu a NAVÁZÁNÍ podle A17

U denního zápisu byl opraven nadpis:

```text
# 8. Otevřené úkoly
```

na:

```text
# 8. Plán pokračování
```

Po opravě již denní zápis neměl `FAIL` ani `PARTIAL`.

U NAVÁZÁNÍ byly:

- normalizovány povinné nadpisy,
- doplněna kapitola `DATABASE SNAPSHOT`,
- odstraněny strukturální chyby.

Výsledek A17:

```text
SCORE: 97.78 %
FAIL: 0
PARTIAL: 0
MANUAL_REVIEW: 1
```

Jediným otevřeným bodem byla opět obecná terminologická kontrola.

## 4.4 Analýza panelu a backendu A18

Byl analyzován aktivní panel:

```text
matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py
```

Bylo potvrzeno:

- registr skriptů obsahoval A17 až A24, A6 a A7,
- uživatelské rozhraní nabízelo pouze A17,
- metody pro orchestrace A18 až A24 nebyly připojeny,
- A18 má bezpečné rozhraní:

```text
--audit
--output-dir
```

- A18 vytváří návrh, diff a mapovací kontrakty,
- A18 nemění databázi,
- A18 nemění zdrojový dokument,
- A18 ověřuje SHA-256 zdroje proti auditu A17.

## 4.5 Doplnění tlačítka NÁVRH OPRAVY do Q3 panelu

Byla vytvořena opravená aktivní verze panelu s krokem:

```text
V20.1.Q3 STEP 10
```

Do panelu bylo přidáno tlačítko:

```text
🛠 NÁVRH OPRAVY
```

Byly doplněny metody:

```text
documentation_run_a18
_documentation_run_a18_worker
_documentation_finish_a18
```

Nová logika:

- vyžaduje hotový audit A17,
- podporuje pouze `DAILY_LOG` a `CHAT_CONTINUATION`,
- A18 nespustí, pokud audit obsahuje pouze `PASS` a očekávaný `MANUAL_REVIEW`,
- běží vzdáleně na PC2,
- ukládá výstupy pouze do workspace,
- kontroluje návratový kód a očekávané výstupní soubory,
- aktualizuje manifest panelového workspace,
- nabízí otevření vytvořeného návrhu,
- nikdy nepřepisuje zdrojový dokument.

Syntaktická a strukturální kontrola panelu byla úspěšná.

## 4.6 Diagnostika staré lokální kopie panelu na PC1

Po prvním spuštění se nové tlačítko v panelu nezobrazilo.

Kontrola ukázala:

```text
Aktivní nový soubor:
\\192.168.3.119\matchmatrix\tools\
matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py
```

ale spuštěný proces používal:

```text
C:\MatchMatrix-Platform\tools\
matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py
```

Panel tedy běžel z lokální kopie na PC1, nikoli přímo z aktivního souboru na PC2.

Nový panel byl z PC2 zkopírován do lokálního umístění PC1.

Oba soubory měly shodný SHA-256:

```text
CAD39E462DCF2E918E4F7734E770B2D5E42D0ED4D360B60D00BFBFB2D304C906
```

Po novém spuštění se tlačítko `NÁVRH OPRAVY` zobrazilo.

## 4.7 První úspěšné spuštění A18 z panelu

A18 byl úspěšně spuštěn nad dokumentem:

```text
MM-NAV-20260701-02
```

Panel oznámil:

```text
Typ: CHAT_CONTINUATION
Pokrytí obsahu: 100.00 %
Stav: DOCUMENT_STANDARDIZATION_PROPOSAL_READY
Zdrojový dokument nebyl změněn
```

Bylo potvrzeno, že:

- panel správně spustil A18 na PC2,
- návrh vznikl ve workspace,
- zdrojový dokument zůstal beze změny,
- databáze nebyla změněna.

První návrh však nebyl obsahově použitelný.

## 4.8 Analýza prvního mapování A18

První panelový mapovací kontrakt obsahoval přibližně:

```text
111 bloků
3 automaticky přijatelné
108 k ruční kontrole
83 LOW
25 MEDIUM
12 placeholderů
85 bloků zařazených do sources
100 % technické pokrytí
```

Bylo potvrzeno, že hodnota `100 % pokrytí` znamenala pouze, že žádný zdrojový text nebyl ztracen. Neznamenala správné významové zařazení.

Hlavní problém:

- cesty,
- příkazy,
- kódové bloky,
- technické tokeny,
- sousední bloky

převážily nad skutečným významem nadpisů.

## 4.9 A18 V3 – SECTION FIRST

Byl opraven aktivní A18 na engine:

```text
A18_CONTEXTUAL_MAPPING_V3_SECTION_FIRST
```

Hlavní změny:

- nadpis kapitoly získal přednost před technickými signály,
- očíslované nadpisy byly rozpoznány přesněji,
- odstavce pod jedním nadpisem byly lépe seskupeny,
- metadata byla načítána z tabulky dokumentu,
- byly podporovány identifikátory typu `MM-NAV-20260701-02`,
- placeholdery byly počítány přesněji.

Test nad `MM-NAV-20260701-02`:

```text
33 bloků
32 automatických
1 k ručnímu rozhodnutí
0 placeholderů
100 % pokrytí
```

Jediným nejednoznačným blokem byl `Závěr`.

Současně byly odhaleny obsahové časové rozpory mezi:

- potvrzeným Git push,
- starým PROJECT SNAPSHOT,
- starým AI CONTEXT,
- starým NEXT STEP.

A18 tedy správně restrukturalizoval, ale nemohl sám rozhodnout, která historická informace je aktuálnější.

## 4.10 Test A18 V3 nad jinak strukturovaným dokumentem

Další test byl proveden nad:

```text
MM-NAV-20260702-01
```

Výsledek:

```text
13 bloků
3 automatické
10 k ruční kontrole
10 placeholderů
100 % pokrytí
```

Bylo potvrzeno, že V3 fungoval dobře pouze u známých kanonických nadpisů.

Chybně byly zařazeny například:

- `Aktivní soubor`,
- `Databázový model`,
- `Poslední validační výsledek`,
- `Kritický otevřený bod`,
- `První a jediný další krok`,
- `Následující pořadí práce`,
- `Důležitá pravidla`,
- `Další relevantní dokončené práce`.

## 4.11 A18 V4 – SEMANTIC HEADING ROUTING

Byl připraven engine:

```text
A18_CONTEXTUAL_MAPPING_V4_SEMANTIC_HEADING_ROUTING
```

Doplněno bylo obecnější významové směrování nadpisů, například:

```text
Aktivní soubor
→ CURRENT STATUS

Databázový model
→ DATABASE SNAPSHOT

Kritický otevřený bod
→ Rizika / OPEN QUESTIONS

První a jediný další krok
→ NEXT STEP

Důležitá pravidla
→ Přijatá rozhodnutí

Další relevantní dokončené práce
→ Co bylo dokončeno
```

Test nad dokumentem:

```text
MM-NAV-20260705-01
```

však ukázal další slabiny:

```text
17 bloků
5 automatických
12 k ruční kontrole
8 placeholderů
```

V4 například mylně vyhodnotil větu:

```text
A ověř pouze tuto jednu položku v tabulce Informace o dokumentu
```

jako nový identifikační nadpis.

## 4.12 A18 V5 – HIERARCHICAL SEMANTIC ROUTING

Na základě testu V4 byl připraven engine:

```text
A18_CONTEXTUAL_MAPPING_V5_HIERARCHICAL_SEMANTIC_ROUTING
```

V5 doplňuje:

- dědičnost kategorie nadřazené kapitoly,
- přísnější rozpoznávání skutečných nadpisů,
- ochranu proti falešné klasifikaci delších instrukčních vět,
- významové směrování checkpointů, snapshotů, pravidel, rizik a plánů,
- preferenci významu nadpisu před výskytem technických názvů uvnitř textu.

Kontrolní test nad 17 nadpisy z mapování V4 zařadil jednoznačně 16 bloků. Pouze smíšený `Závěr` zůstal určen k ručnímu rozhodnutí.

Syntaktická kontrola V5 byla úspěšná.

## 4.13 Neuzavřená instalace a test A18 V5

A18 V5 byl připraven a předán jako nový aktivní soubor.

Cílové umístění:

```text
\\192.168.3.119\matchmatrix\tools\documentation\
25_1_A_18_BUILD_DOCUMENT_STANDARDIZATION_PROPOSAL_V1.py
```

Po předání však byl zobrazen návrh, který stále uváděl:

```text
A18_CONTEXTUAL_MAPPING_V3_SECTION_FIRST
```

a pocházel ze starého workspace:

```text
20260709_142741_MM_NAV_20260702_01_MATCHMATRIX_NAVAZANI_DO_CHATU
```

Proto dnes nebylo spolehlivě potvrzeno:

- zda je V5 skutečně uložen jako aktivní soubor na PC2,
- zda panel spustil nový běh,
- zda uživatel pouze otevřel starý návrh z předchozího workspace.

---

# 5. Přijatá rozhodnutí

## 5.1 A18 je pouze bezpečný návrhový krok

A18:

- nesmí přepisovat zdroj,
- nesmí měnit databázi,
- nesmí vytvořit finální kanonický dokument,
- smí pouze vytvořit návrh, diff a mapovací kontrakt.

## 5.2 A19 se zatím nepřipojuje

A19 bude připojen až tehdy, když A18:

- správně zařadí většinu kapitol automaticky,
- ponechá k ručnímu rozhodnutí jen skutečně nejednoznačné bloky,
- nevytváří zbytečné placeholdery pro obsah, který ve zdroji existuje.

## 5.3 A20 se zatím nespouští

A20 nesmí být spuštěn nad chybným nebo neověřeným mapováním.

## 5.4 Význam nadpisu má přednost před technickými tokeny

Cesta, SQL, Git commit nebo kódový blok uvnitř kapitoly nesmí automaticky změnit význam celé kapitoly na `sources`.

## 5.5 Smíšený závěr může vyžadovat ruční rozhodnutí

Kapitola `Závěr` často současně obsahuje:

- dokončený stav,
- riziko,
- rozpracovanou oblast,
- další krok.

Takový blok může zůstat v A19 k potvrzení, přesunu nebo rozdělení.

## 5.6 PC2 je zdroj pravdy, PC1 je ovládací pracoviště

Aktivní backendové skripty a reporty jsou na PC2.

PC1 používá lokální kopii panelu pouze pro spuštění a ovládání. Při změně panelu musí být lokální kopie synchronizována.

## 5.7 Starý report není důkazem aktivního engine

Při ověřování nové verze A18 se musí současně kontrolovat:

- `ENGINE_VERSION` aktivního skriptu,
- čas a cestu nejnovějšího návrhu,
- engine uvedený uvnitř nejnovějšího návrhu.

---

# 6. Problémy a jejich řešení

## 6.1 A17 zaměňoval referenční dokumenty za jiné typy

**Příčina:** Typ `REFERENCE_DOCUMENT` neexistoval.

**Řešení:** Doplněn nový typ a pravidla pro MM-REF dokumenty.

**Výsledek:** MM-REF-001 a MM-REF-002 již nemají strukturální `FAIL` ani `PARTIAL`.

## 6.2 Nové tlačítko panelu se nezobrazilo

**Příčina:** Spuštěný panel na PC1 používal lokální starou kopii.

**Řešení:** Aktivní panel z PC2 byl překopírován na PC1 a ověřen SHA-256.

**Výsledek:** Tlačítko `NÁVRH OPRAVY` se zobrazilo.

## 6.3 První A18 vytvořil 108 ručních bloků

**Příčina:** Technické signály převážily nad strukturou dokumentu.

**Řešení:** A18 V3 zavedl princip `SECTION FIRST`.

**Výsledek:** U prvního testovacího dokumentu klesla ruční fronta na jeden blok.

## 6.4 A18 V3 nebyl dostatečně obecný

**Příčina:** Znal pouze omezenou sadu přesných názvů kapitol.

**Řešení:** A18 V4 doplnil významové směrování nadpisů.

## 6.5 A18 V4 mylně vytvářel nadpisy z instrukčních vět

**Příčina:** Výskyt známého názvu uvnitř delší věty byl považován za význam celé kapitoly.

**Řešení:** A18 V5 zpřísnil rozpoznávání nadpisů a doplnil hierarchickou dědičnost.

## 6.6 Po předání V5 byl otevřen starý návrh V3

**Příčina:** Zatím nepotvrzena.

Možnosti:

- V5 nebyl uložen do aktivní složky,
- panel spustil starý aktivní soubor,
- nový běh nebyl spuštěn,
- otevřen byl starý workspace.

**Stav:** Otevřeno pro další diagnostiku.

---

# 7. Ověřené výsledky a technické výstupy

## 7.1 Aktivní panelový soubor

```text
\\192.168.3.119\matchmatrix\tools\
matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py
```

Lokální spouštěná kopie na PC1:

```text
C:\MatchMatrix-Platform\tools\
matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py
```

Ověřený SHA-256 obou kopií:

```text
CAD39E462DCF2E918E4F7734E770B2D5E42D0ED4D360B60D00BFBFB2D304C906
```

## 7.2 Aktivní A17

```text
\\192.168.3.119\matchmatrix\tools\documentation\
25_1_A_17_AUDIT_DOCUMENT_STANDARD_COMPLIANCE_V1.py
```

Engine:

```text
A17_STANDARD_COMPLIANCE_V1_3_REFERENCE_DOCUMENT_TYPE
```

## 7.3 Cílový aktivní A18

```text
\\192.168.3.119\matchmatrix\tools\documentation\
25_1_A_18_BUILD_DOCUMENT_STANDARDIZATION_PROPOSAL_V1.py
```

Poslední připravený engine:

```text
A18_CONTEXTUAL_MAPPING_V5_HIERARCHICAL_SEMANTIC_ROUTING
```

Aktivace tohoto engine na PC2 však na konci dne nebyla spolehlivě ověřena.

## 7.4 Panelové výstupy A18

A18 vytváří ve workspace:

```text
document_standardization_proposal_latest.md
document_standardization_diff_latest.diff
document_standardization_mapping_latest.json
document_standardization_mapping_latest.md
document_standardization_panel_mapping_latest.json
document_standardization_panel_mapping_latest.csv
document_standardization_panel_mapping_latest.md
```

## 7.5 Databázové změny

```text
DATABASE MODIFIED: False
```

Dnes nebyl proveden import ani změna dokumentační databáze.

## 7.6 Zdrojové dokumenty

```text
SOURCE MODIFIED: False
```

Testované dokumenty zůstaly beze změny.

---

# 8. Výsledky dne a stav na konci dne

## Dokončeno

- A17 správně rozpoznává `REFERENCE_DOCUMENT`.
- MM-REF-001 a MM-REF-002 již nemají strukturální chyby A17.
- Denní zápis a NAVÁZÁNÍ byly strukturálně opraveny podle A17.
- Q3 panel obsahuje tlačítko `NÁVRH OPRAVY`.
- Panel umí vzdáleně spustit A18 na PC2.
- Byla vyřešena odlišná aktivní kopie panelu na PC1.
- Bylo ověřeno bezpečné vytvoření návrhu bez změny zdroje.
- A18 byl postupně rozšířen na V3, V4 a připravenou V5.
- Byly odhaleny a popsány hlavní třídy klasifikačních chyb.

## Rozpracováno

- potvrzení aktivní instalace A18 V5 na PC2,
- nový test V5 nad problematickým dokumentem,
- ověření počtu automatických a ručních bloků,
- kontrola, že V5 nevytváří zbytečné placeholdery.

## Zatím nezačato

- připojení A19 do panelu,
- interaktivní potvrzení, přesun nebo rozdělení bloků,
- spuštění A20,
- finální vytvoření opraveného kandidátního dokumentu,
- schválení a publikace.

---

# 9. Plán pokračování

Po ověření aktivního engine A18 bude postup:

1. potvrdit, že aktivní A18 na PC2 je V5,
2. potvrdit, že nejnovější návrh vznikl novým během,
3. znovu otestovat `MM-NAV-20260702-01` nebo `MM-NAV-20260705-01`,
4. porovnat:
   - počet bloků,
   - automatické bloky,
   - ruční frontu,
   - placeholdery,
   - významové zařazení kapitol,
5. pokud zůstane pouze skutečně nejednoznačný závěr, uzavřít A18,
6. následně navrhnout panelové připojení A19.

---

# 10. Jeden hlavní další krok

Na PC1 ověřit aktivní engine A18 a engine uvedený v nejnovějším vytvořeném návrhu.

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

Před vyhodnocením tohoto výstupu se nemá provádět další změna skriptu ani spouštět A19 nebo A20.

---

# 11. Vazby a NAVÁZÁNÍ

Na tento denní zápis navazuje:

```text
MM-NAV-20260709-01
```

Cílové umístění:

```text
docs/09_HISTORY/NAVÁZÁNÍ_NA_CHAT/
MM-NAV-20260709-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md
```

Navazovací dokument obsahuje:

- přesný aktuální stav A17 a A18,
- aktivní cesty PC1 a PC2,
- stav panelového tlačítka,
- výsledky testů V3 a V4,
- připravený, ale dosud nepotvrzený A18 V5,
- jediný povinný diagnostický krok pro nový chat.

---

# 12. Závěr

Dne 2026-07-09 se dokumentační workflow MatchMatrix posunulo od samotného auditu A17 k prvnímu bezpečnému panelovému návrhu opravy A18.

Technicky funguje celý tok:

```text
výběr dokumentu
→ A17 audit
→ zobrazení nálezů
→ A18 návrh opravy na PC2
→ otevření návrhu
```

Současně se ukázalo, že spolehlivá automatická restrukturalizace dokumentů vyžaduje více než prosté vyhodnocení technických slov. A18 proto postupně přešel od blokového skórování k principu nadpisové priority, významového směrování a hierarchické dědičnosti.

Poslední připravenou verzí je A18 V5. Její skutečné aktivní nasazení a nový běh však musí být nejprve ověřeny. Do té doby se A19 ani A20 nepřipojují a žádný zdrojový dokument se nemění.
