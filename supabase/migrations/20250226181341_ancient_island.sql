-- This migration fixes RLS policies for critical tables

-- First, drop existing policies that might be causing issues
DROP POLICY IF EXISTS "allow_all" ON system_settings;
DROP POLICY IF EXISTS "gerenciar_configuracoes" ON system_settings;
DROP POLICY IF EXISTS "view_settings" ON system_settings;
DROP POLICY IF EXISTS "update_settings" ON system_settings;
DROP POLICY IF EXISTS "allow_read_settings" ON system_settings;
DROP POLICY IF EXISTS "allow_update_settings" ON system_settings;
DROP POLICY IF EXISTS "allow_insert_settings" ON system_settings;
DROP POLICY IF EXISTS "permitir_leitura" ON system_settings;
DROP POLICY IF EXISTS "permitir_atualizacao" ON system_settings;

-- Create a simple, permissive policy for system_settings
CREATE POLICY "system_settings_access_policy"
  ON system_settings
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Drop existing policies for profiles
DROP POLICY IF EXISTS "Usuários podem ver seus próprios perfis" ON profiles;
DROP POLICY IF EXISTS "Admins podem ver todos os perfis" ON profiles;
DROP POLICY IF EXISTS "Usuários podem atualizar seus próprios perfis" ON profiles;
DROP POLICY IF EXISTS "Admins podem atualizar qualquer perfil" ON profiles;
DROP POLICY IF EXISTS "Visualizar próprio perfil" ON profiles;
DROP POLICY IF EXISTS "Admin visualizar todos os perfis" ON profiles;
DROP POLICY IF EXISTS "Atualizar próprio perfil" ON profiles;
DROP POLICY IF EXISTS "Admin gerenciar perfis" ON profiles;
DROP POLICY IF EXISTS "perfis_visualizar_proprio" ON profiles;
DROP POLICY IF EXISTS "perfis_admin_visualizar" ON profiles;
DROP POLICY IF EXISTS "perfis_atualizar_proprio" ON profiles;
DROP POLICY IF EXISTS "perfis_admin_gerenciar" ON profiles;

-- Create simplified policies for profiles
CREATE POLICY "profiles_select_policy"
  ON profiles
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "profiles_update_policy"
  ON profiles
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Ensure the system_settings table has a default record
INSERT INTO system_settings (
  id,
  company_name,
  support_user_name,
  support_document,
  support_id,
  timezone,
  enable_product_requests,
  maintenance_interval,
  maintenance_price
) VALUES (
  '1',
  'Empresa Padrão',
  'Usuário Padrão',
  '12345678901',
  '0000',
  'America/Sao_Paulo',
  true,
  120,
  150.00
) ON CONFLICT (id) DO NOTHING;

-- Notify PostgREST to reload schema
NOTIFY pgrst, 'reload schema';