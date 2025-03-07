-- Remover todas as políticas existentes
DO $$ 
BEGIN
  EXECUTE (
    SELECT string_agg('DROP POLICY IF EXISTS ' || quote_ident(policyname) || ' ON ' || quote_ident(tablename) || ';', E'\n')
    FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename IN ('clients', 'client_collaborators', 'client_history')
  );
END $$;

-- Remover tabelas relacionadas
DROP TABLE IF EXISTS client_collaborators CASCADE;
DROP TABLE IF EXISTS client_history CASCADE;

-- Recriar tabela de relacionamento cliente-colaborador
CREATE TABLE client_collaborators (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id uuid NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  collaborator_id uuid NOT NULL REFERENCES collaborators(id) ON DELETE CASCADE,
  service_date date NOT NULL,
  created_at timestamptz DEFAULT now(),
  CONSTRAINT unique_client_collaborator_date UNIQUE (client_id, collaborator_id, service_date)
);

-- Recriar tabela de histórico
CREATE TABLE client_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id uuid NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES profiles(id),
  changes jsonb NOT NULL,
  collaborators jsonb DEFAULT '[]'::jsonb,
  created_at timestamptz DEFAULT now()
);

-- Criar índices para melhor performance
CREATE INDEX idx_client_collaborators_client ON client_collaborators(client_id);
CREATE INDEX idx_client_collaborators_collaborator ON client_collaborators(collaborator_id);
CREATE INDEX idx_client_collaborators_date ON client_collaborators(service_date);
CREATE INDEX idx_client_history_client ON client_history(client_id);
CREATE INDEX idx_client_history_created ON client_history(created_at);

-- Habilitar RLS
ALTER TABLE client_collaborators ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_history ENABLE ROW LEVEL SECURITY;

-- Criar políticas simplificadas
CREATE POLICY "allow_all_authenticated"
  ON client_collaborators FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "allow_all_authenticated"
  ON client_history FOR ALL
  TO authenticated
  USING (true)
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
      'role', c.role,
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
    collaborators
  )
  VALUES (
    NEW.id,
    auth.uid(),
    jsonb_build_object(
      'before', to_jsonb(OLD),
      'after', to_jsonb(NEW)
    ),
    COALESCE(collaborators_data, '[]'::jsonb)
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

-- Forçar atualização do cache
ALTER TABLE clients REPLICA IDENTITY FULL;
NOTIFY pgrst, 'reload schema';