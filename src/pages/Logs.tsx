import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { Log } from '../types/database';

interface LogsByDate {
  [date: string]: Log[];
}

export function Logs() {
  const [logs, setLogs] = useState<Log[]>([]);
  const [logsByDate, setLogsByDate] = useState<LogsByDate>({});
  const [selectedDate, setSelectedDate] = useState('');
  const [selectedMonth, setSelectedMonth] = useState('');
  const [selectedYear, setSelectedYear] = useState('');

  useEffect(() => {
    loadLogs();
  }, []);

  const loadLogs = async () => {
    try {
      const { data, error } = await supabase
        .from('logs')
        .select(`
          *,
          profiles:user_id (email),
          products:product_id (name)
        `)
        .order('created_at', { ascending: false });

      if (error) throw error;
      if (data) setLogs(data);
    } catch (error) {
      console.error('Erro ao carregar logs:', error);
    }
  };

  useEffect(() => {
    organizeLogs();
  }, [logs]);

  const organizeLogs = () => {
    const organized = logs.reduce((acc, log) => {
      const date = new Date(log.created_at).toLocaleDateString('pt-BR');
      if (!acc[date]) {
        acc[date] = [];
      }
      acc[date].push(log);
      return acc;
    }, {} as LogsByDate);
    setLogsByDate(organized);
  };

  const formatAction = (log: Log) => {
    let action = log.action;
    if (log.clients?.name) {
      action = action.replace('{client}', log.clients.name);
    }
    if (log.products?.name) {
      action = action.replace('{product}', log.products.name);
    }
    return action;
  };

  const getAvailableYears = () => {
    const years = new Set(logs.map(log => 
      new Date(log.created_at).getFullYear()
    ));
    return Array.from(years).sort((a, b) => b - a);
  };

  const getAvailableMonths = () => {
    const months = new Set(logs.map(log => {
      const date = new Date(log.created_at);
      return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
    }));
    return Array.from(months).sort((a, b) => b.localeCompare(a));
  };

  const filterLogs = () => {
    let filtered = { ...logsByDate };

    if (selectedYear) {
      filtered = Object.fromEntries(
        Object.entries(filtered).filter(([date]) => {
          const year = date.split('/')[2];
          return year === selectedYear;
        })
      );
    }

    if (selectedMonth) {
      filtered = Object.fromEntries(
        Object.entries(filtered).filter(([date]) => {
          const [day, month, year] = date.split('/');
          return `${year}-${month}` === selectedMonth;
        })
      );
    }

    if (selectedDate) {
      filtered = Object.fromEntries(
        Object.entries(filtered).filter(([date]) => date === selectedDate)
      );
    }

    return filtered;
  };

  const filteredLogs = filterLogs();

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Logs do Sistema</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Logs Section */}
        <div className="space-y-6">
          {Object.entries(filteredLogs).map(([date, dateLogs]) => (
            <div key={date} className="space-y-4">
              <h2 className="text-xl font-semibold border-b border-blue-500/20 pb-2">
                {date}
              </h2>
              <div className="space-y-4">
                {dateLogs.map((log) => (
                  <div key={log.id} className="card">
                    <div className="flex justify-between items-start">
                      <div>
                        <p className="text-muted-foreground">
                          {new Date(log.created_at).toLocaleTimeString('pt-BR')}
                        </p>
                        <p className="mt-1">
                          <span className="text-primary">{log.profiles?.email}</span>
                          {' '}{formatAction(log)}
                        </p>
                        {log.clients?.name && (
                          <p className="text-sm text-muted-foreground">
                            Cliente: {log.clients.name}
                          </p>
                        )}
                        {log.products?.name && (
                          <p className="text-sm text-muted-foreground">
                            Produto: {log.products.name}
                          </p>
                        )}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>

        {/* Filters Section */}
        <div className="space-y-6">
          <div className="card">
            <h2 className="text-xl font-semibold mb-4">Filtros</h2>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-400 mb-1">
                  Ano
                </label>
                <select
                  className="input w-full"
                  value={selectedYear}
                  onChange={(e) => setSelectedYear(e.target.value)}
                >
                  <option value="">Todos os anos</option>
                  {getAvailableYears().map(year => (
                    <option key={year} value={year}>{year}</option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-400 mb-1">
                  Mês
                </label>
                <select
                  className="input w-full"
                  value={selectedMonth}
                  onChange={(e) => setSelectedMonth(e.target.value)}
                >
                  <option value="">Todos os meses</option>
                  {getAvailableMonths().map(month => {
                    const [year, monthNum] = month.split('-');
                    const date = new Date(Number(year), Number(monthNum) - 1);
                    return (
                      <option key={month} value={month}>
                        {date.toLocaleString('pt-BR', { month: 'long', year: 'numeric' })}
                      </option>
                    );
                  })}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-400 mb-1">
                  Data Específica
                </label>
                <input
                  type="date"
                  className="input w-full"
                  value={selectedDate}
                  onChange={(e) => {
                    const date = e.target.value ? 
                      new Date(e.target.value).toLocaleDateString('pt-BR') : 
                      '';
                    setSelectedDate(date);
                  }}
                />
              </div>

              <button
                className="btn btn-primary w-full"
                onClick={() => {
                  setSelectedDate('');
                  setSelectedMonth('');
                  setSelectedYear('');
                }}
              >
                Limpar Filtros
              </button>
            </div>
          </div>

          <div className="card">
            <h2 className="text-xl font-semibold mb-4">Estatísticas</h2>
            <div className="space-y-2">
              <p>Total de logs: {logs.length}</p>
              <p>Períodos registrados: {Object.keys(logsByDate).length} dias</p>
              <p>Logs filtrados: {Object.values(filteredLogs).flat().length}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}