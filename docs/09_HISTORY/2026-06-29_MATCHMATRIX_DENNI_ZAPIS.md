# MATCHMATRIX – DENNÍ ZÁPIS

## Informace o zápisu
| Položka | Hodnota |
|---|---|
| Datum | 2026-06-29 |
| Oblast | Dokumentace / TECH REVIEW / řízení znalostí |
| Typ zápisu | Denní pracovní zápis |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Stav | DOKONČENO |
| Primární formát | Markdown (.md) |

# 1. Výchozí stav
Na začátku dne byla k dispozici první generace hlavních dokumentů dokumentační řady MatchMatrix. Dokumenty již obsahovaly základní účel, filozofii a návrh pravidel pro vedení denních zápisů, navazování práce, evidenci významných změn a evidenci architektonických rozhodnutí.

Dokumenty však vznikaly původně pod starším označením:
- MM-DOC-006 – MatchMatrix Navázání,
- MM-DOC-007 – MatchMatrix Changelog,
- MM-DOC-008 – MatchMatrix Architectural Decisions.

Aktuální dokumentační architektura přitom používá novou řadu:
- MM-DOC-900 – Denní zápisy,
- MM-DOC-901 – Navázání,
- MM-DOC-902 – Changelog,
- MM-DOC-903 – Architectural Decisions.

Cílem dnešní práce bylo provést REVIEW dokumentů MM-DOC-901 až MM-DOC-903 podle standardů a hlavních dokumentů MatchMatrix, zachovat původní odborný obsah, sjednotit strukturu a připravit kompletní Markdown soubory ke stažení.

# 2. Použité zdroje
REVIEW vycházelo zejména z těchto dokumentů:
- MM-DOC-000 – MatchMatrix Documentation Framework,
- MM-DOC-100 – MatchMatrix Master,
- MM-DOC-200 – MatchMatrix Governance,
- MM-DOC-300 – MatchMatrix Architecture,
- MM-DOC-800 – MatchMatrix Development Handbook,
- MM-DOC-900 – MatchMatrix Denní zápisy,
- MM-STD-001 až MM-STD-009,
- MM-STD-1000 – Index standardů MatchMatrix,
- MM-REF-001 – Slovník pojmů MatchMatrix,
- původní dokumenty MM-DOC-006, MM-DOC-007 a MM-DOC-008.

# 3. Provedené práce

## 3.1 REVIEW dokumentu MM-DOC-901 – MatchMatrix Navázání
Původní dokument MM-DOC-006 byl převeden do aktuální dokumentační řady jako MM-DOC-901.

Bylo provedeno:
- sjednocení identifikace dokumentu,
- změna označení z MM-DOC-006 na MM-DOC-901,
- zachování původního smyslu a odborného obsahu,
- přepracování struktury podle MM-DOC-000 a standardů MM-STD,
- sjednocení terminologie a vazeb na ostatní dokumenty,
- doplnění účelu, rozsahu, cílové skupiny a zdrojů REVIEW,
- doplnění historie verzí,
- doplnění sekcí AI CONTEXT, PROJECT SNAPSHOT, DATABASE SNAPSHOT, CURRENT STATUS, OPEN QUESTIONS a NEXT STEP,
- oddělení pravidel řídicího dokumentu od konkrétních navazovacích zápisů,
- kompaktní formátování bez nadměrného množství prázdných řádků.

Výstup:
`MM-DOC-901_MATCHMATRIX_NAVAZANI_TECH_REVIEW.md`

## 3.2 REVIEW dokumentu MM-DOC-902 – MatchMatrix Changelog
Původní dokument MM-DOC-007 byl převeden do aktuální dokumentační řady jako MM-DOC-902.

Bylo provedeno:
- sjednocení identifikace dokumentu,
- změna označení z MM-DOC-007 na MM-DOC-902,
- zachování původního obsahu a významu,
- doplnění přesných hranic mezi CHANGELOGEM, denními zápisy, NAVÁZÁNÍM a registry rozhodnutí,
- doplnění kritérií pro zařazení významné změny,
- doplnění životního cyklu changelogového záznamu,
- sjednocení struktury záznamu,
- vyřešení vztahu mezi verzováním aktivního dokumentu a neměnností již publikovaných historických záznamů,
- doplnění vazeb na Git commit, milestone, dokumentaci a Documentation Management System,
- doplnění povinných kontextových sekcí podle MM-STD-009,
- kompaktní formátování.

Výstup:
`MM-DOC-902_MATCHMATRIX_CHANGELOG_TECH_REVIEW.md`

## 3.3 REVIEW dokumentu MM-DOC-903 – MatchMatrix Architectural Decisions
Původní dokument MM-DOC-008 byl převeden do aktuální dokumentační řady jako MM-DOC-903.

Bylo provedeno:
- sjednocení identifikace dokumentu,
- změna označení z MM-DOC-008 na MM-DOC-903,
- zachování původního odborného obsahu,
- zavedení pojmu Architecture Decision Record (ADR; záznam architektonického rozhodnutí),
- potvrzení identifikátorů jednotlivých rozhodnutí ve formátu `AD-xxxx`,
- doplnění kritérií pro vznik samostatného rozhodnutí,
- doplnění životního a stavového cyklu rozhodnutí,
- oddělení řídicího dokumentu MM-DOC-903 od konkrétních historických záznamů `AD-xxxx`,
- doplnění pravidla, že přijaté rozhodnutí se zpětně nemaže ani nepřepisuje, ale může být nahrazeno novým rozhodnutím,
- doplnění vazeb na ARCHITECTURE, GOVERNANCE, CHANGELOG, denní zápisy, NAVÁZÁNÍ, Git a milestone,
- doplnění povinných kontextových sekcí,
- kompaktní formátování.

Výstup:
`MM-DOC-903_MATCHMATRIX_ARCHITECTURAL_DECISIONS_TECH_REVIEW.md`

## 3.4 Sjednocení způsobu předávání výstupů
Během práce bylo jednoznačně potvrzeno praktické názvosloví:
- **stažení** znamená vytvoření celého hotového souboru a předání odkazu ke stažení,
- **zkopírování** znamená vložení textu přímo do chatu.

Toto pravidlo se bude používat automaticky při další práci.

## 3.5 Požadavek na kompaktní dokumenty
Bylo potvrzeno, že dokumenty mohou být obsahově delší než původní verze, pokud doplnění přináší skutečnou hodnotu. Nemají však být uměle natahovány nadměrným množstvím prázdných řádků, rozvolněnou sazbou nebo opakováním stejných informací.

Používá se:
- kompaktní Markdown,
- souvislé odstavce,
- pouze funkční mezery mezi kapitolami,
- přehledné tabulky a seznamy,
- žádné umělé prodlužování dokumentu.

# 4. Hlavní zjištění
Po přečtení revidovaných dokumentů bylo zjištěno, že dokumentační řada je zatím převážně metodická a teoretická.

Dokumenty velmi podrobně vysvětlují:
- co má denní zápis obsahovat,
- co má NAVÁZÁNÍ obsahovat,
- co má CHANGELOG obsahovat,
- co má záznam architektonického rozhodnutí obsahovat,
- jak mají být dokumenty spravovány.

Zatím však obsahují jen omezené množství skutečných dat z vývoje MatchMatrix.

Chybějí zejména:
- konkrétní denní zápisy z reálné práce,
- konkrétní navazovací zápisy použitelné pro nový chat,
- skutečný chronologický CHANGELOG projektu,
- skutečný katalog architektonických rozhodnutí `AD-xxxx`,
- přímé vazby na existující SQL skripty, Python workery, OPS objekty, databázové audity, Git commity a milestone,
- skutečný PROJECT SNAPSHOT a DATABASE SNAPSHOT místo připravených teoretických sekcí.

# 5. Přijaté rozhodnutí
Dokumentační práce přechází z fáze tvorby metodiky do fáze tvorby skutečného obsahu projektu.

Metodické dokumenty MM-DOC-900 až MM-DOC-903 zůstávají pravidly a referenčním rámcem. Vedle nich nyní začnou vznikat konkrétní provozní dokumenty založené na reálném vývoji MatchMatrix.

Prvním konkrétním výstupem je tento denní zápis.

Druhým konkrétním výstupem je samostatné NAVÁZÁNÍ pro nový chat vytvořené ke dni 2026-06-29.

# 6. Význam rozhodnutí pro dokumentační systém
Tímto krokem se mění praktický směr dokumentace:
- dokumentace již nebude pouze popisovat, jak má být vedena,
- začne přímo uchovávat skutečný stav projektu,
- reálné výsledky vývoje budou propojeny s metodickými dokumenty,
- budoucí AI a spolupracovníci získají konkrétní zdroj pravdy,
- dokumentační systém začne plnit funkci skutečné pracovní paměti projektu.

# 7. Aktuální stav dokumentační řady
| Dokument | Stav | Reálný obsah |
|---|---|---|
| MM-DOC-000 – Documentation Framework | REVIEW | Rámec a filozofie dokumentace |
| MM-DOC-100 – Master | REVIEW | Strategický základ, vyžaduje další konkrétní data |
| MM-DOC-200 – Governance | REVIEW | Popis pravidel a skutečných governance oblastí |
| MM-DOC-300 – Architecture | REVIEW | Obsahuje více reálné architektury, vyžaduje další technické snapshoty |
| MM-DOC-800 – Development Handbook | REVIEW | Metodika vývoje, vyžaduje přesné aktuální postupy a strukturu repozitáře |
| MM-DOC-900 – Denní zápisy | REVIEW | Metodický dokument; konkrétní zápisy se začínají vytvářet |
| MM-DOC-901 – Navázání | REVIEW | Metodický dokument; konkrétní navázání se začínají vytvářet |
| MM-DOC-902 – Changelog | REVIEW | Metodický dokument; skutečný changelog zatím musí být vytvořen |
| MM-DOC-903 – Architectural Decisions | REVIEW | Metodický dokument; katalog `AD-xxxx` zatím musí být vytvořen |

# 8. Otevřené úkoly

## Priorita 1 – konkrétní provozní dokumentace
1. Vytvořit první skutečný chronologický CHANGELOG projektu z existujících denních zápisů a projektových milníků.
2. Vytvořit první katalog reálných architektonických rozhodnutí `AD-xxxx`.
3. Doplnit skutečný PROJECT SNAPSHOT a DATABASE SNAPSHOT z aktuálního stavu databáze, providerů, vrstev a infrastruktury.
4. Zavést pravidelný vznik konkrétního denního zápisu a navázání na konci významné pracovní etapy.

## Priorita 2 – konkretizace hlavních dokumentů
1. Doplnit MM-DOC-100 o skutečné produkty, služby, obchodní cíle a současný stav platformy.
2. Doplnit MM-DOC-200 o konkrétní aktivní governance mechanismy, tabulky, pohledy, audity a HOLD procesy.
3. Doplnit MM-DOC-300 o aktuální databázové objekty, skutečné datové toky, workery, servery a nasazení PC1/PC2.
4. Doplnit MM-DOC-800 o reálnou strukturu repozitáře, aktuální číslování skriptů a používané pracovní postupy.

# 9. Kandidáti pro první skutečná architektonická rozhodnutí
Při navazující práci mají být posouzeny zejména tyto kandidátní záznamy:
- přechod ze sportovně specifických staging tabulek `api_*` na sjednocené tabulky `stg_*`,
- víceproviderová architektura a nezávislost na jediném poskytovateli dat,
- Canonical Entity Model pro týmy, hráče, soutěže a zápasy,
- rozdělení databáze na schémata `staging`, `public`, `ops` a `runtime`,
- Governance First jako povinný princip nových modulů,
- oddělení PC1 jako řídicího pracoviště a PC2 jako hlavního datového a harvest uzlu,
- pořadí harvestu CORE HISTORY → CURRENT → PEOPLE → MEDIA → ODDS,
- vznik Source Intelligence Layer,
- Operator / Denní práce jako akční panel, nikoliv pouze dashboard,
- dokumentace jako řízená znalostní vrstva platformy.

# 10. Rizika a upozornění
- Nesmí vznikat další dlouhé dokumenty, které pouze znovu popisují metodiku bez doplnění skutečných dat.
- Konkrétní údaje musí být čerpány z aktuálních zdrojů projektu, databázových výstupů, repozitáře a schválených zápisů.
- Historické hodnoty musí být odlišeny od aktuálního stavu.
- Pokud není aktuální stav ověřen, musí být označen jako neověřený nebo připravený k aktualizaci.
- Jednotlivé dokumenty nesmí duplikovat stejnou informaci; musí odkazovat na její referenční místo.

# 11. Výsledek dne
Dnešní práce uzavřela REVIEW dokumentů MM-DOC-901 až MM-DOC-903 a současně odhalila zásadní další potřebu dokumentačního systému: přejít od popisu pravidel k systematickému zaznamenávání skutečného vývoje projektu.

Dokumentační rámec je nyní dostatečně připravený k tomu, aby začal být plněn reálnými záznamy.

# 12. Další hlavní krok
V novém chatu pokračovat vytvořením skutečného CHANGELOGU projektu MatchMatrix a následně prvního katalogu konkrétních architektonických rozhodnutí `AD-xxxx`.

Při práci nepřepisovat znovu metodiku. Čerpat z existujících denních zápisů, projektových snapshotů, databázových auditů, aktuální architektury a reálných výsledků projektu.
