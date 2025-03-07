-- Remover todas as políticas existentes
DO $$ 
BEGIN
  EXECUTE (
    SELECT string_agg('DROP POLICY IF EXISTS ' || quote_ident(policyname) || ' ON ' || quote_ident(tablename) || ';', E'\n')
    FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename IN ('support_api_credentials', 'company_settings')
  );
END $$;

-- Remover views existentes
DROP VIEW IF EXISTS support_id_view;

-- Criar view simplificada
CREATE VIEW support_id_view AS
SELECT 
  COALESCE(support_id, '0000') as support_id,
  COALESCE(client_name, 'Cliente Padrão') as client_name,
  COALESCE(company_name, 'Empresa Padrão') as company_name
FROM (
  SELECT * FROM support_api_credentials LIMIT 1
) sq;

-- Garantir que existe um registro padrão
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

-- Políticas para support_api_credentials
CREATE POLICY "allow_select"
  ON support_api_credentials FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "allow_admin_all"
  ON support_api_credentials FOR ALL
  TO authenticated
  USING (is_admin());

-- Políticas para company_settings
CREATE POLICY "allow_select_settings"
  ON company_settings FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "allow_admin_all_settings"
  ON company_settings FOR ALL
  TO authenticated
  USING (is_admin());

-- Notificar PostgREST para recarregar o schema
NOTIFY pgrst, 'reload schema';