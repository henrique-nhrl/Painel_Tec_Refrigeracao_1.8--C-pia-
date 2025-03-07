-- Verificar e criar colunas necessárias
DO $$
BEGIN
  -- Adicionar coluna type se não existir
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'notification_templates' 
    AND column_name = 'type'
  ) THEN
    ALTER TABLE notification_templates 
    ADD COLUMN type text CHECK (type IN ('maintenance', 'welcome')) NOT NULL DEFAULT 'maintenance';
  END IF;

  -- Adicionar coluna variables se não existir
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'notification_templates' 
    AND column_name = 'variables'
  ) THEN
    ALTER TABLE notification_templates 
    ADD COLUMN variables jsonb;
  END IF;
END $$;

-- Adicionar colunas maintenance_interval e maintenance_price na tabela company_settings
ALTER TABLE company_settings 
ADD COLUMN IF NOT EXISTS maintenance_interval integer DEFAULT 120,
ADD COLUMN IF NOT EXISTS maintenance_price decimal(10,2) DEFAULT 150.00;

-- Adicionar colunas maintenance_template_id e welcome_template_id na tabela company_settings
ALTER TABLE company_settings 
ADD COLUMN IF NOT EXISTS maintenance_template_id uuid REFERENCES notification_templates(id),
ADD COLUMN IF NOT EXISTS welcome_template_id uuid REFERENCES notification_templates(id);

-- Migrar dados de welcome_messages para notification_templates (se a tabela existir)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'welcome_messages') THEN
    -- Tornar user_id opcional se não existir
    ALTER TABLE notification_templates ALTER COLUMN user_id DROP NOT NULL;

    INSERT INTO notification_templates (
      id, 
      title, 
      content, 
      type, 
      variables, 
      created_at,
      maintenance_interval,
      maintenance_price,
      company_name
    )
    SELECT 
      id,
      title,
      content,
      'welcome' AS type,
      jsonb_build_object(
        'nome_cliente', 'Nome formal do cliente',
        'nome_empresa', 'Nome da empresa'
      ) AS variables,
      created_at,
      120 AS maintenance_interval,
      150.00 AS maintenance_price,
      'Empresa' AS company_name
    FROM welcome_messages
    ON CONFLICT (id) DO NOTHING;
  END IF;
END $$;

-- Atualizar templates existentes
DO $$
BEGIN
  -- Atualizar type para templates existentes
  UPDATE notification_templates 
  SET type = 'welcome'
  WHERE title ILIKE '%boas-vindas%' 
  AND type = 'maintenance';

  -- Atualizar variables para templates existentes
  UPDATE notification_templates 
  SET variables = jsonb_build_object(
    'nome_cliente', 'Nome formal do cliente',
    'dias_instalacao', 'Dias desde o último serviço',
    'tipo_servico', 'Tipo do serviço realizado',
    'preco_manutencao', 'Preço da manutenção',
    'nome_empresa', 'Nome da empresa'
  )
  WHERE variables IS NULL;
END $$;

-- Remover tabela welcome_messages se existir
DROP TABLE IF EXISTS welcome_messages;

-- Atualizar políticas RLS para clients
DROP POLICY IF EXISTS "Usuários podem ver seus clientes" ON clients;
DROP POLICY IF EXISTS "Usuários podem gerenciar seus clientes" ON clients;

CREATE POLICY "Todos podem ver clientes"
  ON clients FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Usuários autenticados podem gerenciar clientes"
  ON clients FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Atualizar políticas RLS para company_settings
DROP POLICY IF EXISTS "Todos podem ver configurações da empresa" ON company_settings;
DROP POLICY IF EXISTS "Admins podem gerenciar configurações da empresa" ON company_settings;

CREATE POLICY "Todos podem ver e atualizar configurações básicas"
  ON company_settings
  USING (true)
  WITH CHECK (
    auth.role() = 'authenticated' AND (
      is_admin() OR (
        maintenance_interval IS NOT DISTINCT FROM maintenance_interval AND
        maintenance_price IS NOT DISTINCT FROM maintenance_price
      )
    )
  );

-- Inserir templates de manutenção
INSERT INTO notification_templates (
  id,
  title, 
  content, 
  type, 
  variables,
  maintenance_interval,
  maintenance_price,
  company_name,
  created_at
) VALUES
(
  '00000000-0000-0000-0000-000000000001'::uuid,
  'Lembrete de Manutenção Padrão',
  '🔧 Olá {nome_cliente}!\n\nJá se passaram {dias_instalacao} dias desde {tipo_servico}. Para manter seu equipamento funcionando perfeitamente, que tal agendar uma revisão?\n\nValor especial: R$ {preco_manutencao}\n\nAtenciosamente,\n{nome_empresa}',
  'maintenance',
  '{"nome_cliente": "Nome formal do cliente", "dias_instalacao": "Dias desde o último serviço", "tipo_servico": "Tipo do serviço realizado", "preco_manutencao": "Preço da manutenção", "nome_empresa": "Nome da empresa"}',
  120,
  150.00,
  'Empresa',
  NOW()
),
(
  '00000000-0000-0000-0000-000000000002'::uuid,
  'Lembrete de Manutenção Preventiva',
  '⚡ Importante: Manutenção Preventiva\n\nOlá {nome_cliente},\n\nSeu equipamento precisa de cuidados! Já se passaram {dias_instalacao} dias desde {tipo_servico}.\n\nAgende agora sua manutenção por apenas R$ {preco_manutencao} e evite problemas futuros!\n\n{nome_empresa}',
  'maintenance',
  '{"nome_cliente": "Nome formal do cliente", "dias_instalacao": "Dias desde o último serviço", "tipo_servico": "Tipo do serviço realizado", "preco_manutencao": "Preço da manutenção", "nome_empresa": "Nome da empresa"}',
  120,
  150.00,
  'Empresa',
  NOW()
),
(
  '00000000-0000-0000-0000-000000000003'::uuid,
  'Lembrete de Manutenção Urgente',
  '🚨 Atenção {nome_cliente}!\n\nSeu equipamento está há {dias_instalacao} dias sem {tipo_servico}. Isso pode causar:\n- Maior consumo de energia\n- Problemas técnicos\n- Redução da vida útil\n\nAgende já sua manutenção: R$ {preco_manutencao}\n\n{nome_empresa}',
  'maintenance',
  '{"nome_cliente": "Nome formal do cliente", "dias_instalacao": "Dias desde o último serviço", "tipo_servico": "Tipo do serviço realizado", "preco_manutencao": "Preço da manutenção", "nome_empresa": "Nome da empresa"}',
  120,
  150.00,
  'Empresa',
  NOW()
)
ON CONFLICT (id) DO NOTHING;

-- Inserir templates de boas-vindas
INSERT INTO notification_templates (
  id,
  title, 
  content, 
  type, 
  variables,
  maintenance_interval,
  maintenance_price,
  company_name,
  created_at
) VALUES
(
  '00000000-0000-0000-0000-000000000004'::uuid,
  'Boas-vindas Residencial',
  '👋 Olá {nome_cliente}!\n\nSeja bem-vindo ao programa de fidelidade da {nome_empresa}! 🌟\n\nAgora você terá acesso a:\n✅ Descontos especiais\n✅ Lembretes de manutenção\n✅ Atendimento prioritário\n\nObrigado pela confiança! 💙',
  'welcome',
  '{"nome_cliente": "Nome formal do cliente", "nome_empresa": "Nome da empresa"}',
  120,
  150.00,
  'Empresa',
  NOW()
),
(
  '00000000-0000-0000-0000-000000000005'::uuid,
  'Boas-vindas Comercial',
  '🏢 Prezado(a) {nome_cliente},\n\nÉ com satisfação que damos as boas-vindas à {nome_empresa}!\n\nComo cliente VIP, você conta com:\n✅ Manutenção programada\n✅ Preços diferenciados\n✅ Suporte prioritário\n\nContamos com sua parceria! 🤝',
  'welcome',
  '{"nome_cliente": "Nome formal do cliente", "nome_empresa": "Nome da empresa"}',
  120,
  150.00,
  'Empresa',
  NOW()
),
(
  '00000000-0000-0000-0000-000000000006'::uuid,
  'Boas-vindas Premium',
  '✨ Bem-vindo(a) {nome_cliente}!\n\nVocê agora faz parte do seleto grupo de clientes premium da {nome_empresa}!\n\nBenefícios exclusivos:\n👑 Atendimento VIP\n💎 Descontos especiais\n⚡ Prioridade nos agendamentos\n\nSeja muito bem-vindo(a)! 🌟',
  'welcome',
  '{"nome_cliente": "Nome formal do cliente", "nome_empresa": "Nome da empresa"}',
  120,
  150.00,
  'Empresa',
  NOW()
)
ON CONFLICT (id) DO NOTHING;

-- Criar função e trigger para registrar mudanças na tabela clients
CREATE OR REPLACE FUNCTION log_client_changes()
RETURNS trigger AS $$
BEGIN
  INSERT INTO client_history (
    client_id,
    user_id,
    changes
  )
  VALUES (
    NEW.id,
    auth.uid(),
    jsonb_build_object(
      'before', to_jsonb(OLD),
      'after', to_jsonb(NEW)
    )
  );

  INSERT INTO logs (
    user_id,
    client_id,
    action
  )
  VALUES (
    auth.uid(),
    NEW.id,
    CASE
      WHEN TG_OP = 'INSERT' THEN 'Cliente cadastrado'
      WHEN TG_OP = 'UPDATE' THEN 'Cliente atualizado'
      ELSE 'Cliente modificado'
    END
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recriar trigger para capturar todas as mudanças
DROP TRIGGER IF EXISTS client_changes_trigger ON clients;
CREATE TRIGGER client_changes_trigger
  AFTER INSERT OR UPDATE ON clients
  FOR EACH ROW
  EXECUTE FUNCTION log_client_changes();