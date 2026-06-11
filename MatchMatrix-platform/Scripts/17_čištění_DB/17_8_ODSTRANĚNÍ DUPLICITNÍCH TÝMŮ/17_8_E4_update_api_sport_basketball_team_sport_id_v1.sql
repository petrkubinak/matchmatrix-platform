/*
MATCHMATRIX SQL 17_8_E4
UPDATE API_SPORT BASKETBALL TEAM SPORT_ID V1

CO TO JE:
- Doplnění chybějícího sport_id pro 10 basketbalových týmů z api_sport.

K ČEMU TO JE:
- Odstraní HOLD_NO_SPORT_ID u známých basketbalových týmů.
- Umožní bezpečnější týmový dedup merge plán.
- Zabrání tomu, aby basketbalové týmy zůstaly mimo sportovní normalizaci.

KDE TO UVIDÍME:
- public.teams.sport_id
- OPS Panel -> ČIŠTĚNÍ DB
- OPS Panel -> DATA QUALITY
- DBeaver kontrola HOLD_NO_SPORT_ID

JAK SE TO VYUŽIJE:
- Po update znovu přepočítáme team duplicate audit a safe merge plan.
- Basketbalové týmy už nebudou v HOLD_NO_SPORT_ID.
- Následný merge plán bude přesnější.
*/

UPDATE public.teams t
SET
    sport_id = 4,
    updated_at = now()
WHERE t.id IN (
    119258, -- Basket Zaragoza
    119254, -- Basquet Girona
    119255, -- Bilbao
    119252, -- Breogan
    119259, -- Joventut Badalona
    119260, -- MoraBanc Andorra
    119261, -- Murcia
    119262, -- Obradoiro CAB
    119253, -- Palencia
    119265  -- Unicaja
)
AND t.ext_source = 'api_sport'
AND t.sport_id IS NULL;