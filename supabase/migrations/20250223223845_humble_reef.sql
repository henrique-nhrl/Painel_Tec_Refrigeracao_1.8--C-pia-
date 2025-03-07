-- Remover todas as políticas existentes da tabela profiles
DROP POLICY IF EXISTS "Permitir leitura de perfis" ON profiles;
DROP POLICY IF EXISTS "Permitir atualização do próprio perfil" ON profiles;
DROP POLICY IF EXISTS "profiles_read_own" ON profiles;
DROP POLICY IF EXISTS "profiles_update_own" ON profiles;

-- Política para usuários autenticados verem seus próprios perfis
CREATE POLICY "Usuários podem ver seus próprios perfis"
  ON profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- Política para admins verem todos os perfis
CREATE POLICY "Admins podem ver todos os perfis"
  ON profiles FOR SELECT
  TO service_role
  USING (true);

-- Política para usuários atualizarem seus próprios perfis
CREATE POLICY "Usuários podem atualizar seus próprios perfis"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Política para admins atualizarem qualquer perfil
CREATE POLICY "Admins podem atualizar qualquer perfil"
  ON profiles FOR UPDATE
  TO service_role
  USING (true)
  WITH CHECK (true);