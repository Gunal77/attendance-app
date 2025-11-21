-- Create attendance_override table for manual attendance entries
CREATE TABLE IF NOT EXISTS attendance_override (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  worker_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  supervisor_id UUID NOT NULL REFERENCES supervisors(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  check_in_time TIMESTAMPTZ,
  check_out_time TIMESTAMPTZ,
  reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(worker_id, date)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_attendance_override_worker_id ON attendance_override(worker_id);
CREATE INDEX IF NOT EXISTS idx_attendance_override_supervisor_id ON attendance_override(supervisor_id);
CREATE INDEX IF NOT EXISTS idx_attendance_override_date ON attendance_override(date);

