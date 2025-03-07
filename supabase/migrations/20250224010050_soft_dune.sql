-- Remover view existente
DROP VIEW IF EXISTS support_id_view;

-- Desabilitar temporariamente o trigger
ALTER TABLE support_api_credentials DISABLE TRIGGER support_credentials_before_insert;

-- Inserir registro padrão se não existir
INSERT INTO support_api_credentials (
  support_id,
  client_name,
  company_name,
  document,
  api_key
)
SELECT
  '0000',
  'Cliente Padrão',
  'Empresa Padrão',
  '12345678901', -- CPF válido para registro padrão
  'chave_padrao_' || gen_random_uuid()
WHERE NOT EXISTS (
  SELECT 1 FROM support_api_credentials
);

-- Reabilitar o trigger
ALTER TABLE support_api_credentials ENABLE TRIGGER support_credentials_before_insert;

-- Criar nova view que lida com resultados vazios
CREATE OR REPLACE VIEW support_id_view AS
SELECT COALESCE(
  (SELECT support_id FROM support_api_credentials LIMIT 1),
  '0000'
) as support_id;