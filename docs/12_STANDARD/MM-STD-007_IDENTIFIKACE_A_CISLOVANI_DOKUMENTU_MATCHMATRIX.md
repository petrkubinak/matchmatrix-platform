# MM-STD-007

# IDENTIFIKACE A ČÍSLOVÁNÍ DOKUMENTŮ MATCHMATRIX

## STANDARD

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-STD-007 |
| Název | Identifikace a číslování dokumentů MatchMatrix |
| Edice | MM-STD |
| Verze | 1.2 |
| Stav | REVIEW |
| Datum aktualizace | 2026-07-27 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Primární formát | Markdown (`.md`) |
| Aktivní soubor | `docs/12_STANDARD/MM-STD-007_IDENTIFIKACE_A_CISLOVANI_DOKUMENTU_MATCHMATRIX.md` |

---

## Historie verzí

| Verze | Datum | Stav | Popis |
|---:|---|---|---|
| 1.0 | 2026 | REVIEW | První návrh identifikace a číslování. Obsahoval samostatný prefix pro každou složku. |
| 1.1 | 2026-07-27 | REVIEW | Zachovány již zavedené Document ID, odstraněno automatické odvozování prefixu ze složky, doplněn registr typů, časové identity, číselné bloky, aliasy, rezervace, přidělování a kontroly kolizí. Doplněna formální hierarchie a závěry hlavních kapitol podle výsledku A17 ze dne 2026-07-28. |
| 1.2 | 2026-07-29 | REVIEW | Doplněny závěry hlavních kapitol a sjednocena struktura dokumentu pro kontrolu A17; obsahová změna je oddělena novou verzí. |

---

## Úvod a účel dokumentu
Tento standard stanovuje jednotný a dlouhodobě stabilní systém:

- identifikace dokumentů,
- přidělování Document ID,
- číslování jednotlivých typů dokumentů,
- registrace prefixů,
- ochrany již zavedených identit,
- řešení historických a pracovních označení,
- číselných rezervací,
- časově specifických identit,
- kontroly duplicit a kolizí,
- návaznosti na dokumentační index a Documentation Management System.

Cílem je, aby každý řízený dokument MatchMatrix měl jedinou jednoznačnou identitu nezávislou na názvu souboru, verzi, stavu nebo fyzickém umístění.

---

## Rozsah

Standard je závazný pro všechny řízené dokumenty a dokumentové artefakty projektu MatchMatrix.

Týká se zejména typů:

- `MM-DOC`,
- `MM-STD`,
- `MM-REF`,
- `MM-PRV`,
- `MM-TPL`,
- `MM-DL`,
- `MM-NAV`,
- `MM-EXP`,
- dalších typů schválených a zapsaných do centrálního registru.

Názvosloví souborů upravuje `MM-STD-004`.

Životní cyklus a verzování upravuje `MM-STD-003`.

---

# 1. Základní principy

## 1.1 Document ID je primární identita

Každý řízený dokument má jeden Document ID.

Příklad:

```text
MM-DOC-300
```

Document ID je:

- jedinečný,
- stabilní,
- neměnný po celý životní cyklus,
- nezávislý na názvu souboru,
- nezávislý na verzi,
- nezávislý na stavu,
- nezávislý na složce,
- použitelný jako databázový a systémový identifikátor.

## 1.2 Složka neurčuje prefix

Fyzické umístění dokumentu neznamená, že dokument musí používat zvláštní prefix podle názvu složky.

Například dokument ve složce:

```text
docs/01_MASTER/
```

může správně používat:

```text
MM-DOC-100
```

a nemusí být přejmenován na:

```text
MM-MST-001
```

Stejně tak:

- Governance dokument zůstává `MM-DOC-200`,
- Architecture dokument zůstává `MM-DOC-300`,
- Development Handbook zůstává `MM-DOC-800`,
- Denní zápisy zůstávají upraveny dokumentem `MM-DOC-900`.

Složka určuje tematické nebo provozní umístění. Prefix určuje typ dokumentu.

## 1.3 Publikované a zavedené identity se zachovávají

Document ID, které již bylo:

- publikováno,
- používáno v odkazech,
- importováno do dokumentační databáze,
- zapsáno v historii,
- použito v šablonách nebo skriptech,

se nepřečíslovává pouze kvůli novému návrhu číselného systému.

Přečíslování je mimořádná operace a vyžaduje:

1. jednoznačný důvod,
2. mapu starého a nového ID,
3. aktualizaci všech odkazů,
4. aktualizaci dokumentační databáze,
5. archivaci původního označení,
6. schválení uživatelem,
7. audit kolizí.

## 1.4 Jedno ID nelze znovu použít

Zrušené, archivované nebo nahrazené ID se nevrací do volného fondu.

Zůstává trvale obsazené kvůli historické dohledatelnosti.

## 1.5 Jedna identita neznamená jednu verzi

Nová verze stejného dokumentu používá stejné Document ID.

Příklad:

```text
MM-STD-007 v1.0
MM-STD-007 v1.1
```

Obě verze představují stejný dokument.

---


## 1.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „1. Základní principy“ v rámci dokumentu MM-STD-007 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „2. Struktura Document ID“, která rozvíjí další část řízeného dokumentu.

# 2. Struktura Document ID

## 2.1 Standardní číselný typ

Obecný formát:

```text
MM-XXX-NNN
```

nebo pro schválené širší rozsahy:

```text
MM-XXX-NNNN
```

kde:

- `MM` = projekt MatchMatrix,
- `XXX` = registrovaný typ dokumentu,
- `NNN` nebo `NNNN` = jedinečné číslo v daném typu.

Příklady:

```text
MM-DOC-100
MM-STD-007
MM-REF-001
MM-DOC-1000
MM-STD-1000
```

## 2.2 Časově specifický typ

Dokumenty, jejichž identita přirozeně vychází z data, používají datum ve formátu `YYYYMMDD`.

Příklady:

```text
MM-DL-20260727
MM-NAV-20260727-01
MM-EXP-20260727-01
```

## 2.3 Oddělovače

Document ID používá pouze:

- velká písmena,
- číslice,
- spojovník `-`.

Nepoužívá:

- mezery,
- podtržítka,
- diakritiku,
- závorky,
- lomítka,
- tečky,
- stavové nebo verzovací přípony.

## 2.4 Zápis v dokumentu

Document ID musí být uveden:

- v prvním nadpisu,
- v tabulce metadat,
- v historii verzí podle potřeby,
- v dokumentačním indexu,
- v dokumentační databázi.

---


## 2.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „2. Struktura Document ID“ v rámci dokumentu MM-STD-007 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „3. Registrované typy dokumentů“, která rozvíjí další část řízeného dokumentu.

# 3. Registrované typy dokumentů

## 3.1 MM-DOC

`MM-DOC` označuje hlavní řízenou dokumentaci projektu.

Zahrnuje zejména:

- dokumentační framework,
- strategické dokumenty,
- governance,
- architekturu,
- development handbook,
- standard denních zápisů,
- další hlavní systémové dokumenty.

Příklady zavedených identit:

```text
MM-DOC-000
MM-DOC-100
MM-DOC-200
MM-DOC-300
MM-DOC-800
MM-DOC-900
MM-DOC-1000
```

## 3.2 MM-STD

`MM-STD` označuje závazné standardy projektu.

Příklady:

```text
MM-STD-001
MM-STD-009
MM-STD-1000
```

## 3.3 MM-REF

`MM-REF` označuje referenční dokumenty.

Příklady:

- slovník pojmů,
- výkladový rejstřík,
- referenční mapy,
- řízené seznamy.

Příklad:

```text
MM-REF-001
```

## 3.4 MM-PRV

`MM-PRV` označuje dokumentaci providerů, právních, licenčních a zdrojových otázek.

Příklad:

```text
MM-PRV-006
```

## 3.5 MM-TPL

`MM-TPL` označuje oficiální dokumentové šablony.

Příklady:

```text
MM-TPL-001
MM-TPL-002
```

## 3.6 MM-DL

`MM-DL` označuje denní zápis.

Formát:

```text
MM-DL-YYYYMMDD
```

Příklad:

```text
MM-DL-20260727
```

Pro jeden kalendářní den standardně existuje jeden kanonický denní zápis.

## 3.7 MM-NAV

`MM-NAV` označuje dokument NAVÁZÁNÍ do nového chatu nebo pracovní etapy.

Formát:

```text
MM-NAV-YYYYMMDD-NN
```

Příklad:

```text
MM-NAV-20260727-01
```

`NN` je dvoumístné pořadové číslo v daném dni.

## 3.8 MM-EXP

`MM-EXP` označuje řízený exportní artefakt.

Formát:

```text
MM-EXP-YYYYMMDD-NN
```

Příklad:

```text
MM-EXP-20260727-01
```

Export může mít vlastní neměnnou verzi v názvu souboru, pokud představuje konkrétní datovou dodávku.

## 3.9 Další typy

Nový typ dokumentu lze zavést pouze po:

1. definování jeho účelu,
2. ověření, že jej nepokrývá existující typ,
3. přidání prefixu do tohoto standardu,
4. přidání do dokumentačního indexu,
5. definování způsobu číslování,
6. schválení.

Původní návrhy prefixů typu:

```text
MM-MST
MM-GOV
MM-ARC
MM-DEV
MM-HIS
```

se nezavádějí automaticky pouze podle názvu složky.

Mohou vzniknout v budoucnu pouze pro skutečně samostatný dokumentový typ, nikoli jako náhrada již existujících `MM-DOC` identit.

---


## 3.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „3. Registrované typy dokumentů“ v rámci dokumentu MM-STD-007 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „4. Závazný registr hlavních dokumentů“, která rozvíjí další část řízeného dokumentu.

# 4. Závazný registr hlavních dokumentů

Následující identity jsou zavedené a musí být zachovány:

| Document ID | Název / role | Kanonická oblast |
|---|---|---|
| `MM-DOC-000` | MatchMatrix Documentation Framework | `docs/00_DOCUMENTATION/` |
| `MM-DOC-100` | MatchMatrix Master | `docs/01_MASTER/` |
| `MM-DOC-200` | MatchMatrix Governance | `docs/02_GOVERNANCE/` |
| `MM-DOC-300` | MatchMatrix Architecture | `docs/03_ARCHITECTURE/` |
| `MM-DOC-800` | MatchMatrix Development Handbook | `docs/08_DEVELOPMENT/` |
| `MM-DOC-900` | MatchMatrix Denní zápisy | `docs/09_HISTORY/` |
| `MM-DOC-1000` | Index nebo centrální registr hlavních dokumentů | `docs/10_REFERENCE/` nebo jiná schválená oblast |

Historická pracovní označení:

```text
MM-DOC-001
MM-DOC-002
MM-DOC-003
MM-DOC-004
MM-DOC-005
MM-DOC-090
```

se nesmějí znovu použít jako nové aktivní identity, pokud již byla spojena s existujícím dokumentem.

V aktivních odkazech se používají pouze současné identity.

---


## 4.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „4. Závazný registr hlavních dokumentů“ v rámci dokumentu MM-STD-007 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „5. Číselné bloky MM-DOC“, která rozvíjí další část řízeného dokumentu.

# 5. Číselné bloky MM-DOC

Číselné bloky hlavních dokumentů vyjadřují logické oblasti, nikoli pořadí vzniku.

## 5.1 Kořenová dokumentace

```text
000–099
```

Použití:

- dokumentační framework,
- dokumentační systém,
- obecné kořenové dokumenty.

Zavedeno:

```text
MM-DOC-000
```

## 5.2 Strategie a Master

```text
100–199
```

Zavedeno:

```text
MM-DOC-100
```

## 5.3 Governance

```text
200–299
```

Zavedeno:

```text
MM-DOC-200
```

## 5.4 Architektura

```text
300–399
```

Zavedeno:

```text
MM-DOC-300
```

## 5.5 Databáze, providery, vrstvy a provoz

Bloky `400–799` jsou rezervovány pro budoucí hlavní dokumenty podle schválené dokumentační architektury.

Přesné přidělení se provádí v centrálním registru, nikoli automaticky podle pořadí souboru.

## 5.6 Vývoj

```text
800–899
```

Zavedeno:

```text
MM-DOC-800
```

## 5.7 Historie a kontinuita

```text
900–999
```

Zavedeno:

```text
MM-DOC-900
```

Budoucí související identity mohou být přiděleny pouze po kontrole registru.

## 5.8 Centrální indexy

```text
1000 a vyšší
```

Použití:

- centrální indexy,
- systémové registry,
- nadřazené přehledy.

Zavedeno:

```text
MM-DOC-1000
```

---


## 5.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „5. Číselné bloky MM-DOC“ v rámci dokumentu MM-STD-007 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „6. Číslování MM-STD“, která rozvíjí další část řízeného dokumentu.

# 6. Číslování MM-STD

## 6.1 Základní standardy

Standardy používají průběžný tříciferný registr:

```text
MM-STD-001
MM-STD-002
...
MM-STD-009
```

Aktuálně zavedené standardy:

| Document ID | Název |
|---|---|
| `MM-STD-001` | Standard tvorby hlavních dokumentů |
| `MM-STD-002` | Standard tvorby rozsáhlých dokumentů |
| `MM-STD-003` | Standard životního cyklu dokumentace a verzování |
| `MM-STD-004` | Standard názvosloví a struktury dokumentace |
| `MM-STD-005` | Standard vizuální identity dokumentace |
| `MM-STD-006` | Standard terminologie a slovníku pojmů |
| `MM-STD-007` | Identifikace a číslování dokumentů MatchMatrix |
| `MM-STD-008` | Správa terminologie a referenčního slovníku |
| `MM-STD-009` | AI Context a Project Snapshot |

## 6.2 Index standardů

Centrální index používá:

```text
MM-STD-1000
```

Číslo `1000` je rezervováno pro index standardů a nesmí být použito pro jiný standard.

## 6.3 Nový standard

Nový standard obdrží nejbližší vhodné volné ID po kontrole:

- indexu standardů,
- repozitáře,
- dokumentační databáze,
- archivu,
- historických aliasů.

Pouhý chybějící soubor v aktivní složce neznamená, že ID je volné.

---


## 6.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „6. Číslování MM-STD“ v rámci dokumentu MM-STD-007 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „7. Číslování MM-REF“, která rozvíjí další část řízeného dokumentu.

# 7. Číslování MM-REF

`MM-REF` používá průběžnou číselnou řadu.

Příklad:

```text
MM-REF-001
MM-REF-002
```

Pro každý Document ID existuje jediný aktivní referenční dokument.

Dvě různé aktivní varianty slovníku nesmějí používat stejné `MM-REF-001` bez jasného verzovacího vztahu.

Pokud existují soubory:

```text
MM-REF-001_SLOVNIK_POJMU_MATCHMATRIX.md
MM-REF-001_SLOVNIK_POJMU_MATCHMATRIX_v1.3.md
```

nejde o dva různé dokumenty. Jde o konflikt aktivních verzí téhož Document ID, který se musí vyřešit podle `MM-STD-003`.

---


## 7.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „7. Číslování MM-REF“ v rámci dokumentu MM-STD-007 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „8. Číslování MM-PRV“, která rozvíjí další část řízeného dokumentu.

# 8. Číslování MM-PRV

`MM-PRV` používá průběžnou číselnou řadu.

Přidělené číslo zůstává stabilní i při:

- změně provideru,
- změně právního stavu,
- nové verzi dokumentu,
- změně názvu souboru,
- přesunu do jiné složky.

Pokud jeden dokument pokrývá právní a licenční řízení více providerů, jeho identita se nemění jen proto, že se rozšíří rozsah.

---


## 8.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „8. Číslování MM-PRV“ v rámci dokumentu MM-STD-007 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „9. Číslování MM-TPL“, která rozvíjí další část řízeného dokumentu.

# 9. Číslování MM-TPL

Oficiální šablony používají průběžnou číselnou řadu.

Zavedené identity:

| Document ID | Účel |
|---|---|
| `MM-TPL-001` | Šablona NAVÁZÁNÍ do nového chatu |
| `MM-TPL-002` | Šablona denního zápisu |

Nová verze šablony používá stejné Document ID a nové číslo verze uvnitř dokumentu.

---


## 9.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „9. Číslování MM-TPL“ v rámci dokumentu MM-STD-007 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „10. Časové identity“, která rozvíjí další část řízeného dokumentu.

# 10. Časové identity

## 10.1 MM-DL

Formát:

```text
MM-DL-YYYYMMDD
```

Pravidla:

- datum odpovídá pracovnímu dni,
- používá se místní kalendářní datum projektu,
- standardně jeden kanonický dokument na den,
- duplicitní ID je zakázáno,
- oprava se řeší verzí nebo řízeným následným dokumentem.

## 10.2 MM-NAV

Formát:

```text
MM-NAV-YYYYMMDD-NN
```

Pravidla:

- datum odpovídá dni vzniku NAV,
- `NN` začíná `01`,
- číslování je samostatné pro každý den,
- číslo přiděluje panel nebo registr podle existujících dokumentů,
- zrušené číslo se znovu nepoužívá, pokud již bylo publikováno.

## 10.3 MM-EXP

Formát:

```text
MM-EXP-YYYYMMDD-NN
```

Pravidla:

- datum odpovídá vytvoření nebo vydání exportu,
- `NN` rozlišuje více exportů stejného dne,
- exportní verze může být uvedena v názvu souboru,
- nový obsahový export může obdržet nové pořadové číslo nebo novou verzi podle charakteru artefaktu.

---


## 10.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „10. Časové identity“ v rámci dokumentu MM-STD-007 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „11. Přidělení nového Document ID“, která rozvíjí další část řízeného dokumentu.

# 11. Přidělení nového Document ID

Před přidělením nového ID se provede kontrola:

1. aktivní dokumentace,
2. dokumentačního indexu,
3. Git historie,
4. `docs/99_ARCHIVE`,
5. dokumentační databáze,
6. existujících šablon a odkazů,
7. historických pracovních označení.

Nové ID se přidělí až po potvrzení, že:

- dokument skutečně představuje nový samostatný účel,
- stejné téma již nemá vlastní Document ID,
- číslo není obsazeno,
- číslo není rezervováno,
- prefix odpovídá typu,
- budoucí umístění je určeno.

## 11.1 Rezervace

Document ID lze dočasně rezervovat.

Rezervace musí obsahovat:

- zamýšlený název,
- typ,
- odpovědnou osobu,
- datum rezervace,
- stav,
- důvod.

Rezervace nesmí zůstávat neurčitě bez kontroly.

## 11.2 Přidělení AI

AI může navrhnout vhodné ID, ale nesmí je považovat za závazně přidělené bez kontroly registru a schválení.

---


## 11.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „11. Přidělení nového Document ID“ v rámci dokumentu MM-STD-007 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „12. Historické aliasy“, která rozvíjí další část řízeného dokumentu.

# 12. Historické aliasy

## 12.1 Účel aliasu

Historický alias zachovává dohledatelnost staršího označení.

Příklad:

```text
Historické pracovní označení: MM-DOC-003
Současné Document ID: MM-DOC-300
```

## 12.2 Alias není druhá identita

Alias:

- nesmí být používán jako aktivní ID,
- nesmí obdržet nový samostatný dokument,
- nesmí být znovu přidělen,
- slouží pouze k dohledání historie.

## 12.3 Evidence aliasů

Alias se eviduje:

- v metadatech aktivního dokumentu,
- v historii verzí,
- případně v centrálním dokumentovém registru,
- v dokumentační databázi.

---


## 12.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „12. Historické aliasy“ v rámci dokumentu MM-STD-007 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „13. Kolize a duplicity“, která rozvíjí další část řízeného dokumentu.

# 13. Kolize a duplicity

## 13.1 Stejné ID, různý obsah

Pokud existují dva soubory se stejným Document ID, nejprve se určí:

- zda jde o dvě verze téhož dokumentu,
- zda jde o export a zdroj,
- zda jde o pracovní REVIEW kandidát,
- zda došlo k chybné duplicitní identitě.

## 13.2 Stejný dokument, různá ID

Pokud má jeden dokument více ID, určí se:

- původní a současná identita,
- publikované odkazy,
- databázová evidence,
- nejnovější schválené rozhodnutí.

Jedna identita se stanoví jako kanonická. Ostatní se evidují jako historické aliasy nebo chybné pracovní označení.

## 13.3 Chyba v přidělení

Chybně přidělené ID se nesmí tiše přepsat bez historie.

Oprava musí obsahovat:

- popis chyby,
- správné ID,
- mapu odkazů,
- archivaci nebo alias,
- aktualizaci indexu,
- aktualizaci dokumentační databáze.

---


## 13.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „13. Kolize a duplicity“ v rámci dokumentu MM-STD-007 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „14. Vazba na názvy souborů“, která rozvíjí další část řízeného dokumentu.

# 14. Vazba na názvy souborů

Document ID je první část názvu aktivního souboru.

Příklad:

```text
MM-STD-007_IDENTIFIKACE_A_CISLOVANI_DOKUMENTU_MATCHMATRIX.md
```

Název souboru může změnit popisnou část, ale Document ID zůstává stejné.

Číslo verze se do aktivního názvu nepřidává.

Podrobnosti určuje `MM-STD-004`.

---


## 14.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „14. Vazba na názvy souborů“ v rámci dokumentu MM-STD-007 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „15. Vazba na složky“, která rozvíjí další část řízeného dokumentu.

# 15. Vazba na složky

Složka:

- usnadňuje orientaci,
- určuje funkční oblast,
- může se v budoucnu změnit,
- neurčuje identitu.

Příklad:

```text
docs/03_ARCHITECTURE/MM-DOC-300_MATCHMATRIX_ARCHITECTURE_TECH.md
```

Identita je:

```text
MM-DOC-300
```

nikoli:

```text
MM-ARC-001
```

Přesun souboru do jiné schválené složky nevyžaduje nové Document ID.

---


## 15.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „15. Vazba na složky“ v rámci dokumentu MM-STD-007 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „16. Vazba na Documentation Management System“, která rozvíjí další část řízeného dokumentu.

# 16. Vazba na Documentation Management System

Document ID je primární obchodní identifikátor dokumentu.

Documentation Management System musí umět uchovat:

- Document ID,
- interní databázový klíč,
- název,
- typ,
- edici,
- verzi,
- stav,
- aktivní cestu,
- historii cest,
- historické aliasy,
- vztahy,
- archivní kopie,
- importní historii.

Interní databázový číselný klíč nesmí nahrazovat Document ID v uživatelské nebo dokumentové komunikaci.

---


## 16.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „16. Vazba na Documentation Management System“ v rámci dokumentu MM-STD-007 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „17. Vazba na Git“, která rozvíjí další část řízeného dokumentu.

# 17. Vazba na Git

Git cesta a commit jsou důkazem konkrétního stavu souboru.

Nemění však Document ID.

Při přejmenování nebo přesunu je potřeba zachovat:

- historii souboru,
- stejné Document ID,
- aktualizované odkazy,
- záznam v historii verzí.

---


## 17.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „17. Vazba na Git“ v rámci dokumentu MM-STD-007 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „18. Kontrola před vytvořením dokumentu“, která rozvíjí další část řízeného dokumentu.

# 18. Kontrola před vytvořením dokumentu

Nový dokument může vzniknout pouze tehdy, když jsou ověřeny body:

- [ ] Je skutečně potřeba nový samostatný dokument.
- [ ] Existující dokument nepokrývá stejný účel.
- [ ] Typ dokumentu je správný.
- [ ] Prefix je registrovaný.
- [ ] Číslo je volné nebo rezervované pro tento účel.
- [ ] ID není historickým aliasem.
- [ ] ID se nenachází v archivu.
- [ ] ID se nenachází v dokumentační databázi pro jiný dokument.
- [ ] Kanonická složka je určena.
- [ ] Název souboru odpovídá MM-STD-004.
- [ ] Dokument bude zapsán do příslušného indexu.

---


## 18.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „18. Kontrola před vytvořením dokumentu“ v rámci dokumentu MM-STD-007 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „19. Kontrola existující dokumentace“, která rozvíjí další část řízeného dokumentu.

# 19. Kontrola existující dokumentace

Při auditu identit se kontroluje:

- duplicitní Document ID,
- více aktivních souborů,
- historické aliasy používané jako aktivní ID,
- čísla verzí v aktivních názvech,
- prefix odvozený chybně ze složky,
- chybějící indexace,
- chybějící databázová evidence,
- kolize mezi aktivní složkou a archivem,
- chybné datum nebo pořadí u `MM-DL`, `MM-NAV` a `MM-EXP`.

---


## 19.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „19. Kontrola existující dokumentace“ v rámci dokumentu MM-STD-007 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „20. Výjimky“, která rozvíjí další část řízeného dokumentu.

# 20. Výjimky

Výjimka z tohoto standardu musí být:

- výslovná,
- zdokumentovaná,
- schválená,
- časově nebo věcně ohraničená,
- bez kolize s existující identitou.

Výjimka nesmí umožnit:

- opětovné použití starého ID,
- dvě aktivní identity téhož dokumentu,
- tiché přečíslování publikovaného dokumentu,
- přidělení prefixu pouze podle složky.

---


## 20.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „20. Výjimky“ v rámci dokumentu MM-STD-007 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost směřuje k závěru dokumentu a k navazujícím kontextovým, auditním a publikačním krokům.

# 21. Závěr

Identifikační systém MatchMatrix je založen na oddělení čtyř věcí:

1. Document ID,
2. typu dokumentu,
3. názvu a umístění souboru,
4. verze a stavu.

Document ID je dlouhodobá identita.

Složka není identita.

Nová verze není nový dokument.

Historický alias není volné číslo.

Již zavedené identity hlavních dokumentů se zachovávají a tvoří základ dokumentační architektury MatchMatrix.

---

# AI CONTEXT

**Role dokumentu:** Závazný registr pravidel pro přidělování a ochranu Document ID.

**Hlavní pravidlo:** Složka neurčuje prefix. Document ID se zachovává napříč verzemi, stavy a přesuny.

**Zavedené hlavní identity:** `MM-DOC-000`, `100`, `200`, `300`, `800`, `900`, `1000`.

**Historické pracovní identity:** `MM-DOC-001` až `005` a `MM-DOC-090` se nesmějí znovu použít, pokud již označovaly existující dokument.

**Časové typy:** `MM-DL-YYYYMMDD`, `MM-NAV-YYYYMMDD-NN`, `MM-EXP-YYYYMMDD-NN`.

**Nový prefix:** Smí vzniknout pouze změnou standardu a registru, nikoli automaticky podle názvu složky.

---

# PROJECT SNAPSHOT

- Hlavní dokumenty byly sjednoceny pod stabilními ID `MM-DOC-000`, `100`, `200`, `300`, `800` a `900`.
- Původní REVIEW varianty již nejsou druhými aktivními zdroji.
- Aktivní názvy neobsahují číslo verze.
- Historické pracovní identity jsou evidovány jako aliasy.
- `MM-TPL-001` a `MM-TPL-002` jsou zavedené oficiální šablony.
- `MM-STD-001` až `MM-STD-009` tvoří aktuální sadu základních standardů.
- `MM-STD-1000` je centrální index standardů.

---

# CURRENT STATUS

- Stable Document ID: ACTIVE
- Main Document Registry: ACTIVE
- Time-Based IDs: ACTIVE
- Prefix Registry: ACTIVE
- Historical Alias Handling: ACTIVE
- Automated Collision Detection: PARTIAL
- Documentation Database Synchronization: ACTIVE / REQUIRES AUDIT

---

# OPEN QUESTIONS

- úplný databázový registr všech historických aliasů,
- automatické blokování znovupoužití archivního ID,
- automatické přidělování nového čísla podle typu,
- přesný budoucí registr hlavních dokumentů v blocích 400–799,
- sjednocení případných dalších neřízených prefixů v repozitáři.

---

# NEXT STEP

Aktualizovat `MM-STD-1000`, aby evidoval standardy `MM-STD-001` až `MM-STD-009`, jejich aktuální verze, stav a vzájemné návaznosti.
