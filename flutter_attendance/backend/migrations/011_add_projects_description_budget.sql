-- Add description and budget columns to projects table
ALTER TABLE projects 
ADD COLUMN IF NOT EXISTS description TEXT,
ADD COLUMN IF NOT EXISTS budget DOUBLE PRECISION;

