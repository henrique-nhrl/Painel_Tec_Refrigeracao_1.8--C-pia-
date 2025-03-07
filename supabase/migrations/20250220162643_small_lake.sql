/*
  # Adicionar sistema de notificações e clientes

  1. Novas Tabelas
    - clients
    - notification_settings
    - notification_templates
*/

-- Tabela de clientes
CREATE TABLE IF NOT EXISTS clients (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  phone text NOT NULL CHECK (phone ~ '^[0-9]{13}$'),
  email text,
  last_service_date date,
  next_service_date date,
  created_by uuid REFERENCES profiles(id),
  created_at timestamptz DEFAULT now()
);

-- Tabela de configurações de notificação
CREATE TABLE IF NOT EXISTS notification_settings (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  api_url text,
  api_key text,
  instance_name text,
  created_at timestamptz DEFAULT now()
);

-- Tabela de templates de notificação
CREATE TABLE IF NOT EXISTS notification_templates (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid REFERENCES profiles(id),
  title text NOT NULL,
  content text NOT NULL,
  maintenance_interval integer NOT NULL,
  maintenance_price decimal(10,2) NOT NULL,
  company_name text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Habilitar RLS
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_templates ENABLE ROW LEVEL SECURITY;

-- Políticas RLS
CREATE POLICY "Usuários podem ver seus clientes"
  ON clients FOR SELECT
  USING (auth.uid() = created_by OR is_admin());

CREATE POLICY "Usuários podem gerenciar seus clientes"
  ON clients FOR ALL
  USING (auth.uid() = created_by OR is_admin());

CREATE POLICY "Apenas admin pode gerenciar configurações"
  ON notification_settings
  USING (is_admin());

CREATE POLICY "Usuários podem gerenciar seus templates"
  ON notification_templates
  USING (auth.uid() = user_id OR is_admin());