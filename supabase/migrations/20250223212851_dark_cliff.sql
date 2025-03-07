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
CREATE POLICY "profiles_read_own"
  ON profiles FOR SELECT
  USING (auth.uid() = id OR is_admin());

CREATE POLICY "profiles_update_own"
  ON profiles FOR UPDATE
  USING (auth.uid() = id OR is_admin())
  WITH CHECK (auth.uid() = id OR is_admin());

-- Políticas para products
CREATE POLICY "products_read_all"
  ON products FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "products_manage_admin"
  ON products FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- Políticas para product_requests
CREATE POLICY "requests_read_all"
  ON product_requests FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "requests_create_authenticated"
  ON product_requests FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "requests_manage_admin"
  ON product_requests FOR UPDATE
  USING (is_admin())
  WITH CHECK (is_admin());

-- Políticas para logs
CREATE POLICY "logs_create_authenticated"
  ON logs FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "logs_read_admin"
  ON logs FOR SELECT
  USING (is_admin());

-- Políticas para categories
CREATE POLICY "categories_read_all"
  ON categories FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "categories_manage_admin"
  ON categories FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());

-- Políticas para company_settings
CREATE POLICY "settings_read_all"
  ON company_settings FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "settings_manage_all"
  ON company_settings FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Políticas para clients
CREATE POLICY "clients_read_all"
  ON clients FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "clients_manage_all"
  ON clients FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Políticas para notification_templates
CREATE POLICY "templates_read_all"
  ON notification_templates FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "templates_manage_all"
  ON notification_templates FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Políticas para client_history
CREATE POLICY "history_read_all"
  ON client_history FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "history_create_authenticated"
  ON client_history FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() IS NOT NULL);

-- Políticas para support_api_credentials
CREATE POLICY "api_credentials_read_all"
  ON support_api_credentials FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "api_credentials_manage_admin"
  ON support_api_credentials FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());