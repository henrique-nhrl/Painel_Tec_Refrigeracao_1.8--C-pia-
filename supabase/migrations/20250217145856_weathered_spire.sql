/*
  # Correção final das políticas da tabela profiles

  1. Alterações
    - Remove todas as políticas existentes
    - Implementa política única e simplificada
*/

-- Remove políticas existentes
DROP POLICY IF EXISTS "Visualizar próprio perfil" ON profiles;
DROP POLICY IF EXISTS "Admin visualizar todos os perfis" ON profiles;
DROP POLICY IF EXISTS "Atualizar próprio perfil" ON profiles;

-- Política única e simplificada
CREATE POLICY "Gerenciar perfis"
ON profiles
USING (
  auth.uid() = id OR 
  auth.uid() IN (
    SELECT id FROM auth.users 
    WHERE email IN (
      SELECT email FROM profiles 
      WHERE role = 'admin'
    )
  )
);