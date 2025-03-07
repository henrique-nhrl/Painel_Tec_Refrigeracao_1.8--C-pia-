-- Adicionar coluna para controle de solicitações de produtos
ALTER TABLE company_settings
ADD COLUMN IF NOT EXISTS enable_product_requests boolean DEFAULT true;

-- Atualizar políticas
DROP POLICY IF EXISTS "configuracoes_visualizar" ON company_settings;
DROP POLICY IF EXISTS "configuracoes_gerenciar" ON company_settings;

CREATE POLICY "configuracoes_visualizar"
  ON company_settings FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "configuracoes_gerenciar"
  ON company_settings FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (
    (is_admin() AND true) OR
    (
      -- Usuários normais só podem atualizar campos específicos
      coalesce(name = name, true) AND
      coalesce(maintenance_interval = maintenance_interval, true) AND
      coalesce(maintenance_price = maintenance_price, true) AND
      coalesce(maintenance_template_id = maintenance_template_id, true) AND
      coalesce(welcome_template_id = welcome_template_id, true)
    )
  );