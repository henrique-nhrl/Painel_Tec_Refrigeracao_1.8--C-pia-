-- Remover políticas existentes da tabela logs
DROP POLICY IF EXISTS "Permitir inserção de logs" ON logs;
DROP POLICY IF EXISTS "Admins podem ver logs" ON logs;

-- Criar novas políticas para logs
CREATE POLICY "Permitir inserção de logs"
ON logs
FOR INSERT
WITH CHECK (
  auth.role() = 'authenticated' AND
  EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
  )
);

CREATE POLICY "Admins podem ver logs"
ON logs
FOR SELECT
USING (is_admin());
