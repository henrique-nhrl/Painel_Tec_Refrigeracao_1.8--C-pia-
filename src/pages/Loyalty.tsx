import React, { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { SystemSettings } from '../types/database';
import toast from 'react-hot-toast';

interface Template {
  id: string;
  title: string;
  content: string;
  type: 'maintenance' | 'welcome';
  variables: Record<string, string>;
}

export function Loyalty() {
  const [templates, setTemplates] = useState<Template[]>([]);
  const [settings, setSettings] = useState<SystemSettings | null>(null);
  const [testPhone, setTestPhone] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    loadTemplates();
    loadSettings();
  }, []);

  const loadTemplates = async () => {
    try {
      const { data, error } = await supabase
        .from('notification_templates')
        .select('*')
        .order('type', { ascending: true })
        .order('created_at', { ascending: false });

      if (error) throw error;
      if (data) setTemplates(data);
    } catch (error) {
      console.error('Erro ao carregar templates:', error);
      toast.error('Erro ao carregar templates');
    }
  };

  const loadSettings = async () => {
    try {
      const { data, error } = await supabase
        .from('system_settings')
        .select('*')
        .single();

      if (error) throw error;
      if (data) setSettings(data);
    } catch (error) {
      console.error('Erro ao carregar configurações:', error);
      toast.error('Erro ao carregar configurações');
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      if (!settings) return;

      const { error } = await supabase
        .from('system_settings')
        .update({
          maintenance_interval: settings.maintenance_interval,
          maintenance_price: settings.maintenance_price,
          maintenance_template_id: settings.maintenance_template_id,
          welcome_template_id: settings.welcome_template_id
        })
        .eq('id', '1');

      if (error) throw error;
      toast.success('Configurações salvas com sucesso');
      loadSettings();
    } catch (error) {
      console.error('Erro ao salvar configurações:', error);
      toast.error('Erro ao salvar configurações');
    } finally {
      setLoading(false);
    }
  };

  const handleTestMessage = async (type: 'welcome' | 'maintenance') => {
    if (!testPhone.match(/^\d{13}$/)) {
      toast.error('Digite um número válido no formato: 5545988110011');
      return;
    }

    if (!settings?.whatsapp_api_url || !settings?.whatsapp_api_key) {
      toast.error('Configure a API do WhatsApp primeiro');
      return;
    }

    setLoading(true);

    try {
      const templateId = type === 'welcome' 
        ? settings.welcome_template_id 
        : settings.maintenance_template_id;

      const template = templates.find(t => t.id === templateId);

      if (!template) {
        throw new Error(`Template de ${type === 'welcome' ? 'boas-vindas' : 'manutenção'} não encontrado`);
      }

      const testData = {
        nome_cliente: 'Cliente Teste',
        dias_instalacao: '30',
        tipo_servico: type === 'maintenance' ? 'manutenção' : undefined,
        preco_manutencao: settings.maintenance_price?.toFixed(2),
        nome_fantasia: settings.company_name
      };

      let message = template.content;
      Object.entries(testData).forEach(([key, value]) => {
        if (value) {
          message = message.replace(new RegExp(`{${key}}`, 'g'), value);
        }
      });

      const options = {
        method: 'POST',
        headers: {
          'apikey': settings.whatsapp_api_key,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          number: testPhone,
          textMessage: {
            text: message
          }
        })
      };

      const response = await fetch(settings.whatsapp_api_url, options);
      if (!response.ok) {
        throw new Error('Erro ao enviar mensagem');
      }

      toast.success(`Mensagem de ${type === 'welcome' ? 'boas-vindas' : 'manutenção'} enviada com sucesso!`);
    } catch (error) {
      console.error('Erro ao enviar mensagem:', error);
      toast.error(`Erro ao enviar mensagem de ${type === 'welcome' ? 'boas-vindas' : 'manutenção'}`);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6 max-w-full">
      <h1 className="text-2xl font-bold">Fidelização</h1>
      
      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Configurações de Manutenção */}
        <div className="card space-y-4">
          <h2 className="text-xl font-semibold">Configurações de Manutenção</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-muted-foreground">
                Intervalo de Manutenção (dias)
              </label>
              <input
                type="number"
                className="input w-full mt-1"
                value={settings?.maintenance_interval || 120}
                onChange={(e) => setSettings(prev => ({ 
                  ...prev!, 
                  maintenance_interval: parseInt(e.target.value) 
                }))}
                min="1"
                required
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-muted-foreground">
                Preço da Manutenção (R$)
              </label>
              <input
                type="number"
                className="input w-full mt-1"
                value={settings?.maintenance_price || 150}
                onChange={(e) => setSettings(prev => ({ 
                  ...prev!, 
                  maintenance_price: parseFloat(e.target.value) 
                }))}
                min="0"
                step="0.01"
                required
              />
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-muted-foreground">
                Template de Manutenção
              </label>
              <select
                className="input w-full mt-1"
                value={settings?.maintenance_template_id || ''}
                onChange={(e) => setSettings(prev => ({ 
                  ...prev!, 
                  maintenance_template_id: e.target.value || null 
                }))}
              >
                <option value="">Selecione um template</option>
                {templates
                  .filter(t => t.type === 'maintenance')
                  .map(template => (
                    <option key={template.id} value={template.id}>
                      {template.title}
                    </option>
                  ))
                }
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-muted-foreground">
                Template de Boas-vindas
              </label>
              <select
                className="input w-full mt-1"
                value={settings?.welcome_template_id || ''}
                onChange={(e) => setSettings(prev => ({ 
                  ...prev!, 
                  welcome_template_id: e.target.value || null 
                }))}
              >
                <option value="">Selecione um template</option>
                {templates
                  .filter(t => t.type === 'welcome')
                  .map(template => (
                    <option key={template.id} value={template.id}>
                      {template.title}
                    </option>
                  ))
                }
              </select>
            </div>
          </div>

          <button
            type="submit"
            className="btn btn-primary w-full"
            disabled={loading}
          >
            {loading ? 'Salvando...' : 'Salvar Configurações'}
          </button>
        </div>

        {/* Testar Mensagens */}
        <div className="card space-y-4">
          <h2 className="text-xl font-semibold">Testar Mensagens</h2>
          
          <div>
            <label className="block text-sm font-medium text-muted-foreground">
              Número para Teste (ex: 5545988110011)
            </label>
            <div className="flex gap-2 mt-1">
              <input
                type="text"
                className="input flex-1"
                placeholder="5545988110011"
                value={testPhone}
                onChange={(e) => setTestPhone(e.target.value)}
              />
              <button
                type="button"
                onClick={() => handleTestMessage('welcome')}
                className="btn btn-primary whitespace-nowrap"
                disabled={loading || !settings?.welcome_template_id}
              >
                {loading ? 'Enviando...' : 'Boas-vindas'}
              </button>
              <button
                type="button"
                onClick={() => handleTestMessage('maintenance')}
                className="btn btn-primary whitespace-nowrap"
                disabled={loading || !settings?.maintenance_template_id}
              >
                {loading ? 'Enviando...' : 'Manutenção'}
              </button>
            </div>
          </div>
        </div>
      </form>

      {/* Templates Disponíveis */}
      <div className="card space-y-4">
        <h2 className="text-xl font-semibold">Templates Disponíveis</h2>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {templates.map((template) => (
            <div key={template.id} className="bg-secondary/10 p-4 rounded-lg">
              <h3 className="font-medium">
                {template.type === 'maintenance' ? '🔧 ' : '👋 '}
                {template.title}
              </h3>
              <pre className="mt-2 whitespace-pre-wrap text-sm text-muted-foreground break-words w-full">
                {template.content}
              </pre>
              <p className="mt-2 text-sm text-muted-foreground">
                Variáveis: {Object.keys(template.variables).join(', ')}
              </p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}