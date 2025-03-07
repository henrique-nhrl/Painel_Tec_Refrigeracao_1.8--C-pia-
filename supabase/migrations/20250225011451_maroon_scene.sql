-- Remover todas as políticas existentes
DO $$ 
BEGIN
  EXECUTE (
    SELECT string_agg('DROP POLICY IF EXISTS ' || quote_ident(policyname) || ' ON ' || quote_ident(tablename) || ';', E'\n')
    FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename IN ('clients', 'client_collaborators', 'client_history', 'notification_templates')
  );
END $$;

-- Garantir que RLS está habilitado
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_collaborators ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_templates ENABLE ROW LEVEL SECURITY;

-- Criar políticas simplificadas
CREATE POLICY "allow_all_clients"
  ON clients FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "allow_all_client_collaborators"
  ON client_collaborators FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "allow_all_client_history"
  ON client_history FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "allow_all_notification_templates"
  ON notification_templates FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Forçar atualização do cache
ALTER TABLE clients REPLICA IDENTITY FULL;
ALTER TABLE client_collaborators REPLICA IDENTITY FULL;
ALTER TABLE client_history REPLICA IDENTITY FULL;
ALTER TABLE notification_templates REPLICA IDENTITY FULL;

-- Notificar PostgREST para recarregar o schema
NOTIFY pgrst, 'reload schema';