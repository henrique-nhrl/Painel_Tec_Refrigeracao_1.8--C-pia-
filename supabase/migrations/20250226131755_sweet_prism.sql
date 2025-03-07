-- Garantir que existe um registro padrão com todos os campos
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
) ON CONFLICT (id) DO UPDATE SET
  company_name = EXCLUDED.company_name,
  support_user_name = EXCLUDED.support_user_name,
  support_document = EXCLUDED.support_document,
  support_id = EXCLUDED.support_id,
  timezone = EXCLUDED.timezone,
  enable_product_requests = EXCLUDED.enable_product_requests,
  maintenance_interval = EXCLUDED.maintenance_interval,
  maintenance_price = EXCLUDED.maintenance_price
WHERE system_settings.id = '1';

-- Atualizar a estrutura da tabela logs
ALTER TABLE logs DROP COLUMN IF EXISTS client_id;

-- Recriar a coluna client_id com a referência correta
ALTER TABLE logs ADD COLUMN client_id uuid REFERENCES clients(id) ON DELETE SET NULL;

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_logs_client_id ON logs(client_id);
CREATE INDEX IF NOT EXISTS idx_logs_created_at ON logs(created_at);
CREATE INDEX IF NOT EXISTS idx_logs_user_id ON logs(user_id);
CREATE INDEX IF NOT EXISTS idx_logs_product_id ON logs(product_id);