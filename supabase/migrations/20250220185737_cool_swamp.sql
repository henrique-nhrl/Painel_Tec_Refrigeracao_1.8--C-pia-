/*
  # Add service categories and welcome messages

  1. New Tables
    - service_categories
    - welcome_messages
  
  2. Initial Data
    - Default service categories
    - Default welcome message templates
*/

-- Create service categories table
CREATE TABLE IF NOT EXISTS service_categories (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name text NOT NULL UNIQUE,
  created_at timestamptz DEFAULT now()
);

-- Create welcome messages table
CREATE TABLE IF NOT EXISTS welcome_messages (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  title text NOT NULL,
  content text NOT NULL,
  is_default boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE service_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE welcome_messages ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Everyone can view service categories"
  ON service_categories FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Only admins can manage service categories"
  ON service_categories
  USING (is_admin());

CREATE POLICY "Everyone can view welcome messages"
  ON welcome_messages FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Only admins can manage welcome messages"
  ON welcome_messages
  USING (is_admin());

-- Insert default service categories
INSERT INTO service_categories (name) VALUES
  ('a manutenção'),
  ('a instalação'),
  ('a higienização');

-- Insert default welcome message templates
INSERT INTO welcome_messages (title, content, is_default) VALUES
  (
    'Boas-vindas Padrão',
    '👋 *Olá, {nome_cliente}!*\n\nSeja bem-vindo ao nosso programa de fidelidade! 🌟\n\nAgora você terá acesso a descontos especiais e lembretes para manter seu ar-condicionado sempre em dia.\n\nContamos com você para um ar mais limpo e saudável! 💨❤️\n\nAtenciosamente,\n{nome_empresa}',
    true
  ),
  (
    'Boas-vindas Premium',
    '✨ *Bem-vindo(a) {nome_cliente}!*\n\nÉ com grande satisfação que damos as boas-vindas ao nosso programa VIP de fidelidade! 🎯\n\nComo cliente especial, você terá:\n- Prioridade nos agendamentos\n- Descontos exclusivos\n- Lembretes personalizados\n\nObrigado pela confiança!\n{nome_empresa}',
    true
  ),
  (
    'Boas-vindas Comercial',
    '🏢 *Olá, {nome_cliente}!*\n\nAgradecemos por escolher nossa empresa para cuidar do seu sistema de climatização! 🌟\n\nComo parceiro comercial, você conta com:\n- Atendimento prioritário\n- Preços diferenciados\n- Manutenção programada\n\nEstamos à disposição!\n{nome_empresa}',
    true
  );

-- Add new columns to clients table
ALTER TABLE clients
ADD COLUMN IF NOT EXISTS formal_name text,
ADD COLUMN IF NOT EXISTS service_category_id uuid REFERENCES service_categories(id),
ADD COLUMN IF NOT EXISTS send_maintenance_reminders boolean DEFAULT false,
ADD COLUMN IF NOT EXISTS next_reminder_date date,
ADD COLUMN IF NOT EXISTS welcome_message_sent boolean DEFAULT false;