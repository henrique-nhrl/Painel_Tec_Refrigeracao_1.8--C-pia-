-- Drop existing trigger if exists
DROP TRIGGER IF EXISTS support_credentials_before_insert ON support_api_credentials;

-- Criar tabela de credenciais de API
CREATE TABLE IF NOT EXISTS support_api_credentials (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  support_id text UNIQUE NOT NULL,
  client_name text NOT NULL,
  company_name text NOT NULL,
  document text NOT NULL,
  api_key text UNIQUE NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Função para gerar ID de suporte (4 dígitos)
CREATE OR REPLACE FUNCTION generate_support_id()
RETURNS text AS $$
DECLARE
  new_id text;
  exists_id boolean;
BEGIN
  LOOP
    -- Gerar número aleatório de 4 dígitos
    new_id := lpad(floor(random() * 10000)::text, 4, '0');
    
    -- Verificar se já existe
    SELECT EXISTS (
      SELECT 1 
      FROM support_api_credentials 
      WHERE support_id = new_id
    ) INTO exists_id;
    
    -- Se não existe, retornar
    IF NOT exists_id THEN
      RETURN new_id;
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Função para gerar chave API (32 caracteres)
CREATE OR REPLACE FUNCTION generate_api_key()
RETURNS text AS $$
DECLARE
  chars text := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  result text := '';
  i integer := 0;
BEGIN
  FOR i IN 1..32 LOOP
    result := result || substr(chars, floor(random() * length(chars) + 1)::integer, 1);
  END LOOP;
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Função para validar CPF
CREATE OR REPLACE FUNCTION is_valid_cpf(cpf text)
RETURNS boolean AS $$
DECLARE
  sum integer;
  digit integer;
  weight integer;
  i integer;
  clean_cpf text;
BEGIN
  -- Remover caracteres não numéricos
  clean_cpf := regexp_replace(cpf, '[^0-9]', '', 'g');
  
  -- Verificar tamanho
  IF length(clean_cpf) != 11 THEN
    RETURN false;
  END IF;
  
  -- Verificar dígitos repetidos
  IF clean_cpf ~ '^(\d)\1*$' THEN
    RETURN false;
  END IF;
  
  -- Validar primeiro dígito
  sum := 0;
  weight := 10;
  FOR i IN 1..9 LOOP
    sum := sum + (substr(clean_cpf, i, 1)::integer * weight);
    weight := weight - 1;
  END LOOP;
  
  digit := 11 - (sum % 11);
  IF digit >= 10 THEN
    digit := 0;
  END IF;
  
  IF digit != substr(clean_cpf, 10, 1)::integer THEN
    RETURN false;
  END IF;
  
  -- Validar segundo dígito
  sum := 0;
  weight := 11;
  FOR i IN 1..10 LOOP
    sum := sum + (substr(clean_cpf, i, 1)::integer * weight);
    weight := weight - 1;
  END LOOP;
  
  digit := 11 - (sum % 11);
  IF digit >= 10 THEN
    digit := 0;
  END IF;
  
  RETURN digit = substr(clean_cpf, 11, 1)::integer;
END;
$$ LANGUAGE plpgsql;

-- Função para validar CNPJ
CREATE OR REPLACE FUNCTION is_valid_cnpj(cnpj text)
RETURNS boolean AS $$
DECLARE
  sum integer;
  digit integer;
  weight integer;
  i integer;
  clean_cnpj text;
BEGIN
  -- Remover caracteres não numéricos
  clean_cnpj := regexp_replace(cnpj, '[^0-9]', '', 'g');
  
  -- Verificar tamanho
  IF length(clean_cnpj) != 14 THEN
    RETURN false;
  END IF;
  
  -- Verificar dígitos repetidos
  IF clean_cnpj ~ '^(\d)\1*$' THEN
    RETURN false;
  END IF;
  
  -- Validar primeiro dígito
  sum := 0;
  weight := 5;
  FOR i IN 1..12 LOOP
    sum := sum + (substr(clean_cnpj, i, 1)::integer * weight);
    weight := weight - 1;
    IF weight = 1 THEN
      weight := 9;
    END IF;
  END LOOP;
  
  digit := 11 - (sum % 11);
  IF digit >= 10 THEN
    digit := 0;
  END IF;
  
  IF digit != substr(clean_cnpj, 13, 1)::integer THEN
    RETURN false;
  END IF;
  
  -- Validar segundo dígito
  sum := 0;
  weight := 6;
  FOR i IN 1..13 LOOP
    sum := sum + (substr(clean_cnpj, i, 1)::integer * weight);
    weight := weight - 1;
    IF weight = 1 THEN
      weight := 9;
    END IF;
  END LOOP;
  
  digit := 11 - (sum % 11);
  IF digit >= 10 THEN
    digit := 0;
  END IF;
  
  RETURN digit = substr(clean_cnpj, 14, 1)::integer;
END;
$$ LANGUAGE plpgsql;

-- Função para validar CPF ou CNPJ
CREATE OR REPLACE FUNCTION is_valid_document(doc text)
RETURNS boolean AS $$
DECLARE
  clean_doc text;
BEGIN
  -- Remover caracteres não numéricos
  clean_doc := regexp_replace(doc, '[^0-9]', '', 'g');
  
  -- Verificar se é CPF ou CNPJ pelo tamanho
  IF length(clean_doc) = 11 THEN
    RETURN is_valid_cpf(clean_doc);
  ELSIF length(clean_doc) = 14 THEN
    RETURN is_valid_cnpj(clean_doc);
  ELSE
    RETURN false;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Trigger para gerar ID e chave automaticamente
CREATE OR REPLACE FUNCTION before_insert_credentials()
RETURNS trigger AS $$
BEGIN
  -- Validar documento
  IF NOT is_valid_document(NEW.document) THEN
    RAISE EXCEPTION 'Documento inválido';
  END IF;

  -- Gerar ID de suporte se não fornecido
  IF NEW.support_id IS NULL THEN
    NEW.support_id := generate_support_id();
  END IF;
  
  -- Gerar chave API se não fornecida
  IF NEW.api_key IS NULL THEN
    NEW.api_key := generate_api_key();
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar trigger novamente
CREATE TRIGGER support_credentials_before_insert
  BEFORE INSERT ON support_api_credentials
  FOR EACH ROW
  EXECUTE FUNCTION before_insert_credentials();

-- Habilitar RLS
ALTER TABLE support_api_credentials ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança
DROP POLICY IF EXISTS "Visualizar credenciais" ON support_api_credentials;
DROP POLICY IF EXISTS "Inserir credenciais" ON support_api_credentials;

CREATE POLICY "Visualizar credenciais"
  ON support_api_credentials
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Inserir credenciais"
  ON support_api_credentials
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Criar endpoint para API
CREATE OR REPLACE FUNCTION get_support_info(support_id text, api_key text)
RETURNS json AS $$
DECLARE
  result json;
BEGIN
  SELECT json_build_object(
    'support_id', support_id,
    'client_name', client_name,
    'company_name', company_name,
    'document', document,
    'created_at', created_at
  )
  INTO result
  FROM support_api_credentials
  WHERE support_id = $1 AND api_key = $2;
  
  IF result IS NULL THEN
    RAISE EXCEPTION 'Credenciais inválidas';
  END IF;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;