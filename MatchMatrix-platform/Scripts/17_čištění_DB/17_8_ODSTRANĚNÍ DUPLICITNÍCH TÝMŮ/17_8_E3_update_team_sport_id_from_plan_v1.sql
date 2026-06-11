/*
MATCHMATRIX SQL 17_8_E3
UPDATE TEAM SPORT_ID FROM PLAN V1

CO TO JE:
- Bezpečný UPDATE pro doplnění sport_id do public.teams.
- Použije pouze záznamy označené jako READY_FOR_UPDATE.

K ČEMU TO JE:
- Doplní chybějící sport_id u týmů, kde ho umíme určit podle ext_source.
- Sníží počet falešných duplicit v team dedup auditu.
- Připraví bezpečnější podklad pro budoucí merge týmů.

KDE TO UVIDÍME:
- public.teams.sport_id
- OPS Panel -> ČIŠTĚNÍ DB
- OPS Panel -> DATA QUALITY
- DBeaver kontrola týmů bez sport_id

JAK SE TO VYUŽIJE:
- Po update znovu přepočítáme team duplicate audit.
- Merge plán už nebude chybně slučovat týmy bez sport_id.
- MEDIA, PEOPLE, CORE i ODDS vrstvy budou pracovat s přesnějším sportovým zařazením týmů.
*/

UPDATE public.teams t
SET
    sport_id = p.suggested_sport_id,
    updated_at = now()
FROM ops.v_team_sport_normalization_plan_v1 p
WHERE p.plan_status = 'READY_FOR_UPDATE'
  AND p.suggested_sport_id IS NOT NULL
  AND t.id = p.team_id
  AND t.sport_id IS NULL;