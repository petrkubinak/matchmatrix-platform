# MM-DOC-007

# MATCHMATRIX CHANGELOG (TECH)

---

## Informace o dokumentu

| Položka              | Hodnota                                              |
| :------------------- | :--------------------------------------------------- |
| Název dokumentu      | MATCHMATRIX CHANGELOG                                |
| Označení             | MM-DOC-007                                           |
| Edice                | TECH                                                 |
| Verze                | 1.0 (Pracovní verze)                                 |
| Stav                 | Rozpracováno                                         |
| Autor projektu       | Petr                                                 |
| Technická spolupráce | OpenAI ChatGPT                                       |
| Primární formát      | Markdown (.md)                                       |
| Umístění             | `docs/07_CHANGELOG/07_MATCHMATRIX_CHANGELOG_TECH.md` |

---

# Motto

> **Ne každá změna je důležitá. Changelog zachycuje pouze ty, které mění projekt.**

---

# Obsah

1. Úvod
2. Účel changelogu
3. Filozofie evidence změn
4. Druhy změn
5. Struktura záznamu
6. Pravidla evidence
7. Vazba na ostatní dokumentaci
8. Závěr

---

# 1. Úvod

Vývoj projektu MatchMatrix probíhá nepřetržitě.

Každý den vznikají nové skripty, databázové objekty, dokumenty i architektonická rozhodnutí.

Ne všechny změny však mají stejnou důležitost.

Právě proto vznikl dokument MATCHMATRIX CHANGELOG.

Jeho úkolem není zaznamenat každou úpravu.

Jeho cílem je evidovat pouze změny, které mají dlouhodobý význam pro celý projekt.

---

# 2. Účel dokumentu

CHANGELOG představuje chronologický přehled významných milníků projektu.

Slouží zejména k evidenci:

* nových modulů,
* dokončených etap,
* významných architektonických změn,
* změn databázové struktury,
* nových Layer,
* změn workflow,
* důležitých rozhodnutí.

Na rozdíl od denních zápisů neobsahuje podrobný průběh práce.

Obsahuje pouze výsledky.

---

# 3. Filozofie evidence změn

Do changelogu se zapisují pouze změny, které budou důležité i po delší době.

Každý záznam by měl odpovědět na tři základní otázky.

* Co se změnilo?
* Proč ke změně došlo?
* Jaký bude její dlouhodobý dopad?

Tím vzniká stručná historie vývoje projektu bez zbytečných detailů.

---

# 4. Druhy změn

V projektu MatchMatrix rozlišujeme několik základních kategorií změn.

## Architektonické změny

Například:

* vznik nové Layer,
* změna databázové architektury,
* nový způsob harvestu,
* změna workflow.

---

## Funkční změny

Například:

* nový modul,
* nový dashboard,
* nový provider,
* nový parser.

---

## Governance změny

Například:

* nové standardy,
* nová pravidla,
* změny řízení projektu,
* nové kontrolní mechanismy.

---

## Dokumentační změny

Například:

* vznik nového dokumentu,
* nová dokumentační pravidla,
* změna standardu dokumentace.

---

# Závěr první části

MATCHMATRIX CHANGELOG představuje stručnou historii významných změn projektu. Jeho cílem není zaznamenávat každodenní práci, ale vytvářet dlouhodobý přehled nejdůležitějších milníků vývoje platformy.

V další části dokumentu bude popsána doporučená struktura jednotlivých záznamů, pravidla jejich vytváření a vazba changelogu na ostatní dokumentaci projektu.

# 5. Struktura záznamu

Každý záznam v dokumentu CHANGELOG používá jednotnou strukturu. Díky tomu lze rychle dohledat jednotlivé změny a současně je zajištěna dlouhodobá přehlednost celé historie projektu.

Každý záznam by měl být dostatečně stručný, ale současně musí obsahovat všechny informace potřebné pro pochopení významu provedené změny.

---

# 5.1 Povinné informace

Každý záznam obsahuje minimálně:

* datum změny,
* název změny,
* oblast projektu,
* stručný popis,
* důvod změny,
* očekávaný přínos,
* návaznost na další části systému.

Tato struktura umožňuje velmi rychlou orientaci i při větším počtu záznamů.

---

# 5.2 Doporučený formát

Každý záznam by měl být zapisován jednotným způsobem.

Například:

```text
Datum:

Kategorie:

Oblast:

Změna:

Důvod:

Dopad:

Navazuje na:
```

Použití jednotné šablony výrazně usnadňuje čtení i pozdější vyhledávání.

---

# 5.3 Úroveň podrobnosti

CHANGELOG není technická dokumentace.

Proto se zde neuvádějí:

* celé SQL skripty,
* zdrojové kódy,
* podrobné postupy implementace.

Tyto informace patří do ostatních dokumentů projektu.

CHANGELOG obsahuje pouze přehled změn.

---

# 6. Pravidla evidence

Během vývoje MatchMatrix se osvědčilo několik jednoduchých pravidel.

Do CHANGELOGU se zapisují pouze změny, které mají dlouhodobý význam.

Například:

* dokončení významné etapy,
* zavedení nové architektury,
* vytvoření nové databázové vrstvy,
* přidání významného provideru,
* změna vývojových standardů,
* vznik nového dokumentačního pravidla.

Naopak se nezapisují drobné opravy nebo běžné pracovní úpravy.

Ty jsou zachyceny v denních zápisech.

---

# 6.1 Četnost aktualizace

CHANGELOG není nutné aktualizovat každý den.

Nový záznam vzniká pouze tehdy, pokud došlo ke změně, která bude významná i v budoucnu.

Tím zůstává dokument stručný a přehledný.

---

# 6.2 Neměnnost záznamů

Po zapsání změny by záznam neměl být měněn.

Pokud je potřeba některou informaci upřesnit, vytvoří se nový navazující záznam.

Tím zůstává zachována historie vývoje projektu.

---

# 7. Vazba na ostatní dokumentaci

CHANGELOG tvoří společně s ostatní dokumentací jednotný celek.

Je propojen zejména s následujícími dokumenty.

---

## DENNÍ ZÁPISY

Denní zápisy obsahují podrobný průběh práce.

CHANGELOG zachycuje pouze její nejvýznamnější výsledky.

---

## NAVÁZÁNÍ

Dokument NAVÁZÁNÍ popisuje aktuální stav projektu.

Pokud během pracovní etapy vznikne významná změna, měla by být následně zapsána také do CHANGELOGU.

---

## ARCHITECTURAL DECISIONS

Každé důležité architektonické rozhodnutí je evidováno samostatně.

CHANGELOG na něj pouze odkazuje.

---

## MASTER

Pokud některá změna ovlivňuje dlouhodobou strategii projektu, měla by být promítnuta také do dokumentu MASTER.

---

# 8. Závěr dokumentu

MATCHMATRIX CHANGELOG představuje oficiální přehled nejvýznamnějších milníků projektu.

Na rozdíl od denních zápisů zachycuje pouze změny s dlouhodobým významem.

Díky tomu poskytuje rychlý přehled o vývoji platformy bez nutnosti procházet podrobné pracovní záznamy.

Společně s dokumenty MASTER, GOVERNANCE, ARCHITECTURE, DENNÍ ZÁPISY a NAVÁZÁNÍ tvoří jednotný systém dokumentace projektu MatchMatrix.

---

# Stav dokumentu

**Dokument:** MM-DOC-007 – MATCHMATRIX CHANGELOG

**Edice:** TECH

**Verze:** 1.0 – První pracovní verze

**Stav:** Připraven k první revizi

---

## Navazující dokument

Dalším a současně posledním dokumentem první série TECH bude:

> **MM-DOC-008 – MATCHMATRIX ARCHITECTURAL DECISIONS (TECH)**

Tento dokument bude sloužit jako centrální registr všech významných architektonických rozhodnutí přijatých během vývoje MatchMatrix. U každého rozhodnutí bude zaznamenán důvod jeho přijetí, očekávaný přínos, možné alternativy i dlouhodobý dopad na architekturu celé platformy.

---

### Poznámka pro TECH V2

Při druhé revizi dokumentace bude CHANGELOG rozšířen o:

* klasifikaci změn podle závažnosti,
* vazbu na Git commit,
* vazbu na milestone projektu,
* odkazy na související dokumenty,
* doporučený systém verzování jednotlivých záznamů.

Tyto části budou doplněny po dokončení celé série dokumentů **MM-DOC-000 až MM-DOC-008**, aby odpovídaly jednotnému standardu celé dokumentace.


