/*
MATCHMATRIX 104_M - ADD INDEX TEAMS SPORT_ID V1

Co skript dělá:
- přidá index na public.teams.sport_id

K čemu to slouží:
- rychlejší filtrování týmů podle sportu
- lepší výkon pro CORE / PEOPLE / MEDIA / AI joiny
*/

CREATE INDEX IF NOT EXISTS idx_teams_sport_id
ON public.teams (sport_id);