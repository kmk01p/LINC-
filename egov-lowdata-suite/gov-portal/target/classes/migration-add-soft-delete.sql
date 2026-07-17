-- Migration script to add soft delete columns to projects_biz table
-- This script should be run on existing databases to add the deleted_at and deleted_by columns

-- Add deleted_at column for tracking when a project was soft deleted
ALTER TABLE projects_biz ADD COLUMN IF NOT EXISTS deleted_at timestamp without time zone;

-- Add deleted_by column for tracking who soft deleted the project
ALTER TABLE projects_biz ADD COLUMN IF NOT EXISTS deleted_by uuid;

-- Add index on deleted_at for better query performance when filtering active/deleted projects
CREATE INDEX IF NOT EXISTS idx_projects_biz_deleted_at ON projects_biz(deleted_at);

-- Add comment to the columns for documentation
COMMENT ON COLUMN projects_biz.deleted_at IS 'Timestamp when the project was moved to ODK 정리 (soft deleted)';
COMMENT ON COLUMN projects_biz.deleted_by IS 'User ID who moved the project to ODK 정리';
