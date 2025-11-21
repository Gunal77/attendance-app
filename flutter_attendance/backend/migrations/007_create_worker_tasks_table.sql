-- Create worker_tasks table
CREATE TABLE IF NOT EXISTS worker_tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  worker_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  supervisor_id UUID NOT NULL REFERENCES supervisors(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL DEFAULT 'pending', -- pending, in_progress, completed, delayed
  due_date DATE,
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_worker_tasks_project_id ON worker_tasks(project_id);
CREATE INDEX IF NOT EXISTS idx_worker_tasks_worker_id ON worker_tasks(worker_id);
CREATE INDEX IF NOT EXISTS idx_worker_tasks_supervisor_id ON worker_tasks(supervisor_id);
CREATE INDEX IF NOT EXISTS idx_worker_tasks_status ON worker_tasks(status);
CREATE INDEX IF NOT EXISTS idx_worker_tasks_due_date ON worker_tasks(due_date);

