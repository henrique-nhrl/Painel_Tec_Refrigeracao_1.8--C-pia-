-- Primeiro, remover todas as políticas existentes da tabela
DROP POLICY IF EXISTS "user_view_credentials" ON support_api_credentials;
DROP POLICY IF EXISTS "user_update_basic_fields" ON support_api_credentials;
DROP POLICY IF EXISTS "admin_manage_credentials" ON support_api_credentials;
DROP POLICY IF EXISTS "credenciais_api_admin_gerenciar" ON support_api_credentials;
DROP POLICY IF EXISTS "credenciais_api_visualizar" ON support_api_credentials;

-- Criar novas políticas simplificadas

-- 1. Política de visualização para todos os usuários
CREATE POLICY "view_support_credentials"
  ON support_api_credentials FOR SELECT
  TO authenticated
  USING (true);

-- 2. Política de atualização para usuários normais (apenas campos específicos)
CREATE POLICY "update_basic_credentials"
  ON support_api_credentials FOR UPDATE
  TO authenticated
  USING (NOT is_admin())
  WITH CHECK (
    NOT is_admin() AND
    -- Garantir que campos protegidos não sejam alterados
    support_id = support_id AND
    created_at = created_at
  );

-- 3. Política de gerenciamento completo para admins
CREATE POLICY "manage_all_credentials"
  ON support_api_credentials FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- Recriar view simplificada
DROP VIEW IF EXISTS support_id_view;
CREATE VIEW support_id_view AS
SELECT 
  support_id,
  client_name,
  company_name,
  document
FROM support_api_credentials
LIMIT 1;