# MM-PRV-006

# PRÁVNÍ A LICENČNÍ ŘÍZENÍ PROVIDERŮ

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-PRV-006 |
| Document ID | MM-PRV-006 |
| Název dokumentu | Právní a licenční řízení providerů |
| Typ dokumentu | PROVIDER_LEGAL_AND_LICENSING_GOVERNANCE |
| Dokumentační oblast | 05_PROVIDERS |
| Edice | MM-DOC TECH |
| Verze | 0.9 |
| Stav | APPROVED |
| Původní stav zdrojového dokumentu | NOVÝ DOKUMENT |
| Datum | 2026-07-18 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Primární formát | Markdown (`.md`) |
| Cílové umístění | `docs/05_PROVIDERS/` |
| Nahrazuje | — |
| Navazuje na | MM-PRV-001, MM-PRV-002, MM-PRV-003, MM-PRV-004, MM-PRV-005 |
| Související dokumenty | MM-DOC-100, MM-DOC-200, MM-DOC-300, MM-DOC-800, MM-DB-001, MM-DB-002, MM-DB-003, MM-REF-001, MM-REF-002 |
| Referenční standardy | MM-STD-001, MM-STD-003, MM-STD-004, MM-STD-005, MM-STD-006, MM-STD-007, MM-STD-008, MM-STD-009 |

---

# 1. Úvod

Právní a licenční řízení providerů stanovuje pravidla, podle kterých MatchMatrix posuzuje, schvaluje, používá, kontroluje a ukončuje datové zdroje z hlediska oprávnění k jejich využití.

Technická dostupnost dat sama o sobě neznamená, že je povoleno tato data získávat, ukládat, dlouhodobě archivovat, kombinovat s jinými zdroji, veřejně zobrazovat, poskytovat přes API nebo používat v komerčních produktech. Každé z těchto použití představuje samostatnou právní a licenční otázku.

Tento dokument vytváří jednotnou řídicí vrstvu mezi:

```text
ZDROJEM A JEHO PODMÍNKAMI
→ SCHVÁLENÝM ROZSAHEM POUŽITÍ
→ TECHNICKOU INTEGRACÍ
→ INTERNÍM ZPRACOVÁNÍM
→ PRODUKTOVÝM ZOBRAZENÍM NEBO DISTRIBUCÍ
→ PRŮBĚŽNOU REVALIDACÍ
→ UKONČENÍM ZDROJE
```

Cílem není nahrazovat individuální právní posouzení konkrétní smlouvy, licence, území nebo produktu. Cílem je zajistit, aby žádný provider nebyl použit bez doloženého rozhodnutí, známého rozsahu práv, auditní stopy a bezpečnostních blokací.

## 1.1 Proč dokument vzniká

Providerová dokumentace `MM-PRV-001` až `MM-PRV-005` již stanovuje:

- providerový ekosystém,
- životní cyklus a schvalování providerů,
- routing a fallback,
- Provider Health Monitoring,
- technickou integraci přes RAW, parser, staging, validaci, mapování, merge a post-importní ověření.

Tyto dokumenty vytvářejí technický a provozní rámec. Pro bezpečné použití zdrojů je však nutné samostatně řídit také:

- smluvní oprávnění,
- licenční omezení,
- práva k databázím,
- autorská a související práva,
- práva k fotografiím, videím, článkům, logům a ochranným známkám,
- ochranu osobních údajů,
- pravidla atribuce,
- zákaz další distribuce nebo sublicence,
- územní a produktová omezení,
- změny podmínek,
- právní incidenty,
- povinnosti při ukončení služby.

## 1.2 Rozsah dokumentu

Dokument se vztahuje na všechny externí nebo partnerské zdroje používané platformou MatchMatrix, zejména:

- placená sportovní API,
- bezplatná API,
- oficiální zdroje federací, lig, klubů a pořadatelů,
- veřejně dostupné webové stránky,
- otevřená data,
- referenční a znalostní databáze,
- poskytovatele kurzů,
- poskytovatele statistik,
- poskytovatele mediálního obsahu,
- obrazové a video banky,
- partnerské datové feedy,
- obsah poskytnutý uživateli nebo smluvním partnerem,
- zdroje získávané automatizovaným sběrem.

Dokument se vztahuje na každý způsob použití dat, včetně interního testování. Testovací použití nesmí automaticky obcházet licenční nebo právní omezení.

## 1.3 Právní interpretační hranice

Tento dokument je interní technický a governance standard.

Neurčuje definitivní právní výklad konkrétní smlouvy ani právního předpisu. Při nejasnosti, vysokém dopadu, mezinárodním použití, zpracování osobních údajů, mediálních právech nebo sporu musí být provedeno samostatné odborné právní posouzení.

Automatizace, AI ani technický operátor nesmí samostatně rozhodnout, že právně nejasný zdroj je povolen.

## 1.4 Závěr kapitoly

Kapitola vymezuje právní a licenční řízení jako povinnou součást providerového ekosystému. Přínosem je oddělení technické dostupnosti dat od oprávnění tato data skutečně využívat. Následující kapitola stanovuje základní principy, které platí pro každý zdroj a každý způsob použití.

---

# 2. Základní principy právního a licenčního řízení

## 2.1 Oprávnění před použitím

Provider nebo zdroj nesmí být aktivován pro produkční použití, dokud není doloženo oprávnění pro konkrétní účel.

Schválení musí odpovídat minimálně kombinaci:

```text
provider
+ zdroj nebo endpoint
+ datová oblast
+ způsob získání
+ způsob uložení
+ způsob zpracování
+ produkt nebo distribuční kanál
+ území
+ obchodní účel
+ časová platnost
```

Obecné tvrzení „data lze používat“ není dostatečné.

## 2.2 Oddělení jednotlivých práv

Práva se nesmí posuzovat jako jeden společný příznak.

Samostatně se ověřuje zejména:

- právo přístupu ke zdroji,
- právo automatizovaného získávání,
- právo dočasného uložení,
- právo RAW uložení,
- právo dlouhodobé archivace,
- právo zálohování,
- právo normalizace a technické transformace,
- právo kombinování s jinými zdroji,
- právo vytváření odvozených výstupů,
- právo interní analýzy,
- právo použití pro strojové učení nebo text and data mining,
- právo veřejného zobrazení,
- právo poskytování přes API,
- právo exportu nebo redistribuce,
- právo komerčního použití,
- právo použití médií,
- právo sublicence.

Povolení jednoho způsobu použití se nesmí automaticky přenášet na jiný způsob.

## 2.3 Princip nejmenšího oprávnění

Technická konfigurace smí používat pouze taková práva a rozsah, které byly skutečně schváleny.

Pokud je provider schválen pouze pro interní kontrolu, nesmí být jeho data zobrazena veřejně.

Pokud je schváleno pouze dočasné cache, nesmí být stejná data bez dalšího rozhodnutí vedena jako trvalý historický archiv.

## 2.4 Právní stav je samostatná dimenze

Právní stav nesmí být odvozován z:

- technického health stavu,
- datové kvality,
- ceny tarifu,
- dostupnosti endpointu,
- existence API klíče,
- skutečnosti, že zdroj již používá jiná služba,
- veřejné dostupnosti dat na internetu.

Provider může být technicky `HEALTHY`, ale právně `HOLD`.

Provider může být datově kvalitní, ale nesmí být použit pro veřejnou distribuci.

## 2.5 Dohledatelnost rozhodnutí

Každé právní a licenční rozhodnutí musí být doložitelné.

Musí být možné zjistit:

- kdo rozhodnutí provedl,
- kdy bylo provedeno,
- jaké dokumenty byly posouzeny,
- jaká verze podmínek platila,
- jaké způsoby použití byly povoleny,
- jaké podmínky a zákazy byly stanoveny,
- do kdy je rozhodnutí platné,
- kdy proběhne další kontrola,
- co má systém provést při změně podmínek.

## 2.6 Ochrana důkazů

Podmínky, smlouvy, objednávky, licenční texty, potvrzení podpory a další právně významné podklady musí být uchovány v řízené podobě.

Pouhý odkaz na webovou stránku není dostatečným důkazem, protože obsah stránky se může změnit.

Podle povahy zdroje se uchovává zejména:

- dokument nebo export podmínek,
- datum a čas získání,
- zdrojová adresa,
- jazyková verze,
- identifikátor nebo hash souboru,
- datum účinnosti,
- obchodní nabídka nebo objednávka,
- komunikace, která upřesňuje práva,
- interní rozhodnutí a jeho rozsah.

## 2.7 Zákaz tichého rozšíření použití

Nový produkt, nový distribuční kanál, nový partner, nový export, nové API nebo nový typ analýzy může změnit právní význam použití dat.

Před rozšířením musí být ověřeno, zda původní schválení nový účel skutečně pokrývá.

## 2.8 Závěr kapitoly

Základní principy oddělují jednotlivá práva a zavádějí povinnost doložit oprávnění před technickým použitím. Přínosem je ochrana projektu před neúmyslným rozšířením použití mimo schválený rozsah. Následující kapitola klasifikuje zdroje podle jejich právní povahy a rizika.

---

# 3. Klasifikace zdrojů a právního rizika

## 3.1 Účel klasifikace

Klasifikace určuje, jak podrobná kontrola je nutná před použitím zdroje.

Klasifikace nenahrazuje individuální posouzení. Pomáhá určit prioritu, povinné důkazy, schvalovací úroveň a bezpečnostní blokace.

## 3.2 Smluvní komerční API

Zdroj je poskytován na základě:

- placeného tarifu,
- individuální smlouvy,
- objednávky,
- partnerské dohody,
- podnikových podmínek.

Musí být ověřeno zejména:

- kdo je smluvní stranou,
- jaký tarif je aktivní,
- zda je povoleno komerční použití,
- zda je povoleno dlouhodobé ukládání,
- zda je povolena veřejná prezentace,
- zda je povoleno další poskytování dat,
- jaké jsou limity odpovědnosti,
- jaké jsou povinnosti po ukončení,
- zda je povoleno zapojení cloudových nebo jiných subdodavatelů.

## 3.3 Standardní veřejné API s podmínkami

Zdroj je veřejně dostupný, ale jeho použití je řízeno zveřejněnými podmínkami.

Musí být ověřeno:

- zda podmínky tvoří závaznou součást přístupu,
- zda je vyžadována registrace,
- zda jsou oddělena pravidla pro nekomerční a komerční použití,
- zda je zakázána redistribuce,
- zda je povinná atribuce,
- zda jsou omezeny odvozené produkty,
- zda je povolena automatizace.

## 3.4 Otevřená licence

Zdroj používá výslovně uvedenou otevřenou licenci.

Musí být ověřeno:

- přesné označení a verze licence,
- zda se licence vztahuje na celý obsah nebo pouze na jeho část,
- zda je povoleno komerční použití,
- zda je vyžadována atribuce,
- zda existuje podmínka share-alike,
- zda jsou vyloučeny fotografie, loga, ochranné známky nebo osobní údaje,
- zda je povoleno kombinování s jinými daty,
- zda je povolena distribuce přes API.

Označení „open“, „free“ nebo „public“ bez konkrétní licence není dostatečné.

## 3.5 Otevřená data veřejného sektoru

U dat veřejného sektoru se ověřuje:

- právní titul opětovného použití,
- konkrétní licenční podmínky,
- případné poplatky,
- atribuce,
- výjimky a chráněné části,
- osobní údaje,
- důvěrné nebo bezpečnostně omezené informace,
- přesný rozsah dat, na která se otevřený režim vztahuje.

Skutečnost, že data vytvořil veřejný orgán, sama o sobě nemusí znamenat neomezené použití všech souvisejících materiálů.

## 3.6 Oficiální web federace, ligy, klubu nebo pořadatele

Oficiální zdroj může mít vysokou obsahovou autoritu, ale neznamená automaticky volnou licenci.

Samostatně se posuzuje:

- textový obsah,
- tabulky a databázové výstupy,
- zápasové rozpisy,
- fotografie,
- loga,
- video,
- tiskové zprávy,
- statistiky,
- dokumenty ke stažení,
- pravidla automatizovaného přístupu.

## 3.7 Veřejně dostupný web bez jasné licence

Jde o rizikový zdroj.

Veřejná dostupnost neprokazuje právo:

- provádět systematický sběr,
- kopírovat celý obsah,
- ukládat databázi,
- používat fotografie,
- redistribuovat data,
- vytvářet komerční produkt.

Takový zdroj musí být veden minimálně ve stavu `REVIEW_REQUIRED` nebo `HOLD`, dokud není rozsah použití doložen.

## 3.8 Komunitní a znalostní zdroj

U komunitních databází a wiki zdrojů se posuzuje:

- licence databáze,
- licence jednotlivého textu,
- licence jednotlivého média,
- povinnosti atribuce,
- podmínky share-alike,
- kvalita a původ příspěvků,
- možnost, že konkrétní vložený obsah má odlišnou licenci.

## 3.9 Uživatelský nebo partnerský obsah

U obsahu dodaného partnerem nebo uživatelem musí být doloženo:

- že poskytovatel má právo obsah poskytnout,
- jaká práva MatchMatrix získává,
- zda je právo převoditelné,
- zda je možné obsah upravovat,
- zda je možné obsah veřejně zobrazovat,
- zda je možné obsah dále poskytovat,
- jak se řeší reklamace a odstranění.

## 3.10 Mediální zdroj

Fotografie, video, zvuk, komentář, článek nebo grafický materiál se posuzují odděleně od faktických sportovních dat.

Licence k API se nesmí automaticky považovat za licenci ke všem mediálním souborům dostupným přes stejné rozhraní.

## 3.11 Neznámý nebo nedoložený zdroj

Zdroj bez doloženého vlastníka, podmínek, licence nebo původu má právní stav `UNKNOWN`.

Takový zdroj nesmí být použit pro produkční harvest ani publikaci.

Může být evidován pouze jako kandidát k dalšímu posouzení.

## 3.12 Rizikové úrovně

| Úroveň | Význam | Minimální reakce |
|---|---|---|
| LOW | Práva jsou výslovná, aktuální a odpovídají plánovanému použití. | Standardní schválení a pravidelná revalidace. |
| CONTROLLED | Použití je povoleno s podmínkami, atribucí nebo omezením produktu. | Technické vynucení podmínek a častější kontrola. |
| HIGH | Významná nejasnost, omezená licence, média, osobní údaje nebo přeshraniční dopad. | Odborné posouzení před aktivací. |
| CRITICAL | Pravděpodobný zákaz, spor, výzva k odstranění, nedoložené právo nebo zásadní změna podmínek. | Okamžitý HOLD a zastavení dotčeného použití. |

## 3.13 Závěr kapitoly

Klasifikace umožňuje rozlišit smluvní, otevřené, veřejné, komunitní, mediální a nejasné zdroje. Přínosem je řízení intenzity kontroly podle skutečného rizika. Následující kapitola převádí právní posouzení do jednotného licenčního profilu a matice práv.

---

# 4. Licenční profil a matice práv

## 4.1 Licenční profil providera

Každý provider musí mít samostatný licenční profil.

Profil nesmí obsahovat pouze název licence. Musí popsat skutečný rozsah schváleného použití.

Minimální identifikace:

| Položka | Význam |
|---|---|
| provider_id | Interní identifikátor providera. |
| legal_profile_id | Identifikátor právního profilu. |
| source_scope | Endpoint, dataset, webová sekce nebo datová oblast. |
| agreement_type | Smlouva, tarif, veřejné podmínky, otevřená licence nebo jiné oprávnění. |
| agreement_version | Verze nebo datum účinnosti podmínek. |
| jurisdiction | Rozhodné právo nebo relevantní území. |
| valid_from | Začátek platnosti. |
| valid_to | Konec platnosti nebo datum expirace. |
| review_due_at | Datum další povinné kontroly. |
| legal_status | Aktuální právní stav. |
| evidence_location | Řízené umístění důkazních podkladů. |
| approved_by | Odpovědná schvalující role. |
| approved_at | Datum schválení. |

## 4.2 Stavy jednotlivých práv

Každé právo používá jednu z hodnot:

| Stav | Význam |
|---|---|
| PERMITTED | Použití je doloženě povoleno. |
| PERMITTED_WITH_CONDITIONS | Použití je povoleno pouze při splnění evidovaných podmínek. |
| REVIEW_REQUIRED | Právo nelze potvrdit bez dalšího posouzení. |
| PROHIBITED | Použití je zakázáno. |
| NOT_APPLICABLE | Právo se pro daný zdroj nebo produkt nepoužije. |
| UNKNOWN | Nebyly získány dostatečné podklady. |

`UNKNOWN` nesmí být technicky interpretováno jako `PERMITTED`.

## 4.3 Povinná matice práv

| Právo nebo způsob použití | Povinné posouzení |
|---|---|
| ACCESS | Je povolen přístup ke zdroji a účtu. |
| AUTOMATED_COLLECTION | Je povolen automatizovaný sběr nebo harvest. |
| TEMPORARY_CACHE | Je povoleno krátkodobé technické uložení. |
| RAW_STORAGE | Je povoleno uložení původních odpovědí nebo souborů. |
| LONG_TERM_ARCHIVE | Je povolena dlouhodobá historická archivace. |
| BACKUP | Je povolena tvorba a uchování záloh. |
| INTERNAL_PROCESSING | Je povoleno interní zpracování a analýza. |
| NORMALIZATION | Je povolena transformace do interního modelu. |
| COMBINATION | Je povoleno kombinování s jinými zdroji. |
| DERIVED_DATA | Je povolena tvorba odvozených metrik, ratingů nebo modelových výstupů. |
| TDM_OR_ML_USE | Je povoleno použití pro text and data mining nebo strojové učení. |
| PUBLIC_DISPLAY | Je povoleno zobrazení uživatelům. |
| API_REDISTRIBUTION | Je povoleno poskytování přes API. |
| DOWNLOAD_EXPORT | Je povolen export nebo stažení dat uživatelem. |
| PARTNER_SHARING | Je povoleno předání smluvním partnerům. |
| SUBLICENSING | Je povolena sublicence nebo další oprávnění třetí straně. |
| COMMERCIAL_USE | Je povoleno použití v placeném nebo reklamním produktu. |
| MEDIA_USE | Je povoleno použití fotografií, videí, zvuku nebo textových děl. |
| ATTRIBUTION_REQUIRED | Je vyžadováno uvedení zdroje. |
| DELETION_ON_TERMINATION | Je nutný výmaz po ukončení. |

## 4.4 Podmínky práva

U stavu `PERMITTED_WITH_CONDITIONS` se eviduje nejméně:

- přesný text nebo význam podmínky,
- produkt, kterého se týká,
- území,
- datová oblast,
- technický způsob vynucení,
- odpovědná role,
- způsob kontroly,
- důsledek nesplnění.

## 4.5 Rozsah podle atributu a média

Stejný provider může mít různé podmínky pro různé části obsahu.

Například:

- výsledky lze zobrazovat,
- detailní statistiky pouze interně,
- fotografie nelze ukládat,
- loga lze použít pouze s atribucí,
- články lze pouze odkazovat,
- video lze pouze vložit pomocí schváleného přehrávače.

Licenční profil musí umožnit řízení minimálně na úrovni:

```text
provider
× dataset nebo endpoint
× typ entity
× atribut nebo media asset
× produktový kanál
```

## 4.6 Právní stav providera

Doporučené právní stavy:

| Stav | Význam |
|---|---|
| NOT_ASSESSED | Právní posouzení nebylo zahájeno. |
| REVIEW_IN_PROGRESS | Probíhá shromažďování a vyhodnocování podkladů. |
| APPROVED | Rozsah použití je schválen bez zvláštních podmínek nad rámec profilu. |
| APPROVED_WITH_CONDITIONS | Použití je schváleno s technicky vynucovanými podmínkami. |
| REVALIDATION_REQUIRED | Původní rozhodnutí musí být znovu ověřeno. |
| HOLD | Dotčené použití je dočasně pozastaveno. |
| PROHIBITED | Použití je zakázáno. |
| EXPIRED | Oprávnění nebo smlouva skončily. |
| TERMINATED | Provider byl právně a smluvně ukončen. |

## 4.7 Závěr kapitoly

Licenční profil převádí právní podmínky do jednoznačných, technicky použitelných stavů a práv. Přínosem je možnost blokovat konkrétní nepovolené použití bez zastavení celého providera. Následující kapitola stanovuje schvalovací workflow od získání podkladů po aktivaci.

---

# 5. Schvalovací workflow

## 5.1 Zahájení posouzení

Právní workflow začíná nejpozději při přechodu providera do stavu `REVIEW` podle `MM-PRV-002`.

Technické testování smí před úplným právním schválením probíhat pouze tehdy, pokud:

- je omezeno na nezbytný rozsah,
- nevede k veřejné publikaci,
- nevytváří nepovolený dlouhodobý archiv,
- nepoužívá obcházení ochranných opatření,
- je evidováno jako test,
- lze je okamžitě zastavit a odstranit.

## 5.2 Shromáždění podkladů

Povinně se shromažďuje podle relevance:

- smlouva,
- objednávka,
- tarifní podmínky,
- licenční podmínky,
- podmínky API,
- všeobecné obchodní podmínky,
- privacy dokumentace,
- Data Processing Agreement,
- popis oprávněných produktů,
- pravidla atribuce,
- pravidla pro média,
- pravidla pro archivaci a ukončení,
- ceník a limity,
- potvrzení poskytovatele,
- aktuální technická dokumentace.

## 5.3 Snapshot podmínek

Před rozhodnutím se vytvoří řízený snapshot všech relevantních podmínek.

Snapshot musí být spojen s:

- providerem,
- datem získání,
- verzí,
- jazykem,
- zdrojovou adresou,
- hashem nebo jiným identifikátorem,
- osobou nebo systémem, který snapshot vytvořil.

## 5.4 Rozklad plánovaného použití

Technická a produktová strana musí popsat plánované použití.

Minimálně:

- která data budou získávána,
- jak často,
- jakým způsobem,
- kde budou uložena,
- jak dlouho,
- jak budou transformována,
- s čím budou kombinována,
- kdo k nim bude mít přístup,
- kde budou zobrazena,
- zda budou poskytována třetím stranám,
- zda budou použita komerčně,
- zda budou použita pro modely nebo analýzy.

Právní posouzení bez konkrétního popisu použití není dostatečné.

## 5.5 Vyplnění matice práv

Pro každý relevantní způsob použití se určí:

- stav práva,
- podmínky,
- zákaz,
- důkazní podklad,
- technická kontrola,
- datum expirace nebo revalidace.

## 5.6 Technický návrh vynucení

Před aktivací musí být určeno, jak systém zajistí dodržení podmínek.

Příklady:

- zákaz veřejného zobrazení,
- omezení pouze na interní staging,
- automatická atribuce,
- omezení území,
- zákaz exportu,
- zákaz použití médií,
- časově omezená retence RAW,
- zákaz partner feedu,
- limit requestů,
- povinné odstranění po ukončení.

## 5.7 Schválení

Schválení musí mít definovanou odpovědnou roli.

U zdrojů s nízkým rizikem může být použit standardní governance approval.

U vysokého rizika musí být vyžádáno odborné právní posouzení.

Schválení nesmí provést pouze osoba, která má technický nebo obchodní zájem na rychlém spuštění zdroje, pokud existuje významný nevyřešený konflikt.

## 5.8 Aktivace

Provider smí přejít do produkčního `ACTIVE` pouze tehdy, pokud:

- právní profil je `APPROVED` nebo `APPROVED_WITH_CONDITIONS`,
- technická konfigurace odpovídá schváleným právům,
- podmínky jsou vynutitelné,
- odpovědné osoby jsou známy,
- je nastaveno datum revalidace,
- existuje bezpečná cesta pro HOLD.

## 5.9 Závěr kapitoly

Schvalovací workflow propojuje právní podklady, konkrétní technické použití a systémové blokace. Přínosem je, že provider není schválen abstraktně, ale pouze pro přesně popsaný rozsah. Následující kapitola řeší právo přístupu a automatizovaného získávání dat.

---

# 6. Právo přístupu a získávání dat

## 6.1 Přístup není automaticky licence

Technická možnost otevřít stránku, stáhnout soubor nebo zavolat endpoint není sama o sobě dokladem oprávnění k dalšímu použití.

Musí být odděleno:

- oprávnění ke vstupu,
- oprávnění k automatizaci,
- oprávnění ke kopírování,
- oprávnění k systematickému získávání,
- oprávnění k dalšímu zpracování,
- oprávnění k publikaci.

## 6.2 API přístup

U API se ověřuje zejména:

- rozsah účtu,
- tarif,
- povolené endpointy,
- povolené sporty a entity,
- request limity,
- zákaz sdílení klíče,
- počet aplikací nebo uživatelů,
- produkční versus testovací použití,
- způsob cachování,
- zákaz další distribuce,
- povinnost ochrany přihlašovacích údajů.

## 6.3 Automatizovaný sběr z webu

Před automatizovaným sběrem se posuzuje:

- podmínka použití webu,
- ochranná opatření,
- přístupové limity,
- zákaz scraperů nebo robotů,
- rozsah a četnost sběru,
- dopad na službu,
- databázová práva,
- autorská práva,
- osobní údaje,
- zamýšlená komerční činnost.

Soubor `robots.txt` nebo jiný technický signál se eviduje jako provozní pravidlo přístupu. Nesmí být považován za úplnou licenci k ukládání, kombinování nebo publikaci obsahu.

## 6.4 Zákaz obcházení

Nesmí se bez výslovného schválení používat postupy, jejichž účelem je obcházet:

- autentizaci,
- paywall,
- geografické omezení,
- rate limiting,
- blokaci účtu,
- CAPTCHA,
- přístupové řízení,
- technická ochranná opatření,
- zákaz určitého endpointu nebo datasetu.

## 6.5 Identita klienta

Pokud to podmínky nebo provozní standard vyžadují, automatizovaný klient musí používat:

- jednoznačný User-Agent,
- kontaktní údaje,
- rozumné časování,
- retry s řízeným backoff,
- respektování limitů,
- omezení souběhu.

## 6.6 Testovací získávání

Testovací harvest musí mít:

- omezený rozsah,
- časové omezení,
- označení testovacího účelu,
- definovanou retenci,
- zákaz veřejné publikace bez schválení,
- možnost úplného odstranění.

## 6.7 Závěr kapitoly

Právo získávání dat musí být posouzeno odděleně od jejich dalšího použití. Přínosem je prevence situace, kdy technicky funkční worker vytváří právně nepoužitelný dataset. Následující kapitola stanovuje pravidla pro ukládání, cache, zálohy a dlouhodobou archivaci.

---

# 7. Ukládání, cache, zálohy a archivace

## 7.1 Samostatné režimy uložení

Rozlišují se minimálně:

- tranzitní technická paměť,
- krátkodobá cache,
- RAW úložiště,
- staging,
- kanonické uložení,
- provozní log,
- záloha,
- dlouhodobý historický archiv,
- vývojová nebo testovací kopie.

Každý režim může mít jiné licenční podmínky.

## 7.2 RAW uložení

RAW odpověď může obsahovat více informací, než které jsou následně použity v kanonické vrstvě.

Právo na interní zpracování vybraných atributů nemusí automaticky znamenat právo uchovat celý RAW payload bez časového omezení.

RAW retence se proto stanovuje samostatně.

## 7.3 Doba uchování

Pro každý dataset se eviduje:

- minimální nezbytná doba,
- maximální povolená doba,
- důvod uchování,
- okamžik zahájení lhůty,
- pravidlo prodloužení,
- pravidlo výmazu,
- výjimka pro spor, audit nebo právní povinnost.

## 7.4 Historická data

Historická hodnota dat je pro MatchMatrix strategická.

Dlouhodobý archiv však může být vytvořen pouze tehdy, pokud:

- licence archivaci dovoluje,
- smlouva ji nezakazuje,
- je známo postavení dat po skončení tarifu,
- jsou řešeny osobní údaje,
- jsou řešena práva k médiím,
- je znám rozsah dalšího zobrazování.

## 7.5 Zálohy

Záloha není automaticky mimo licenční režim.

Musí být určeno:

- kolik kopií je povoleno nebo nezbytných,
- kde mohou být uloženy,
- kdo k nim má přístup,
- jak jsou chráněny,
- jak se provede výmaz při ukončení,
- jak se zabrání opětovnému obnovení zakázaných dat.

## 7.6 Vývojové a testovací kopie

Vývojové prostředí nesmí nekontrolovaně duplikovat celý licencovaný dataset.

Preferuje se:

- anonymizovaný vzorek,
- minimální reprezentativní sada,
- syntetická data,
- časově omezená kopie,
- oddělené přístupové řízení.

## 7.7 Uchování důkazů versus výmaz dat

Při ukončení nebo sporu může být nutné vymazat obsah, ale zachovat důkaz o tom:

- odkud data pocházela,
- kdy byla používána,
- jaké podmínky platily,
- jak bylo ukončení provedeno.

Auditní metadata mají být oddělena od samotného licencovaného obsahu.

## 7.8 Závěr kapitoly

Pravidla uložení rozlišují krátkodobou cache, RAW, staging, kanonická data, zálohy a historický archiv. Přínosem je kontrolovaná retence bez automatického předpokladu, že jednou získaná data lze uchovávat trvale. Následující kapitola řeší transformaci, kombinování a odvozené výstupy.

---

# 8. Transformace, kombinování a odvozená data

## 8.1 Technická normalizace

Normalizace může zahrnovat:

- převod datových typů,
- sjednocení časových pásem,
- úpravu textového formátu,
- mapování identifikátorů,
- odstranění technických duplicit,
- převod do interního schématu.

I technická transformace musí být pokryta schváleným právem interního zpracování.

## 8.2 Kombinování zdrojů

MatchMatrix používá víceproviderový model.

Při kombinování se musí ověřit, zda licence dovoluje:

- spojování s konkurenčním zdrojem,
- použití v souhrnném profilu,
- atributové doplňování,
- vytváření jednotné kanonické entity,
- uchování zdrojové provenance,
- publikaci výsledku kombinace.

## 8.3 Atributová provenance

Každý významný atribut má mít dohledatelný původ.

Provenance musí umožnit:

- oddělit data při právním HOLD,
- odstranit dotčený zdroj,
- přepočítat odvozené výstupy,
- ověřit atribuci,
- zjistit, který provider ovlivnil výsledek.

## 8.4 Odvozená data

Za odvozené výstupy mohou být považovány například:

- ratingy,
- predikce,
- agregované statistiky,
- skóre kvality,
- normalizované indexy,
- interní klasifikace,
- modelové příznaky,
- souhrnné reporty.

Skutečnost, že výstup vytvořil algoritmus MatchMatrix, neznamená automaticky, že původní licenční omezení přestala být relevantní.

Musí být posouzeno:

- zda lze původní data z výstupu rekonstruovat,
- zda výstup nahrazuje původní dataset,
- zda licence omezuje deriváty,
- zda je vyžadována atribuce,
- zda je výstup možné komerčně poskytovat.

## 8.5 Text and data mining a strojové učení

Použití obsahu pro text and data mining nebo strojové učení musí být evidováno jako samostatný účel.

Ověřuje se zejména:

- právní přístup k obsahu,
- licenční omezení,
- případná výhrada práv,
- možnost uchování pracovních kopií,
- použití výstupního modelu,
- osobní údaje,
- možnost reprodukce chráněného obsahu ve výstupu.

## 8.6 Konflikt licencí

Při kombinaci více zdrojů může vzniknout konflikt, například:

- zákaz další distribuce versus plánované API,
- share-alike versus proprietární produkt,
- nekomerční licence versus placená služba,
- povinná atribuce, kterou nelze v cílovém kanálu splnit,
- zákaz kombinace s konkurenčním datasetem,
- rozdílné povinnosti výmazu.

Konflikt musí vést do `REVIEW_REQUIRED` nebo `HOLD`.

## 8.7 Závěr kapitoly

Transformace a kombinování musí zachovat provenance a respektovat práva jednotlivých zdrojů. Přínosem je schopnost bezpečně vytvářet kanonická a odvozená data bez ztráty vazby na původní omezení. Následující kapitola řeší veřejné zobrazení, export a redistribuci.

---

# 9. Veřejné zobrazení, export a redistribuce

## 9.1 Veřejné zobrazení

Povolení interního zpracování neznamená automaticky povolení veřejného zobrazení.

Pro veřejné zobrazení se určuje:

- které atributy lze zobrazit,
- v jakém produktu,
- zda je nutná atribuce,
- zda je omezen počet záznamů,
- zda je povolena historie,
- zda jsou povoleny detailní statistiky,
- zda lze zobrazit média,
- zda je použití komerční.

## 9.2 Web a mobilní aplikace

Webový a mobilní kanál mohou mít odlišné podmínky.

Licenční profil musí umožnit samostatně řídit:

- veřejnou stránku,
- přihlášenou část,
- placenou část,
- mobilní aplikaci,
- push notifikace,
- widget,
- vložený obsah.

## 9.3 Veřejné API

Poskytování přes API představuje samostatnou formu distribuce.

Musí být výslovně ověřeno:

- zda je redistribuce povolena,
- zda lze data stahovat hromadně,
- zda lze data ukládat u klienta,
- zda je nutná atribuce,
- zda existují limity,
- zda je nutné oddělit vlastní data MatchMatrix od licencovaných atributů,
- zda je povoleno poskytování odvozených dat.

## 9.4 Exporty a reporty

PDF, CSV, XLSX, datový export, e-mailový report nebo partnerský feed mohou umožnit další kopírování mimo kontrolu platformy.

Proto se posuzují odděleně od pouhého zobrazení na stránce.

## 9.5 Partner sharing

Předání dat partnerovi musí být kryto:

- původní licencí,
- samostatnou partnerskou smlouvou,
- povoleným účelem,
- bezpečnostními podmínkami,
- pravidly výmazu,
- zákazem dalšího neoprávněného předání.

## 9.6 Omezení rekonstruovatelnosti

Pokud licence dovoluje pouze odvozené výstupy, nesmí export umožnit snadnou rekonstrukci původního licencovaného datasetu.

## 9.7 Geografická omezení

Pokud je použití omezeno územím, musí být určeno:

- podle čeho se území vyhodnocuje,
- zda se omezení týká uživatele, společnosti, serveru nebo produktu,
- jak se řeší roaming, VPN a CDN,
- jak se blokuje zakázaný kanál.

## 9.8 Závěr kapitoly

Veřejné zobrazení, API, export a partner sharing jsou samostatné formy využití, které vyžadují vlastní oprávnění. Přínosem je ochrana před situací, kdy interně licencovaná data opustí kontrolované prostředí. Následující kapitola stanovuje pravidla atribuce a zachování původu.

---

# 10. Atribuce a označení původu

## 10.1 Povinnost atribuce

Atribuce může být:

- licenční podmínkou,
- smluvní podmínkou,
- podmínkou konkrétního média,
- podmínkou otevřených dat,
- podmínkou odvozeného použití.

Nesmí být řešena pouze ručním textem v jedné části aplikace.

## 10.2 Atribuční profil

Pro každý zdroj se eviduje:

- přesný požadovaný název,
- povinný text,
- povinný odkaz,
- povinné logo,
- minimální velikost,
- zakázané úpravy,
- jazykové varianty,
- umístění,
- kanály, ve kterých se musí zobrazit,
- podmínky pro export a API.

## 10.3 Technické vynucení

Atribuce má být generována z centrálního profilu.

Nesmí být pevně zapsána v mnoha oddělených částech aplikace bez řízené aktualizace.

## 10.4 Zachování metadat a oznámení

Nesmí být bez oprávnění odstraňovány:

- copyright notice,
- informace o autorovi,
- licence,
- source credit,
- embedded metadata,
- identifikace media assetu,
- vodoznak,
- informace o správě práv.

## 10.5 Zákaz klamavé prezentace

Atribuce nesmí vytvářet nepravdivý dojem:

- partnerství,
- oficiálního schválení,
- sponzorství,
- výhradního vztahu,
- vlastnictví dat,
- autorství MatchMatrix k cizímu obsahu.

## 10.6 Atribuce více zdrojů

Při kombinování se stanoví pravidlo, zda se atribuuje:

- každý atribut,
- každý záznam,
- stránka,
- dataset,
- souhrnná sekce zdrojů,
- API metadata.

Řešení musí být srozumitelné uživateli a současně technicky udržitelné.

## 10.7 Závěr kapitoly

Atribuce je řízená produktová a technická povinnost, nikoli pouze dekorativní text. Přínosem je konzistentní plnění licenčních podmínek ve všech kanálech. Následující kapitola řeší zvláštní režim fotografií, videí, článků, log a ochranných známek.

---

# 11. Média, články, loga a ochranné známky

## 11.1 Oddělení dat a médií

Faktické sportovní údaje, textové dílo, fotografie, video, zvuk, grafika, logo a ochranná známka mají rozdílný právní režim.

Schválení sportovního datasetu nesmí automaticky schválit mediální obsah dostupný ze stejného zdroje.

## 11.2 Fotografie

U každé fotografie nebo skupiny fotografií se eviduje:

- autor nebo nositel práv,
- licence,
- zdroj,
- povolené úpravy,
- povolené rozlišení,
- povolené kanály,
- doba použití,
- území,
- atribuce,
- možnost komerčního použití,
- právo zachycené osoby, je-li relevantní.

## 11.3 Video a zvuk

U videa a zvuku se posuzuje zejména:

- právo rozmnožování,
- právo streamování nebo zpřístupnění,
- možnost embed použití,
- geoblokace,
- reklamní a komerční omezení,
- délka klipu,
- hudební a komentátorská práva,
- povinnost použít originální přehrávač.

## 11.4 Články a tiskové zprávy

Samostatně se rozlišuje:

- právo zobrazit celý text,
- právo zobrazit krátkou ukázku,
- právo vytvořit vlastní shrnutí,
- právo použít titulek,
- právo použít náhledový obrázek,
- povinnost odkázat na originál,
- zákaz automatizovaného přebírání.

## 11.5 Loga, erby a ochranné známky

Použití loga může být omezeno i tehdy, když je logo veřejně dostupné.

Musí být ověřeno:

- oprávnění k zobrazení,
- povolené rozměry a úpravy,
- ochranná zóna,
- zákaz změny barev nebo proporcí,
- zákaz použití způsobem vytvářejícím dojem partnerství,
- pravidla v placeném produktu.

## 11.6 Náhledy a odvozené vizuály

Vytvoření thumbnailu, ořezu, komprese, koláže nebo AI úpravy může být samostatně omezeno.

Technická potřeba optimalizace obrazu nesmí automaticky převážit nad licenční podmínkou.

## 11.7 Asset-level řízení

Mediální práva mají být řízena na úrovni konkrétního assetu nebo přesně definované kolekce.

Doporučené stavy:

- `MEDIA_APPROVED`,
- `MEDIA_APPROVED_WITH_ATTRIBUTION`,
- `MEDIA_INTERNAL_ONLY`,
- `MEDIA_EMBED_ONLY`,
- `MEDIA_EXPIRED`,
- `MEDIA_HOLD`,
- `MEDIA_PROHIBITED`.

## 11.8 Závěr kapitoly

Mediální obsah vyžaduje samostatné asset-level řízení oddělené od sportovních dat. Přínosem je zabránění neoprávněnému použití fotografií, videí, článků a log při jinak povoleném použití faktických údajů. Následující kapitola řeší osobní údaje a profily sportovních osob.

---

# 12. Osobní údaje a profily osob

## 12.1 Rozsah

People Layer může zpracovávat údaje o:

- hráčích,
- trenérech,
- rozhodčích,
- funkcionářích,
- členech realizačních týmů,
- dalších sportovních osobách.

I veřejně známý nebo veřejně dostupný údaj může být osobním údajem.

## 12.2 Zákonnost a účel

Pro každou skupinu osobních údajů musí být určen:

- účel,
- právní základ,
- zdroj,
- kategorie osob,
- příjemci,
- doba uchování,
- způsob aktualizace,
- bezpečnostní opatření,
- způsob řešení práv subjektu údajů.

## 12.3 Minimalizace

Zpracovávají se pouze údaje potřebné pro definovaný sportovní a produktový účel.

Bez zvláštního důvodu se nemají získávat nebo zveřejňovat:

- soukromé kontakty,
- přesná soukromá adresa,
- rodná čísla,
- identifikační doklady,
- soukromé rodinné informace,
- citlivé osobní údaje,
- informace nesouvisející se sportovní rolí.

## 12.4 Veřejně známé osoby

Veřejná sportovní činnost může odůvodňovat zpracování některých profesních nebo veřejných údajů.

To však neznamená neomezené právo zpracovávat jakékoliv informace o soukromí osoby.

Rozsah musí být přiměřený, relevantní a spojený s definovaným účelem platformy.

## 12.5 Zvláštní kategorie údajů

Údaje o zdraví, biometrice, politických názorech, náboženství nebo jiných zvláštních kategoriích se nesmí zpracovávat pouze proto, že jsou dostupné v médiích nebo na sociálních sítích.

Takové použití vyžaduje samostatné odborné posouzení a technické blokace.

## 12.6 Nezletilé osoby

U nezletilých sportovců se používá zvýšená ochrana.

Musí být omezen zejména:

- rozsah profilu,
- fotografie,
- kontaktní údaje,
- detailní osobní informace,
- dlouhodobá dohledatelnost,
- přenos dat třetím stranám.

## 12.7 Přesnost a opravy

Osobní profily musí mít postup pro:

- opravu chybného údaje,
- označení sporného údaje,
- aktualizaci zdroje,
- řešení duplicity,
- omezení zpracování,
- výmaz, pokud je oprávněný,
- zachování auditní stopy bez zbytečného ponechání sporného obsahu.

## 12.8 Transparentnost

Projekt musí být připraven vysvětlit:

- jaké osobní údaje zpracovává,
- odkud je získává,
- proč je používá,
- jak dlouho je uchovává,
- komu je zpřístupňuje,
- jak lze uplatnit práva.

## 12.9 Přenos a poskytovatelé služeb

Pokud jsou osobní údaje zpracovávány přes externí služby, musí být posouzeno:

- postavení správce a zpracovatele,
- smluvní zajištění,
- umístění zpracování,
- přeshraniční přenos,
- subdodavatelé,
- bezpečnost,
- incidentní postup.

## 12.10 Závěr kapitoly

Osobní údaje sportovních osob vyžadují vlastní právní základ, účel, minimalizaci a postup oprav. Přínosem je ochrana People Layer před nekontrolovaným přebíráním veřejně dostupných, ale nepřiměřených informací. Následující kapitola řeší obchodní, tarifní a smluvní omezení.

---

# 13. Obchodní, tarifní a smluvní omezení

## 13.1 Tarif jako právní hranice

Tarif neurčuje pouze cenu a request budget.

Může určovat také:

- povolené sporty,
- historickou hloubku,
- živá data,
- počet aplikací,
- počet zákazníků,
- interní nebo veřejné použití,
- možnost zobrazování,
- možnost dalšího prodeje,
- povolené území,
- povolený typ společnosti.

## 13.2 Zákaz redistribuce a resale

Častým omezením je zákaz:

- dalšího prodeje dat,
- poskytování surového datasetu,
- vytvoření konkurenčního feedu,
- sublicence,
- umožnění hromadného stažení,
- sdílení účtu nebo klíče.

Technický návrh produktu musí tato omezení respektovat.

## 13.3 Omezení konkurenčního použití

Smlouva může omezovat použití pro:

- konkurenční datovou službu,
- benchmarking,
- vývoj náhradního datasetu,
- zpětné inženýrství,
- model určený k replikaci služby,
- poskytování stejných dat třetím stranám.

Taková omezení musí být označena jako strategické riziko.

## 13.4 Limity a overage

Musí být známo:

- základní limit,
- způsob měření,
- chování po překročení,
- cena nadlimitního použití,
- možnost automatického navýšení,
- odpovědná osoba,
- maximální schválený náklad.

Překročení komerčního limitu může mít zároveň smluvní dopad.

## 13.5 SLA a podpora

Eviduje se:

- dostupnost služby,
- reakční doba,
- údržba,
- oznámení změn,
- podpora migrace,
- kompenzace,
- omezení odpovědnosti.

SLA nesmí být zaměňováno s právem na obsah.

## 13.6 Důvěrnost

Smlouva nebo dokumentace může obsahovat důvěrné informace.

Důvěrné části nesmí být:

- vloženy do veřejné dokumentace,
- commitovány do běžného Git repozitáře,
- zveřejněny v logu,
- předány AI nebo externí službě bez oprávnění,
- zpřístupněny neoprávněným osobám.

## 13.7 Subdodavatelé a cloud

Musí být ověřeno, zda data mohou být zpracována:

- na PC1 nebo PC2,
- v cloudové infrastruktuře,
- v CDN,
- u analytického poskytovatele,
- u AI služby,
- u dalšího technického dodavatele.

## 13.8 Auditní a oznamovací povinnosti

Provider může požadovat:

- audit použití,
- hlášení incidentu,
- evidenci zákazníků,
- schválení produktu,
- pravidelný reporting,
- součinnost při kontrole.

Tyto povinnosti musí mít vlastníka a termín.

## 13.9 Odpovědnost, indemnity a spory

Rizikové smluvní podmínky zahrnují:

- nepřiměřenou odpovědnost,
- povinnost náhrady škody třetím stranám,
- jednostranné změny,
- krátkou výpovědní dobu,
- povinnou arbitráž,
- vzdálenou jurisdikci,
- okamžitý výmaz bez přechodného období.

Tyto podmínky musí být zohledněny při strategickém hodnocení providera.

## 13.10 Závěr kapitoly

Tarif a smlouva určují nejen cenu, ale také produktový, technický a strategický rozsah použití. Přínosem je propojení právního profilu s request budgetem, cloudem, exportem a provozní odpovědností. Následující kapitola stanovuje sledování změn podmínek a povinnou revalidaci.

---

# 14. Sledování změn podmínek a revalidace

## 14.1 Změny jako provozní událost

Změna smlouvy, licence, tarifu, dokumentace nebo vlastnictví providera je událost s možným dopadem na produkční provoz.

Nesmí být řešena pouze jako administrativní informace.

## 14.2 Sledované změny

Sleduje se zejména:

- nová verze podmínek,
- změna data účinnosti,
- změna ceny,
- změna limitu,
- změna povoleného použití,
- nový zákaz redistribuce,
- změna atribuce,
- změna retence,
- změna pravidel médií,
- změna pravidel osobních údajů,
- změna vlastníka nebo smluvní strany,
- ukončení endpointu,
- migrace na novou službu,
- změna rozhodného práva.

## 14.3 Způsob detekce

Detekce může používat:

- pravidelnou ruční kontrolu,
- oznámení providera,
- changelog,
- e-mail podpory,
- automatické porovnání textu,
- hash dokumentu,
- kontrolu data účinnosti,
- smluvní kalendář.

Automatická detekce změny nesmí automaticky vytvořit nové právní schválení.

## 14.4 Klasifikace dopadu

| Dopad | Příklad | Reakce |
|---|---|---|
| NONE | Oprava formátování bez významu. | Uložit snapshot a uzavřít kontrolu. |
| LOW | Upřesnění bez změny oprávnění. | Aktualizovat profil. |
| MEDIUM | Nová atribuce nebo provozní podmínka. | Upravit technické vynucení před účinností. |
| HIGH | Omezení archivace, publikace nebo distribuce. | `REVALIDATION_REQUIRED`, případně částečný HOLD. |
| CRITICAL | Zákaz použití, výzva k odstranění, okamžité ukončení. | Okamžitý právní HOLD. |

## 14.5 Datum účinnosti a přechod

Musí být určeno:

- kdy změna začne platit,
- zda platí pro dříve získaná data,
- zda existuje přechodné období,
- které produkty jsou dotčeny,
- zda je nutný výmaz,
- zda lze použít fallback,
- kdo odpovídá za dokončení změny.

## 14.6 Periodická revalidace

I bez zjištěné změny musí být právní profil pravidelně revalidován.

Frekvence se řídí rizikem:

- nízké riziko: nejméně při výroční kontrole nebo před významnou změnou produktu,
- kontrolované riziko: častěji podle podmínek,
- vysoké riziko: podle stanoveného krátkého intervalu a každé významné události,
- média a osobní údaje: podle expirace práv a účelu.

## 14.7 Expirace bez kontroly

Pokud uplyne povinný termín revalidace, stav se nesmí automaticky ponechat jako plně schválený.

Doporučený přechod:

```text
APPROVED
→ REVALIDATION_REQUIRED
→ omezený provoz nebo HOLD podle rizika
```

## 14.8 Závěr kapitoly

Sledování změn převádí právní podmínky do průběžně řízeného provozního procesu. Přínosem je včasná reakce před účinností nové podmínky. Následující kapitola stanovuje právní incident a stav HOLD.

---

# 15. Právní incident a HOLD

## 15.1 Právní incident

Právní incident je událost, která může znamenat, že současné získávání, uchování, zpracování nebo publikace není oprávněná.

Příklady:

- výzva providera,
- oznámení nositele práv,
- stížnost osoby,
- změna podmínek,
- zjištěná absence licence,
- překročení schváleného rozsahu,
- neoprávněné použití fotografie,
- únik licencovaného datasetu,
- neoprávněné sdílení klíče,
- publikace zakázaného atributu,
- spor o atribuci,
- zjištěné zpracování citlivých osobních údajů.

## 15.2 Typy HOLD

| Stav | Význam |
|---|---|
| HARVEST_HOLD | Zastaví nové získávání dat. |
| PROCESSING_HOLD | Zastaví parser, transformaci nebo merge. |
| PUBLICATION_HOLD | Zastaví veřejné zobrazení. |
| EXPORT_HOLD | Zastaví API, exporty a partner feedy. |
| MEDIA_HOLD | Zastaví použití dotčených médií. |
| LEGAL_HOLD | Zastaví všechny právně dotčené operace podle stanoveného rozsahu. |
| DELETION_HOLD | Dočasně zabrání výmazu, pokud je nutné zachovat důkaz pro spor nebo zákonnou povinnost. |

HOLD musí být co nejpřesnější. Pokud je problém pouze u fotografií, nemá se bez důvodu zastavit celý Core dataset.

## 15.3 Spouštěče

HOLD může být spuštěn:

- ručním governance rozhodnutím,
- právní nebo bezpečnostní rolí,
- ověřeným incidentním pravidlem,
- automatickou detekcí kritické expirace,
- přijetím výzvy nebo takedown požadavku.

Automatický spouštěč může provoz bezpečně zastavit. Nesmí však samostatně rozhodnout o konečném právním výsledku.

## 15.4 Okamžité kroky

Po vzniku incidentu se podle rozsahu provede:

1. identifikace dotčeného providera a datasetu,
2. zastavení nového získávání,
3. zastavení publikace nebo exportu,
4. ochrana důkazů,
5. vytvoření incidentního záznamu,
6. identifikace dotčených produktů,
7. posouzení dat v cache, zálohách a partnerech,
8. určení odpovědné osoby,
9. příprava nápravného rozhodnutí.

## 15.5 Důkazní stopa

Incidentní záznam obsahuje:

- čas zjištění,
- zdroj oznámení,
- přesný rozsah,
- podmínku nebo právo,
- dotčené verze dat,
- provedené blokace,
- osoby a systémy s přístupem,
- komunikaci,
- rozhodnutí,
- datum uzavření,
- povinnost další kontroly.

## 15.6 Obnovení provozu

HOLD lze zrušit pouze po doložení:

- právního nebo smluvního oprávnění,
- odstranění příčiny,
- opravy technického vynucení,
- nápravy atribuce,
- odstranění zakázaného obsahu,
- aktualizace licenčního profilu,
- schválení odpovědnou rolí.

## 15.7 Závěr kapitoly

Právní HOLD vytváří bezpečný způsob okamžitého a cíleného zastavení rizikového použití. Přínosem je ochrana projektu bez nutnosti mazat auditní stopu nebo nekontrolovaně zastavit nesouvisející data. Následující kapitola řeší ukončení a nahrazení providera.

---

# 16. Ukončení a nahrazení providera

## 16.1 Důvody ukončení

Provider může být ukončen zejména kvůli:

- skončení smlouvy,
- neobnovení tarifu,
- změně podmínek,
- právnímu zákazu,
- dlouhodobému HOLD,
- cenové neudržitelnosti,
- nedostatečné kvalitě,
- zániku služby,
- strategické náhradě,
- bezpečnostnímu incidentu.

## 16.2 Ukončovací plán

Před ukončením se určí:

- datum posledního povoleného přístupu,
- datum zastavení workerů,
- datum odvolání klíčů,
- dopad na routing,
- náhradní provider,
- osud RAW dat,
- osud kanonických atributů,
- osud médií,
- osud záloh,
- osud partner feedů,
- povinnosti atribuce po ukončení,
- povinnosti výmazu,
- zachování auditních metadat.

## 16.3 Data získaná před ukončením

Musí být samostatně rozhodnuto, zda dříve získaná data:

- lze ponechat a dále zobrazovat,
- lze ponechat pouze interně,
- lze ponechat pouze v odvozené podobě,
- musí být po určité době odstraněna,
- musí být okamžitě odstraněna,
- mohou zůstat pouze jako důkazní metadata.

## 16.4 Provider mapy a historie

Provider mapy a auditní záznamy se standardně nemažou pouze proto, že je zdroj ukončen.

Musí však být odděleno:

- samotné licencované nebo chráněné datum,
- interní identifikátor,
- informace o historickém původu,
- technický záznam o dřívějším použití.

## 16.5 Odvolání přístupů

Po ukončení se provede:

- deaktivace API klíče,
- odstranění tokenu z runtime,
- zrušení naplánovaných úloh,
- odstranění přístupu uživatelů,
- aktualizace tajných údajů,
- kontrola logů a konfigurací,
- potvrzení, že žádný worker zdroj dále nepoužívá.

## 16.6 Nahrazení

Náhradní provider musí projít vlastním schvalovacím a licenčním workflow.

Fallback nesmí být aktivován jen proto, že primární provider právně skončil.

## 16.7 Ověření výmazu nebo omezení

Pokud je vyžadován výmaz, musí být ověřeno:

- produkční úložiště,
- staging,
- RAW,
- cache,
- zálohy,
- exporty,
- testovací kopie,
- partner systémy,
- media storage.

Výsledek musí být auditovatelný.

## 16.8 Závěr kapitoly

Ukončení providera je řízený proces zahrnující data, přístupy, routing, zálohy, média a smluvní povinnosti. Přínosem je bezpečná nahraditelnost zdroje bez ztráty historie a bez ponechání nepovolených kopií. Následující kapitola navrhuje databázový model a auditní stopu právního řízení.

---

# 17. Databázový model a auditní stopa

## 17.1 Princip

Právní a licenční stav musí být veden jako strukturovaná data, nikoli pouze jako textová poznámka v dokumentu.

Dokumentace stanovuje pravidla. Databázový registr má řídit konkrétní providery, smlouvy, licence, práva, důkazy, incidenty a expirace.

## 17.2 Doporučené objekty

### provider_legal_profiles

Centrální právní profil providera.

Doporučená pole:

- `legal_profile_id`,
- `provider_id`,
- `legal_status`,
- `risk_level`,
- `jurisdiction`,
- `valid_from`,
- `valid_to`,
- `review_due_at`,
- `approved_by`,
- `approved_at`,
- `source_scope`,
- `notes`,
- `created_at`,
- `updated_at`.

### provider_agreements

Evidence smluv, tarifů a licencí.

Doporučená pole:

- `agreement_id`,
- `provider_id`,
- `agreement_type`,
- `agreement_name`,
- `agreement_version`,
- `effective_from`,
- `effective_to`,
- `auto_renewal`,
- `termination_notice_days`,
- `evidence_reference`,
- `confidentiality_level`,
- `status`.

### provider_usage_rights

Matice jednotlivých práv.

Doporučená pole:

- `usage_right_id`,
- `legal_profile_id`,
- `right_code`,
- `right_status`,
- `dataset_scope`,
- `entity_scope`,
- `product_scope`,
- `territory_scope`,
- `conditions`,
- `enforcement_rule`,
- `valid_from`,
- `valid_to`.

### provider_terms_snapshots

Snapshoty podmínek.

Doporučená pole:

- `snapshot_id`,
- `provider_id`,
- `document_type`,
- `source_location`,
- `captured_at`,
- `effective_at`,
- `language_code`,
- `content_hash`,
- `storage_reference`,
- `previous_snapshot_id`,
- `change_detected`.

### provider_legal_reviews

Záznam jednotlivého posouzení.

Doporučená pole:

- `review_id`,
- `legal_profile_id`,
- `review_type`,
- `requested_at`,
- `completed_at`,
- `reviewed_by`,
- `decision`,
- `decision_scope`,
- `conditions`,
- `next_review_at`,
- `evidence_summary`.

### provider_legal_incidents

Evidence incidentů a HOLD.

Doporučená pole:

- `incident_id`,
- `provider_id`,
- `incident_type`,
- `severity`,
- `detected_at`,
- `source`,
- `affected_scope`,
- `hold_type`,
- `status`,
- `owner`,
- `resolved_at`,
- `resolution`.

### media_rights

Asset-level evidence médií.

Doporučená pole:

- `media_right_id`,
- `media_asset_id`,
- `provider_id`,
- `rights_holder`,
- `license_name`,
- `usage_status`,
- `attribution_text`,
- `valid_from`,
- `valid_to`,
- `territory_scope`,
- `allowed_transformations`,
- `evidence_reference`.

## 17.3 Oddělení dokumentu a tajných údajů

Databáze ani dokumentace nesmí obsahovat:

- API klíče,
- hesla,
- neveřejné tokeny,
- citlivé smluvní přílohy v nechráněné podobě,
- osobní kontakty bez potřeby,
- tajné obchodní informace bez přístupového řízení.

Evidence má používat bezpečný odkaz na řízené úložiště.

## 17.4 Vazba na execution trace

Každý providerový běh má být schopen doložit:

- právní profil použitý v době běhu,
- verzi práva,
- dataset scope,
- aktivní podmínky,
- případný HOLD,
- datum získání.

Tím lze zpětně ověřit, zda byl harvest v okamžiku spuštění povolen.

## 17.5 Historie změn

Právní stav se nesmí přepisovat bez historie.

Každá změna musí zachovat:

- předchozí hodnotu,
- novou hodnotu,
- důvod,
- autora,
- datum,
- související důkaz,
- dopad na provoz.

## 17.6 Závěr kapitoly

Strukturovaný databázový model umožňuje propojit smlouvu, práva, snapshoty, incidenty, média a skutečné providerové běhy. Přínosem je auditovatelnost rozhodnutí v čase. Následující kapitola popisuje panelové workflow a bezpečnou automatizaci.

---

# 18. Panelové workflow a automatizace

## 18.1 Cíl panelu

Budoucí providerový panel má zobrazovat právní stav stejně viditelně jako technický health stav.

Operátor musí na první pohled poznat:

- zda je provider právně schválen,
- jaký rozsah použití je povolen,
- kdy končí smlouva,
- kdy je nutná revalidace,
- zda existuje HOLD,
- zda je vyžadována atribuce,
- zda jsou média povolena,
- zda je povolen export a API.

## 18.2 Oddělené stavové indikátory

Panel má zobrazovat samostatně:

```text
TECHNICKÝ STAV
DATOVÁ KVALITA
EKONOMICKÝ STAV
PRÁVNÍ A LICENČNÍ STAV
```

Jeden zelený souhrnný indikátor nesmí zakrýt právní problém.

## 18.3 Povinné blokace

Panel nebo orchestrace musí blokovat například:

- aktivaci providera bez právního profilu,
- veřejnou publikaci při `PUBLIC_DISPLAY = PROHIBITED`,
- export při `API_REDISTRIBUTION = PROHIBITED`,
- média při `MEDIA_USE = UNKNOWN`,
- harvest při `AUTOMATED_COLLECTION = PROHIBITED`,
- dlouhodobý RAW archiv při `LONG_TERM_ARCHIVE = PROHIBITED`,
- běh po expiraci kritického oprávnění,
- použití při `LEGAL_HOLD`.

## 18.4 Upozornění

Panel má vytvářet včasná upozornění na:

- blížící se expiraci,
- datum revalidace,
- změnu podmínek,
- chybějící snapshot,
- nesplněnou atribuci,
- neuzavřený incident,
- neprovedený výmaz,
- změnu tarifu,
- chybějící potvrzení poskytovatele.

## 18.5 Automatické porovnání podmínek

Automatizace může:

- stáhnout novou verzi veřejných podmínek,
- vytvořit snapshot,
- vypočítat hash,
- porovnat změny,
- zvýraznit rozdílné části,
- vytvořit úkol k posouzení,
- dočasně přepnout stav do `REVALIDATION_REQUIRED`.

Automatizace nesmí sama rozhodnout, že změněné podmínky jsou právně přijatelné.

## 18.6 Atribuční služba

Centrální atribuční služba má poskytovat:

- správný text,
- odkaz,
- logo,
- jazykovou variantu,
- platnost,
- kanál,
- dataset.

Produkt nesmí používat vlastní neřízené kopie atribučních textů.

## 18.7 Takedown workflow

Panel má podporovat:

1. přijetí požadavku,
2. identifikaci assetu nebo datasetu,
3. okamžitý cílený HOLD,
4. dohledání původu,
5. rozhodnutí,
6. odstranění nebo obnovení,
7. auditní uzavření.

## 18.8 Závěr kapitoly

Panelové workflow převádí právní podmínky do viditelných stavů, blokací, expirací a incidentních akcí. Přínosem je praktické dodržování pravidel při každodenním provozu. Následující kapitola vymezuje role a odpovědnosti.

---

# 19. Role a odpovědnosti

## 19.1 Vlastník providera

Odpovídá za:

- úplnost providerového profilu,
- koordinaci technického a právního posouzení,
- aktuálnost smlouvy a tarifu,
- řešení změn,
- plán ukončení nebo náhrady.

## 19.2 Právní reviewer

Odpovídá za:

- odborné posouzení rizikových podmínek,
- výklad rozsahu práv,
- posouzení konfliktu licencí,
- incidentní doporučení,
- schválení nebo zákaz rizikového použití.

Role může být interní nebo externí podle potřeb projektu.

## 19.3 Datový architekt

Odpovídá za:

- atributovou provenance,
- oddělení dat podle licence,
- návrh retence,
- možnost selektivního výmazu,
- vazbu na RAW, staging a kanonické vrstvy.

## 19.4 Vývojář nebo integrační vlastník

Odpovídá za:

- implementaci schválených omezení,
- request limity,
- atribuci,
- blokaci nepovoleného exportu,
- zachování právního kontextu v execution trace,
- odstranění tajných údajů z kódu a logů.

## 19.5 Produktový vlastník

Odpovídá za:

- popis zamýšleného použití,
- identifikaci nových kanálů,
- kontrolu veřejného zobrazení,
- kontrolu placených funkcí,
- oznámení změny účelu před nasazením.

## 19.6 Operátor

Odpovídá za:

- sledování expirací a alertů,
- provedení HOLD podle pravidla,
- zastavení dotčených procesů,
- eskalaci incidentu,
- ověření nápravného kroku.

Operátor nesmí samostatně měnit právní stav na `APPROVED`.

## 19.7 Bezpečnostní role

Odpovídá za:

- ochranu přístupových údajů,
- řízení oprávnění,
- incidenty úniku dat,
- bezpečné odstranění,
- ochranu smluvních a osobních údajů.

## 19.8 Správce dokumentace

Odpovídá za:

- správnou evidenci dokumentů,
- verzování,
- vazby na providerové profily,
- auditní dohledatelnost,
- zachování schválených pravidel.

## 19.9 AI a automatizace

AI může:

- připravit souhrn,
- vyhledat změny,
- porovnat text,
- navrhnout klasifikaci,
- upozornit na chybějící právo,
- připravit kontrolní otázky.

AI nesmí bez lidského schválení:

- uzavřít právní posouzení,
- změnit `HOLD` na `APPROVED`,
- přijmout smluvní podmínky,
- rozšířit schválený účel,
- rozhodnout o sporu nebo odpovědnosti.

## 19.10 Závěr kapitoly

Role oddělují obchodní zájem, technickou implementaci, právní rozhodnutí, provoz a dokumentaci. Přínosem je kontrola konfliktu zájmů a jednoznačná odpovědnost. Následující kapitola shrnuje současný stav a cílový rozvoj.

---

# 20. Aktuální stav a cílový rozvoj

## 20.1 Aktuální stav

Providerová oblast MatchMatrix má vytvořeny hlavní dokumenty:

```text
MM-PRV-001  Providerový ekosystém MatchMatrix
MM-PRV-002  Životní cyklus a schvalování providerů
MM-PRV-003  Provider routing a fallback
MM-PRV-004  Provider Health Monitoring
MM-PRV-005  Integrace providerů do datových vrstev
MM-PRV-006  Právní a licenční řízení providerů
```

Existující architektura podporuje oddělení providerů, RAW, parseru, stagingu, mapování, merge, health stavů, fallbacku a auditní stopy.

Z dostupného dokumentačního kontextu však nelze potvrdit, že již existuje úplný strukturovaný registr všech konkrétních smluv, licencí, práv, expirací, media assetů a právních incidentů. Tento dokument proto stanovuje cílový standard, který musí být následně porovnán se skutečnou implementací.

## 20.2 Krátkodobé cíle

Krátkodobě je nutné:

- schválit tento dokument,
- určit umístění konkrétního providerového právního registru,
- vytvořit jednotnou matici práv,
- evidovat aktuální smlouvy a veřejné podmínky,
- vytvořit snapshoty podmínek,
- označit nejasné providery jako `REVIEW_REQUIRED`,
- oddělit práva k datům a médiím,
- doplnit datum revalidace.

## 20.3 Střednědobé cíle

Střednědobě je cílem:

- implementovat databázové objekty právního registru,
- propojit profil s provider routingem,
- blokovat nepovolené kanály,
- automatizovat atribuci,
- sledovat expirace,
- porovnávat změny podmínek,
- evidovat takedown a právní incidenty,
- propojit data s atributovou provenance.

## 20.4 Dlouhodobý cíl

Dlouhodobým cílem je právně bezpečný a auditovatelný providerový ekosystém, ve kterém systém automaticky:

- ověří existenci platného právního profilu,
- aplikuje schválený rozsah,
- zablokuje zakázané použití,
- upozorní na změnu nebo expiraci,
- aktivuje bezpečný HOLD,
- dohledá původ každého kritického atributu,
- připraví podklady pro lidské rozhodnutí.

Strategické a právní schválení zůstává vždy lidskou odpovědností.

## 20.5 Závěr kapitoly

Aktuální dokumentace vytváří technický základ, ale cílový stav vyžaduje strukturovaný právní registr a panelové blokace. Přínosem této kapitoly je oddělení ověřeného současného stavu od plánované implementace. Následující kapitola stanovuje vazby a referenční právní rámec.

---

# 21. Vazby a referenční právní rámec

## 21.1 Vazby na providerovou řadu

| Dokument | Vazba |
|---|---|
| MM-PRV-001 | Definuje providerový ekosystém a právní vhodnost jako jednu z hlavních dimenzí. |
| MM-PRV-002 | Řídí životní cyklus providera a přechody REVIEW, ACTIVE, HOLD a RETIRED. |
| MM-PRV-003 | Routing a fallback musí respektovat právní rozsah každého zdroje. |
| MM-PRV-004 | Právní a licenční stav je samostatná health dimenze a může aktivovat HOLD. |
| MM-PRV-005 | Technická integrace musí zachovat původ, rozsah, retenci a možnost selektivního zastavení. |

## 21.2 Vazby na hlavní dokumentaci

| Dokument | Vazba |
|---|---|
| MM-DOC-100 | Strategický a technický stav projektu. |
| MM-DOC-200 | Provider Governance, Source Governance, odpovědnosti a audit. |
| MM-DOC-300 | Víceproviderová architektura, datové vrstvy a Source Intelligence Layer. |
| MM-DOC-800 | Vývojové standardy, tajné údaje, workflow a provozní implementace. |
| MM-DB-001 | Databázové principy a odpovědnosti vrstev. |
| MM-DB-002 | Databázová schémata a registry. |
| MM-DB-003 | Datový slovník implementovaných objektů. |
| MM-REF-001 | Jednotné české překlady odborných pojmů. |
| MM-REF-002 | Výkladové definice, vazby a klikací navigace. |

## 21.3 Referenční právní zdroje

Při konkrétním posouzení se používá aktuální znění relevantních právních předpisů, smluv a licencí.

Mezi hlavní evropské a české referenční zdroje patří podle povahy použití zejména:

- směrnice 96/9/ES o právní ochraně databází,
- směrnice 2001/29/ES o autorském právu a právech souvisejících v informační společnosti,
- směrnice (EU) 2019/790 o autorském právu na jednotném digitálním trhu,
- nařízení (EU) 2016/679 – GDPR,
- nařízení (EU) 2022/868 – Data Governance Act, pokud je pro danou službu relevantní,
- nařízení (EU) 2023/2854 – Data Act, pokud je pro daný datový vztah relevantní,
- zákon č. 121/2000 Sb., autorský zákon, v aktuálním znění,
- zákon č. 110/2019 Sb., o zpracování osobních údajů, v aktuálním znění,
- rozhodné smluvní a občanskoprávní předpisy,
- pravidla příslušné jurisdikce, území a produktového trhu.

Výčet není úplný. Konkrétní provider může podléhat dalším předpisům, odvětvovým pravidlům, rozhodnému právu nebo smluvním závazkům.

## 21.4 Pravidlo aktuálnosti

Právní zdroj se musí posuzovat v aktuálním konsolidovaném znění a ve vztahu ke konkrétní jurisdikci.

Starý snapshot právního předpisu nebo stará verze licence může sloužit jako historický důkaz, nikoli automaticky jako současný podklad pro nové schválení.

## 21.5 Referenční katalog providerů

Konkrétní smlouvy, tarify, endpointy, práva a expirace nemají být udržovány přímo v tomto stabilním architektonickém dokumentu.

Mají být vedeny v řízeném providerovém registru nebo samostatném referenčním katalogu s databázovou podporou.

## 21.6 Závěr kapitoly

Vazby propojují právní řízení s životním cyklem, routingem, health monitoringem, integrací a databází. Přínosem je jednotná interpretace napříč celou providerovou oblastí. Následující kapitola obsahuje kontrolní kritéria dokumentu.

---

# 22. Kontrolní kritéria dokumentu

Dokument lze předložit ke schválení, pokud je potvrzeno:

- [ ] Document ID a cílové umístění odpovídají MM-STD-007.
- [ ] Dokument navazuje na MM-PRV-001 až MM-PRV-005.
- [ ] Dokument rozlišuje získávání, ukládání, archivaci, transformaci, kombinování, publikaci a redistribuci.
- [ ] Dokument obsahuje samostatná pravidla pro média a osobní údaje.
- [ ] Dokument zavádí jednoznačné právní stavy a matici práv.
- [ ] `UNKNOWN` není interpretováno jako povolení.
- [ ] Nejasnost vede do REVIEW nebo HOLD.
- [ ] Dokument neobsahuje API klíče, tokeny, hesla ani neveřejné smluvní údaje.
- [ ] Aktuální stav je oddělen od cílového návrhu.
- [ ] Každá hlavní kapitola obsahuje závěr se shrnutím, přínosem a návazností.
- [ ] Role lidského schválení je oddělena od AI a automatizace.
- [ ] Je popsána revalidace, změna podmínek a expirace.
- [ ] Je popsán právní incident, cílený HOLD a obnovení provozu.
- [ ] Je popsáno ukončení, výmaz, archivace a náhrada providera.
- [ ] Terminologie bude zkontrolována přes A23 proti MM-REF-001 a MM-REF-002.
- [ ] A17 neobsahuje nevyřešený strukturální blokátor.
- [ ] Schválení proběhne před Git commitem a databázovým importem.
- [ ] A24 VALIDATE_ONLY proběhne před A24 APPLY.
- [ ] A7 ověří integritu po importu.

## 22.1 Závěr kapitoly

Kontrolní kritéria sjednocují podmínky, které musí dokument splnit před schválením a publikací.

Přínosem kapitoly je vytvoření jednoznačné závěrečné kontroly strukturálního, terminologického, právního a procesního souladu dokumentu.

Po splnění uvedených kritérií může dokument pokračovat do kontroly terminologie A23, uživatelského schválení, Git commitu a následného databázového importu přes A24 a A7.

Na tuto kapitolu navazuje kapitola 23 – Historie verzí, která zaznamenává vznik a další vývoj dokumentu.

---

# 23. Historie verzí

| Verze | Datum | Stav | Popis |
|---|---|---|---|
| 0.9 | 2026-07-18 | DRAFT – NEEDS_USER_APPROVAL | První návrh dokumentu právního a licenčního řízení providerů, včetně matice práv, médií, osobních údajů, revalidace, HOLD, ukončení a cílového databázového modelu. |

---

# Závěr dokumentu

`MM-PRV-006` uzavírá základní providerovou řadu MatchMatrix z pohledu právního a licenčního řízení.

Dokument stanovuje, že technická dostupnost dat, existence API, veřejná webová stránka ani aktivní tarif samy o sobě neprokazují právo data získávat, ukládat, archivovat, kombinovat, publikovat nebo dále distribuovat.

Každý provider musí mít strukturovaný licenční profil a matici práv oddělující přístup, automatizovaný sběr, RAW uložení, dlouhodobou archivaci, interní zpracování, kombinování, odvozená data, text and data mining, veřejné zobrazení, API redistribuci, export, komerční použití a média.

Zvláštní režim se používá pro fotografie, video, články, loga, ochranné známky a osobní údaje sportovních osob. Každá změna podmínek, expirace nebo právní incident musí být auditovatelná a může aktivovat cílený `HARVEST_HOLD`, `PUBLICATION_HOLD`, `MEDIA_HOLD`, `EXPORT_HOLD` nebo celkový `LEGAL_HOLD`.

Dlouhodobým cílem je propojit právní profil providera s routingem, execution trace, databázovými vrstvami, produktovými kanály a řídicím panelem tak, aby systém automaticky vynucoval schválený rozsah, ale konečné právní a strategické rozhodnutí vždy zůstalo na odpovědném člověku.
