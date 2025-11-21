-- Add missing columns to admins table if they don't exist
ALTER TABLE admins 
ADD COLUMN IF NOT EXISTS name TEXT,
ADD COLUMN IF NOT EXISTS phone TEXT,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- Update existing rows to have a default name if name is null
UPDATE admins SET name = 'Admin User' WHERE name IS NULL;

-- Make name NOT NULL after setting defaults
ALTER TABLE admins ALTER COLUMN name SET NOT NULL;

