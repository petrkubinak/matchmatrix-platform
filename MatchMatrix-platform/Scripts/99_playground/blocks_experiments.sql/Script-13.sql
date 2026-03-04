INSERT INTO generated_tickets (run_id, ticket_index, probability, snapshot)
SELECT
  3,
  ROW_NUMBER() OVER (ORDER BY b1.outcome, b3.outcome) AS ticket_index,
  NULL::numeric AS probability,
  jsonb_build_object(
    'blocks', jsonb_build_array(
      jsonb_build_object('block', 1, 'outcome', b1.outcome),
      jsonb_build_object('block', 2, 'outcome', '1'),
      jsonb_build_object('block', 3, 'outcome', b3.outcome)
    )
  )
FROM (VALUES ('1'),('X'),('2')) b1(outcome)
CROSS JOIN (VALUES ('1'),('X'),('2')) b3(outcome);
