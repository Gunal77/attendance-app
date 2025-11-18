-- Create employees table
CREATE TABLE IF NOT EXISTS employees (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  email TEXT UNIQUE,
  phone TEXT,
  role TEXT,
  project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_employees_email ON employees(email);
CREATE INDEX IF NOT EXISTS idx_employees_project_id ON employees(project_id);

