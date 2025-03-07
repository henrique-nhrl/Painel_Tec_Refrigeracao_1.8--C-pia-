import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { useAuthStore } from '../store/authStore';
import { FileUpload } from '../components/FileUpload';
import { ApiMethodSelector } from '../components/ApiMethodSelector';
import { ColumnSelector } from '../components/ColumnSelector';
import { ApiPreview } from '../components/ApiPreview';
import toast from 'react-hot-toast';

interface SystemSettings {
  id: string;
  company_name: string;
  logo_url: string | null;
  timezone: string;
  welcome_message: string | null;
  whatsapp_api_url: string | null;
  whatsapp_api_key: string | null;
  whatsapp_instance_name: string | null;
  support_id: string;
  support_user_name: string;
  support_document: string;
  support_url: string | null;
  enable_product_requests: boolean;
  maintenance_interval: number;
  maintenance_price: number;
  maintenance_template_id: string | null;
  welcome_template_id: string | null;
}

export function CompanySettings() {
  const [settings, setSettings] = useState<SystemSettings | null>(null);
  const [loading, setLoading] = useState(true);
  const [apiMethod, setApiMethod] = useState('GET');
  const [selectedColumns, setSelectedColumns] = useState<string[]>(['support_id', 'company_name', 'support_user_name']);
  const [testPhone, setTestPhone] = useState('');
  const { user } = useAuthStore();
  const isAdmin = user?.role === 'admin';

  const columns = [
    { name: 'support_id', description: 'ID de suporte' },
    { name: 'company_name', description: 'Nome da empresa' },
    { name: 'support_user_name', description: 'Nome do usuário' },
    { name: 'support_document', description: 'CPF/CNPJ' }
  ];

  useEffect(() => {
    loadSettings();
  }, []);

  const loadSettings = async () => {
    try {
      setLoading(true);
      
      // Try to get settings directly
      const { data, error } = await supabase
        .from('system_settings')
        .select('*')
        .eq('id', '1')
        .single();
      
      if (error) {
        console.error('Error loading settings:', error);
        
        // Try to create default settings if they don't exist
        const { data: insertData, error: insertError } = await supabase
          .from('system_settings')
          .insert({
            id: '1',
            company_name: 'Empresa Padrão',
            support_user_name: 'Usuário Padrão',
            support_document: '12345678901',
            support_id: '0000',
            timezone: 'America/Sao_Paulo',
            enable_product_requests: true,
            maintenance_interval: 120,
            maintenance_price: 150.00
          })
          .select()
          .single();
        
        if (insertError) {
          throw insertError;
        }
        
        setSettings(insertData);
      } else {
        setSettings(data);
        
        // Update document title with company name
        if (data.company_name) {
          document.title = data.company_name;
        }
      }
    } catch (error) {
      console.error('Erro ao carregar configurações:', error);
      toast.error('Erro ao carregar configurações');
    } finally {
      setLoading(false);
    }
  };

  const handleTestMessage = async () => {
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
      const { data: templates } = await supabase
        .from('notification_templates')
        .select('*')
        .eq('type', 'welcome')
        .limit(1)
        .single();

      if (!templates) {
        throw new Error('Template não encontrado');
      }

      const message = templates.content
        .replace('{nome_cliente}', settings.support_user_name)
        .replace('{nome_empresa}', settings.company_name);

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

      toast.success('Mensagem enviada com sucesso!');
    } catch (error) {
      console.error('Erro ao enviar mensagem:', error);
      toast.error('Erro ao enviar mensagem');
    } finally {
      setLoading(false);
    }
  };

  const updateSettings = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      if (settings) {
        const { error } = await supabase
          .from('system_settings')
          .update({
            company_name: settings.company_name,
            logo_url: settings.logo_url,
            timezone: settings.timezone,
            welcome_message: settings.welcome_message,
            whatsapp_api_url: settings.whatsapp_api_url,
            whatsapp_api_key: settings.whatsapp_api_key,
            whatsapp_instance_name: settings.whatsapp_instance_name,
            support_user_name: settings.support_user_name,
            support_document: settings.support_document,
            support_url: settings.support_url,
            enable_product_requests: settings.enable_product_requests,
            maintenance_interval: settings.maintenance_interval,
            maintenance_price: settings.maintenance_price,
            maintenance_template_id: settings.maintenance_template_id,
            welcome_template_id: settings.welcome_template_id
          })
          .eq('id', '1');

        if (error) throw error;
        toast.success('Configurações atualizadas com sucesso');
        
        // Update document title with company name
        if (settings.company_name) {
          document.title = settings.company_name;
        }
        
        loadSettings();
      }
    } catch (error) {
      console.error('Erro ao atualizar configurações:', error);
      toast.error('Erro ao atualizar configurações');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="w-16 h-16 border-4 border-primary border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
          <p className="text-muted-foreground">Carregando configurações...</p>
        </div>
      </div>
    );
  }

  if (!settings) {
    return (
      <div className="text-center p-8">
        <p className="text-destructive mb-4">Erro ao carregar configurações</p>
        <button 
          onClick={loadSettings}
          className="btn btn-primary"
        >
          Tentar novamente
        </button>
      </div>
    );
  }

  return (
    <div className="space-y-6 w-full">
      <h1 className="text-2xl font-bold">Configurações</h1>
      
      <form onSubmit={updateSettings} className="space-y-6 w-full">
        {/* Configurações da Empresa */}
        <div className="card space-y-4 w-full">
          <h2 className="text-xl font-semibold">Configurações da Empresa</h2>
          
          <div className="w-full">
            <label className="block text-sm font-medium text-muted-foreground">
              Nome da Empresa
            </label>
            <input
              type="text"
              className="input w-full mt-1"
              value={settings.company_name || ''}
              onChange={(e) => setSettings(prev => ({ ...prev!, company_name: e.target.value }))}
              required
            />
          </div>

          <div className="w-full">
            <label className="block text-sm font-medium text-muted-foreground">
              Logo da Empresa
            </label>
            <FileUpload
              onUpload={(url) => setSettings(prev => ({ ...prev!, logo_url: url }))}
              currentUrl={settings.logo_url}
              maxSize={2}
            />
          </div>

          <div className="w-full">
            <label className="block text-sm font-medium text-muted-foreground">
              Fuso Horário
            </label>
            <select
              className="input w-full mt-1"
              value={settings.timezone}
              onChange={(e) => setSettings(prev => ({ ...prev!, timezone: e.target.value }))}
            >
              <option value="America/Sao_Paulo">Brasília (GMT-3)</option>
              <option value="America/Manaus">Manaus (GMT-4)</option>
              <option value="America/Belem">Belém (GMT-3)</option>
            </select>
          </div>

          {isAdmin && (
            <div className="w-full">
              <label className="block text-sm font-medium text-muted-foreground">
                Mensagem de Boas-vindas
              </label>
              <textarea
                className="input w-full mt-1"
                rows={3}
                value={settings.welcome_message || ''}
                onChange={(e) => setSettings(prev => ({ ...prev!, welcome_message: e.target.value }))}
              />
            </div>
          )}
        </div>

        {/* Configurações API WhatsApp (apenas admin) */}
        {isAdmin && (
          <div className="card space-y-4 w-full">
            <h2 className="text-xl font-semibold">Configurações API WhatsApp</h2>
            
            <div className="w-full">
              <label className="block text-sm font-medium text-muted-foreground">
                URL da API
              </label>
              <input
                type="url"
                className="input w-full mt-1"
                value={settings.whatsapp_api_url || ''}
                onChange={(e) => setSettings(prev => ({ ...prev!, whatsapp_api_url: e.target.value }))}
                placeholder="https://api.whatsapp.com/v1/messages"
              />
            </div>

            <div className="w-full">
              <label className="block text-sm font-medium text-muted-foreground">
                Chave da API
              </label>
              <input
                type="text"
                className="input w-full mt-1"
                value={settings.whatsapp_api_key || ''}
                onChange={(e) => setSettings(prev => ({ ...prev!, whatsapp_api_key: e.target.value }))}
                placeholder="Sua chave de API"
              />
            </div>

            <div className="w-full">
              <label className="block text-sm font-medium text-muted-foreground">
                Nome da Instância
              </label>
              <input
                type="text"
                className="input w-full mt-1"
                value={settings.whatsapp_instance_name || ''}
                onChange={(e) => setSettings(prev => ({ ...prev!, whatsapp_instance_name: e.target.value }))}
                placeholder="Nome da sua instância"
              />
            </div>

            <div className="w-full">
              <label className="block text-sm font-medium text-muted-foreground">
                Testar Envio
              </label>
              <div className="flex gap-2">
                <input
                  type="text"
                  className="input flex-1"
                  placeholder="5545988110011"
                  value={testPhone}
                  onChange={(e) => setTestPhone(e.target.value)}
                />
                <button
                  type="button"
                  onClick={handleTestMessage}
                  className="btn btn-primary"
                  disabled={loading}
                >
                  Enviar Teste
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Identificação API de Suporte */}
        <div className="card space-y-4 w-full">
          <h2 className="text-xl font-semibold">Identificação API de Suporte</h2>
          
          <div className="w-full">
            <label className="block text-sm font-medium text-muted-foreground">
              ID de Suporte
            </label>
            <input
              type="text"
              className="input w-full mt-1 bg-gray-700"
              value={settings.support_id}
              readOnly
            />
          </div>

          <div className="w-full">
            <label className="block text-sm font-medium text-muted-foreground">
              Nome da Empresa
            </label>
            <input
              type="text"
              className="input w-full mt-1"
              value={settings.company_name}
              onChange={(e) => setSettings(prev => ({ ...prev!, company_name: e.target.value }))}
              required
            />
          </div>

          <div className="w-full">
            <label className="block text-sm font-medium text-muted-foreground">
              Nome do Usuário
            </label>
            <input
              type="text"
              className="input w-full mt-1"
              value={settings.support_user_name}
              onChange={(e) => setSettings(prev => ({ ...prev!, support_user_name: e.target.value }))}
              required
            />
          </div>

          <div className="w-full">
            <label className="block text-sm font-medium text-muted-foreground">
              CPF/CNPJ
            </label>
            <input
              type="text"
              className="input w-full mt-1"
              value={settings.support_document}
              onChange={(e) => setSettings(prev => ({ ...prev!, support_document: e.target.value }))}
              required
            />
          </div>
        </div>

        {/* Configuração da API (apenas admin) */}
        {isAdmin && (
          <div className="card space-y-4 w-full">
            <h2 className="text-xl font-semibold">Configuração da API</h2>
            
            <div className="w-full">
              <label className="block text-sm font-medium text-muted-foreground">
                URL API Suporte
              </label>
              <input
                type="text"
                className="input w-full mt-1 bg-gray-700"
                value={`${import.meta.env.VITE_API_BASE_URL || window.location.origin}/api/${settings.support_id}`}
                readOnly
              />
            </div>

            <div className="w-full">
              <label className="block text-sm font-medium text-muted-foreground">
                Chave da API
              </label>
              <input
                type="text"
                className="input w-full mt-1 bg-gray-700"
                value={import.meta.env.VITE_SUPPORT_API_KEY || 'Não configurada'}
                readOnly
              />
            </div>

            <div className="w-full">
              <label className="block text-sm font-medium text-muted-foreground mb-2">
                Método
              </label>
              <ApiMethodSelector
                value={apiMethod}
                onChange={setApiMethod}
              />
            </div>

            <div className="w-full">
              <label className="block text-sm font-medium text-muted-foreground mb-2">
                Colunas
              </label>
              <ColumnSelector
                columns={columns}
                selectedColumns={selectedColumns}
                onChange={setSelectedColumns}
              />
            </div>

            <ApiPreview
              method={apiMethod}
              url={`${import.meta.env.VITE_API_BASE_URL || window.location.origin}/api/${settings.support_id}`}
              apiKey={import.meta.env.VITE_SUPPORT_API_KEY || 'SUA_CHAVE_API'}
              selectedColumns={selectedColumns}
            />
          </div>
        )}

        {/* URL página de suporte */}
        <div className="card space-y-4 w-full">
          <h2 className="text-xl font-semibold">URL Página de Suporte</h2>
          
          <div className="w-full">
            <label className="block text-sm font-medium text-muted-foreground">
              URL do Suporte
            </label>
            <input
              type="url"
              className="input w-full mt-1"
              value={settings.support_url || ''}
              onChange={(e) => setSettings(prev => ({ ...prev!, support_url: e.target.value }))}
              placeholder="https://exemplo.com/suporte"
            />
          </div>

          {settings.support_url && (
            <div className="w-full h-[400px] border border-border rounded-lg overflow-hidden">
              <iframe
                src={settings.support_url}
                className="w-full h-full"
                title="Página de Suporte"
                sandbox="allow-same-origin allow-scripts allow-popups allow-forms"
              />
            </div>
          )}
        </div>

        <button
          type="submit"
          className="btn btn-primary w-full"
          disabled={loading}
        >
          {loading ? 'Salvando...' : 'Salvar Configurações'}
        </button>
      </form>
    </div>
  );
}