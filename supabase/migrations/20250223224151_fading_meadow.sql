-- Função auxiliar para verificar se é admin
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

-- Políticas para profiles
CREATE POLICY "Visualizar próprio perfil"
  ON profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Admin visualizar todos os perfis"
  ON profiles FOR SELECT
  USING (is_admin());

CREATE POLICY "Atualizar próprio perfil"
  ON profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Admin gerenciar perfis"
  ON profiles FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());

-- Políticas para categories
CREATE POLICY "Visualizar categorias"
  ON categories FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admin gerenciar categorias"
  ON categories FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());

-- Políticas para client_history
CREATE POLICY "Gerenciar histórico de clientes"
  ON client_history FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Políticas para clients
CREATE POLICY "Gerenciar clientes"
  ON clients FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Políticas para company_settings
CREATE POLICY "Visualizar configurações"
  ON company_settings FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admin gerenciar configurações"
  ON company_settings FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());

-- Políticas para logs
CREATE POLICY "Gerenciar logs"
  ON logs FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Políticas para notification_settings
CREATE POLICY "Visualizar configurações de notificação"
  ON notification_settings FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admin gerenciar configurações de notificação"
  ON notification_settings FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());

-- Políticas para notification_templates
CREATE POLICY "Visualizar templates"
  ON notification_templates FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Usuário atualizar templates"
  ON notification_templates FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Admin gerenciar templates"
  ON notification_templates FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());

-- Políticas para product_requests
CREATE POLICY "Gerenciar solicitações de produtos"
  ON product_requests FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Políticas para products
CREATE POLICY "Visualizar produtos"
  ON products FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Usuário atualizar preço"
  ON products FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Admin gerenciar produtos"
  ON products FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());

-- Políticas para service_categories
CREATE POLICY "Visualizar categorias de serviço"
  ON service_categories FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admin gerenciar categorias de serviço"
  ON service_categories FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());

-- Políticas para support_api_credentials
CREATE POLICY "Visualizar credenciais API"
  ON support_api_credentials FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Usuário atualizar credenciais API"
  ON support_api_credentials FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Admin gerenciar credenciais API"
  ON support_api_credentials FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());