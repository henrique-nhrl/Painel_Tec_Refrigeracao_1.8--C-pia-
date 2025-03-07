-- Remover todas as políticas existentes
DROP POLICY IF EXISTS "permitir_leitura" ON system_settings;
DROP POLICY IF EXISTS "permitir_atualizacao" ON system_settings;
DROP POLICY IF EXISTS "allow_read_settings" ON system_settings;
DROP POLICY IF EXISTS "allow_update_settings" ON system_settings;
DROP POLICY IF EXISTS "allow_insert_settings" ON system_settings;

-- Criar política única e simplificada
CREATE POLICY "gerenciar_configuracoes"
  ON system_settings
  FOR ALL
  TO authenticated
  USING (id = '1')
  WITH CHECK (id = '1');

-- Garantir que existe um registro padrão
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