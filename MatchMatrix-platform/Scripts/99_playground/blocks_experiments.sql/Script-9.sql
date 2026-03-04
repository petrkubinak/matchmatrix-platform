INSERT INTO generated_runs (template_id)
VALUES (1)
RETURNING id;
INSERT INTO generated_tickets (run_id, ticket_index, probability, snapshot)
VALUES
(
  1,
  1,
  NULL,
  jsonb_build_object(
    'blocks', jsonb_build_array(
      jsonb_build_object('block', 1, 'outcome', '1'),
      jsonb_build_object('block', 2, 'outcome', '1')
    )
  )
),
(
  1,
  2,
  NULL,
  jsonb_build_object(
    'blocks', jsonb_build_array(
      jsonb_build_object('block', 1, 'outcome', 'X'),
      jsonb_build_object('block', 2, 'outcome', '1')
    )
  )
),
(
  1,
  3,
  NULL,
  jsonb_build_object(
    'blocks', jsonb_build_array(
      jsonb_build_object('block', 1, 'outcome', '2'),
      jsonb_build_object('block', 2, 'outcome', '1')
    )
  )
);
