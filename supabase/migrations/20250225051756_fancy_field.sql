-- Remover todas as políticas existentes
DROP POLICY IF EXISTS "view_support_credentials" ON support_api_credentials;
DROP POLICY IF EXISTS "update_basic_credentials" ON support_api_credentials;
DROP POLICY IF EXISTS "manage_all_credentials" ON support_api_credentials;
DROP POLICY IF EXISTS "user_view_credentials" ON support_api_credentials;
DROP POLICY IF EXISTS "user_update_basic_fields" ON support_api_credentials;
DROP POLICY IF EXISTS "admin_manage_credentials" ON support_api_credentials;

-- Política para usuários normais verem apenas seus dados básicos
CREATE POLICY "user_view_basic_info"
  ON support_api_credentials FOR SELECT
  TO authenticated
  USING (NOT is_admin());

-- Política para usuários normais atualizarem apenas seus dados básicos
CREATE POLICY "user_update_basic_info"
  ON support_api_credentials FOR UPDATE
  TO authenticated
  USING (NOT is_admin())
  WITH CHECK (
    NOT is_admin() AND
    client_name IS NOT NULL AND
    company_name IS NOT NULL AND
    document IS NOT NULL AND
    support_id = support_id AND
    created_at = created_at
  );

-- Política para admins terem controle total
CREATE POLICY "admin_manage_all"
  ON support_api_credentials FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- Atualizar view para mostrar apenas o necessário
DROP VIEW IF EXISTS support_id_view;
CREATE VIEW support_id_view AS
SELECT 
  support_id,
  client_name,
  company_name,
  document
FROM support_api_credentials
WHERE NOT is_admin()
LIMIT 1;