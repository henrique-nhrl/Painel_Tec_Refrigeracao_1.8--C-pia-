/*
  # Atualização do schema com verificação de existência
  
  1. Tipos
    - Criação de tipos enumerados se não existirem
    
  2. Tabelas
    - Verificação de existência antes da criação
    
  3. Políticas
    - Adição de políticas RLS básicas
*/

DO $$ 
BEGIN
    -- Criar tipos enumerados se não existirem
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
        CREATE TYPE user_role AS ENUM ('admin', 'user');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'request_status') THEN
        CREATE TYPE request_status AS ENUM ('pending', 'approved', 'rejected');
    END IF;
END $$;

-- Tabela de perfis de usuário
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  email text NOT NULL,
  role user_role NOT NULL DEFAULT 'user',
  created_at timestamptz DEFAULT now()
);

-- Tabela de produtos
CREATE TABLE IF NOT EXISTS products (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  price decimal(10,2) NOT NULL,
  category text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Tabela de solicitações de produtos
CREATE TABLE IF NOT EXISTS product_requests (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  name text NOT NULL,
  price decimal(10,2) NOT NULL,
  description text NOT NULL,
  status request_status DEFAULT 'pending',
  created_at timestamptz DEFAULT now()
);

-- Tabela de logs
CREATE TABLE IF NOT EXISTS logs (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  product_id uuid REFERENCES products(id) ON DELETE CASCADE,
  action text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Habilitar RLS (não gera erro se já estiver habilitado)
DO $$ 
BEGIN
    ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
    ALTER TABLE products ENABLE ROW LEVEL SECURITY;
    ALTER TABLE product_requests ENABLE ROW LEVEL SECURITY;
    ALTER TABLE logs ENABLE ROW LEVEL SECURITY;
EXCEPTION 
    WHEN OTHERS THEN NULL;
END $$;

-- Remover políticas existentes se houver
DROP POLICY IF EXISTS "Usuários podem ver seus próprios perfis" ON profiles;
DROP POLICY IF EXISTS "Todos podem ver produtos" ON products;

-- Criar novas políticas
CREATE POLICY "Usuários podem ver seus próprios perfis"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Todos podem ver produtos"
  ON products FOR SELECT
  TO authenticated
  USING (true);