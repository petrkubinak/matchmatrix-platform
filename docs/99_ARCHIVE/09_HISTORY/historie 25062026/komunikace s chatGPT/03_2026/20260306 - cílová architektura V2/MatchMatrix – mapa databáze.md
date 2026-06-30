MatchMatrix – mapa databáze
1. Core sportovní vrstva

To je úplný základ systému.

Hlavní entity

sports

countries

leagues

teams

matches

Rozšíření, které jsme přidali

seasons

players

coaches

stadiums

Vazby

leagues -> seasons

teams -> players

teams -> coaches přes team_coaches

teams -> stadiums přes team_stadiums

matches -> teams

matches -> leagues

matches -> seasons později může být doplněno přímo nebo nepřímo přes ligu + sezónu

2. Provider mapping vrstva

Tohle je klíčové pro multi-provider architekturu.

Už existující / navázané

league_provider_map

team_provider_map

team_aliases

Nově přidané

player_provider_map

Smysl

Tato vrstva řeší:

jeden canonical tým / hráč / liga

více providerů

audit

fallback mezi zdroji

3. Match detail vrstva

To je vrstva, díky které nebudeš mít jen seznam zápasů, ale skutečný detail zápasu.

Přidané tabulky

lineups

injuries

match_events

match_officials

match_weather

Statistiky

player_match_statistics

team_match_statistics

Co to umožní

timeline zápasu

sestavy

střídání

góly

karty

statistiky týmů

statistiky hráčů

rozhodčí

počasí

Tohle je jedna z nejsilnějších částí celé platformy.

4. Týmová a hráčská historie

To je vrstva pro fanoušky a detail profilů.

Přidané tabulky

player_team_history

team_transfers

team_coaches

Co to umožní

historie hráče v klubech

přestupy

aktuální a bývalí trenéři

soupiska podle sezóny

profil klubu a hráče do hloubky

5. Betting vrstva

Tady už jsi měl dobrý základ.

Existující

bookmakers

markets

market_outcomes

odds

Další napojené analytické tabulky

ml_predictions

ml_match_dataset

ml_match_dataset_v2

ml_team_ratings

ml_value_latest_v1

ml_fair_odds_latest_v1

ml_block_candidates_latest_v1

Co to umožní

bookmaker odds

porovnání kurzů

fair odds

value betting

ticket optimizer

6. Ticket / generátor tiketů

To už jsi měl rozpracované velmi dobře.

Existující

templates

template_blocks

template_block_matches

template_feed_picks

generated_runs

generated_tickets

generated_ticket_blocks

generated_ticket_fixes

generated_ticket_risk

user_selections

Co to umožní

kombinace tiketů

bloky

risk scoring

více variant tiketů

To je tvoje velmi silná konkurenční výhoda.

7. Content vrstva

Tohle je zásadní pro fanoušky, SEO a růst.

Přidané tabulky

content_sources

articles

article_team_map

article_league_map

article_match_map

Co to umožní

team news

league news

match preview

články navázané na tým / ligu / zápas

budoucí AI shrnutí

8. Multijazyčnost

Tohle je zásadní pro globální produkt.

Přidané tabulky

languages

article_translations

league_translations

team_translations

player_translations

Co to umožní

více jazyků na webu

lokalizované URL

SEO podle regionu

globální expanzi

9. Translation engine

Aby překlady fungovaly systematicky.

Přidané tabulky

translation_jobs

translation_job_logs

Co to umožní

frontu překladů

retry

debugging

ruční review

napojení na DeepL / Google / OpenAI

10. Fan layer

Tohle dělá z MatchMatrix skutečně fanouškovskou platformu.

Přidané tabulky

team_social_links

player_social_links

stadiums

team_stadiums

Co to umožní

oficiální weby

sociální sítě klubů a hráčů

stadion, město, kapacita

bohatší týmové stránky

11. User / personalizace vrstva

To je základ pro personal feed a budoucí appku.

Přidané tabulky

users

user_favorite_teams

user_favorite_leagues

user_favorite_players

Co to umožní

personalizaci

sledování týmů

feed podle oblíbených entit

notifikace

engagement

12. Monetizace vrstva

Tohle je základ pro 4 placené úrovně.

Přidané tabulky

subscription_plans

subscriptions

Co to umožní

free / fan / pro / elite

limity funkcí

premium obsah

premium analytiku

13. Notifikace a realtime vrstva

To je důležité pro web i mobil.

Přidané tabulky

user_notifications

notification_queue

Co to umožní

upozornění na zápasy

změny kurzů

injury news

nové články

push/email workflow později

Celkový obraz

Teď už databáze MatchMatrix není jen:

ligy

týmy

zápasy

kurzy

Ale je to už skoro:

globální sportovní graph

který pokrývá:

sportovní entity

match detail

content

překlady

uživatele

monetizaci

notifikace

betting intelligence

Přibližný logický celek tabulek
A. Core sport

cca 15–20 tabulek

B. Provider / ingest / mapping

cca 10+ tabulek

C. Betting / ML / ticketing

cca 15+ tabulek

D. Content / translations

cca 10+ tabulek

E. User / premium / notifications

cca 8–12 tabulek

Celkově už jsi architektonicky někde kolem:

60–80 tabulek

podle toho, co už v DB máš z dřívějška a co jsme teď doplnili.

To už je opravdu plnohodnotná platformová databáze.