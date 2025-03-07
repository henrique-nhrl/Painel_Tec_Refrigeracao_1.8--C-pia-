-- Primeiro, remover todas as políticas existentes
DO $$ 
BEGIN
  EXECUTE (
    SELECT string_agg('DROP POLICY IF EXISTS ' || quote_ident(policyname) || ' ON ' || quote_ident(tablename) || ';', E'\n')
    FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename IN ('clients', 'client_collaborators', 'client_history', 'collaborators')
  );
END $$;

-- Garantir que RLS está habilitado em todas as tabelas
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_collaborators ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE collaborators ENABLE ROW LEVEL SECURITY;

-- Criar políticas para clients
CREATE POLICY "allow_select_clients"
  ON clients FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "allow_insert_clients"
  ON clients FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "allow_update_clients"
  ON clients FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "allow_delete_clients"
  ON clients FOR DELETE
  TO authenticated
  USING (true);

-- Criar políticas para client_collaborators
CREATE POLICY "allow_select_client_collaborators"
  ON client_collaborators FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "allow_insert_client_collaborators"
  ON client_collaborators FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "allow_update_client_collaborators"
  ON client_collaborators FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "allow_delete_client_collaborators"
  ON client_collaborators FOR DELETE
  TO authenticated
  USING (true);

-- Criar políticas para client_history
CREATE POLICY "allow_select_client_history"
  ON client_history FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "allow_insert_client_history"
  ON client_history FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Criar políticas para collaborators
CREATE POLICY "allow_select_collaborators"
  ON collaborators FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "allow_insert_collaborators"
  ON collaborators FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "allow_update_collaborators"
  ON collaborators FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "allow_delete_collaborators"
  ON collaborators FOR DELETE
  TO authenticated
  USING (true);

-- Forçar atualização do cache do PostgREST
ALTER TABLE clients REPLICA IDENTITY FULL;
ALTER TABLE client_collaborators REPLICA IDENTITY FULL;
ALTER TABLE client_history REPLICA IDENTITY FULL;
ALTER TABLE collaborators REPLICA IDENTITY FULL;

-- Notificar PostgREST para recarregar o schema
NOTIFY pgrst, 'reload schema';