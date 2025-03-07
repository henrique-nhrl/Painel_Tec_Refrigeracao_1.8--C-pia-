-- Remover restrição de UUID na coluna id
ALTER TABLE company_settings
ALTER COLUMN id DROP DEFAULT,
ALTER COLUMN id TYPE text;

-- Atualizar política para permitir atualizações
DROP POLICY IF EXISTS "configuracoes_gerenciar" ON company_settings;
CREATE POLICY "configuracoes_gerenciar"
  ON company_settings
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Criar bucket para logos se não existir
INSERT INTO storage.buckets (id, name)
VALUES ('public', 'public')
ON CONFLICT (id) DO NOTHING;

-- Atualizar políticas de storage
BEGIN;
  DROP POLICY IF EXISTS "Permitir acesso público" ON storage.objects;
  CREATE POLICY "Permitir acesso público"
    ON storage.objects FOR SELECT
    TO public
    USING (bucket_id = 'public');

  DROP POLICY IF EXISTS "Permitir upload autenticado" ON storage.objects;
  CREATE POLICY "Permitir upload autenticado"
    ON storage.objects FOR INSERT
    TO authenticated
    WITH CHECK (bucket_id = 'public');
COMMIT;