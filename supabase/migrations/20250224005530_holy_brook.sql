-- Remove todas as políticas existentes
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT schemaname, tablename, policyname
        FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename IN ('products', 'clients', 'notification_templates')
    ) LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', 
            r.policyname, r.schemaname, r.tablename);
    END LOOP;
END $$;

-- Criar novas políticas para produtos
CREATE POLICY "produtos_visualizar"
  ON products FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "produtos_admin"
  ON products FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- Políticas para clientes
CREATE POLICY "clientes_gerenciar"
  ON clients FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Políticas para templates
CREATE POLICY "templates_gerenciar"
  ON notification_templates FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);