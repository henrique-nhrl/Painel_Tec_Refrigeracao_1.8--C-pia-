-- Create support_api_credentials table
CREATE TABLE IF NOT EXISTS support_api_credentials (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  support_id text UNIQUE NOT NULL,
  client_name text NOT NULL,
  company_name text NOT NULL,
  document text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE support_api_credentials ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Admins podem gerenciar credenciais"
  ON support_api_credentials
  FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());

CREATE POLICY "Usuários podem ver ID de suporte"
  ON support_api_credentials
  FOR SELECT
  TO authenticated
  USING (true);

-- Create view for normal users
CREATE OR REPLACE VIEW public.support_id_view AS
SELECT support_id
FROM support_api_credentials
LIMIT 1;