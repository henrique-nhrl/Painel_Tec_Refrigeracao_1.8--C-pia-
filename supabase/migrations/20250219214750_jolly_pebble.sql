/*
  # Adicionar tabelas de categorias e empresa

  1. Novas Tabelas
    - `categories`
      - `id` (uuid, primary key)
      - `name` (text, unique)
      - `created_at` (timestamp)
    
    - `company_settings`
      - `id` (uuid, primary key)
      - `name` (text)
      - `logo_url` (text)
      - `welcome_message` (text)
      - `created_at` (timestamp)

  2. Alterações
    - Adicionar `category_id` e `display_order` em `products`
    - Adicionar `category_id` em `product_requests`

  3. Segurança
    - Habilitar RLS
    - Adicionar políticas para admin
*/

-- Criar tabela de categorias
CREATE TABLE IF NOT EXISTS categories (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name text UNIQUE NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Criar tabela de configurações da empresa
CREATE TABLE IF NOT EXISTS company_settings (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  logo_url text,
  welcome_message text,
  created_at timestamptz DEFAULT now()
);

-- Adicionar colunas em products
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS category_id uuid REFERENCES categories(id),
ADD COLUMN IF NOT EXISTS display_order integer DEFAULT 0;

-- Adicionar coluna em product_requests
ALTER TABLE product_requests 
ADD COLUMN IF NOT EXISTS category_id uuid REFERENCES categories(id);

-- Habilitar RLS
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE company_settings ENABLE ROW LEVEL SECURITY;

-- Políticas para categories
CREATE POLICY "Todos podem ver categorias"
  ON categories FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins podem gerenciar categorias"
  ON categories
  USING (is_admin());

-- Políticas para company_settings
CREATE POLICY "Todos podem ver configurações da empresa"
  ON company_settings FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins podem gerenciar configurações da empresa"
  ON company_settings
  USING (is_admin());

-- Criar função para próxima ordem
CREATE OR REPLACE FUNCTION next_display_order() 
RETURNS integer AS $$
DECLARE
  next_order integer;
BEGIN
  SELECT COALESCE(MAX(display_order) + 1, 1)
  INTO next_order
  FROM products;
  RETURN next_order;
END;
$$ LANGUAGE plpgsql;