-- Primeiro, remover as referências em company_settings
UPDATE company_settings
SET maintenance_template_id = NULL,
    welcome_template_id = NULL;

-- Agora podemos limpar e recriar os templates
DELETE FROM notification_templates;

-- Inserir novos templates com nome fantasia
INSERT INTO notification_templates (
  id,
  title,
  content,
  type,
  variables,
  maintenance_interval,
  maintenance_price,
  company_name,
  created_at
) VALUES
-- Templates de Manutenção
(
  gen_random_uuid(),
  'Lembrete de Manutenção Padrão',
  '🔧 Olá {nome_cliente}!\n\nJá se passaram {dias_instalacao} dias desde {tipo_servico}. Para manter seu equipamento funcionando perfeitamente, que tal agendar uma revisão?\n\nValor especial: R$ {preco_manutencao}\n\nAtenciosamente,\n{nome_fantasia}',
  'maintenance',
  jsonb_build_object(
    'nome_cliente', 'Nome formal do cliente',
    'dias_instalacao', 'Dias desde o último serviço',
    'tipo_servico', 'Tipo do serviço realizado',
    'preco_manutencao', 'Preço da manutenção',
    'nome_fantasia', 'Nome fantasia da empresa'
  ),
  120,
  150.00,
  (SELECT name FROM company_settings LIMIT 1),
  now()
),
(
  gen_random_uuid(),
  'Lembrete de Manutenção Preventiva',
  '⚡ Importante: Manutenção Preventiva\n\nOlá {nome_cliente},\n\nSeu equipamento precisa de cuidados! Já se passaram {dias_instalacao} dias desde {tipo_servico}.\n\nAgende agora sua manutenção por apenas R$ {preco_manutencao} e evite problemas futuros!\n\n{nome_fantasia}',
  'maintenance',
  jsonb_build_object(
    'nome_cliente', 'Nome formal do cliente',
    'dias_instalacao', 'Dias desde o último serviço',
    'tipo_servico', 'Tipo do serviço realizado',
    'preco_manutencao', 'Preço da manutenção',
    'nome_fantasia', 'Nome fantasia da empresa'
  ),
  120,
  150.00,
  (SELECT name FROM company_settings LIMIT 1),
  now()
),
-- Templates de Boas-vindas
(
  gen_random_uuid(),
  'Boas-vindas Residencial',
  '👋 Olá {nome_cliente}!\n\nSeja bem-vindo ao programa de fidelidade da {nome_fantasia}! 🌟\n\nAgora você terá acesso a:\n✅ Descontos especiais\n✅ Lembretes de manutenção\n✅ Atendimento prioritário\n\nObrigado pela confiança! 💙',
  'welcome',
  jsonb_build_object(
    'nome_cliente', 'Nome formal do cliente',
    'nome_fantasia', 'Nome fantasia da empresa'
  ),
  120,
  150.00,
  (SELECT name FROM company_settings LIMIT 1),
  now()
),
(
  gen_random_uuid(),
  'Boas-vindas Comercial',
  '🏢 Prezado(a) {nome_cliente},\n\nÉ com satisfação que damos as boas-vindas à {nome_fantasia}!\n\nComo cliente VIP, você conta com:\n✅ Manutenção programada\n✅ Preços diferenciados\n✅ Suporte prioritário\n\nContamos com sua parceria! 🤝',
  'welcome',
  jsonb_build_object(
    'nome_cliente', 'Nome formal do cliente',
    'nome_fantasia', 'Nome fantasia da empresa'
  ),
  120,
  150.00,
  (SELECT name FROM company_settings LIMIT 1),
  now()
);

-- Atualizar as referências em company_settings
UPDATE company_settings
SET maintenance_template_id = (
  SELECT id FROM notification_templates 
  WHERE type = 'maintenance' 
  ORDER BY created_at DESC 
  LIMIT 1
),
welcome_template_id = (
  SELECT id FROM notification_templates 
  WHERE type = 'welcome' 
  ORDER BY created_at DESC 
  LIMIT 1
);