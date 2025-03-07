-- Remover view existente
DROP VIEW IF EXISTS support_id_view;

-- Criar view com resultado padrão garantido usando COALESCE e subquery
CREATE VIEW support_id_view AS
WITH user_data AS (
  SELECT 
    support_id,
    client_name,
    company_name,
    document
  FROM support_api_credentials
  WHERE user_id = auth.uid()
  ORDER BY created_at DESC
  LIMIT 1
)
SELECT 
  COALESCE(
    (SELECT support_id FROM user_data),
    '0000'
  ) as support_id,
  COALESCE(
    (SELECT client_name FROM user_data),
    'Atualize seus dados'
  ) as client_name,
  COALESCE(
    (SELECT company_name FROM user_data),
    'Atualize seus dados'
  ) as company_name,
  COALESCE(
    (SELECT document FROM user_data),
    ''
  ) as document;

-- Atualizar políticas para garantir acesso correto
DROP POLICY IF EXISTS "user_view_own_credentials" ON support_api_credentials;
DROP POLICY IF EXISTS "user_update_own_credentials" ON support_api_credentials;
DROP POLICY IF EXISTS "admin_manage_all_credentials" ON support_api_credentials;

-- Política para usuários verem seus próprios dados
CREATE POLICY "user_view_own_credentials"
  ON support_api_credentials FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid() OR
    is_admin()
  );

-- Política para usuários atualizarem seus próprios dados
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