-- Remover políticas existentes
DROP POLICY IF EXISTS "service_categories_read" ON service_categories;
DROP POLICY IF EXISTS "service_categories_manage" ON service_categories;

-- Criar novas políticas
CREATE POLICY "service_categories_read"
  ON service_categories FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "service_categories_manage"
  ON service_categories FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());