-- Remover triggers existentes para evitar conflitos
DROP TRIGGER IF EXISTS client_changes_trigger ON clients;
DROP TRIGGER IF EXISTS log_client_collaborator_changes_trigger ON client_collaborators;

-- Recriar tabela client_collaborators com estrutura correta
DROP TABLE IF EXISTS client_collaborators CASCADE;

CREATE TABLE client_collaborators (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id uuid REFERENCES clients(id) ON DELETE CASCADE,
  collaborator_id uuid REFERENCES collaborators(id) ON DELETE CASCADE,
  service_date date NOT NULL,
  created_at timestamptz DEFAULT now(),
  UNIQUE(client_id, collaborator_id, service_date)
);

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_client_collaborators_client ON client_collaborators(client_id);
CREATE INDEX IF NOT EXISTS idx_client_collaborators_collaborator ON client_collaborators(collaborator_id);
CREATE INDEX IF NOT EXISTS idx_client_collaborators_date ON client_collaborators(service_date);

-- Habilitar RLS
ALTER TABLE client_collaborators ENABLE ROW LEVEL SECURITY;

-- Remover políticas existentes
DROP POLICY IF EXISTS "Authenticated users can view client collaborators" ON client_collaborators;
DROP POLICY IF EXISTS "Authenticated users can manage client collaborators" ON client_collaborators;

-- Criar novas políticas
CREATE POLICY "client_collaborators_select"
  ON client_collaborators FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "client_collaborators_insert"
  ON client_collaborators FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "client_collaborators_update"
  ON client_collaborators FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "client_collaborators_delete"
  ON client_collaborators FOR DELETE
  TO authenticated
  USING (true);

-- Função para registrar alterações
CREATE OR REPLACE FUNCTION log_client_collaborator_changes()
RETURNS trigger AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO logs (
      user_id,
      client_id,
      action
    ) VALUES (
      auth.uid(),
      NEW.client_id,
      'Colaborador associado ao atendimento'
    );
  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO logs (
      user_id,
      client_id,
      action
    ) VALUES (
      auth.uid(),
      OLD.client_id,
      'Colaborador removido do atendimento'
    );
  END IF;
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Criar trigger para logging
CREATE TRIGGER log_client_collaborator_changes_trigger
  AFTER INSERT OR DELETE ON client_collaborators
  FOR EACH ROW
  EXECUTE FUNCTION log_client_collaborator_changes();

-- Atualizar função de log de clientes
CREATE OR REPLACE FUNCTION log_client_changes()
RETURNS trigger AS $$
DECLARE
  collaborators_data jsonb;
BEGIN
  -- Buscar colaboradores atuais do cliente
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

  -- Inserir registro no histórico
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

-- Recriar trigger de clientes
CREATE TRIGGER client_changes_trigger
  AFTER UPDATE ON clients
  FOR EACH ROW
  EXECUTE FUNCTION log_client_changes();

-- Atualizar cache do schema
NOTIFY pgrst, 'reload schema';