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

-- Recriar tabelas com estrutura simplificada
CREATE TABLE client_collaborators (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id uuid REFERENCES clients(id) ON DELETE CASCADE,
  collaborator_id uuid REFERENCES collaborators(id) ON DELETE CASCADE,
  service_date date NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE client_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id uuid REFERENCES clients(id) ON DELETE CASCADE,
  user_id uuid REFERENCES profiles(id),
  changes jsonb NOT NULL,
  collaborators jsonb DEFAULT '[]'::jsonb,
  created_at timestamptz DEFAULT now()
);

-- Criar índices essenciais
CREATE INDEX IF NOT EXISTS idx_client_collaborators_client ON client_collaborators(client_id);
CREATE INDEX IF NOT EXISTS idx_client_history_client ON client_history(client_id);

-- Habilitar RLS
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_collaborators ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_history ENABLE ROW LEVEL SECURITY;

-- Criar políticas simplificadas
CREATE POLICY "allow_all_authenticated"
  ON clients FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

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

-- Função para histórico
CREATE OR REPLACE FUNCTION log_client_changes()
RETURNS trigger AS $$
BEGIN
  INSERT INTO client_history (client_id, user_id, changes)
  VALUES (
    NEW.id,
    auth.uid(),
    jsonb_build_object('before', to_jsonb(OLD), 'after', to_jsonb(NEW))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Criar trigger
DROP TRIGGER IF EXISTS client_changes_trigger ON clients;
CREATE TRIGGER client_changes_trigger
  AFTER UPDATE ON clients
  FOR EACH ROW
  EXECUTE FUNCTION log_client_changes();

-- Forçar atualização do cache
ALTER TABLE clients REPLICA IDENTITY FULL;
NOTIFY pgrst, 'reload schema';