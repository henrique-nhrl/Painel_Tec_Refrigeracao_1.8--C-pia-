-- Remover todas as políticas existentes
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT schemaname, tablename, policyname
        FROM pg_policies
        WHERE schemaname = 'public'
    ) LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', 
            r.policyname, r.schemaname, r.tablename);
    END LOOP;
END $$;

-- Função auxiliar para verificar se é administrador
CREATE OR REPLACE FUNCTION is_admin() 
RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Políticas para perfis (profiles)
CREATE POLICY "perfis_visualizar_proprio"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "perfis_admin_visualizar"
  ON profiles FOR SELECT
  USING (is_admin());

CREATE POLICY "perfis_atualizar_proprio"
  ON profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "perfis_admin_gerenciar"
  ON profiles FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());

-- Políticas para produtos (products)
CREATE POLICY "produtos_visualizar"
  ON products FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "produtos_admin_gerenciar"
  ON products FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());

-- Políticas para solicitações de produtos (product_requests)
CREATE POLICY "solicitacoes_visualizar"
  ON product_requests FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "solicitacoes_criar"
  ON product_requests FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "solicitacoes_admin_gerenciar"
  ON product_requests FOR UPDATE
  USING (is_admin())
  WITH CHECK (is_admin());

-- Políticas para logs
CREATE POLICY "logs_criar"
  ON logs FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "logs_admin_visualizar"
  ON logs FOR SELECT
  USING (is_admin());

-- Políticas para categorias (categories)
CREATE POLICY "categorias_visualizar"
  ON categories FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "categorias_admin_gerenciar"
  ON categories FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());

-- Políticas para configurações da empresa (company_settings)
CREATE POLICY "configuracoes_visualizar"
  ON company_settings FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "configuracoes_admin_gerenciar"
  ON company_settings FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());

-- Políticas para clientes (clients)
CREATE POLICY "clientes_gerenciar"
  ON clients FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Políticas para templates de notificação (notification_templates)
CREATE POLICY "templates_visualizar"
  ON notification_templates FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "templates_gerenciar"
  ON notification_templates FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Políticas para histórico de clientes (client_history)
CREATE POLICY "historico_visualizar"
  ON client_history FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "historico_criar"
  ON client_history FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() IS NOT NULL);

-- Políticas para credenciais da API (support_api_credentials)
CREATE POLICY "credenciais_api_visualizar"
  ON support_api_credentials FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "credenciais_api_admin_gerenciar"
  ON support_api_credentials FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());