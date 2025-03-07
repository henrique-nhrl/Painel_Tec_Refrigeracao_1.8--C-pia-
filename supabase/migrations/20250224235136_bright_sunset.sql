/*
  # Correção da estrutura de histórico e colaboradores

  1. Recriação das tabelas
    - Recriação da tabela client_history com estrutura correta
    - Ajustes na tabela client_collaborators
    
  2. Índices e Políticas
    - Índices otimizados
    - Políticas RLS atualizadas
*/

-- Remover tabelas existentes
DROP TABLE IF EXISTS client_history CASCADE;
DROP TABLE IF EXISTS client_collaborators CASCADE;

-- Recriar tabela de histórico
CREATE TABLE client_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id uuid REFERENCES clients(id) ON DELETE CASCADE,
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  changes jsonb NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Recriar tabela de colaboradores
CREATE TABLE client_collaborators (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id uuid REFERENCES clients(id) ON DELETE CASCADE,
  collaborator_id uuid REFERENCES collaborators(id) ON DELETE CASCADE,
  service_date date NOT NULL,
  created_at timestamptz DEFAULT now(),
  UNIQUE(client_id, collaborator_id, service_date)
);

-- Criar índices
CREATE INDEX idx_client_history_client ON client_history(client_id);
CREATE INDEX idx_client_history_user ON client_history(user_id);
CREATE INDEX idx_client_history_created_at ON client_history(created_at);
CREATE INDEX idx_client_collaborators_client ON client_collaborators(client_id);
CREATE INDEX idx_client_collaborators_collaborator ON client_collaborators(collaborator_id);
CREATE INDEX idx_client_collaborators_date ON client_collaborators(service_date);

-- Habilitar RLS
ALTER TABLE client_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_collaborators ENABLE ROW LEVEL SECURITY;

-- Políticas para histórico
CREATE POLICY "Visualizar histórico"
  ON client_history FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Inserir histórico"
  ON client_history FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Políticas para colaboradores
CREATE POLICY "Visualizar colaboradores do cliente"
  ON client_collaborators FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Gerenciar colaboradores do cliente"
  ON client_collaborators FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Função para registrar histórico
CREATE OR REPLACE FUNCTION log_client_changes()
RETURNS trigger AS $$
BEGIN
  INSERT INTO client_history (
    client_id,
    user_id,
    changes,
    created_at
  )
  VALUES (
    NEW.id,
    auth.uid(),
    jsonb_build_object(
      'before', to_jsonb(OLD),
      'after', to_jsonb(NEW)
    ),
    now()
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para histórico
DROP TRIGGER IF EXISTS client_changes_trigger ON clients;
CREATE TRIGGER client_changes_trigger
  AFTER UPDATE ON clients
  FOR EACH ROW
  EXECUTE FUNCTION log_client_changes();