/*
  # Correção dos relacionamentos do histórico de clientes

  1. Estrutura
    - Adiciona coluna para armazenar colaboradores no histórico
    - Mantém compatibilidade com registros existentes

  2. Relacionamentos
    - Permite rastrear colaboradores associados a cada mudança
    - Mantém integridade referencial

  3. Segurança
    - Atualiza políticas RLS
    - Garante acesso apropriado aos dados
*/

-- Adicionar coluna para armazenar colaboradores no histórico
ALTER TABLE client_history
ADD COLUMN IF NOT EXISTS collaborators jsonb;

-- Função para atualizar histórico com colaboradores
CREATE OR REPLACE FUNCTION log_client_changes()
RETURNS trigger AS $$
DECLARE
  collaborators_data jsonb;
BEGIN
  -- Buscar colaboradores atuais do cliente
  SELECT jsonb_agg(
    jsonb_build_object(
      'collaborator_id', cc.collaborator_id,
      'service_date', cc.service_date,
      'collaborator', jsonb_build_object(
        'id', c.id,
        'name', c.name
      )
    )
  )
  INTO collaborators_data
  FROM client_collaborators cc
  JOIN collaborators c ON c.id = cc.collaborator_id
  WHERE cc.client_id = NEW.id;

  -- Inserir registro no histórico com colaboradores
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
    collaborators_data,
    now()
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recriar trigger com a nova função
DROP TRIGGER IF EXISTS client_changes_trigger ON clients;
CREATE TRIGGER client_changes_trigger
  AFTER UPDATE ON clients
  FOR EACH ROW
  EXECUTE FUNCTION log_client_changes();

-- Atualizar políticas RLS
DROP POLICY IF EXISTS "Visualizar histórico" ON client_history;
CREATE POLICY "Visualizar histórico"
  ON client_history FOR SELECT
  TO authenticated
  USING (true);

-- Criar índice para melhor performance
CREATE INDEX IF NOT EXISTS idx_client_history_client_id ON client_history(client_id);
CREATE INDEX IF NOT EXISTS idx_client_history_created_at ON client_history(created_at);