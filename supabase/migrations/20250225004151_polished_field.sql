-- Remover tabelas existentes
DROP TABLE IF EXISTS client_collaborators CASCADE;
DROP TABLE IF EXISTS client_history CASCADE;

-- Recriar tabela de colaboradores do cliente
CREATE TABLE client_collaborators (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id uuid REFERENCES clients(id) ON DELETE CASCADE,
  collaborator_id uuid REFERENCES collaborators(id) ON DELETE CASCADE,
  service_date date NOT NULL,
  created_at timestamptz DEFAULT now(),
  UNIQUE(client_id, collaborator_id, service_date)
);

-- Recriar tabela de histórico
CREATE TABLE client_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id uuid REFERENCES clients(id) ON DELETE CASCADE,
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  changes jsonb NOT NULL,
  collaborators jsonb DEFAULT '[]'::jsonb,
  created_at timestamptz DEFAULT now()
);

-- Criar índices
CREATE INDEX idx_client_collaborators_client ON client_collaborators(client_id);
CREATE INDEX idx_client_collaborators_collaborator ON client_collaborators(collaborator_id);
CREATE INDEX idx_client_collaborators_date ON client_collaborators(service_date);
CREATE INDEX idx_client_history_client ON client_history(client_id);
CREATE INDEX idx_client_history_created ON client_history(created_at);

-- Habilitar RLS
ALTER TABLE client_collaborators ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_history ENABLE ROW LEVEL SECURITY;

-- Políticas para client_collaborators
CREATE POLICY "client_collaborators_select"
  ON client_collaborators FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "client_collaborators_insert"
  ON client_collaborators FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "client_collaborators_delete"
  ON client_collaborators FOR DELETE
  TO authenticated
  USING (true);

-- Políticas para client_history
CREATE POLICY "client_history_select"
  ON client_history FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "client_history_insert"
  ON client_history FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Função para registrar histórico
CREATE OR REPLACE FUNCTION log_client_changes()
RETURNS trigger AS $$
DECLARE
  collaborators_data jsonb;
BEGIN
  -- Buscar colaboradores atuais
  SELECT jsonb_agg(
    jsonb_build_object(
      'id', c.id,
      'name', c.name,
      'service_date', cc.service_date
    )
  )
  INTO collaborators_data
  FROM client_collaborators cc
  JOIN collaborators c ON c.id = cc.collaborator_id
  WHERE cc.client_id = NEW.id;

  -- Inserir no histórico
  INSERT INTO client_history (
    client_id,
    user_id,
    changes,
    collaborators,
    created_at
  )
  VALUES (
    NEW.id,
    auth.uid(),
    jsonb_build_object(
      'before', to_jsonb(OLD),
      'after', to_jsonb(NEW)
    ),
    COALESCE(collaborators_data, '[]'::jsonb),
    now()
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recriar trigger
DROP TRIGGER IF EXISTS client_changes_trigger ON clients;
CREATE TRIGGER client_changes_trigger
  AFTER UPDATE ON clients
  FOR EACH ROW
  EXECUTE FUNCTION log_client_changes();