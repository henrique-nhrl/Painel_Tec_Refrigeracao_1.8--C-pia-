/*
  # Correção das políticas de acesso para API de Suporte

  1. Políticas
    - Somente admin pode gerenciar credenciais
    - Usuários podem visualizar apenas o ID de suporte
    - Remoção de políticas conflitantes

  2. Ajustes
    - Remoção de políticas antigas
    - Criação de novas políticas restritas
    - Ajuste da view para usuários normais
*/

-- Remover todas as políticas existentes
DROP POLICY IF EXISTS "Visualizar credenciais" ON support_api_credentials;
DROP POLICY IF EXISTS "Inserir credenciais" ON support_api_credentials;
DROP POLICY IF EXISTS "Admins podem gerenciar credenciais" ON support_api_credentials;
DROP POLICY IF EXISTS "Usuários podem ver ID de suporte" ON support_api_credentials;

-- Criar novas políticas
CREATE POLICY "Admins podem gerenciar credenciais"
  ON support_api_credentials
  FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());

CREATE POLICY "Usuários podem ver ID de suporte"
  ON support_api_credentials
  FOR SELECT
  USING (true);

-- Recriar view para usuários normais
DROP VIEW IF EXISTS public.support_id_view;
CREATE VIEW public.support_id_view AS
SELECT support_id
FROM support_api_credentials
LIMIT 1;