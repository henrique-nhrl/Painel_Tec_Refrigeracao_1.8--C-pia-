/*
  # Correções e atualizações finais

  1. Correções
    - Adiciona coluna client_id na tabela logs
    - Atualiza políticas de RLS
    - Adiciona índices para melhor performance

  2. Atualizações
    - Adiciona campos para histórico de atualizações
    - Melhora estrutura de logs
*/

-- Adicionar coluna client_id na tabela logs
ALTER TABLE logs
ADD COLUMN IF NOT EXISTS client_id uuid REFERENCES clients(id) ON DELETE CASCADE;

-- Adicionar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_logs_client_id ON logs(client_id);
CREATE INDEX IF NOT EXISTS idx_logs_created_at ON logs(created_at);
CREATE INDEX IF NOT EXISTS idx_clients_phone ON clients(phone);
CREATE INDEX IF NOT EXISTS idx_clients_service_category_id ON clients(service_category_id);

-- Criar tabela de histórico de atualizações de clientes
CREATE TABLE IF NOT EXISTS client_history (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_id uuid REFERENCES clients(id) ON DELETE CASCADE,
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  changes jsonb NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Habilitar RLS na nova tabela
ALTER TABLE client_history ENABLE ROW LEVEL SECURITY;

-- Políticas para histórico de clientes
CREATE POLICY "Usuários podem ver histórico dos seus clientes"
  ON client_history
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM clients
      WHERE clients.id = client_history.client_id
      AND (clients.created_by = auth.uid() OR is_admin())
    )
  );

-- Função para registrar histórico de alterações
CREATE OR REPLACE FUNCTION log_client_changes()
RETURNS trigger AS $$
BEGIN
  IF TG_OP = 'UPDATE' THEN
    INSERT INTO client_history (client_id, user_id, changes)
    VALUES (
      NEW.id,
      auth.uid(),
      jsonb_build_object(
        'before', to_jsonb(OLD),
        'after', to_jsonb(NEW)
      )
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para registrar alterações
CREATE TRIGGER client_changes_trigger
  AFTER UPDATE ON clients
  FOR EACH ROW
  EXECUTE FUNCTION log_client_changes();

-- Atualizar política de logs para incluir client_id
DROP POLICY IF EXISTS "Permitir inserção de logs" ON logs;
CREATE POLICY "Permitir inserção de logs"
  ON logs
  FOR INSERT
  WITH CHECK (
    auth.role() = 'authenticated' AND
    (
      EXISTS (
        SELECT 1 FROM profiles
        WHERE id = auth.uid()
      )
    )
  );