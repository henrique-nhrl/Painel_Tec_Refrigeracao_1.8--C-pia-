-- Forçar atualização do cache do PostgREST
ALTER TABLE clients REPLICA IDENTITY FULL;

-- Remover e recriar as políticas para garantir consistência
DROP POLICY IF EXISTS "Gerenciar clientes" ON clients;
DROP POLICY IF EXISTS "Visualizar clientes" ON clients;

-- Criar novas políticas
CREATE POLICY "Gerenciar clientes"
  ON clients FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Garantir que as tabelas relacionadas estejam com RLS correto
ALTER TABLE client_collaborators ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_history ENABLE ROW LEVEL SECURITY;

-- Recriar políticas para client_collaborators
DROP POLICY IF EXISTS "client_collaborators_select" ON client_collaborators;
DROP POLICY IF EXISTS "client_collaborators_insert" ON client_collaborators;
DROP POLICY IF EXISTS "client_collaborators_delete" ON client_collaborators;

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

-- Notificar PostgREST para recarregar o schema
NOTIFY pgrst, 'reload schema';