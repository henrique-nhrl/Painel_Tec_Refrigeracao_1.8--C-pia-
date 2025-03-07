-- Add maintenance settings columns
ALTER TABLE system_settings
ADD COLUMN IF NOT EXISTS maintenance_interval integer DEFAULT 120,
ADD COLUMN IF NOT EXISTS maintenance_price decimal(10,2) DEFAULT 150.00,
ADD COLUMN IF NOT EXISTS maintenance_template_id uuid REFERENCES notification_templates(id),
ADD COLUMN IF NOT EXISTS welcome_template_id uuid REFERENCES notification_templates(id);

-- Update existing record with default values if exists
UPDATE system_settings
SET 
  maintenance_interval = COALESCE(maintenance_interval, 120),
  maintenance_price = COALESCE(maintenance_price, 150.00)
WHERE id = '1';

-- Notify PostgREST to reload schema
NOTIFY pgrst, 'reload schema';