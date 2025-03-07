/*
  # Ajustes de permissões e políticas

  1. Ajustes
    - Atualização das políticas para produtos
    - Atualização das políticas para clientes
    - Atualização das políticas para fidelização
    
  2. Alterações
    - Permissões igualitárias para clientes e fidelização
    - Restrição de produtos para usuários normais
*/

-- Remover políticas existentes
DROP POLICY IF EXISTS "Admins podem gerenciar produtos" ON products;
DROP POLICY IF EXISTS "Usuários podem atualizar preços" ON products;
DROP POLICY IF EXISTS "Todos podem ver produtos" ON products;

-- Criar novas políticas para produtos
CREATE POLICY "Visualizar produtos"
  ON products FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Gerenciar produtos"
  ON products FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- Atualizar políticas para clientes
DROP POLICY IF EXISTS "Todos podem ver e gerenciar clientes" ON clients;

CREATE POLICY "Gerenciar clientes"
  ON clients FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Atualizar políticas para notification_templates
DROP POLICY IF EXISTS "Todos podem gerenciar templates" ON notification_templates;

CREATE POLICY "Gerenciar templates"
  ON notification_templates FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);