import React, { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { FinancialRecord } from '../types/database';
import { Calendar, DollarSign, TrendingUp, Filter } from 'lucide-react';
import toast from 'react-hot-toast';

export function Financial() {
  const [records, setRecords] = useState<FinancialRecord[]>([]);
  const [loading, setLoading] = useState(false);
  const [startDate, setStartDate] = useState(
    new Date(new Date().getFullYear(), new Date().getMonth(), 1)
      .toISOString()
      .split('T')[0]
  );
  const [endDate, setEndDate] = useState(
    new Date().toISOString().split('T')[0]
  );
  const [totals, setTotals] = useState({
    total_amount: 0,
    average_amount: 0,
    total_services: 0
  });

  useEffect(() => {
    loadRecords();
    loadTotals();
  }, [startDate, endDate]);

  const loadRecords = async () => {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('financial_records')
        .select(`
          *,
          service:services(
            id,
            service_number,
            service_date,
            client:clients(
              name
            ),
            service_type:service_types(
              name
            )
          )
        `)
        .gte('date', startDate)
        .lte('date', endDate)
        .order('date', { ascending: false });

      if (error) throw error;
      setRecords(data || []);
    } catch (error) {
      console.error('Erro ao carregar registros:', error);
      toast.error('Erro ao carregar registros financeiros');
    } finally {
      setLoading(false);
    }
  };

  const loadTotals = async () => {
    try {
      const { data, error } = await supabase
        .rpc('get_financial_totals', {
          start_date: startDate,
          end_date: endDate
        });

      if (error) throw error;
      if (data) {
        setTotals(data[0]);
      }
    } catch (error) {
      console.error('Erro ao carregar totais:', error);
      toast.error('Erro ao carregar totais');
    }
  };

  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value);
  };

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Financeiro</h1>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="card bg-green-500/10">
          <div className="flex items-center gap-3">
            <DollarSign className="text-green-500" size={24} />
            <div>
              <h3 className="text-sm font-medium text-muted-foreground">
                Total do Período
              </h3>
              <p className="text-2xl font-bold text-green-500">
                {formatCurrency(totals.total_amount)}
              </p>
            </div>
          </div>
        </div>

        <div className="card bg-blue-500/10">
          <div className="flex items-center gap-3">
            <TrendingUp className="text-blue-500" size={24} />
            <div>
              <h3 className="text-sm font-medium text-muted-foreground">
                Média por Serviço
              </h3>
              <p className="text-2xl font-bold text-blue-500">
                {formatCurrency(totals.average_amount)}
              </p>
            </div>
          </div>
        </div>

        <div className="card bg-purple-500/10">
          <div className="flex items-center gap-3">
            <Calendar className="text-purple-500" size={24} />
            <div>
              <h3 className="text-sm font-medium text-muted-foreground">
                Total de Serviços
              </h3>
              <p className="text-2xl font-bold text-purple-500">
                {totals.total_services}
              </p>
            </div>
          </div>
        </div>
      </div>

      <div className="card">
        <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-6">
          <div className="flex items-center gap-2">
            <Filter size={20} className="text-muted-foreground" />
            <h2 className="text-lg font-semibold">Filtros</h2>
          </div>

          <div className="flex flex-col md:flex-row gap-4">
            <div>
              <label className="block text-sm font-medium text-muted-foreground mb-1">
                Data Inicial
              </label>
              <input
                type="date"
                className="input"
                value={startDate}
                onChange={(e) => setStartDate(e.target.value)}
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-muted-foreground mb-1">
                Data Final
              </label>
              <input
                type="date"
                className="input"
                value={endDate}
                onChange={(e) => setEndDate(e.target.value)}
              />
            </div>
          </div>
        </div>

        <div className="space-y-4">
          {loading ? (
            <p className="text-center text-muted-foreground">Carregando...</p>
          ) : records.length === 0 ? (
            <p className="text-center text-muted-foreground">
              Nenhum registro encontrado no período selecionado.
            </p>
          ) : (
            records.map((record) => (
              <div key={record.id} className="flex justify-between items-center p-4 bg-secondary/10 rounded-lg">
                <div>
                  <h3 className="font-medium">
                    {record.service?.client?.name}
                  </h3>
                  <p className="text-sm text-muted-foreground">
                    {record.service?.service_type?.name} - {record.service?.service_number}º Atendimento
                  </p>
                  <p className="text-sm text-muted-foreground">
                    {new Date(record.date).toLocaleDateString('pt-BR')}
                  </p>
                </div>
                <div className="text-right">
                  <p className="text-lg font-bold text-green-500">
                    {formatCurrency(record.amount)}
                  </p>
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
}