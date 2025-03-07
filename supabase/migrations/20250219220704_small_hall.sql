/*
  # Ajustes no esquema do banco de dados

  1. Alterações
    - Remover coluna category de products
    - Ajustar políticas de RLS
*/

-- Remover coluna category de products
ALTER TABLE products DROP COLUMN IF EXISTS category;

-- Atualizar política de produtos
DROP POLICY IF EXISTS "Admins podem gerenciar produtos" ON products;
CREATE POLICY "Admins podem gerenciar produtos"
  ON products FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );