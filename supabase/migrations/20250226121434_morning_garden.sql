-- Adicionar coluna user_id como nullable primeiro
ALTER TABLE support_api_credentials
ADD COLUMN IF NOT EXISTS user_id uuid REFERENCES auth.users(id);

-- Remover políticas existentes
DROP POLICY IF EXISTS "user_view_credentials" ON support_api_credentials;
DROP POLICY IF EXISTS "user_update_credentials" ON support_api_credentials;
DROP POLICY IF EXISTS "admin_manage_credentials" ON support_api_credentials;

-- Política para usuários verem apenas seus próprios dados
CREATE POLICY "user_view_own_credentials"
  ON support_api_credentials FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid() OR
    user_id IS NULL OR
    is_admin()
  );

-- Política para usuários atualizarem apenas seus próprios dados
CREATE POLICY "user_update_own_credentials"
  ON support_api_credentials FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid() OR user_id IS NULL)
  WITH CHECK (
    (user_id = auth.uid() OR user_id IS NULL) AND
    client_name IS NOT NULL AND
    company_name IS NOT NULL AND
    document IS NOT NULL AND
    support_id = support_id
  );

-- Política para admins gerenciarem todos os registros
CREATE POLICY "admin_manage_all_credentials"
  ON support_api_credentials FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- Atualizar view para respeitar o contexto do usuário
DROP VIEW IF EXISTS support_id_view;
CREATE VIEW support_id_view AS
SELECT 
  support_id,
  client_name,
  company_name,
  document
FROM support_api_credentials
WHERE 
  user_id = auth.uid() OR
  user_id IS NULL OR
  is_admin();