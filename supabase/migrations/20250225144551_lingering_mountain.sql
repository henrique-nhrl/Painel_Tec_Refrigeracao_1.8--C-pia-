-- Função para registrar movimentação financeira
CREATE OR REPLACE FUNCTION handle_service_financial()
RETURNS trigger AS $$
BEGIN
  -- Se é uma inserção
  IF TG_OP = 'INSERT' THEN
    -- Criar registro financeiro
    INSERT INTO financial_records (
      service_id,
      amount,
      date
    ) VALUES (
      NEW.id,
      NEW.total,
      NEW.service_date
    );
  
  -- Se é uma atualização e o valor mudou
  ELSIF TG_OP = 'UPDATE' AND NEW.total != OLD.total THEN
    -- Atualizar registro financeiro existente
    UPDATE financial_records
    SET amount = NEW.total,
        date = NEW.service_date
    WHERE service_id = NEW.id;
  
  -- Se é uma exclusão
  ELSIF TG_OP = 'DELETE' THEN
    -- O registro financeiro será excluído automaticamente pela FK ON DELETE CASCADE
    RETURN OLD;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Criar triggers para gerenciar registros financeiros
DROP TRIGGER IF EXISTS service_financial_trigger ON services;
CREATE TRIGGER service_financial_trigger
  AFTER INSERT OR UPDATE OR DELETE ON services
  FOR EACH ROW
  EXECUTE FUNCTION handle_service_financial();

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_financial_records_service_id ON financial_records(service_id);
CREATE INDEX IF NOT EXISTS idx_financial_records_amount ON financial_records(amount);

-- Atualizar políticas RLS
DROP POLICY IF EXISTS "permitir_gerenciar_financeiro" ON financial_records;
CREATE POLICY "permitir_gerenciar_financeiro"
  ON financial_records FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Criar função para calcular totais
CREATE OR REPLACE FUNCTION get_financial_totals(
  start_date date,
  end_date date
)
RETURNS TABLE (
  total_amount decimal(10,2),
  average_amount decimal(10,2),
  total_services bigint
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    COALESCE(SUM(amount), 0) as total_amount,
    COALESCE(AVG(amount), 0) as average_amount,
    COUNT(*) as total_services
  FROM financial_records
  WHERE date BETWEEN start_date AND end_date;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;