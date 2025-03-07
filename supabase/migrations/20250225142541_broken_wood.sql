-- Criar tipo enumerado se não existir
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'service_type') THEN
    CREATE TYPE service_type AS ENUM ('installation', 'maintenance', 'cleaning');
  END IF;
END $$;

-- Tabela de tipos de serviço
CREATE TABLE IF NOT EXISTS service_types (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  created_at timestamptz DEFAULT now()
);

-- Tabela de clientes
CREATE TABLE IF NOT EXISTS clients (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name text NOT NULL,
  formal_name text NOT NULL,
  phone text NOT NULL CHECK (phone ~ '^[0-9]{13}$'),
  registration_date date NOT NULL DEFAULT CURRENT_DATE,
  address text,
  number text,
  neighborhood text,
  city text,
  state text,
  notes text,
  send_maintenance_reminders boolean DEFAULT false,
  send_welcome_message boolean DEFAULT false,
  next_maintenance_date date,
  created_at timestamptz DEFAULT now(),
  created_by uuid REFERENCES auth.users(id)
);

-- Tabela de colaboradores
CREATE TABLE IF NOT EXISTS collaborators (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- Tabela de serviços
CREATE TABLE IF NOT EXISTS services (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id uuid REFERENCES clients(id) ON DELETE CASCADE,
  service_number integer NOT NULL,
  service_date date NOT NULL,
  service_type_id uuid REFERENCES service_types(id),
  collaborator_id uuid REFERENCES collaborators(id),
  use_client_address boolean DEFAULT true,
  service_address text,
  notes text,
  total decimal(10,2) NOT NULL,
  created_at timestamptz DEFAULT now(),
  created_by uuid REFERENCES auth.users(id),
  UNIQUE(client_id, service_number)
);

-- Tabela de registros financeiros
CREATE TABLE IF NOT EXISTS financial_records (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  service_id uuid REFERENCES services(id) ON DELETE CASCADE,
  amount decimal(10,2) NOT NULL,
  date date NOT NULL,
  created_at timestamptz DEFAULT now()
);

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
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE collaborators ENABLE ROW LEVEL SECURITY;
ALTER TABLE financial_records ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança
CREATE POLICY "permitir_gerenciar_clientes"
  ON clients FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "permitir_gerenciar_servicos"
  ON services FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "permitir_gerenciar_tipos_servico"
  ON service_types FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "permitir_gerenciar_colaboradores"
  ON collaborators FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "permitir_gerenciar_financeiro"
  ON financial_records FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Inserir tipos de serviço padrão
INSERT INTO service_types (name) VALUES
  ('Instalação'),
  ('Manutenção'),
  ('Higienização')
ON CONFLICT (name) DO NOTHING;

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_clients_phone ON clients(phone);
CREATE INDEX IF NOT EXISTS idx_services_client_id ON services(client_id);
CREATE INDEX IF NOT EXISTS idx_services_date ON services(service_date);
CREATE INDEX IF NOT EXISTS idx_financial_records_date ON financial_records(date);