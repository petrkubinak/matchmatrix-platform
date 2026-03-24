select
    count(*) as remaining_duplicate_groups
from (
    select
        player_id,
        league_id,
        season
    from public.player_season_statistics
    group by player_id, league_id, season
    having count(*) > 1
) x;