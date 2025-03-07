-- Remover políticas existentes
DROP POLICY IF EXISTS "allow_select" ON support_api_credentials;
DROP POLICY IF EXISTS "allow_admin_all" ON support_api_credentials;

-- Política para usuários normais visualizarem seus dados
CREATE POLICY "user_view_credentials"
  ON support_api_credentials FOR SELECT
  TO authenticated
  USING (true);

-- Política para usuários normais atualizarem seus dados básicos
CREATE POLICY "user_update_credentials"
  ON support_api_credentials FOR UPDATE
  TO authenticated
  USING (NOT is_admin())
  WITH CHECK (
    NOT is_admin() AND
    client_name IS NOT NULL AND
    company_name IS NOT NULL AND
    document IS NOT NULL
  );

-- Política para admins terem controle total
CREATE POLICY "admin_manage_credentials"
  ON support_api_credentials FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- Atualizar view para mostrar dados corretamente
DROP VIEW IF EXISTS support_id_view;
CREATE VIEW support_id_view AS
SELECT 
  support_id,
  client_name,
  company_name,
  document
FROM support_api_credentials
LIMIT 1;