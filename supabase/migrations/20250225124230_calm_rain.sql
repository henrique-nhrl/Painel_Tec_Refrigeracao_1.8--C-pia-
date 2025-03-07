-- Remove existing policies
DROP POLICY IF EXISTS "view_settings" ON system_settings;
DROP POLICY IF EXISTS "admin_manage_settings" ON system_settings;
DROP POLICY IF EXISTS "update_settings" ON system_settings;

-- Create new policies
CREATE POLICY "allow_read_settings"
  ON system_settings FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "allow_update_settings"
  ON system_settings FOR UPDATE
  TO authenticated
  USING (id = '1')
  WITH CHECK (id = '1');

CREATE POLICY "allow_insert_settings"
  ON system_settings FOR INSERT
  TO authenticated
  WITH CHECK (
    NOT EXISTS (
      SELECT 1 FROM system_settings
    )
  );

-- Ensure default settings exist
INSERT INTO system_settings (
  id,
  company_name,
  support_user_name,
  support_document,
  support_id,
  timezone,
  enable_product_requests
) VALUES (
  '1',
  'Empresa Padrão',
  'Usuário Padrão',
  '12345678901',
  '0000',
  'America/Sao_Paulo',
  true
) ON CONFLICT (id) DO NOTHING;