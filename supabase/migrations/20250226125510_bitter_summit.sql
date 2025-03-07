-- Drop existing policies
DROP POLICY IF EXISTS "gerenciar_configuracoes" ON system_settings;

-- Create simplified policy
CREATE POLICY "allow_all"
  ON system_settings
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Ensure default settings exist
INSERT INTO system_settings (
  id,
  company_name,
  support_user_name,
  support_document,
  support_id,
  timezone,
  enable_product_requests,
  maintenance_interval,
  maintenance_price
) VALUES (
  '1',
  'Empresa Padrão',
  'Usuário Padrão',
  '12345678901',
  '0000',
  'America/Sao_Paulo',
  true,
  120,
  150.00
) ON CONFLICT (id) DO NOTHING;