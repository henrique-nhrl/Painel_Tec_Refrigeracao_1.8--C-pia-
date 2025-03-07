-- Garantir que a tabela system_settings existe com a estrutura correta
CREATE TABLE IF NOT EXISTS system_settings (
  id text PRIMARY KEY DEFAULT '1',
  company_name text NOT NULL DEFAULT 'Empresa Padrão',
  logo_url text,
  timezone text DEFAULT 'America/Sao_Paulo',
  welcome_message text,
  whatsapp_api_url text,
  whatsapp_api_key text,
  whatsapp_instance_name text,
  support_id text UNIQUE NOT NULL DEFAULT '0000',
  support_user_name text NOT NULL DEFAULT 'Usuário Padrão',
  support_document text NOT NULL DEFAULT '12345678901',
  support_url text,
  enable_product_requests boolean DEFAULT true,
  maintenance_interval integer DEFAULT 120,
  maintenance_price decimal(10,2) DEFAULT 150.00,
  maintenance_template_id uuid,
  welcome_template_id uuid,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT single_row CHECK (id = '1')
);

-- Garantir que existe um registro padrão
INSERT INTO system_settings (id) 
VALUES ('1')
ON CONFLICT (id) DO NOTHING;

-- Atualizar a estrutura da tabela logs
ALTER TABLE logs
ADD COLUMN IF NOT EXISTS client_id uuid REFERENCES clients(id) ON DELETE SET NULL;

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_logs_client_id ON logs(client_id);
CREATE INDEX IF NOT EXISTS idx_logs_created_at ON logs(created_at);

-- Atualizar políticas RLS
ALTER TABLE system_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "allow_all" ON system_settings;
CREATE POLICY "allow_all"
  ON system_settings
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);