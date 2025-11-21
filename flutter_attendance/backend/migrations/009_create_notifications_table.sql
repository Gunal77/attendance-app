-- Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  supervisor_id UUID NOT NULL REFERENCES supervisors(id) ON DELETE CASCADE,
  type TEXT NOT NULL, -- worker_absent, location_mismatch, delayed_task, attendance_override
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  related_entity_type TEXT, -- worker, project, task, attendance
  related_entity_id UUID,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_notifications_supervisor_id ON notifications(supervisor_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(type);

