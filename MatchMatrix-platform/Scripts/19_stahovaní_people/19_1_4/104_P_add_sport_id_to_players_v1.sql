/*
================================================================================
MATCHMATRIX 104_P - ADD SPORT_ID TO PLAYERS V1
================================================================================

Co skript dělá:
- přidá public.players.sport_id
- zatím bez foreign key

Proč:
- PEOPLE / MEDIA / AI vrstva potřebuje jednoznačné rozlišení sportu hráče
================================================================================
*/

ALTER TABLE public.players
ADD COLUMN IF NOT EXISTS sport_id integer;