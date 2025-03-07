-- Forçar atualização do cache do PostgREST
ALTER TABLE clients REPLICA IDENTITY FULL;

-- Remover e recriar as políticas para garantir consistência
DROP POLICY IF EXISTS "Gerenciar clientes" ON clients;
DROP POLICY IF EXISTS "Visualizar clientes" ON clients;

CREATE POLICY "Gerenciar clientes"
  ON clients FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Notificar PostgREST para recarregar o schema
NOTIFY pgrst, 'reload schema';