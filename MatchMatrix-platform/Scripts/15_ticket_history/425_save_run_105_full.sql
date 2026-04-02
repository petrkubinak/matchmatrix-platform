select
    ordinal_position,
    column_name,
    data_type
from information_schema.columns
where table_schema = 'ops'
  and table_name = 'v_api_budget_today'
order by ordinal_position;