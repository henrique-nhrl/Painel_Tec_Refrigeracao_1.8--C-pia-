-- Drop existing view
DROP VIEW IF EXISTS support_id_view;

-- Create new view with better handling of empty results
CREATE OR REPLACE VIEW support_id_view AS
SELECT 
  COALESCE(support_id, '0000') as support_id,
  COALESCE(client_name, 'Cliente Padrão') as client_name,
  COALESCE(company_name, 'Empresa Padrão') as company_name
FROM (
  SELECT *
  FROM support_api_credentials
  LIMIT 1
) sq;

-- Temporarily disable the trigger
ALTER TABLE support_api_credentials DISABLE TRIGGER support_credentials_before_insert;

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
  '12345678901' -- Valid CPF for default record
WHERE NOT EXISTS (
  SELECT 1 FROM support_api_credentials
);

-- Re-enable the trigger
ALTER TABLE support_api_credentials ENABLE TRIGGER support_credentials_before_insert;

-- Update RLS policies
DROP POLICY IF EXISTS "Visualizar credenciais" ON support_api_credentials;
DROP POLICY IF EXISTS "Inserir credenciais" ON support_api_credentials;

CREATE POLICY "allow_view_credentials"
  ON support_api_credentials FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "allow_manage_credentials"
  ON support_api_credentials FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());