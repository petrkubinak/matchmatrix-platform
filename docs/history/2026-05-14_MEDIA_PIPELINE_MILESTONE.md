MATCHMATRIX MEDIA LAYER – ZÁPIS 2026-05-14
MEDIA PIPELINE – FOOTBALL EXPANSION

Dnes proběhlo výrazné rozšíření football media vrstvy přes official_site ingest.

Nově aktivované football zdroje
Source	Status
Premier League	ACTIVE
LaLiga	ACTIVE
Bundesliga	ACTIVE
Serie A	ACTIVE (redirect issue)
Ligue 1	ACTIVE (404 issue)
UEFA	ACTIVE
FIFA	ACTIVE
OFFICIAL SITE INGEST V1.2

Worker:

workers/media/pull_official_site_media_articles_v1.py

Rozšířen scraper pro:

lepší URL matching
root normalization
football providers
health audit logging
Výsledek ingestu
Source	Found URLs	Inserted	Status
NHL	64	0	OK
NBA	36	0	OK
UEFA	5	0	OK
FIFA	0	0	EMPTY
Premier League	2	2	OK
LaLiga	26	26	OK
Bundesliga	14	14	OK
Serie A	0	0	REDIRECT/EMPTY
Ligue 1	0	0	404 ERROR
ARTICLE DETAIL PARSER V2

Worker:

workers/media/parse_article_details_v1.py

Parser úspěšně zpracoval:

thumbnails
video detection
article metadata
raw_html
raw_text
Přidané nové sloupce do staging.stg_media_articles
thumbnail_url text
video_url text
duration_seconds integer
is_video boolean
DB LOCK / ALTER TABLE ISSUE

Během ALTER TABLE vznikl PostgreSQL lock.

Problém:

idle in transaction
blokovaný ALTER TABLE
parser čekal na lock

Vyřešeno:

rollback/ukončení otevřené transaction
opětovné spuštění ALTER TABLE
následné dokončení parseru
MEDIA MERGE V2

Worker:

workers/media/merge_media_articles_to_public_v1.py

Proběhl successful merge football článků do public.articles.

Merge výsledky
MERGED: 47
UPSERTED: 47
ERRORS: 0
AKTUÁLNÍ STAV PUBLIC ARTICLES
Source	Articles	With Thumbnail
NHL	137	91
NBA	69	41
LaLiga	26	0
Bundesliga	14	0
UEFA	5	0
Premier League	2	0
IDENTIFIKOVANÉ PROBLÉMY
UEFA

Scraper stále tahá:

/news-media/
/documents/
/publications/

=> potřeba custom UEFA article extractor.

FIFA

https://www.fifa.com/en/news
vrací HTML bez jednoduchých /news/ odkazů.

=> potřeba FIFA-specific parser.

Ligue 1

Vrací:

404 https://ligue1.com/en/news

=> najít správný news endpoint.

Serie A

Vrací:

HTTP 307 redirect

=> potřeba redirect-aware parser / final resolved URL.

DALŠÍ KROKY
PRIORITA
1. Football article quality filter

Filtrovat:

newsletter
category pages
generic hubs
pressroom pages
fantasy pages
2. UEFA custom extractor

Oddělit real articles od navigation pages.

3. FIFA parser

Použít jiný selector / embedded JSON parsing.

4. Thumbnail propagation audit

Ověřit proč FB thumbnails nejdou do public.

5. Football entity matcher

Napojení:

clubs
leagues
matches
players
STAV MEDIA LAYER
Stabilní:
NHL
NBA
Rozběhnuto:
Premier League
LaLiga
Bundesliga
Čeká na custom parser:
UEFA
FIFA
Serie A
Ligue 1
CELKOVÝ POSUN

Media layer už není jen NHL/NBA prototype.

Dnes vznikl:

první multi-league football media ingest
první football article merge
základ evropské football media vrstvy
připravená infrastruktura pro entity matching a trending engine.