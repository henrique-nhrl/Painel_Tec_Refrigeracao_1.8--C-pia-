-- Remover tabelas existentes para recriar com estrutura correta
DROP TABLE IF EXISTS financial_records CASCADE;
DROP TABLE IF EXISTS services CASCADE;
DROP TABLE IF EXISTS service_types CASCADE;
DROP TABLE IF EXISTS clients CASCADE;
DROP TABLE IF EXISTS collaborators CASCADE;

-- Criar tabela de tipos de serviço
CREATE TABLE service_types (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  created_at timestamptz DEFAULT now()
);

-- Criar tabela de colaboradores
CREATE TABLE collaborators (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- Criar tabela de clientes
CREATE TABLE clients (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
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

-- Criar tabela de serviços
CREATE TABLE services (
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

-- Criar tabela de registros financeiros
CREATE TABLE financial_records (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  service_id uuid REFERENCES services(id) ON DELETE CASCADE,
  amount decimal(10,2) NOT NULL,
  date date NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Habilitar RLS
ALTER TABLE service_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE collaborators ENABLE ROW LEVEL SECURITY;
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE financial_records ENABLE ROW LEVEL SECURITY;

-- Criar políticas RLS
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
CREATE INDEX idx_services_client_id ON services(client_id);
CREATE INDEX idx_services_service_type_id ON services(service_type_id);
CREATE INDEX idx_services_collaborator_id ON services(collaborator_id);
CREATE INDEX idx_financial_records_service_id ON financial_records(service_id);
CREATE INDEX idx_clients_name ON clients(name);
CREATE INDEX idx_clients_phone ON clients(phone);

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

-- Função para calcular totais financeiros
CREATE OR REPLACE FUNCTION get_financial_totals(
  start_date date,
  end_date date
)
RETURNS TABLE (
  total_amount decimal(10,2),
  average_amount decimal(10,2),
  total_services bigint
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    COALESCE(SUM(amount), 0) as total_amount,
    COALESCE(AVG(amount), 0) as average_amount,
    COUNT(*) as total_services
  FROM financial_records
  WHERE date BETWEEN start_date AND end_date;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para registros financeiros
CREATE OR REPLACE FUNCTION handle_service_financial()
RETURNS trigger AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO financial_records (service_id, amount, date)
    VALUES (NEW.id, NEW.total, NEW.service_date);
  ELSIF TG_OP = 'UPDATE' AND NEW.total != OLD.total THEN
    UPDATE financial_records
    SET amount = NEW.total,
        date = NEW.service_date
    WHERE service_id = NEW.id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER service_financial_trigger
  AFTER INSERT OR UPDATE ON services
  FOR EACH ROW
  EXECUTE FUNCTION handle_service_financial();