-- Create supervisor_projects_relation table to link supervisors with projects
CREATE TABLE IF NOT EXISTS supervisor_projects_relation (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  supervisor_id UUID NOT NULL REFERENCES supervisors(id) ON DELETE CASCADE,
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(supervisor_id, project_id)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_supervisor_projects_supervisor_id ON supervisor_projects_relation(supervisor_id);
CREATE INDEX IF NOT EXISTS idx_supervisor_projects_project_id ON supervisor_projects_relation(project_id);

