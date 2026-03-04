create table if not exists template_fixed_picks (
  template_id        bigint not null references templates(id) on delete cascade,
  match_id           bigint not null references matches(id) on delete cascade,
  market_outcome_id  bigint not null references market_outcomes(id),
  market_id          bigint null references markets(id),
  primary key (template_id, match_id, market_outcome_id)
);

create index if not exists ix_tfp_template
  on template_fixed_picks(template_id);

create index if not exists ix_tfp_match
  on template_fixed_picks(match_id);
