-- Remover políticas existentes
DROP POLICY IF EXISTS "view_support_credentials" ON support_api_credentials;
DROP POLICY IF EXISTS "update_basic_credentials" ON support_api_credentials;
DROP POLICY IF EXISTS "manage_all_credentials" ON support_api_credentials;

-- Política para visualização (todos os usuários)
CREATE POLICY "view_support_credentials"
  ON support_api_credentials FOR SELECT
  TO authenticated
  USING (true);

-- Política para atualização por usuários normais (apenas campos básicos)
CREATE POLICY "update_basic_credentials"
  ON support_api_credentials FOR UPDATE
  TO authenticated
  USING (NOT is_admin())
  WITH CHECK (
    NOT is_admin() AND
    -- Permitir atualizar apenas campos específicos
    client_name IS NOT NULL AND
    company_name IS NOT NULL AND
    document IS NOT NULL AND
    -- Não permitir alterar campos protegidos
    support_id = support_id AND
    created_at = created_at
  );

-- Política para gerenciamento completo por admin
CREATE POLICY "manage_all_credentials"
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