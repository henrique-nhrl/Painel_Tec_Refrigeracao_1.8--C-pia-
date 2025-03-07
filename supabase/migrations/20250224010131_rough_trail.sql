-- Inserir configurações padrão se não existirem
INSERT INTO company_settings (
  id,
  name,
  logo_url,
  welcome_message,
  maintenance_interval,
  maintenance_price,
  maintenance_template_id,
  welcome_template_id
)
SELECT
  gen_random_uuid(),
  'Minha Empresa',
  NULL,
  'Bem-vindo ao nosso sistema!',
  120, -- intervalo padrão de 120 dias
  150.00, -- preço padrão de R$ 150,00
  NULL,
  NULL
WHERE NOT EXISTS (
  SELECT 1 FROM company_settings
);

-- Atualizar política de visualização
DROP POLICY IF EXISTS "configuracoes_visualizar" ON company_settings;
DROP POLICY IF EXISTS "configuracoes_admin_gerenciar" ON company_settings;

CREATE POLICY "configuracoes_visualizar"
  ON company_settings FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "configuracoes_gerenciar"
  ON company_settings FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);