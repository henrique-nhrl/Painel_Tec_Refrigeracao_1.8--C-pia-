-- Criar enum para tipos de serviço
CREATE TYPE service_type AS ENUM ('installation', 'cleaning', 'maintenance');

-- Criar tabela de serviços
CREATE TABLE services (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id uuid REFERENCES clients(id) ON DELETE CASCADE,
  service_number integer NOT NULL,
  service_type service_type NOT NULL,
  service_date date NOT NULL,
  address text,
  use_client_address boolean DEFAULT true,
  collaborator_id uuid REFERENCES collaborators(id),
  price decimal(10,2),
  notes text,
  created_at timestamptz DEFAULT now(),
  created_by uuid REFERENCES profiles(id)
);

-- Criar índice para número do serviço por cliente
CREATE UNIQUE INDEX idx_service_number_by_client ON services(client_id, service_number);

-- Função para gerar próximo número de serviço
CREATE OR REPLACE FUNCTION next_service_number(client_id uuid)
RETURNS integer AS $$
DECLARE
  next_number integer;
BEGIN
  SELECT COALESCE(MAX(service_number) + 1, 1)
  INTO next_number
  FROM services
  WHERE services.client_id = $1;
  
  RETURN next_number;
END;
$$ LANGUAGE plpgsql;

-- Habilitar RLS
ALTER TABLE services ENABLE ROW LEVEL SECURITY;

-- Políticas para serviços
CREATE POLICY "Visualizar serviços"
  ON services FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Gerenciar serviços"
  ON services FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Atualizar políticas da API
DROP POLICY IF EXISTS "allow_view_credentials" ON support_api_credentials;
DROP POLICY IF EXISTS "allow_manage_credentials" ON support_api_credentials;

-- Política para visualização (todos os usuários)
CREATE POLICY "user_view_credentials"
  ON support_api_credentials FOR SELECT
  TO authenticated
  USING (true);

-- Política para atualização por usuários normais
CREATE POLICY "user_update_basic_fields"
  ON support_api_credentials FOR UPDATE
  TO authenticated
  USING (NOT is_admin())
  WITH CHECK (
    NOT is_admin() AND
    support_id IS NOT NULL AND
    support_id = support_id -- Não permitir alterar support_id
  );

-- Política para gerenciamento completo por admin
CREATE POLICY "admin_manage_credentials"
  ON support_api_credentials FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());