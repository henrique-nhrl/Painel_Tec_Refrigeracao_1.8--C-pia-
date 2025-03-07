-- Remover todas as políticas existentes
DO $$ 
BEGIN
  EXECUTE (
    SELECT string_agg('DROP POLICY IF EXISTS ' || quote_ident(policyname) || ' ON support_api_credentials;', E'\n')
    FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'support_api_credentials'
  );
END $$;

-- Remover views existentes
DROP VIEW IF EXISTS support_id_view;
DROP VIEW IF EXISTS user_support_info;
DROP VIEW IF EXISTS admin_support_info;

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

-- Garantir que a coluna support_url existe
ALTER TABLE company_settings
ADD COLUMN IF NOT EXISTS support_url text;

-- Atualizar políticas da tabela company_settings
DROP POLICY IF EXISTS "configuracoes_gerenciar" ON company_settings;
DROP POLICY IF EXISTS "configuracoes_visualizar" ON company_settings;

-- Política para visualização de configurações básicas
CREATE POLICY "view_basic_settings"
  ON company_settings FOR SELECT
  TO authenticated
  USING (true);

-- Política para admins gerenciarem todas as configurações
CREATE POLICY "admin_manage_settings"
  ON company_settings FOR ALL
  TO authenticated
  USING (is_admin());

-- Política para usuários atualizarem apenas campos permitidos
CREATE POLICY "user_update_basic_settings"
  ON company_settings FOR UPDATE
  TO authenticated
  USING (NOT is_admin());

-- Políticas para support_api_credentials
CREATE POLICY "user_view_basic"
  ON support_api_credentials FOR SELECT
  TO authenticated
  USING (NOT is_admin());

CREATE POLICY "user_update_basic"
  ON support_api_credentials FOR UPDATE
  TO authenticated
  USING (NOT is_admin());

CREATE POLICY "admin_full_access"
  ON support_api_credentials FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());