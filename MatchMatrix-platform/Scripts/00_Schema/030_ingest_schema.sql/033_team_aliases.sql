create table if not exists team_aliases (
    id bigserial primary key,
    team_id bigint references teams(id) on delete cascade,
    alias text not null,
    source text not null
);

create unique index if not exists ux_team_alias
on team_aliases(alias, source);
