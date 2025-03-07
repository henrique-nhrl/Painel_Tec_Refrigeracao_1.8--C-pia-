-- Remover políticas existentes
DROP POLICY IF EXISTS "user_view_credentials" ON support_api_credentials;
DROP POLICY IF EXISTS "user_update_basic_fields" ON support_api_credentials;
DROP POLICY IF EXISTS "admin_manage_credentials" ON support_api_credentials;

-- Política para visualização (todos os usuários)
CREATE POLICY "user_view_credentials"
  ON support_api_credentials FOR SELECT
  TO authenticated
  USING (true);

-- Política para atualização por usuários normais
CREATE POLICY "user_update_basic_fields"
  ON support_api_credentials FOR UPDATE
  TO authenticated
  USING (NOT is_admin())
  WITH CHECK (
    NOT is_admin() AND
    support_id IS NOT NULL AND
    support_id = support_id -- Não permitir alterar support_id
  );

-- Política para gerenciamento completo por admin
CREATE POLICY "admin_manage_credentials"
  ON support_api_credentials FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- Atualizar view para mostrar apenas campos necessários
DROP VIEW IF EXISTS support_id_view;
CREATE VIEW support_id_view AS
SELECT 
  support_id,
  client_name,
  company_name,
  document
FROM support_api_credentials
LIMIT 1;