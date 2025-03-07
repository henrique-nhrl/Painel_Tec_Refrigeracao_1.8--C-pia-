-- 1. Adicionar coluna user_id (se não existir)
ALTER TABLE support_api_credentials
ADD COLUMN IF NOT EXISTS user_id uuid;

-- 2. Vincular user_id aos registros existentes (se auth.users não estiver vazio)
DO $$
DECLARE
  first_user_id uuid;
BEGIN
  -- Verificar se há usuários na tabela auth.users
  SELECT id INTO first_user_id
  FROM auth.users
  ORDER BY created_at
  LIMIT 1;

  -- Se houver um usuário, vincular user_id aos registros existentes
  IF first_user_id IS NOT NULL THEN
    UPDATE support_api_credentials
    SET user_id = first_user_id
    WHERE user_id IS NULL;
  ELSE
    -- Se não houver usuários, criar um usuário padrão (opcional)
    INSERT INTO auth.users (id, email, created_at)
    VALUES (gen_random_uuid(), 'default@example.com', now())
    RETURNING id INTO first_user_id;

    -- Vincular user_id aos registros existentes
    UPDATE support_api_credentials
    SET user_id = first_user_id
    WHERE user_id IS NULL;
  END IF;
END $$;

-- 3. Verificar se todos os registros têm user_id (segurança extra)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM support_api_credentials
    WHERE user_id IS NULL
  ) THEN
    RAISE EXCEPTION 'Ainda existem registros com user_id nulo';
  END IF;
END $$;

-- 4. Tornar user_id NOT NULL (após garantir que todos os registros tenham um valor)
ALTER TABLE support_api_credentials
ALTER COLUMN user_id SET NOT NULL;

-- 5. Adicionar restrição de chave estrangeira (após garantir que todos os user_id sejam válidos)
ALTER TABLE support_api_credentials
ADD CONSTRAINT fk_user_id
FOREIGN KEY (user_id) REFERENCES auth.users(id);

-- 6. Remover políticas existentes (se existirem)
DROP POLICY IF EXISTS "user_view_credentials" ON support_api_credentials;
DROP POLICY IF EXISTS "user_update_credentials" ON support_api_credentials;
DROP POLICY IF EXISTS "admin_manage_credentials" ON support_api_credentials;

-- 7. Política para usuários verem apenas seus próprios dados
CREATE POLICY "user_view_own_credentials"
  ON support_api_credentials FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid() OR
    is_admin()
  );

-- 8. Política para usuários atualizarem apenas seus próprios dados
CREATE POLICY "user_update_own_credentials"
  ON support_api_credentials FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (
    user_id = auth.uid() AND
    client_name IS NOT NULL AND
    company_name IS NOT NULL AND
    document IS NOT NULL AND
    support_id = support_id -- Impedir alteração do support_id
  );

-- 9. Política para admins gerenciarem todos os registros
CREATE POLICY "admin_manage_all_credentials"
  ON support_api_credentials FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- 10. Atualizar view para respeitar o contexto do usuário
DROP VIEW IF EXISTS support_id_view;
CREATE VIEW support_id_view AS
SELECT 
  support_id,
  client_name,
  company_name,
  document
FROM support_api_credentials
WHERE 
  user_id = auth.uid() OR
  is_admin();