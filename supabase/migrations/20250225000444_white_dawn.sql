/*
  # Ajustes na estrutura da API de suporte

  1. Remover coluna api_key da tabela support_api_credentials
  2. Atualizar políticas de segurança
*/

-- Remover coluna api_key
ALTER TABLE support_api_credentials
DROP COLUMN IF EXISTS api_key;

-- Atualizar view
DROP VIEW IF EXISTS support_id_view;
CREATE VIEW support_id_view AS
SELECT support_id, client_name, company_name
FROM support_api_credentials
LIMIT 1;