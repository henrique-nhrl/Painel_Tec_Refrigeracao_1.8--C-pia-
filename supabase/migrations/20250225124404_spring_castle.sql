-- Remover políticas existentes
DROP POLICY IF EXISTS "allow_read_settings" ON system_settings;
DROP POLICY IF EXISTS "allow_update_settings" ON system_settings;
DROP POLICY IF EXISTS "allow_insert_settings" ON system_settings;

-- Criar novas políticas simplificadas
CREATE POLICY "permitir_leitura"
  ON system_settings FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "permitir_atualizacao"
  ON system_settings FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Garantir que as configurações padrão existam
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