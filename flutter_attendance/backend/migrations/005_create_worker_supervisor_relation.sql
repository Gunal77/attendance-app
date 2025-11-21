-- Create worker_supervisor_relation table to link workers with supervisors
CREATE TABLE IF NOT EXISTS worker_supervisor_relation (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  worker_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  supervisor_id UUID NOT NULL REFERENCES supervisors(id) ON DELETE CASCADE,
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(worker_id, supervisor_id)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_worker_supervisor_worker_id ON worker_supervisor_relation(worker_id);
CREATE INDEX IF NOT EXISTS idx_worker_supervisor_supervisor_id ON worker_supervisor_relation(supervisor_id);

