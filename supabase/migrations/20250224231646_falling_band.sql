-- Atualizar a estrutura do histórico de clientes
ALTER TABLE client_history
ADD COLUMN IF NOT EXISTS client_collaborators jsonb;

-- Função atualizada para registrar histórico com colaboradores
CREATE OR REPLACE FUNCTION log_client_changes()
RETURNS trigger AS $$
DECLARE
  collaborators_data jsonb;
BEGIN
  -- Buscar colaboradores atuais do cliente
  SELECT jsonb_agg(
    jsonb_build_object(
      'id', cc.id,
      'collaborator', jsonb_build_object(
        'id', c.id,
        'name', c.name
      ),
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
    client_collaborators,
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

-- Atualizar a função de carregamento do histórico no componente ClientList
COMMENT ON TABLE client_history IS 'Histórico de alterações de clientes com colaboradores';
COMMENT ON COLUMN client_history.client_collaborators IS 'Array de colaboradores associados ao cliente no momento da alteração';