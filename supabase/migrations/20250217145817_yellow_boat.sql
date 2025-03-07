/*
  # Correção das políticas da tabela profiles

  1. Alterações
    - Remove todas as políticas existentes
    - Implementa novas políticas otimizadas
    - Adiciona índice para melhor performance
*/

-- Remove políticas existentes
DROP POLICY IF EXISTS "Usuários podem ver seus próprios perfis" ON profiles;
DROP POLICY IF EXISTS "Admins podem ver todos os perfis" ON profiles;
DROP POLICY IF EXISTS "Admins podem gerenciar perfis" ON profiles;

-- Cria índice para role
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);

-- Políticas de visualização
CREATE POLICY "Visualizar próprio perfil"
ON profiles FOR SELECT
USING (auth.uid() = id);

CREATE POLICY "Admin visualizar todos os perfis"
ON profiles FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Política para usuários atualizarem próprio perfil
CREATE POLICY "Atualizar próprio perfil"
ON profiles FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);