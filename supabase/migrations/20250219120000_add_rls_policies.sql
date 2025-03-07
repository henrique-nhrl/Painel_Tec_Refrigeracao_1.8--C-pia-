-- Adicionar função is_admin()
CREATE OR REPLACE FUNCTION is_admin() 
RETURNS boolean AS $$
DECLARE
  admin_email text;
BEGIN
  SELECT email INTO admin_email
  FROM auth.users
  WHERE id = auth.uid()
    AND role = 'authenticated'
    AND email IN (
      SELECT email
      FROM profiles
      WHERE role = 'admin'
    );
  
  RETURN admin_email IS NOT NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Atualizar políticas da tabela profiles
DROP POLICY IF EXISTS "Usuários podem ver seus próprios perfis" ON profiles;

CREATE POLICY "Usuários podem ver seus próprios perfis"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Admins podem ver todos os perfis"
  ON profiles FOR SELECT
  USING (is_admin());

CREATE POLICY "Usuários podem atualizar seus próprios perfis"
  ON profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Admins podem atualizar qualquer perfil"
  ON profiles FOR UPDATE
  USING (is_admin())
  WITH CHECK (is_admin());
