# MM-DOC-900

# MATCHMATRIX DENNÍ ZÁPISY (TECH)

---

## Informace o dokumentu

| Položka              | Hodnota                                                    |
| :------------------- | :--------------------------------------------------------- |
| Název dokumentu      | MATCHMATRIX DENNÍ ZÁPISY                                   |
| Označení             | MM-DOC-900                                                 |
| Edice                | TECH                                                       |
| Verze                | 1.1                                       |
| Stav                 | REVIEW                                               |
| Autor projektu       | Petr                                                       |
| Technická spolupráce | OpenAI ChatGPT                                             |
| Primární formát      | Markdown (.md)                                             |
| Umístění             | `docs/09_HISTORY/MM-DOC-900_MATCHMATRIX_DENNÍ_ZÁPISY_TECH.md` |

---

# Motto

> **Každý pracovní den končí zápisem. Každý nový den na něj navazuje.**

---

# Obsah

1. Úvod
2. Účel denních zápisů
3. Základní principy
4. Struktura denního zápisu
5. Pravidla zapisování
6. Doporučený obsah
7. Využití denních zápisů
8. Navazující dokumenty
9. Závěr

---

---

# 0. Smysl denních zápisů

Denní zápisy nejsou cílem dokumentace.

Jsou pracovním nástrojem, který chrání kontinuitu vývoje MatchMatrix.

Jejich hlavní hodnotou je schopnost přesně zachytit, co bylo skutečně provedeno, proč se tak stalo, jaký byl výsledek a čím má projekt pokračovat.

V projektu MatchMatrix mají denní zápisy zvláštní význam, protože umožňují bezpečné navazování práce mezi jednotlivými dny, pracovními etapami i novými AI chaty.

Denní zápisy tak nejsou pouze archivem.

Jsou živou pracovní pamětí projektu, která podporuje vývoj databáze, webu, aplikací, AI služeb i celé společnosti MatchMatrix.

---

# 1. Úvod

Denní zápisy představují oficiální pracovní kroniku projektu MatchMatrix.

Nejde o běžné poznámky ani pracovní seznam úkolů.

Každý zápis zachycuje skutečný stav projektu v konkrétním okamžiku a umožňuje kdykoliv přesně navázat na předchozí práci.

Díky tomuto systému není vývoj závislý na paměti jednotlivých účastníků projektu.

Veškeré důležité informace jsou průběžně zaznamenávány.

---

# 2. Účel denních zápisů

Hlavním cílem denních zápisů je zachytit vývoj projektu v průběhu času.

Každý zápis by měl odpovědět na několik základních otázek.

* Co bylo dnes provedeno?
* Jaké problémy byly řešeny?
* Jaká rozhodnutí byla přijata?
* Jaký je aktuální stav projektu?
* Na co bude navazovat další práce?

Díky těmto informacím lze projekt kdykoliv bezpečně obnovit nebo předat jinému vývojáři.

---

# 3. Filozofie denních zápisů

Denní zápisy nejsou určeny pouze pro archivaci.

Jsou aktivním pracovním nástrojem.

Každý nový pracovní den začíná přečtením posledního zápisu.

Každý pracovní den končí vytvořením nového zápisu.

Tím vzniká nepřerušený řetězec informací, který zachycuje vývoj projektu od jeho začátku až po současnost.

Denní zápisy tvoří společně s dokumentem NAVÁZÁNÍ hlavní znalostní základnu projektu.

---

# 4. Základní principy

Při vytváření denních zápisů se dodržují následující pravidla.

* Zapisují se pouze skutečně provedené práce.
* Nevynechávají se důležitá rozhodnutí.
* Popisují se i problémy a jejich řešení.
* Uvádí se důvody významných změn.
* Na konci je vždy popsán další plán práce.

Zápisy mají být stručné, ale současně dostatečně podrobné, aby podle nich bylo možné pokračovat i po delší době.

---

# Závěr první části

Denní zápisy představují základní pracovní nástroj pro řízení vývoje MatchMatrix. Umožňují zachytit průběh prací, významná rozhodnutí i aktuální stav projektu a vytvářejí souvislou historii jeho vývoje.

V další části dokumentu budou popsány doporučená struktura zápisu, jednotlivé povinné kapitoly a pravidla pro jejich vyplňování.

# 5. Struktura denního zápisu

Každý denní zápis projektu MatchMatrix používá jednotnou strukturu. Díky tomu lze rychle nalézt potřebné informace a současně je zajištěna dlouhodobá přehlednost celé historie projektu.

Jednotná struktura umožňuje snadné navazování na předchozí práci a výrazně zjednodušuje orientaci i v rozsáhlé historii vývoje.

---

# 5.1 Hlavička zápisu

Každý zápis začíná základní identifikací.

Obsahuje zejména:

* datum,
* pořadové označení zápisu,
* pracovní oblast,
* autora,
* verzi projektu.

Příklad:

```text
Datum:
Název:
Autor:
Oblast:
Verze projektu:
```

---

# 5.2 Výchozí stav

Na začátku každého zápisu je stručně popsán stav projektu před zahájením práce.

Tato část odpovídá například na otázky:

* Na čem se pracovalo naposledy?
* Jaký byl výchozí stav?
* Jaké úkoly byly otevřené?
* Jaké problémy čekaly na řešení?

Výchozí stav umožňuje velmi rychle pochopit kontext celého pracovního dne.

---

# 5.3 Provedené práce

Nejrozsáhlejší část zápisu.

Obsahuje chronologický přehled všech významných činností.

Například:

* vytvořené SQL skripty,
* nové Python workery,
* změny databáze,
* změny OPS panelu,
* nové dokumenty,
* změny architektury,
* testování,
* výsledky auditů.

Každá významnější změna by měla být stručně vysvětlena.

Nejde pouze o seznam souborů.

Důležité je uvést také důvod změny.

---

# 5.4 Přijatá rozhodnutí

Během vývoje často vznikají rozhodnutí, která ovlivňují celý projekt.

Například:

* změna architektury,
* změna workflow,
* změna provideru,
* nové standardy,
* úprava dokumentace.

Tato rozhodnutí se zapisují samostatně.

Díky tomu je lze později snadno dohledat.

---

# 5.5 Problémy

Pokud se během práce objeví problém, měl by být zaznamenán.

Nestačí pouze uvést, že nastala chyba.

Je vhodné popsat:

* příčinu,
* způsob analýzy,
* navržené řešení,
* konečný výsledek.

Takové informace často výrazně usnadní řešení podobných situací v budoucnu.

---

# 5.6 Výsledky dne

Na konci pracovní části následuje stručné shrnutí.

Například:

* co bylo dokončeno,
* co bylo odloženo,
* co bude pokračovat,
* jaký je aktuální stav.

Tato část umožňuje rychle zjistit přínos celého pracovního dne.

---

# 6. Plán pokračování

Každý denní zápis končí plánem další práce.

Tato část patří mezi nejdůležitější.

Obsahuje:

* další krok,
* otevřené úkoly,
* doporučené pořadí,
* upozornění na důležité návaznosti.

Díky tomu lze následující pracovní den začít prakticky okamžitě.

---

# 6.1 Pravidlo „jeden další krok“

Během vývoje MatchMatrix se osvědčilo jednoduché pravidlo.

Na konci zápisu se vždy určí jeden hlavní další krok.

Ne několik desítek úkolů.

Pouze hlavní směr pokračování.

To výrazně usnadňuje návrat k projektu i po delší přestávce.

---

# 6.2 Vazba na dokument NAVÁZÁNÍ

Denní zápisy zachycují průběh jednotlivých pracovních dnů.

Dokument NAVÁZÁNÍ představuje jejich shrnutí.

Proto by měl každý významnější denní zápis obsahovat informaci, zda je potřeba aktualizovat dokument NAVÁZÁNÍ.

Tím zůstávají oba dokumenty dlouhodobě synchronizované.

---

# Závěr druhé části

Jednotná struktura denních zápisů zajišťuje, že každý pracovní den je zaznamenán stejným způsobem. Díky tomu lze kdykoliv zpětně dohledat průběh vývoje projektu, přijatá rozhodnutí i důvody jednotlivých změn.

V další části dokumentu budou popsány doporučené postupy při vytváření denních zápisů, jejich návaznost na ostatní dokumentaci a způsob jejich využití při dlouhodobém řízení projektu MatchMatrix.

# 7. Doporučené postupy při vedení denních zápisů

Kvalita denních zápisů není dána jejich délkou.

Rozhodující je jejich informační hodnota.

Cílem není zaznamenat každou drobnou činnost.

Cílem je zachytit vše, co bude důležité pro pokračování projektu.

Dobře napsaný denní zápis umožňuje navázat na práci i po několika týdnech nebo měsících bez zbytečného hledání informací.

---

# 7.1 Co zapisovat

Do denních zápisů patří zejména:

* významná architektonická rozhodnutí,
* nové databázové objekty,
* vytvořené nebo upravené skripty,
* změny workflow,
* výsledky auditů,
* nové providery,
* změny dokumentace,
* důležité testy,
* problémy a jejich řešení.

Každá informace by měla mít dlouhodobou hodnotu.

---

# 7.2 Co nezapisovat

Naopak není vhodné zapisovat běžné pracovní činnosti bez dlouhodobého významu.

Například:

* drobné překlepy,
* kosmetické úpravy,
* krátké experimenty bez výsledku,
* opakované testovací spuštění,
* běžné administrativní úkony.

Tyto informace zbytečně prodlužují dokument a zhoršují jeho přehlednost.

---

# 7.3 Doporučený rozsah

Rozsah zápisu závisí na množství odvedené práce.

Obecně platí:

* běžný pracovní den – přibližně 1 až 3 strany,
* významné architektonické změny – 5 až 10 stran,
* dokončení větší etapy – podle potřeby.

Důležitější než počet stran je úplnost informací.

---

# 7.4 Jazyk zápisů

Denní zápisy jsou psány srozumitelným technickým jazykem.

Používají se celé věty.

Každá kapitola by měla být čitelná i bez znalosti předchozího kontextu.

Pokud je použit odborný pojem nebo zkratka, měla by být v projektu jednoznačně definována.

---

# 8. Vztah denních zápisů k ostatní dokumentaci

Denní zápisy nejsou izolovaným dokumentem.

Představují jednu z částí dokumentačního systému MatchMatrix.

Jsou propojeny zejména s následujícími dokumenty:

**MM-DOC-100 – MATCHMATRIX MASTER**

Obsahuje dlouhodobou strategii projektu.

Denní zápisy zachycují její praktickou realizaci.

---

**MM-DOC-200 – MATCHMATRIX GOVERNANCE**

Pokud během dne vznikne nové pravidlo nebo governance rozhodnutí, mělo by být zaznamenáno v denním zápisu a následně promítnuto do dokumentu Governance.

---

**MM-DOC-300 – MATCHMATRIX ARCHITECTURE**

Architektonické změny jsou nejprve popsány v denním zápisu.

Po jejich ověření jsou začleněny do architektonické dokumentace.

---

**MM-DOC-901 – MATCHMATRIX NAVÁZÁNÍ**

Tento dokument představuje souhrn aktuálního stavu projektu.

Vzniká na základě informací z denních zápisů.

---

**MM-DOC-902 – MATCHMATRIX CHANGELOG**

Obsahuje pouze významné změny.

Denní zápisy představují podrobnější zdroj informací.

---

# 9. Archivace denních zápisů

Denní zápisy představují oficiální historii projektu.

Z tohoto důvodu se:

* nemažou,
* nepřepisují,
* zachovávají v původní podobě.

Pokud je potřeba některou informaci opravit, provádí se oprava novým zápisem nebo novou verzí dokumentu.

Tím je zachována úplná historie vývoje projektu.

---

# 10. Závěr dokumentu

MATCHMATRIX DENNÍ ZÁPISY tvoří společně s dokumentem NAVÁZÁNÍ hlavní pracovní paměť projektu.

Jejich pravidelné vedení umožňuje dlouhodobě řídit vývoj rozsáhlé platformy bez ztráty souvislostí a bez závislosti na osobní paměti jednotlivých vývojářů.

Každý zápis zachycuje nejen provedenou práci, ale také důvody přijatých rozhodnutí a plán dalšího postupu.

Díky tomu lze kdykoliv bezpečně navázat na předchozí etapy vývoje.

---

# Stav dokumentu

**Dokument:** MM-DOC-900 – MATCHMATRIX DENNÍ ZÁPISY

**Edice:** TECH

**Verze:** 1.1 – REVIEW

**Stav:** REVIEW

---

## Navazující dokument

Dalším dokumentem dokumentační řady bude:

> **MM-DOC-901 – MATCHMATRIX NAVÁZÁNÍ (TECH)**

Tento dokument bude definovat způsob předávání aktuálního stavu projektu mezi jednotlivými pracovními etapami. Popíše strukturu navazovacích dokumentů, pravidla jejich aktualizace a doporučený obsah tak, aby bylo možné kdykoliv plynule pokračovat ve vývoji MatchMatrix bez ztráty kontextu.

---

### Poznámka pro TECH V2

Po dokončení první revize celé dokumentační řady (REVIEW) bude dokument ve druhé generaci (TECH V2) rozšířen o praktické nástroje podporující každodenní řízení projektu MatchMatrix.

Budou doplněny zejména:

* standardní šablona denního zápisu,
* vzorové denní zápisy z reálného vývoje projektu MatchMatrix,
* jednotný systém označování denních zápisů,
* klasifikace zápisů podle oblasti projektu (Database, OPS, AI, Documentation, Web, Mobile, Business apod.),
* vazby na Git Commity,
* vazby na SQL skripty, Python workery a PowerShell skripty,
* vazby na databázové objekty (tabulky, pohledy, funkce, procedury),
* vazby na milestone projektu a roadmapu,
* propojení s dokumenty:
  * **MM-DOC-901 – MATCHMATRIX NAVÁZÁNÍ**,
  * **MM-DOC-902 – MATCHMATRIX CHANGELOG**,
  * **MM-DOC-903 – MATCHMATRIX ARCHITECTURAL DECISIONS**,
* doporučení pro automatickou archivaci denních zápisů,
* doporučení pro automatické vytváření souhrnů pomocí AI,
* propojení s Documentation Management System (DMS),
* automatické generování **Project Snapshot**,
* automatické generování **AI Context** pro navázání práce v novém chatu,
* doporučení pro dlouhodobou správu znalostní báze projektu.

Cílem druhé generace dokumentace nebude pouze evidence provedené práce, ale vytvoření jednotného znalostního systému propojujícího dokumentaci, databázi, zdrojové kódy, Git repozitář, AI asistenty a Documentation Management System do jednoho uceleného ekosystému.

> **Poznámka:** Dokument TECH V2 bude vytvářen až po dokončení REVIEW celé dokumentační řady MM-DOC-000 až MM-DOC-903, aby vycházel z jednotných standardů a ověřených zkušeností získaných během vývoje platformy MatchMatrix.


---

# AI CONTEXT

**Role dokumentu:** Standard pro vedení denních pracovních zápisů projektu MatchMatrix.

**Účel pro AI:** Umožnit rychlé pochopení posledního pracovního stavu projektu, provedených změn, otevřených úkolů a doporučeného dalšího kroku.

**Navazuje na:** MM-DOC-000, MM-DOC-100, MM-DOC-200, MM-DOC-300, MM-DOC-800.

**Související dokumenty:** MM-DOC-901, MM-DOC-902, MM-DOC-903, MM-STD-009.

---

# PROJECT SNAPSHOT

*Tato sekce je připravena pro budoucí automatické generování z Documentation Management System.*

Denní zápisy budou v budoucnu propojeny s databází dokumentace, Git historií, databázovými objekty, skripty, pracovními úlohami a stavem jednotlivých částí platformy.

---

# CURRENT STATUS

| Oblast | Stav |
|--------|------|
| Denní zápisy | REVIEW |
| Navázání | REVIEW |
| Changelog | REVIEW |
| Architectural Decisions | REVIEW |
| AI Context | DEVELOPMENT |
| Documentation Management System | PLANNED |

---

# OPEN QUESTIONS

* Finální šablona denního zápisu.
* Systém označování jednotlivých denních zápisů.
* Vazba denních zápisů na Git Commity.
* Vazba denních zápisů na SQL skripty a workery.
* Budoucí automatická archivace.
* Automatické generování souhrnů pomocí AI.

---

# NEXT STEP

Navazujícím dokumentem je:

> **MM-DOC-901 – MATCHMATRIX NAVÁZÁNÍ (TECH)**

Tento dokument definuje způsob předávání aktuálního stavu projektu mezi jednotlivými pracovními etapami a navazuje přímo na denní zápisy.
