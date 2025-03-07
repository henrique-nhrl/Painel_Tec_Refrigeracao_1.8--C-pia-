/*
  # Atualização do Sistema

  1. Novas Tabelas
    - `collaborators` - Cadastro de colaboradores
    - `client_collaborators` - Relacionamento entre clientes e colaboradores
  
  2. Novos Campos
    - Endereço do cliente
    - Anotações do cliente
    - URL de suporte nas configurações
    - Timezone nas configurações
*/

-- Criar tabela de colaboradores
CREATE TABLE IF NOT EXISTS collaborators (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  email text UNIQUE,
  phone text,
  role text NOT NULL,
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- Criar tabela de relacionamento cliente-colaborador
CREATE TABLE IF NOT EXISTS client_collaborators (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_id uuid REFERENCES clients(id) ON DELETE CASCADE,
  collaborator_id uuid REFERENCES collaborators(id) ON DELETE CASCADE,
  service_date timestamptz NOT NULL,
  created_at timestamptz DEFAULT now(),
  UNIQUE(client_id, collaborator_id, service_date)
);

-- Adicionar campos de endereço e anotações na tabela clients
ALTER TABLE clients
ADD COLUMN IF NOT EXISTS address text,
ADD COLUMN IF NOT EXISTS address_number text,
ADD COLUMN IF NOT EXISTS neighborhood text,
ADD COLUMN IF NOT EXISTS city text,
ADD COLUMN IF NOT EXISTS notes text;

-- Adicionar campos nas configurações
ALTER TABLE company_settings
ADD COLUMN IF NOT EXISTS timezone text DEFAULT 'America/Sao_Paulo',
ADD COLUMN IF NOT EXISTS support_url text;

-- Habilitar RLS nas novas tabelas
ALTER TABLE collaborators ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_collaborators ENABLE ROW LEVEL SECURITY;

-- Políticas para colaboradores
CREATE POLICY "Visualizar colaboradores"
  ON collaborators FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Gerenciar colaboradores"
  ON collaborators FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Políticas para relacionamento cliente-colaborador
CREATE POLICY "Visualizar atendimentos"
  ON client_collaborators FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Gerenciar atendimentos"
  ON client_collaborators FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Função para converter timestamp para timezone configurado
CREATE OR REPLACE FUNCTION convert_to_timezone(
  timestamp_value timestamptz,
  timezone_name text DEFAULT NULL
)
RETURNS timestamptz AS $$
DECLARE
  tz text;
BEGIN
  -- Usar timezone fornecido ou buscar das configurações
  IF timezone_name IS NULL THEN
    SELECT timezone INTO tz
    FROM company_settings
    LIMIT 1;
    
    IF tz IS NULL THEN
      tz := 'America/Sao_Paulo';
    END IF;
  ELSE
    tz := timezone_name;
  END IF;

  RETURN timestamp_value AT TIME ZONE tz;
END;
$$ LANGUAGE plpgsql;

-- Trigger para converter timestamps automaticamente
CREATE OR REPLACE FUNCTION convert_timestamps()
RETURNS trigger AS $$
BEGIN
  NEW.created_at := convert_to_timezone(NEW.created_at);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger nas tabelas relevantes
CREATE TRIGGER convert_client_timestamps
  BEFORE INSERT OR UPDATE ON clients
  FOR EACH ROW
  EXECUTE FUNCTION convert_timestamps();

CREATE TRIGGER convert_collaborator_timestamps
  BEFORE INSERT OR UPDATE ON collaborators
  FOR EACH ROW
  EXECUTE FUNCTION convert_timestamps();

CREATE TRIGGER convert_client_collaborator_timestamps
  BEFORE INSERT OR UPDATE ON client_collaborators
  FOR EACH ROW
  EXECUTE FUNCTION convert_timestamps();