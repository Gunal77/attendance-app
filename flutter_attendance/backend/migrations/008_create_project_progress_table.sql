-- Create project_progress table
CREATE TABLE IF NOT EXISTS project_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  supervisor_id UUID NOT NULL REFERENCES supervisors(id) ON DELETE CASCADE,
  progress_percentage INTEGER NOT NULL DEFAULT 0 CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
  notes TEXT,
  photo_urls TEXT[], -- Array of photo URLs
  reported_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_project_progress_project_id ON project_progress(project_id);
CREATE INDEX IF NOT EXISTS idx_project_progress_supervisor_id ON project_progress(supervisor_id);
CREATE INDEX IF NOT EXISTS idx_project_progress_reported_at ON project_progress(reported_at);

