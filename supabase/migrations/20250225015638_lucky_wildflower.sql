-- Criar bucket para logos se não existir
INSERT INTO storage.buckets (id, name, public)
VALUES ('logos', 'logos', true)
ON CONFLICT (id) DO NOTHING;

-- Criar políticas de storage para logos
BEGIN;
  DROP POLICY IF EXISTS "Permitir acesso público aos logos" ON storage.objects;
  CREATE POLICY "Permitir acesso público aos logos"
    ON storage.objects FOR SELECT
    TO public
    USING (bucket_id = 'logos');

  DROP POLICY IF EXISTS "Permitir upload de logos" ON storage.objects;
  CREATE POLICY "Permitir upload de logos"
    ON storage.objects FOR INSERT
    TO authenticated
    WITH CHECK (bucket_id = 'logos');

  DROP POLICY IF EXISTS "Permitir atualização de logos" ON storage.objects;
  CREATE POLICY "Permitir atualização de logos"
    ON storage.objects FOR UPDATE
    TO authenticated
    USING (bucket_id = 'logos');

  DROP POLICY IF EXISTS "Permitir deleção de logos" ON storage.objects;
  CREATE POLICY "Permitir deleção de logos"
    ON storage.objects FOR DELETE
    TO authenticated
    USING (bucket_id = 'logos');
COMMIT;

-- Atualizar a estrutura de clientes e colaboradores
DROP TABLE IF EXISTS client_collaborators CASCADE;

CREATE TABLE client_collaborators (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id uuid REFERENCES clients(id) ON DELETE CASCADE,
  collaborator_id uuid REFERENCES collaborators(id) ON DELETE CASCADE,
  service_date date NOT NULL,
  created_at timestamptz DEFAULT now(),
  UNIQUE(client_id, collaborator_id, service_date)
);

-- Criar índices
CREATE INDEX IF NOT EXISTS idx_client_collaborators_client ON client_collaborators(client_id);
CREATE INDEX IF NOT EXISTS idx_client_collaborators_collaborator ON client_collaborators(collaborator_id);
CREATE INDEX IF NOT EXISTS idx_client_collaborators_date ON client_collaborators(service_date);

-- Habilitar RLS
ALTER TABLE client_collaborators ENABLE ROW LEVEL SECURITY;

-- Criar políticas
CREATE POLICY "allow_all_client_collaborators"
  ON client_collaborators FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);