-- Remove existing policies
DO $$ 
BEGIN
  EXECUTE (
    SELECT string_agg('DROP POLICY IF EXISTS ' || quote_ident(policyname) || ' ON ' || quote_ident(tablename) || ';', E'\n')
    FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename IN ('support_api_credentials', 'company_settings')
  );
END $$;

-- Remove existing views
DROP VIEW IF EXISTS support_id_view;
DROP VIEW IF EXISTS user_support_info;
DROP VIEW IF EXISTS admin_support_info;

-- Create simplified view that always returns a result
CREATE VIEW support_id_view AS
SELECT 
  COALESCE(support_id, '0000') as support_id,
  CASE 
    WHEN is_admin() THEN client_name
    ELSE COALESCE(client_name, 'Cliente Padrão')
  END as client_name,
  CASE 
    WHEN is_admin() THEN company_name
    ELSE COALESCE(company_name, 'Empresa Padrão')
  END as company_name,
  CASE 
    WHEN is_admin() THEN document
    ELSE COALESCE(document, '12345678901')
  END as document
FROM (
  SELECT * FROM support_api_credentials LIMIT 1
) sq;

-- Ensure support_url column exists
ALTER TABLE company_settings
ADD COLUMN IF NOT EXISTS support_url text;

-- Company Settings Policies
CREATE POLICY "view_settings"
  ON company_settings FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "admin_manage_settings"
  ON company_settings FOR ALL
  TO authenticated
  USING (is_admin());

-- Support API Credentials Policies
CREATE POLICY "view_credentials"
  ON support_api_credentials FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "admin_manage_credentials"
  ON support_api_credentials FOR ALL
  TO authenticated
  USING (is_admin());

-- Insert default record if none exists
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

-- Notify PostgREST to reload schema
NOTIFY pgrst, 'reload schema';