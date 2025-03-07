/*
  # Recriar estrutura de clientes e colaboradores

  1. Novas Tabelas
    - Recriação da tabela client_collaborators com estrutura otimizada
    
  2. Índices
    - Índices para melhor performance nas consultas
    
  3. Políticas
    - Políticas RLS para garantir acesso correto
*/

-- Remover tabela existente se houver
DROP TABLE IF EXISTS client_collaborators CASCADE;

-- Criar nova tabela de relacionamento
CREATE TABLE client_collaborators (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id uuid REFERENCES clients(id) ON DELETE CASCADE,
  collaborator_id uuid REFERENCES collaborators(id) ON DELETE CASCADE,
  service_date date NOT NULL,
  created_at timestamptz DEFAULT now(),
  UNIQUE(client_id, collaborator_id, service_date)
);

-- Criar índices para melhor performance
CREATE INDEX idx_client_collaborators_client ON client_collaborators(client_id);
CREATE INDEX idx_client_collaborators_collaborator ON client_collaborators(collaborator_id);
CREATE INDEX idx_client_collaborators_date ON client_collaborators(service_date);

-- Habilitar RLS
ALTER TABLE client_collaborators ENABLE ROW LEVEL SECURITY;

-- Criar políticas de segurança
CREATE POLICY "Visualizar relacionamentos"
  ON client_collaborators FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Gerenciar relacionamentos"
  ON client_collaborators FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);