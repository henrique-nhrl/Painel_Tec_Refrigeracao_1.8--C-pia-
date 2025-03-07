-- Desabilitar temporariamente o trigger de validação
ALTER TABLE support_api_credentials DISABLE TRIGGER support_credentials_before_insert;

-- Remover view existente
DROP VIEW IF EXISTS support_id_view;

-- Criar view com resultado padrão garantido
CREATE VIEW support_id_view AS
SELECT 
  COALESCE(support_id, '0000') as support_id,
  COALESCE(client_name, 'Atualize seus dados') as client_name,
  COALESCE(company_name, 'Atualize seus dados') as company_name,
  COALESCE(document, '') as document
FROM (
  SELECT *
  FROM support_api_credentials
  WHERE user_id = auth.uid()
  ORDER BY created_at DESC
  LIMIT 1
) user_creds;

-- Adicionar índice para melhorar performance
CREATE INDEX IF NOT EXISTS idx_support_api_credentials_user_id 
ON support_api_credentials(user_id);

-- Atualizar políticas
DROP POLICY IF EXISTS "user_view_own_credentials" ON support_api_credentials;
DROP POLICY IF EXISTS "user_update_own_credentials" ON support_api_credentials;
DROP POLICY IF EXISTS "admin_manage_all_credentials" ON support_api_credentials;

-- Política para usuários verem apenas seus próprios dados
CREATE POLICY "user_view_own_credentials"
  ON support_api_credentials FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid() OR
    is_admin()
  );

-- Política para usuários atualizarem apenas seus próprios dados
CREATE POLICY "user_update_own_credentials"
  ON support_api_credentials FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (
    user_id = auth.uid() AND
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

-- Reabilitar o trigger
ALTER TABLE support_api_credentials ENABLE TRIGGER support_credentials_before_insert;