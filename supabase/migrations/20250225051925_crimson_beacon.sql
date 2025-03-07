-- Remover todas as políticas existentes
DROP POLICY IF EXISTS "view_support_credentials" ON support_api_credentials;
DROP POLICY IF EXISTS "update_basic_credentials" ON support_api_credentials;
DROP POLICY IF EXISTS "manage_all_credentials" ON support_api_credentials;
DROP POLICY IF EXISTS "user_view_credentials" ON support_api_credentials;
DROP POLICY IF EXISTS "user_update_basic_fields" ON support_api_credentials;
DROP POLICY IF EXISTS "admin_manage_credentials" ON support_api_credentials;
DROP POLICY IF EXISTS "user_view_basic_info" ON support_api_credentials;
DROP POLICY IF EXISTS "user_update_basic_info" ON support_api_credentials;
DROP POLICY IF EXISTS "admin_manage_all" ON support_api_credentials;

-- Remover view existente
DROP VIEW IF EXISTS support_id_view;

-- Inserir registro padrão se não existir
INSERT INTO support_api_credentials (
  support_id,
  client_name,
  company_name,
  document
)
SELECT
  '0000',
  'Cliente Padrão',
  'Empresa Padrão',
  '12345678901'
WHERE NOT EXISTS (
  SELECT 1 FROM support_api_credentials
);

-- Criar view simplificada que sempre retorna um resultado
CREATE VIEW support_id_view AS
SELECT 
  COALESCE(support_id, '0000') as support_id,
  COALESCE(client_name, 'Cliente Padrão') as client_name,
  COALESCE(company_name, 'Empresa Padrão') as company_name,
  COALESCE(document, '12345678901') as document
FROM (
  SELECT * FROM support_api_credentials LIMIT 1
) sq;

-- Política para usuários normais verem apenas dados básicos
CREATE POLICY "user_view_basic"
  ON support_api_credentials FOR SELECT
  TO authenticated
  USING (NOT is_admin());

-- Política para usuários normais atualizarem dados básicos
CREATE POLICY "user_update_basic"
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
CREATE POLICY "admin_full_access"
  ON support_api_credentials FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());