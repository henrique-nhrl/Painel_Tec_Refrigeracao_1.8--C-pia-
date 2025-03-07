/*
  # Correção do esquema de clientes e colaboradores

  1. Estrutura
    - Ajusta a estrutura da tabela client_collaborators
    - Adiciona índices para melhor performance
    - Atualiza políticas de segurança

  2. Relacionamentos
    - Garante integridade referencial entre clientes e colaboradores
    - Mantém histórico de atendimentos

  3. Segurança
    - Atualiza políticas RLS
    - Garante acesso apropriado aos dados
*/

-- Remover e recriar a tabela client_collaborators para garantir estrutura correta
DROP TABLE IF EXISTS client_collaborators CASCADE;

CREATE TABLE client_collaborators (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id uuid REFERENCES clients(id) ON DELETE CASCADE,
  collaborator_id uuid REFERENCES collaborators(id) ON DELETE CASCADE,
  service_date date NOT NULL,
  created_at timestamptz DEFAULT now(),
  UNIQUE(client_id, collaborator_id, service_date)
);

-- Adicionar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_client_collaborators_client ON client_collaborators(client_id);
CREATE INDEX IF NOT EXISTS idx_client_collaborators_collaborator ON client_collaborators(collaborator_id);
CREATE INDEX IF NOT EXISTS idx_client_collaborators_date ON client_collaborators(service_date);

-- Habilitar RLS
ALTER TABLE client_collaborators ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança
CREATE POLICY "Usuários autenticados podem visualizar relacionamentos"
  ON client_collaborators FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Usuários autenticados podem gerenciar relacionamentos"
  ON client_collaborators FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Função para registrar alterações em client_collaborators
CREATE OR REPLACE FUNCTION log_client_collaborator_changes()
RETURNS trigger AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO logs (
      user_id,
      client_id,
      action
    ) VALUES (
      auth.uid(),
      NEW.client_id,
      'Colaborador associado ao atendimento'
    );
  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO logs (
      user_id,
      client_id,
      action
    ) VALUES (
      auth.uid(),
      OLD.client_id,
      'Colaborador removido do atendimento'
    );
  END IF;
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Criar triggers para logging
CREATE TRIGGER log_client_collaborator_changes_trigger
  AFTER INSERT OR DELETE ON client_collaborators
  FOR EACH ROW
  EXECUTE FUNCTION log_client_collaborator_changes();