/*
  # Correção das políticas da tabela profiles

  1. Alterações
    - Remove políticas existentes
    - Adiciona novas políticas sem recursão
*/

-- Remove políticas existentes
DROP POLICY IF EXISTS "Usuários podem ver seus próprios perfis" ON profiles;
DROP POLICY IF EXISTS "Admins podem ver todos os perfis" ON profiles;

-- Adiciona novas políticas
CREATE POLICY "Usuários podem ver seus próprios perfis"
ON profiles FOR SELECT
USING (auth.uid() = id);

CREATE POLICY "Admins podem ver todos os perfis"
ON profiles FOR SELECT
USING (
  auth.uid() IN (
    SELECT id FROM profiles WHERE role = 'admin'
  )
);