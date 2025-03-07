-- Drop existing table if it exists
DROP TABLE IF EXISTS system_settings CASCADE;

-- Create system settings table with correct structure
CREATE TABLE system_settings (
  id text PRIMARY KEY DEFAULT '1',
  -- Company Settings
  company_name text NOT NULL DEFAULT 'Empresa Padrão',
  logo_url text,
  timezone text DEFAULT 'America/Sao_Paulo',
  welcome_message text,
  
  -- WhatsApp API Settings
  whatsapp_api_url text,
  whatsapp_api_key text,
  whatsapp_instance_name text,
  
  -- Support API Settings
  support_id text UNIQUE NOT NULL DEFAULT '0000',
  support_user_name text NOT NULL DEFAULT 'Usuário Padrão',
  support_document text NOT NULL DEFAULT '12345678901',
  support_url text,
  
  -- Product Settings
  enable_product_requests boolean DEFAULT true,
  
  -- Maintenance Settings
  maintenance_interval integer DEFAULT 120,
  maintenance_price decimal(10,2) DEFAULT 150.00,
  maintenance_template_id uuid,
  welcome_template_id uuid,
  
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  
  -- Ensure only one row exists
  CONSTRAINT single_row CHECK (id = '1')
);

-- Enable RLS
ALTER TABLE system_settings ENABLE ROW LEVEL SECURITY;

-- Create simplified policy
CREATE POLICY "allow_all"
  ON system_settings
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Insert default settings
INSERT INTO system_settings (id) VALUES ('1')
ON CONFLICT (id) DO NOTHING;