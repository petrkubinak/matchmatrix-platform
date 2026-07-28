# MM-DOC-900

# MATCHMATRIX DENNÍ ZÁPISY

## TECH EDITION

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-DOC-900 |
| Název | MatchMatrix Denní zápisy |
| Edice | MM-DOC TECH |
| Verze | 1.2 |
| Stav | REVIEW |
| Datum aktualizace | 2026-07-27 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Primární formát | Markdown (`.md`) |
| Aktivní soubor | `docs/09_HISTORY/MM-DOC-900_MATCHMATRIX_DENNÍ_ZÁPISY_TECH.md` |
| Historické pracovní označení | MM-DOC-005 |

---

## Historie verzí

| Verze | Datum | Stav | Popis |
|---:|---|---|---|
| 1.0 | 2026-06 | Rozpracováno | Původní pracovní verze vedená pod historickým označením MM-DOC-005. |
| 1.1 | 2026-06-29 | REVIEW | Opravená REVIEW verze se stabilní identitou MM-DOC-900, rozšířenou strukturou a návazností na NAV dokumenty. |
| 1.2 | 2026-07-27 | REVIEW | Aktualizace podle skutečného Q3 workflow, oficiálních šablon MM-TPL-001 a MM-TPL-002, automatického číslování, blokace duplicit, AI Context workflow a ověřené historie projektové komunikace. Doplněna formální hierarchie a závěry hlavních kapitol podle výsledku A17 ze dne 2026-07-28. |

---

## Úvod a účel dokumentu
Tento dokument stanovuje závazný způsob vytváření, kontroly, schvalování, archivace a využívání denních zápisů projektu MatchMatrix.

Současně vymezuje jejich vztah k:

- dokumentům NAVÁZÁNÍ do nového chatu,
- Project Snapshotu,
- AI Contextu,
- Git historii,
- databázovým auditům,
- dokumentační databázi,
- oficiálním šablonám,
- panelu Q3,
- hlavním dokumentům MatchMatrix.

Dokument neobsahuje jednotlivé denní zápisy. Stanovuje pravidla, podle kterých vznikají.

---

## Související dokumenty a šablony

- `MM-DOC-000` – MatchMatrix Documentation Framework
- `MM-DOC-100` – MatchMatrix Master
- `MM-DOC-200` – MatchMatrix Governance
- `MM-DOC-300` – MatchMatrix Architecture
- `MM-DOC-800` – MatchMatrix Development Handbook
- `MM-STD-003` – Standard životního cyklu dokumentace a verzování
- `MM-STD-007` – Identifikace a číslování dokumentů
- `MM-STD-009` – AI Context a Project Snapshot
- `MM-REF-001` – Slovník pojmů MatchMatrix
- `MM-TPL-001_SABLONA_NAVAZANI_DO_NOVEHO_CHATU.md`
- `MM-TPL-002_SABLONA_DENNIHO_ZAPISU.md`

---

# Motto

> **Každý pracovní den končí ověřeným zápisem. Každý nový pracovní blok na něj bezpečně navazuje.**

---

# Obsah

0. Smysl denních zápisů
1. Role pracovní paměti projektu
2. Typy historických a kontextových dokumentů
3. Základní principy
4. Odpovědnost člověka a AI
5. Kdy denní zápis vzniká
6. Identifikace, názvy a umístění
7. Povinná struktura denního zápisu
8. Povinná struktura dokumentu NAVÁZÁNÍ
9. Vytváření z průběhu komunikace
10. Ověřování informací
11. Q3 dokumentační workflow
12. Pravidla obsahu
13. Rozlišení dokončené, validované a otevřené práce
14. Git a databázový stav
15. Project Snapshot, Database Snapshot a AI Context
16. Schvalování, verze a archivace
17. Kvalitativní pravidla
18. Vazby na hlavní dokumentaci
19. Aktuální provozní stav
20. Otevřené otázky a další krok

---

# 0. Smysl denních zápisů

Denní zápisy nejsou cílem dokumentace.

Jsou pracovním nástrojem, který chrání kontinuitu vývoje MatchMatrix a umožňuje bezpečně navázat na práci po několika hodinách, dnech, týdnech nebo v novém AI chatu.

Jejich hlavní hodnotou je schopnost přesně zachytit:

- co bylo skutečně provedeno,
- proč se daný krok provedl,
- jaký byl ověřený výsledek,
- co se nepodařilo nebo zůstalo otevřené,
- jaká rozhodnutí byla přijata,
- který krok má následovat,
- co se nesmí opakovat nebo zaměnit.

Denní zápis není volná poznámka. Je to řízený historický dokument.

---


## 0.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „0. Smysl denních zápisů“ v rámci dokumentu MM-DOC-900 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „1. Role pracovní paměti projektu“, která rozvíjí další část řízeného dokumentu.

# 1. Role pracovní paměti projektu

Projekt MatchMatrix obsahuje rozsáhlou databázi, stovky dokumentů, velké množství skriptů, více sportů, různé providery a dlouhé pracovní etapy.

Bez řízené pracovní paměti by vznikalo riziko:

- opakování již dokončených kroků,
- zaměnění validace za trvalou změnu,
- ztráty důvodu rozhodnutí,
- používání zastaralých počtů,
- spuštění nesprávného skriptu,
- navázání na neaktuální dokument,
- ztráty vazby mezi databází, Git historií a dokumentací.

Pracovní paměť projektu tvoří společně:

1. denní zápisy,
2. dokumenty NAVÁZÁNÍ,
3. Project Snapshot,
4. Database Snapshot,
5. AI Context,
6. aktivní hlavní dokumentace,
7. Git historie,
8. databázové a dokumentační audity.

Žádný z těchto zdrojů se nemá používat izolovaně, pokud je pro dané rozhodnutí dostupný novější a spolehlivější důkaz.

---


## 1.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „1. Role pracovní paměti projektu“ v rámci dokumentu MM-DOC-900 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „2. Typy historických a kontextových dokumentů“, která rozvíjí další část řízeného dokumentu.

# 2. Typy historických a kontextových dokumentů

## 2.1 Denní zápis

Denní zápis zachycuje práci provedenou v konkrétní den.

Odpovídá zejména na otázky:

- Jaký byl výchozí stav?
- Jaký byl cíl dne?
- Co se skutečně provedlo?
- Jaké byly výsledky?
- Jaká rozhodnutí vznikla?
- Jaké problémy se řešily?
- Co zůstalo nedokončeno?
- Jaký je jediný hlavní další krok?

Denní zápis je podrobným historickým zdrojem.

## 2.2 Dokument NAVÁZÁNÍ

Dokument NAVÁZÁNÍ předává aktuální stav do nového chatu nebo další pracovní etapy.

Není kopií denního zápisu.

Jeho úkolem je vytvořit praktický přenosový balíček obsahující:

- aktuální stav,
- dokončené kroky,
- otevřené úkoly,
- rozhodnutí,
- rizika,
- důležité identifikátory,
- Project Snapshot,
- Database Snapshot,
- AI Context,
- přesný další krok,
- seznam věcí, které se nemají opakovat.

NAV dokument může vzniknout na konci dne, při uzavření větší etapy nebo před přechodem do nového chatu.

## 2.3 Project Snapshot

Project Snapshot je stručný ověřený obraz aktuálního projektu nebo pracovní oblasti.

Má vyšší provozní hodnotu než starý denní zápis, pokud:

- je novější,
- vychází z ověřených zdrojů,
- výslovně aktualizuje starší stav.

## 2.4 Database Snapshot

Database Snapshot obsahuje relevantní databázové objekty a kontrolní počty platné v okamžiku vytvoření dokumentu.

Každý počet musí být chápán jako snapshot, nikoli jako trvalá konstanta.

## 2.5 AI Context

AI Context vysvětluje:

- roli dokumentu,
- aktivní oblast,
- závazná pravidla,
- kritické hranice,
- význam aktuálního stavu pro další práci.

AI Context nemá nahrazovat celý dokument. Má umožnit rychlou a bezpečnou orientaci.

---


## 2.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „2. Typy historických a kontextových dokumentů“ v rámci dokumentu MM-DOC-900 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „3. Základní principy“, která rozvíjí další část řízeného dokumentu.

# 3. Základní principy

## 3.1 Zapisuje se skutečnost

Do denního zápisu patří pouze:

- skutečně provedená práce,
- skutečně zjištěné výsledky,
- skutečně přijatá rozhodnutí,
- skutečně otevřené problémy.

Plánovaný krok se nesmí popsat jako dokončený.

## 3.2 Důležitý je výsledek i důvod

Nestačí uvést, že byl vytvořen soubor nebo spuštěn skript.

Zápis má podle významu vysvětlit:

- proč krok vznikl,
- jaký problém řešil,
- jak byl ověřen,
- co změnil,
- co nezměnil,
- na co navazuje.

## 3.3 Rozlišují se stavy

Každý významný krok musí být správně označen, například:

- připraveno,
- analyzováno,
- ověřeno READ ONLY auditem,
- úspěšně validováno,
- rollback potvrzen,
- trvale aplikováno,
- auditně uzavřeno,
- importováno,
- publikováno,
- zůstává otevřené.

## 3.4 Jeden hlavní další krok

Zápis může obsahovat více otevřených úkolů, ale na konci určuje jeden hlavní následující krok.

Ten má být:

- konkrétní,
- proveditelný,
- bezpečně ohraničený,
- v souladu s aktuálním stavem.

## 3.5 Nepřepisuje se historie

Schválený denní zápis se svévolně nepřepisuje.

Pokud je před schválením nalezena chyba, opraví se v řízeném workflow.

Pokud je chyba nalezena až později, musí být oprava dohledatelná prostřednictvím nové verze, opravného zápisu nebo následného dokumentu, podle povahy dokumentu a pravidel životního cyklu.

## 3.6 Starší dokument není automaticky pravda

Denní zápis je správný pro okamžik svého vzniku.

Pozdější audit, APPLY nebo Project Snapshot může jeho stav změnit.

Novější ověřený stav má přednost, ale starší zápis zůstává historickým důkazem vývoje.

---


## 3.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „3. Základní principy“ v rámci dokumentu MM-DOC-900 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „4. Odpovědnost člověka a AI“, která rozvíjí další část řízeného dokumentu.

# 4. Odpovědnost člověka a AI

## 4.1 Role ChatGPT

ChatGPT vytváří návrh denního zápisu a NAV dokumentu přímo z průběhu pracovní komunikace.

Má zejména:

- sledovat provedené kroky,
- zachytit výstupy příkazů a auditů,
- rozlišit plán od skutečnosti,
- správně popsat READ ONLY, VALIDATE ONLY a APPLY,
- vyhledat přijatá rozhodnutí,
- zaznamenat problémy a jejich řešení,
- vytvořit přesný Project Snapshot a Database Snapshot,
- uvést otevřené úkoly a jediný další krok,
- použít správnou šablonu, Document ID a umístění.

ChatGPT nemá čekat, že uživatel ručně vyplní desítky technických polí, rekonstruuje Git snapshot nebo přepisuje průběh celého dne do formuláře.

## 4.2 Role uživatele

Uživatel:

- potvrzuje věcnou správnost,
- upozorňuje na chybějící nebo nesprávnou informaci,
- schvaluje výsledný dokument,
- rozhoduje o sporných nebo neověřitelných skutečnostech,
- provádí lokální uložení, audit, import, commit a další kroky podle workflow.

## 4.3 AI nesmí doplňovat domněnky jako fakta

Pokud není informace ověřena, musí být:

- označena jako otevřená,
- označena jako předpoklad,
- vynechána,
- nebo určena k následnému ověření.

AI nesmí vymyslet:

- výsledek příkazu,
- stav Git commitu,
- databázový počet,
- provedený APPLY,
- identitu entity,
- rozhodnutí uživatele.

---


## 4.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „4. Odpovědnost člověka a AI“ v rámci dokumentu MM-DOC-900 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „5. Kdy denní zápis vzniká“, která rozvíjí další část řízeného dokumentu.

# 5. Kdy denní zápis vzniká

Denní zápis se vytváří:

- na konci pracovního dne,
- při uzavření významného pracovního bloku,
- při výslovném požadavku uživatele,
- před dlouhou přestávkou, pokud je potřeba zachovat stav.

Pro jeden kalendářní den má standardně existovat jeden kanonický denní zápis projektu.

Pokud práce pokračuje v několika chatech během stejného dne, informace se mají sloučit do jednoho zápisu, nikoli vytvářet konkurenční kopie.

Panel Q3 proto blokuje vytvoření duplicitního denního zápisu pro stejné datum, pokud již kanonický dokument existuje.

---


## 5.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „5. Kdy denní zápis vzniká“ v rámci dokumentu MM-DOC-900 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „6. Identifikace, názvy a umístění“, která rozvíjí další část řízeného dokumentu.

# 6. Identifikace, názvy a umístění

## 6.1 Denní zápis

Formát Document ID:

```text
MM-DL-YYYYMMDD
```

Příklad:

```text
MM-DL-20260726
```

Doporučený název souboru:

```text
MM-DL-20260726_MATCHMATRIX_DENNI_ZAPIS.md
```

Kanonické umístění:

```text
docs/09_HISTORY/DENNÍ_ZÁPISY/
```

V názvu souboru se podle technických možností může používat varianta bez diakritiky, ale Document ID a datum musí být jednoznačné.

## 6.2 NAV dokument

Formát Document ID:

```text
MM-NAV-YYYYMMDD-NN
```

Příklad:

```text
MM-NAV-20260726-01
```

Doporučený název souboru:

```text
MM-NAV-20260726-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md
```

Kanonické umístění:

```text
docs/09_HISTORY/NAVÁZÁNÍ_NA_CHAT/
```

Pořadové číslo `NN` umožňuje více NAV dokumentů v jednom dni.

Panel Q3 při tvorbě NAV automaticky zjistí existující dokumenty a přidělí další pořadové číslo.

## 6.3 Oficiální šablony

Denní zápis používá:

```text
docs/13_TEMPLATES/MM-TPL-002_SABLONA_DENNIHO_ZAPISU.md
```

NAV dokument používá:

```text
docs/13_TEMPLATES/MM-TPL-001_SABLONA_NAVAZANI_DO_NOVEHO_CHATU.md
```

Šablona určuje strukturu. Konkrétní obsah se vytváří z ověřeného průběhu práce.

---


## 6.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „6. Identifikace, názvy a umístění“ v rámci dokumentu MM-DOC-900 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „7. Povinná struktura denního zápisu“, která rozvíjí další část řízeného dokumentu.

# 7. Povinná struktura denního zápisu

Rozsah kapitol se přizpůsobuje skutečné práci, ale kanonický denní zápis má obsahovat následující oblasti.

## 7.1 Informace o dokumentu

Minimálně:

- Document ID,
- název,
- typ dokumentu,
- verze,
- stav,
- datum,
- autor,
- pracovní oblast,
- primární formát,
- kanonické umístění,
- použitá šablona.

## 7.2 Identifikace denního zápisu

Obsahuje:

- datum pracovního dne,
- aktivní projekt,
- aktivní oblast,
- výchozí dokument nebo NAV,
- relevantní databázi,
- relevantní Git větev,
- hlavní cíl.

## 7.3 Výchozí stav

Popisuje:

- poslední ověřený stav,
- dokončené předchozí kroky,
- otevřené úkoly,
- bezpečnostní hranice,
- kroky, které se nesmějí opakovat.

## 7.4 Cíle pracovního dne

Uvádí skutečně zamýšlené cíle, ale nesmí je předem označit za dokončené.

## 7.5 Provedené práce

Je hlavní částí dokumentu.

Má být členěna podle významných etap a obsahovat:

- použitý nástroj nebo skript,
- režim,
- vstupní rozsah,
- důležitý výstup,
- ověření,
- dopad,
- návaznost.

## 7.6 Hlavní výsledky dne

Stručně shrnuje:

- dokončené milníky,
- ověřené počty,
- vytvořené artefakty,
- potvrzené stavy.

## 7.7 Přijatá rozhodnutí

Každé významné rozhodnutí se uvádí samostatně.

Má být zřejmé:

- co bylo rozhodnuto,
- proč,
- jaký má rozhodnutí dopad,
- zda je dočasné nebo dlouhodobé.

## 7.8 Problémy a jejich řešení

Uvádí:

- problém,
- příčinu,
- diagnostiku,
- opravu,
- výsledek,
- případné zbývající riziko.

## 7.9 Databázový, Git a dokumentační stav

Podle relevantnosti obsahuje:

- databázový snapshot,
- větev a commit,
- informaci o pushi,
- stav pracovního stromu,
- stav dokumentační databáze,
- výsledky A17, A24, A6 nebo A7.

## 7.10 Rizika a otevřené otázky

Uvádí pouze skutečně otevřené problémy.

## 7.11 Nedokončené práce

Musí jasně rozlišit:

- připravené, ale nespouštěné kroky,
- pouze validované kroky,
- blokované kroky,
- odložené úkoly.

## 7.12 Plán pokračování

Obsahuje doporučené pořadí dalších kroků.

## 7.13 Jediný hlavní další krok

Je praktickým výstupem zápisu.

## 7.14 Vazba na NAV dokument

Uvádí, zda:

- NAV dokument není potřeba,
- má být vytvořen,
- byl vytvořen,
- nebo byl aktualizován.

## 7.15 Související dokumenty, skripty a databázové objekty

Uvádí pouze relevantní vazby, ne mechanický seznam všeho v projektu.

## 7.16 Terminologická kontrola

Použité odborné termíny mají odpovídat `MM-REF-001`.

## 7.17 Historie verzí a závěr

Každý dokument obsahuje svou verzi, stav a stručný závěr.

---


## 7.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „7. Povinná struktura denního zápisu“ v rámci dokumentu MM-DOC-900 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „8. Povinná struktura dokumentu NAVÁZÁNÍ“, která rozvíjí další část řízeného dokumentu.

# 8. Povinná struktura dokumentu NAVÁZÁNÍ

NAV dokument je určen pro rychlé a bezpečné pokračování práce.

Musí obsahovat zejména:

## 8.1 Informace o dokumentu a identifikaci

- Document ID,
- datum,
- pořadí NAV v daném dni,
- pracovní oblast,
- zdrojový denní zápis,
- předchozí NAV,
- šablonu,
- kanonické umístění.

## 8.2 Účel navázání

Jednou až několika větami určuje, proč dokument vznikl a na co má nový chat navázat.

## 8.3 Terminologie

Obsahuje vysvětlení kritických technických pojmů používaných v dokumentu.

## 8.4 Aktuální stav

Odděluje podle potřeby:

- dokumentační stav,
- Git stav,
- databázový stav,
- technický stav projektu.

## 8.5 Project Snapshot

Stručně zachycuje aktivní projektovou oblast a dokončený milník.

## 8.6 Database Snapshot

Obsahuje kontrolní počty a relevantní objekty.

## 8.7 Přijatá rozhodnutí

Nový chat je nesmí znovu otevírat bez nového důkazu nebo uživatelského rozhodnutí.

## 8.8 Otevřené úkoly

Mají mít stav, prioritu a podmínku dokončení.

## 8.9 Otevřené otázky

Musí být formulovány tak, aby je bylo možné zodpovědět auditem nebo rozhodnutím.

## 8.10 Next Step

Obsahuje bezprostřední další krok.

## 8.11 Co bylo dokončeno

Chrání projekt před opakováním uzavřené práce.

## 8.12 Co zůstává rozpracováno

Zabraňuje tomu, aby příprava nebo validace byla považována za dokončený stav.

## 8.13 Co se nemá opakovat

Tato sekce je povinná, pokud by opakování mohlo poškodit data nebo ztratit čas.

## 8.14 AI Context

Musí vysvětlit pravidla a hranice potřebné pro nový chat.

## 8.15 Kritické identifikátory a objekty

Podle potřeby obsahuje:

- ID soutěží,
- ID týmů,
- ID zápasů,
- názvy tabulek,
- názvy skriptů,
- očekávané počty.

## 8.16 Doporučené pořadí pokračování

Má respektovat governance a bezpečnostní workflow.

---


## 8.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „8. Povinná struktura dokumentu NAVÁZÁNÍ“ v rámci dokumentu MM-DOC-900 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „9. Vytváření z průběhu komunikace“, která rozvíjí další část řízeného dokumentu.

# 9. Vytváření z průběhu komunikace

Denní zápis a NAV dokument se nevytvářejí primárně ručním vyplněním formuláře.

ChatGPT při práci průběžně získává podklady z:

- uživatelských pokynů,
- výstupů PowerShellu,
- výstupů SQL,
- auditních protokolů,
- Git stavu,
- přiložených souborů,
- schválených rozhodnutí,
- oprav a připomínek uživatele.

Na konci pracovního bloku z těchto podkladů sestaví souvislý dokument.

## 9.1 Co se nemá vyžadovat od uživatele

Uživatel nemá být nucen ručně doplňovat:

- desítky technických polí,
- všechny názvy skriptů, které již zazněly v chatu,
- Git snapshot, který lze zjistit z výstupu,
- databázové počty, které byly ověřeny auditem,
- znovu informace, které již poskytl,
- formulářový přepis celého pracovního dne.

## 9.2 Kdy je potřeba uživatelská oprava

Uživatel doplňuje nebo opravuje zejména:

- obchodní nebo strategické rozhodnutí,
- skutečnost, kterou nelze ověřit technickým výstupem,
- nesprávně pochopený význam kroku,
- chybějící důležitou souvislost,
- požadovaný datum nebo pracovní oblast, pokud nejsou jednoznačné.

---


## 9.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „9. Vytváření z průběhu komunikace“ v rámci dokumentu MM-DOC-900 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „10. Ověřování informací“, která rozvíjí další část řízeného dokumentu.

# 10. Ověřování informací

## 10.1 Hierarchie důvěryhodnosti

Pro technický stav se používá zejména toto pořadí:

1. aktuální databázový audit nebo přímý read-only dotaz,
2. skutečný stav repozitáře a souborů,
3. výstup právě provedeného skriptu,
4. novější ověřený Project Snapshot,
5. aktivní řízená dokumentace,
6. denní zápis a NAV dokument odpovídající době svého vzniku,
7. historie chatu,
8. neověřená domněnka.

Pořadí se může lišit podle povahy informace, ale novější ověřený důkaz má přednost před starším tvrzením.

## 10.2 Historie chatu jako důkazní zdroj

Historie komunikace obsahuje rozhodnutí, výsledky a souvislosti, které nemusely být okamžitě promítnuty do hlavní dokumentace.

Proto byla vytvořena extrakční matice historie chatů.

Informace z ní se musí:

- posoudit,
- ověřit,
- časově zařadit,
- porovnat s novějšími zdroji,
- teprve potom přenést do aktivní dokumentace.

## 10.3 Relativní čas

Výrazy jako „dnes“, „včera“ nebo „zítra“ se v dokumentu nahrazují konkrétním datem, pokud by později mohly být nejasné.

---


## 10.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „10. Ověřování informací“ v rámci dokumentu MM-DOC-900 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „11. Q3 dokumentační workflow“, která rozvíjí další část řízeného dokumentu.

# 11. Q3 dokumentační workflow

Denní zápisy a NAV dokumenty procházejí řízeným workflow Q3.

## 11.1 Fáze

1. **VYBRAT A ANALYZOVAT**
2. **OPRAVIT A ZKONTROLOVAT**
3. **VYTVOŘIT A SCHVÁLIT**
4. **PUBLIKOVAT**

## 11.2 Nástroje

- A17 – audit standardu dokumentu,
- A18 – standardizační návrh,
- A19 – kontrola mapování,
- A20 – builder,
- A24 – import do dokumentační databáze,
- A6 a A7 – následné kontroly integrity a správnosti.

## 11.3 Tvorba ze šablon

Panel Q3 podporuje vytvoření:

- denního zápisu z `MM-TPL-002`,
- NAV dokumentu z `MM-TPL-001`.

Šablona poskytuje strukturu. Skutečný obsah musí vycházet z průběhu práce.

## 11.4 Blokace duplicitního denního zápisu

Pokud pro dané datum již existuje kanonický `MM-DL-YYYYMMDD`, panel nesmí bez řízeného důvodu vytvořit druhý konkurenční zápis.

## 11.5 Automatické číslování NAV

Panel určuje další pořadové číslo `NN` podle již existujících NAV dokumentů stejného data.

## 11.6 Blokace A17

A17 se nesmí spustit nad neúplným dokumentem, pokud chybějí povinná pole nebo zásadní sekce.

Cílem není mechanicky projít audit, ale zabránit publikaci dokumentu, který není použitelný pro navázání.

## 11.7 A24

A24 nejprve používá `VALIDATE_ONLY`.

Teprve po úspěšné validaci a splnění podmínek se provádí `APPLY`.

Dokumentační import se standardně provádí nad čistým Git stromem. Výjimka nesmí obcházet governance bez výslovného rozhodnutí.

---


## 11.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „11. Q3 dokumentační workflow“ v rámci dokumentu MM-DOC-900 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „13. Rozlišení dokončené, validované a otevřené práce“, která rozvíjí další část řízeného dokumentu.

# 12. Pravidla obsahu

## 12.1 Co zapisovat

Do denního zápisu patří zejména:

- významné databázové změny,
- výsledky auditů,
- nové nebo opravené skripty,
- změny architektury,
- providerová rozhodnutí,
- mapování entit,
- změny dokumentace,
- důležité testy,
- Git milníky,
- problémy a jejich řešení,
- bezpečnostní hranice,
- otevřené úkoly.

## 12.2 Co běžně nezapisovat

Obvykle se nezapisují:

- každé kliknutí,
- opakované spuštění bez nového výsledku,
- bezvýznamný překlep,
- krátký experiment bez dopadu,
- interní technické mezikroky asistenta,
- informace, které nemají význam pro pokračování projektu.

Výjimkou je situace, kdy drobný problém odhalil důležité systémové pravidlo nebo riziko.

## 12.3 Přiměřený rozsah

Rozsah závisí na skutečné práci:

- běžný den: přibližně 1 až 3 strany,
- významná technická etapa: přibližně 5 až 10 stran,
- mimořádně rozsáhlý den: podle potřeby.

Cílem není uměle dosáhnout určitého počtu stran.

---

# 13. Rozlišení dokončené, validované a otevřené práce

Toto rozlišení je závazné.

## 13.1 READ ONLY

Znamená, že byl ověřen stav bez trvalé změny.

## 13.2 VALIDATE ONLY

Znamená, že změnová logika byla provedena v transakci a následně vrácena rollbackem.

Úspěšný `VALIDATE_ONLY` potvrzuje připravenost, nikoli trvalou změnu dat.

## 13.3 APPLY

Znamená, že schválená změna byla trvale provedena a commitnuta.

## 13.4 Post-commit audit

Teprve samostatný audit po APPLY potvrzuje skutečný stav po změně.

## 13.5 Příklad správného zápisu

```text
VALIDATE_ONLY pro 110 zápasů úspěšně dokončen.
Transakce byla vrácena rollbackem.
Trvalý APPLY zatím nebyl proveden.
```

## 13.6 Příklad nesprávného zápisu

```text
110 zápasů bylo migrováno.
```

Tato věta je nesprávná, pokud proběhl pouze `VALIDATE_ONLY`.

---


## 13.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „13. Rozlišení dokončené, validované a otevřené práce“ v rámci dokumentu MM-DOC-900 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „14. Git a databázový stav“, která rozvíjí další část řízeného dokumentu.

# 14. Git a databázový stav

## 14.1 Git stav

Zápis má podle významu uvést:

- větev,
- commit,
- obsah commitu,
- stav push,
- zda je pracovní strom čistý,
- které změny zůstávají necommitnuté.

Nesmí se tvrdit, že push proběhl, pokud byl potvrzen pouze lokální commit.

## 14.2 Dočasné soubory

Před publikací se kontrolují zejména:

- soubory Wordu `~$...`,
- náhodné kopie,
- neřízené exporty,
- tajné údaje,
- pracovní soubory mimo určenou složku.

## 14.3 Databázový stav

Uvádějí se pouze relevantní objekty a počty.

Každý počet má obsahovat nebo umožnit odvodit:

- kdy byl ověřen,
- kterým auditem,
- před nebo po jaké změně,
- zda je globální nebo omezený na konkrétní scope.

## 14.4 Dokumentační databáze

Pokud dokument prošel importem, uvádí se:

- režim A24,
- výsledek validace,
- výsledek APPLY,
- výsledek A6 a A7,
- případné blokace A17.

---


## 14.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „14. Git a databázový stav“ v rámci dokumentu MM-DOC-900 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „15. Project Snapshot, Database Snapshot a AI Context“, která rozvíjí další část řízeného dokumentu.

# 15. Project Snapshot, Database Snapshot a AI Context

## 15.1 Povinnost

Rozsáhlejší denní zápis nebo NAV dokument má obsahovat odpovídající kontextové sekce, zejména pokud se používá pro nový chat.

## 15.2 Project Snapshot

Má být stručný a zaměřený na:

- aktivní projekt,
- aktivní oblast,
- dokončený milník,
- aktuální prioritu,
- pracovní pravidla,
- zakázané zkratky.

## 15.3 Database Snapshot

Má obsahovat pouze počty a objekty potřebné pro pokračování.

Nemá bez důvodu kopírovat celý A33 audit.

## 15.4 AI Context

Má upozornit zejména na:

- rozdíly mezi dokončeným a otevřeným stavem,
- důležité identity,
- kroky, které se nesmějí opakovat,
- očekávaný další postup,
- zdroje pravdy.

---


## 15.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „15. Project Snapshot, Database Snapshot a AI Context“ v rámci dokumentu MM-DOC-900 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „16. Schvalování, verze a archivace“, která rozvíjí další část řízeného dokumentu.

# 16. Schvalování, verze a archivace

## 16.1 Návrh

Nově vytvořený dokument vzniká ve stavu odpovídajícím dokumentačnímu workflow, typicky:

```text
DRAFT – NEEDS_USER_APPROVAL
```

nebo jiném aktuálně definovaném návrhovém stavu.

## 16.2 Uživatelské schválení

Uživatel potvrzuje, že dokument věcně odpovídá skutečné práci.

## 16.3 Audit

Dokument prochází A17 a případně dalšími kontrolami.

## 16.4 Publikace

Po úspěšné kontrole následuje:

- uložení do kanonické složky,
- Git historie,
- A24 VALIDATE_ONLY,
- A24 APPLY,
- A6 a A7,
- případný push.

## 16.5 Verze

Pokud je dokument před publikací opraven, zvyšuje se jeho verze podle rozsahu změny a doplňuje se historie verzí.

## 16.6 Archivace

Denní zápisy a NAV dokumenty se ukládají v historické oblasti projektu a nemažou se jako běžné pracovní soubory.

Duplicitní, chybné nebo nahrazené pracovní varianty se řeší řízeným archivem tak, aby zůstal jednoznačný kanonický dokument.

---


## 16.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „16. Schvalování, verze a archivace“ v rámci dokumentu MM-DOC-900 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „17. Kvalitativní pravidla“, která rozvíjí další část řízeného dokumentu.

# 17. Kvalitativní pravidla

Kvalitní denní zápis nebo NAV dokument je:

- věcně správný,
- časově jednoznačný,
- dostatečně podrobný,
- čitelný bez znalosti celého chatu,
- přehledně strukturovaný,
- bez zbytečného opakování,
- konzistentní se slovníkem,
- přesný v režimech a počtech,
- použitelný pro další práci,
- propojený s důkazními zdroji.

## 17.1 Zakázané chyby

Dokument nesmí:

- označit plán jako výsledek,
- zaměnit rollback za APPLY,
- uvést neověřený commit nebo push,
- znovu otevřít uzavřené rozhodnutí bez důvodu,
- použít historické ID jako aktivní identitu,
- obsahovat nejasné relativní datum,
- vytvořit druhý aktivní dokument se stejnou identitou,
- skrýt důležité riziko.

---


## 17.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „17. Kvalitativní pravidla“ v rámci dokumentu MM-DOC-900 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „18. Vazby na hlavní dokumentaci“, která rozvíjí další část řízeného dokumentu.

# 18. Vazby na hlavní dokumentaci

## MM-DOC-100 – Master

Denní zápisy zachycují praktickou realizaci strategie.

Strategické rozhodnutí s dlouhodobou platností se následně promítne do Master dokumentu.

## MM-DOC-200 – Governance

Nové závazné pravidlo nebo bezpečnostní rozhodnutí se zaznamená v denním zápisu a následně promítne do Governance.

## MM-DOC-300 – Architecture

Ověřená architektonická změna se nejprve objeví v pracovním zápisu a následně v Architecture dokumentu.

## MM-DOC-800 – Development Handbook

Opakovatelný pracovní postup, který se stal standardem, se promítne do Development Handbooku.

## MM-DOC-000 – Documentation Framework

Změna dokumentačního systému, workflow nebo vztahu mezi dokumenty se promítne do Documentation Frameworku.

## MM-REF-001 – Slovník

Nový termín nebo změna významu se předává do řízené terminologické správy.

---


## 18.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „18. Vazby na hlavní dokumentaci“ v rámci dokumentu MM-DOC-900 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „19. Aktuální provozní stav“, která rozvíjí další část řízeného dokumentu.

# 19. Aktuální provozní stav

## 19.1 Oficiální šablony

V projektu existují dvě oficiální šablony:

- `MM-TPL-001` – NAVÁZÁNÍ DO NOVÉHO CHATU,
- `MM-TPL-002` – DENNÍ ZÁPIS.

## 19.2 Panel Q3

Panel Q3 podporuje:

- tvorbu denního zápisu,
- tvorbu NAV dokumentu,
- blokaci duplicitního denního zápisu,
- automatické číslování NAV,
- kontrolu povinných polí před A17,
- navazující audit a publikaci.

## 19.3 Způsob práce

Obsah dokumentu sestavuje ChatGPT z průběhu každodenní komunikace.

Uživatel nemá ručně vyplňovat rozsáhlý formulář ani technicky předvyplňovat Git a databázový snapshot, pokud jsou tyto údaje již dostupné v průběhu práce.

## 19.4 Dokumentační databáze

Aktuální ověřený snapshot dokumentační databáze:

| Ukazatel | Hodnota |
|---|---:|
| Dokumenty | 354 |
| Verze | 360 |
| Aktuální verze | 354 |
| Sekce | 7 075 |
| Vazby | 495 |
| Importní běhy | 48 |

Tyto hodnoty se při dalším ověřeném snapshotu aktualizují.

## 19.5 Historie chatů

Extrakční matice historie chatů obsahuje:

| Ukazatel | Hodnota |
|---|---:|
| Archivní konverzace | 173 |
| Projektové konverzace | 146 |
| Kandidáti důkazů | 719 |
| Kurátorované základní skutečnosti | 30 |
| Otevřené základní otázky | 4 |

Matice je podkladem pro aktualizaci hlavních dokumentů. Není samostatným automatickým zdrojem pravdy.

---


## 19.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „19. Aktuální provozní stav“ v rámci dokumentu MM-DOC-900 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „20. Otevřené otázky a další krok“, která rozvíjí další část řízeného dokumentu.

# 20. Otevřené otázky a další krok

## 20.1 Otevřené otázky

- automatické načítání Git snapshotu do denního zápisu,
- automatické vytváření Database Snapshotu z ověřených auditů,
- propojení denních zápisů s konkrétními commity,
- automatické vyhodnocení, zda je potřeba vytvořit NAV,
- plná synchronizace s Documentation Management System,
- automatické porovnání starého NAV s novějším Project Snapshotem,
- dlouhodobá pravidla pro opravné verze již publikovaných historických dokumentů.

## 20.2 Nejbližší další krok

Po aktualizaci hlavních dokumentů `MM-DOC-000`, `100`, `200`, `300`, `800` a `900`:

1. ověřit jejich metadata a stabilní názvy,
2. provést dokumentační audit,
3. sjednotit související standardy `MM-STD-003`, `004`, `007` a index `MM-STD-1000`,
4. vyřešit jednu aktivní verzi `MM-REF-001`,
5. následně provést řízený import a Git publikaci.

---


## 20.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „20. Otevřené otázky a další krok“ v rámci dokumentu MM-DOC-900 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost směřuje k závěru dokumentu a k navazujícím kontextovým, auditním a publikačním krokům.

# Závěr dokumentu

Dokument MM-DOC-900 uzavírá řízený popis oblasti řízení denních zápisů a projektové kontinuity. Shrnuje pravidla, ověřený stav, odpovědnosti a vazby, které jsou potřebné pro další bezpečnou práci v projektu MatchMatrix. Přínos dokumentu spočívá v jednotném a dohledatelném zachycení této oblasti pro vývoj, audit, rozhodování a dlouhodobou správu. Návaznost pokračuje kontextovými sekcemi AI CONTEXT, PROJECT SNAPSHOT, CURRENT STATUS, OPEN QUESTIONS a NEXT STEP.

# AI CONTEXT

**Role dokumentu:** Závazný standard pro denní zápisy, NAV dokumenty a pracovní kontext MatchMatrix.

**Hlavní pravidlo:** ChatGPT sestavuje obsah z průběhu komunikace a ověřených výstupů. Uživatel kontroluje věcnou správnost a schvaluje dokument.

**Denní zápis:** `MM-DL-YYYYMMDD`, standardně jeden kanonický dokument pro den.

**NAV dokument:** `MM-NAV-YYYYMMDD-NN`, automaticky číslovaný podle pořadí v daném dni.

**Šablony:** MM-TPL-002 pro denní zápis, MM-TPL-001 pro NAV.

**Kritická hranice:** VALIDATE ONLY není APPLY. Rollback není trvalá změna.

**Zdroj pravdy:** Novější ověřený audit nebo Project Snapshot má přednost před starším denním zápisem, ale starý zápis zůstává historickým důkazem.

---

# PROJECT SNAPSHOT

- MatchMatrix používá řízené denní zápisy a NAV dokumenty jako pracovní paměť.
- Q3 panel umí vytvořit oba typy dokumentů z oficiálních šablon.
- Duplicitní denní zápis pro stejné datum je blokován.
- NAV dokumenty jsou automaticky číslovány.
- A17 je blokován, pokud dokument nemá povinná pole.
- A24 používá VALIDATE_ONLY a následný APPLY.
- ChatGPT vytváří dokumenty z průběhu práce; uživatel je věcně schvaluje.
- Historie chatů byla převedena do extrakční matice pro řízenou aktualizaci hlavní dokumentace.

---

# DATABASE SNAPSHOT

| Oblast | Stav |
|---|---|
| Dokumentační databáze | ACTIVE |
| Dokumenty | 354 |
| Verze | 360 |
| Aktuální verze | 354 |
| Sekce | 7 075 |
| Vazby | 495 |
| Importní běhy | 48 |
| Q3 workflow | IMPLEMENTED / ACTIVE DEVELOPMENT |
| Šablony MM-TPL-001 a MM-TPL-002 | ACTIVE |

---

# CURRENT STATUS

- Daily Log Standard: ACTIVE
- NAV Standard: ACTIVE
- Official Templates: ACTIVE
- Q3 Creation Workflow: IMPLEMENTED
- Duplicate Daily Log Blocking: IMPLEMENTED
- Automatic NAV Numbering: IMPLEMENTED
- A17 Required-Field Guard: IMPLEMENTED
- AI-Generated Draft from Conversation: ACTIVE
- Automated Project Snapshot: PARTIAL / FUTURE DEVELOPMENT

---

# OPEN QUESTIONS

- Jak automatizovat Project Snapshot bez ztráty lidské kontroly?
- Jak přesně verzovat opravu již publikovaného historického zápisu?
- Jak automaticky propojit denní zápis s relevantními Git commity a databázovými audity?
- Jak automaticky určit, zda pracovní blok vyžaduje nový NAV dokument?

---

# NEXT STEP

Provést kontrolu nové verze `MM-DOC-900`, uložit ji pod stabilním aktivním názvem a poté zahájit sjednocení standardů `MM-STD-003`, `MM-STD-004`, `MM-STD-007` a indexu `MM-STD-1000`.
