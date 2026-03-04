CREATE TABLE IF NOT EXISTS user_selections (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL,
  template_id INT NOT NULL REFERENCES templates(id) ON DELETE CASCADE,
  created_at TIMESTAMP NOT NULL DEFAULT now(),
  status TEXT NOT NULL DEFAULT 'OPEN'  -- OPEN / LOCKED / USED
);

CREATE TABLE IF NOT EXISTS selection_items (
  id SERIAL PRIMARY KEY,
  selection_id INT NOT NULL REFERENCES user_selections(id) ON DELETE CASCADE,
  match_id INT NOT NULL REFERENCES matches(id),
  UNIQUE(selection_id, match_id)
);
