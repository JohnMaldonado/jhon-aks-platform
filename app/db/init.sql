CREATE TABLE IF NOT EXISTS items (
  id          SERIAL PRIMARY KEY,
  name        VARCHAR(255) NOT NULL,
  description TEXT,
  created_at  TIMESTAMP DEFAULT NOW()
);

INSERT INTO items (name, description) VALUES
  ('Item Alpha', 'First demo item'),
  ('Item Beta',  'Second demo item'),
  ('Item Gamma', 'Third demo item')
ON CONFLICT DO NOTHING;
