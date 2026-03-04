create table template_block_matches (
  template_id   bigint not null,
  block_index   int    not null,
  match_id      bigint not null references matches(id) on delete cascade,
  market_id     bigint null references markets(id),

  primary key (template_id, block_index, match_id),

  foreign key (template_id, block_index)
    references template_blocks (template_id, block_index)
    on delete cascade
);

create index ix_tbm_template_block
  on template_block_matches(template_id, block_index);

create index ix_tbm_match
  on template_block_matches(match_id);
