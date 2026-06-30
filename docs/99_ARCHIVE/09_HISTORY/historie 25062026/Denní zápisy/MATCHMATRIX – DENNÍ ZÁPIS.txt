MATCHMATRIX – DENNÍ ZÁPIS
Datum
24.06.2026
Oblast
24_SOURCE INTELLIGENCE LAYER
Hlavní téma dne
Vybudování základní architektury Source Intelligence Layer
a zahájení globálního auditu datových zdrojů.
1. CO JSME DNES VYBUDOVALI

Dnešek byl zásadní.

Poprvé jsme nezačali řešit konkrétní provider nebo konkrétní data, ale začali jsme budovat vrstvu, která bude řídit všechny budoucí zdroje dat v MatchMatrix.

Vznikla nová vrstva:

24_SOURCE INTELLIGENCE LAYER

jejímž cílem je:

vědět:
- odkud data získáváme
- co zdroj obsahuje
- jak kvalitní data poskytuje
- zda je použitelný právně
- zda je zdarma nebo placený
- kdy ho aktivovat
- jakou má návratnost
2. HANDBALL (HB) – PROOF OF CONCEPT

Jako první sport byl zvolen:

HB – Handball

Důvod:

- relativně přehledné prostředí
- EHF a IHF jako jasné federace
- vhodné pro ověření celé metodiky
3. EHF AUDIT

Auditovali jsme:

European Handball Federation
https://www.eurohandball.com
Co jsme našli
Robots.txt
PASS

Zjištěno:

crawl-delay = 5 sekund

MatchMatrix bude respektovat:

RESPECT_CRAWL_DELAY_5
Sitemap

Nalezeno:

11 sitemap

například:

eurohandball
ehfcl
ehfel
ehfec
beach
respectyourtalent
yac
shop
activities
Privacy Policy

Ověřeno.

Zjištěno:

Google Analytics
Firebase
Cloudflare
Stripe
Google Cloud
Customer.io
Meta
TikTok
People Layer

Potvrzeno:

Player Profiles
Coach Profiles
Team Officials
Team Layer

Potvrzeno:

Soupisky
Trenéři
Lékaři
Fyzioterapeuti
Analytici
Management
History Layer

Potvrzeno:

historické soutěže
historické výsledky
historie hráčů
historie reprezentací
Media Layer

Potvrzeno:

články
fotografie
statistiky
Výsledek EHF
QUALITY SCORE = 88

TIER = TIER_1

STATUS =
USE_NOW_AFTER_LEGAL_REVIEW
4. NÁRODNÍ LIGY

Zjistili jsme důležitou věc.

EHF velmi dobře pokrývá:

evropské poháry
reprezentace
evropské šampionáty

ale nepokrývá plně:

národní ligy

Proto jsme založili další discovery větev:

National League Discovery
Identifikované priority
Germany     Handball Bundesliga
France      LNH Starligue
Spain       Liga ASOBAL
Denmark     Herreligaen
Poland      Superliga
Hungary     NB I
Sweden      Handbollsligan
Norway      REMA 1000 Ligaen
Croatia     Premijer Liga
Romania     Liga Nationala
5. GOVERNANCE VRSTVA

Vzniklo několik nových governance objektů.

SOURCE COVERAGE MATRIX

Evidence:

PLAYERS
COACHES
PHOTOS
MEDIA
HISTORY
SPORT_CORE
SOURCE LEGAL AUDIT

Evidence:

robots
privacy
terms
licenses
commercial use
SOURCE COMMERCIAL MODEL

Evidence:

FREE
PAID
MIXED
ENTERPRISE

plus:

ROI
historie
limity
doporučení
SOURCE QUALITY SCORE

Výsledné hodnocení zdroje.

Příklad:

EHF = 88
SOURCE ACTIVATION ROADMAP

Určuje:

USE_NOW
USE_AFTER_REVIEW
RESEARCH_REQUIRED
6. GLOBÁLNÍ SOURCE DISCOVERY

Nejdůležitější část dne.

Přestali jsme řešit pouze házenou.

Začali jsme budovat systém pro všechny sporty.

Vytvořen Source Discovery Master

Obsahuje:

sport
zdroj
typ zdroje
scope
prioritu
stav
První globální zdroje
Football
FIFA
UEFA
Transfermarkt
Handball
EHF
IHF
Hockey
IIHF
Basketball
FIBA
EuroLeague
Tennis
ATP
WTA
Volleyball
FIVB
Baseball
WBSC
MMA
UFC
American Football
NFL
Cricket
ICC
7. SOURCE DISCOVERY QUEUE

Vznikla fronta úkolů.

Například:

DISCOVER_TOP_LEAGUES
DISCOVER_TOP_CLUBS
DISCOVER_HISTORY
DISCOVER_MEDIA
8. SOURCE DISCOVERY AUDIT TRACKER

Vznikl centrální auditní tracker.

Aktuálně:

EHF = DONE
IHF = OPEN
FIFA = OPEN
UEFA = OPEN
FIBA = OPEN
IIHF = OPEN
ATP = OPEN
WTA = OPEN
NFL = OPEN
UFC = OPEN
...
9. SOURCE DISCOVERY DASHBOARD

Vznikl první dashboard.

Aktuální stav:

HB
DONE = 1
OPEN = 1

FB
OPEN = 3

BK
OPEN = 2

TN
OPEN = 2

ostatní
OPEN
10. IHF AUDIT

Dnes jsme zahájili audit:

International Handball Federation
https://www.ihf.info
Robots.txt

Výsledek:

PASS

Zjištěno:

Drupal CMS
administrativní části blokované
assety povolené
Sitemap

Test:

https://www.ihf.info/sitemap.xml

Výsledek:

404

Zápis:

NOT_FOUND
MANUAL_DISCOVERY_REQUIRED
11. KAM JSME SE POSUNULI

Ráno:

měli jsme audit EHF

Večer:

máme základ celé Source Intelligence architektury
pro všechny sporty.

To je obrovský posun.

Poprvé máme systém, který bude schopen:

evidovat
hodnotit
auditovat
a řídit

všechny zdroje dat MatchMatrix.
12. CO BUDEME DĚLAT ZÍTRA

Pokračujeme přesně zde:

24_2_B_1_IHF_SOURCE_AUDIT_V1
Další kroky
IHF
Privacy Policy
Terms & Conditions
Players
Coaches
Teams
Competitions
History
Media
Commercial Model
Quality Score
Activation Roadmap

Po dokončení IHF:

24_2_B_2_FIFA_SOURCE_AUDIT_V1

poté:

24_2_B_3_UEFA_SOURCE_AUDIT_V1
DLOUHODOBÝ CÍL

Vybudovat kompletní:

MATCHMATRIX SOURCE INTELLIGENCE PLATFORM

která bude pro každý sport vědět:

kdo poskytuje data
jak kvalitní jsou
jaká jsou právní omezení
jaká je cena
jaké je ROI
kdy zdroj použít
jaký má význam pro MatchMatrix

a následně bude schopna řídit:

CORE
PEOPLE
MEDIA
HISTORY
ODDS

napříč všemi sporty.

Stav dne
SOURCE INTELLIGENCE LAYER
STATUS = SUCCESSFULLY ESTABLISHED

EHF AUDIT
STATUS = DONE

IHF AUDIT
STATUS = IN_PROGRESS

GLOBAL SOURCE DISCOVERY
STATUS = ACTIVE

MATCHMATRIX SOURCE GOVERNANCE
STATUS = OPERATIONAL