-- Add image display controls to workshops
ALTER TABLE workshops ADD COLUMN IF NOT EXISTS image_position text         NOT NULL DEFAULT 'center';
ALTER TABLE workshops ADD COLUMN IF NOT EXISTS image_scale    numeric(4,2) NOT NULL DEFAULT 1.0;
