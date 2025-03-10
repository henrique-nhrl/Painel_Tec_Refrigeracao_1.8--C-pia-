-- Drop existing objects if they exist
DROP VIEW IF EXISTS support_id_view CASCADE;
DROP TABLE IF EXISTS support_api_credentials CASCADE;
DROP TABLE IF EXISTS company_settings CASCADE;
DROP TABLE IF EXISTS system_settings CASCADE;

-- Create unified settings table
CREATE TABLE system_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  -- Company Settings
  company_name text NOT NULL,
  logo_url text,
  timezone text DEFAULT 'America/Sao_Paulo',
  welcome_message text,
  
  -- WhatsApp API Settings
  whatsapp_api_url text,
  whatsapp_api_key text,
  whatsapp_instance_name text,
  
  -- Support API Settings
  support_id text UNIQUE NOT NULL DEFAULT '0000',
  support_user_name text NOT NULL,
  support_document text NOT NULL,
  support_url text,
  
  -- Product Settings
  enable_product_requests boolean DEFAULT true,
  
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE system_settings ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "view_settings"
  ON system_settings FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "update_basic_settings"
  ON system_settings FOR UPDATE
  TO authenticated
  USING (NOT is_admin())
  WITH CHECK (
    NOT is_admin() AND
    -- Allow updating only specific fields
    company_name IS NOT NULL AND
    support_user_name IS NOT NULL AND
    support_document IS NOT NULL AND
    -- Prevent changing protected fields
    support_id = support_id AND
    created_at = created_at
  );

CREATE POLICY "admin_manage_settings"
  ON system_settings FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- Insert default settings if not exists
INSERT INTO system_settings (
  company_name,
  support_user_name,
  support_document,
  support_id,
  timezone,
  enable_product_requests
) VALUES (
  'Empresa Padrão',
  'Usuário Padrão',
  '12345678901',
  '0000',
  'America/Sao_Paulo',
  true
) ON CONFLICT (support_id) DO NOTHING;

-- Create function to validate document
CREATE OR REPLACE FUNCTION is_valid_document(doc text)
RETURNS boolean AS $$
DECLARE
  clean_doc text;
BEGIN
  clean_doc := regexp_replace(doc, '[^0-9]', '', 'g');
  RETURN length(clean_doc) IN (11, 14);
END;
$$ LANGUAGE plpgsql;

-- Create trigger to validate document before insert/update
CREATE OR REPLACE FUNCTION validate_settings()
RETURNS trigger AS $$
BEGIN
  -- Validate document
  IF NOT is_valid_document(NEW.support_document) THEN
    RAISE EXCEPTION 'Documento inválido';
  END IF;
  
  -- Set updated_at
  NEW.updated_at := now();
  
  -- Prevent support_id change
  IF TG_OP = 'UPDATE' THEN
    NEW.support_id := OLD.support_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER settings_validation
  BEFORE INSERT OR UPDATE ON system_settings
  FOR EACH ROW
  EXECUTE FUNCTION validate_settings();

-- Create storage bucket for logos if not exists
INSERT INTO storage.buckets (id, name, public)
VALUES ('logos', 'logos', true)
ON CONFLICT (id) DO NOTHING;

-- Create storage policies
BEGIN;
  DROP POLICY IF EXISTS "Allow public access to logos" ON storage.objects;
  CREATE POLICY "Allow public access to logos"
    ON storage.objects FOR SELECT
    TO public
    USING (bucket_id = 'logos');

  DROP POLICY IF EXISTS "Allow authenticated uploads" ON storage.objects;
  CREATE POLICY "Allow authenticated uploads"
    ON storage.objects FOR INSERT
    TO authenticated
    WITH CHECK (bucket_id = 'logos');

  DROP POLICY IF EXISTS "Allow authenticated updates" ON storage.objects;
  CREATE POLICY "Allow authenticated updates"
    ON storage.objects FOR UPDATE
    TO authenticated
    USING (bucket_id = 'logos');

  DROP POLICY IF EXISTS "Allow authenticated deletes" ON storage.objects;
  CREATE POLICY "Allow authenticated deletes"
    ON storage.objects FOR DELETE
    TO authenticated
    USING (bucket_id = 'logos');
COMMIT;

-- Notify PostgREST to reload schema
NOTIFY pgrst, 'reload schema';