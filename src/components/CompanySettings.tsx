import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { useAuthStore } from '../store/authStore';
import { FileUpload } from '../components/FileUpload';
import toast from 'react-hot-toast';

interface CompanySettings {
  id: string;
  name: string;
  logo_url: string;
  welcome_message: string;
  timezone: string;
  support_url: string;
  api_url: string;
  api_key: string;
  instance_name: string;
}

interface SupportCredentials {
  support_id: string;
  client_name: string;
  company_name: string;
  document: string;
}

export function CompanySettings() {
  const [settings, setSettings] = useState<CompanySettings | null>(null);
  const [loading, setLoading] = useState(false);
  const [supportCredentials, setSupportCredentials] = useState<SupportCredentials | null>(null);
  const { user } = useAuthStore();
  const isAdmin = user?.role === 'admin';

  useEffect(() => {
    loadSettings();
    loadSupportCredentials();
  }, []);

  const loadSettings = async () => {
    try {
      const { data, error } = await supabase
        .from('company_settings')
        .select('*')
        .maybeSingle();
      
      if (error) throw error;
      if (data) setSettings(data);
    } catch (error) {
      console.error('Erro ao carregar configurações:', error);
      toast.error('Erro ao carregar configurações');
    }
  };

  const loadSupportCredentials = async () => {
    try {
      const { data, error } = await supabase
        .from('support_api_credentials')
        .select('support_id, client_name, company_name, document')
        .maybeSingle();
      
      if (error) throw error;
      if (data) setSupportCredentials(data);
    } catch (error) {
      console.error('Erro ao carregar credenciais:', error);
      toast.error('Erro ao carregar credenciais');
    }
  };

  const updateSettings = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      if (settings) {
        const { error } = await supabase
          .from('company_settings')
          .upsert({
            id: settings.id,
            name: settings.name,
            logo_url: settings.logo_url,
            welcome_message: settings.welcome_message,
            timezone: settings.timezone,
            support_url: isAdmin ? settings.support_url : undefined, // Apenas admin pode atualizar
            api_url: settings.api_url,
            api_key: settings.api_key,
            instance_name: settings.instance_name
          });

        if (error) throw error;
        toast.success('Configurações atualizadas com sucesso');
        loadSettings();
      }
    } catch (error) {
      toast.error('Erro ao atualizar configurações');
    } finally {
      setLoading(false);
    }
  };

  const updateSupportCredentials = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      if (supportCredentials) {
        const { error } = await supabase
          .from('support_api_credentials')
          .update({
            client_name: supportCredentials.client_name,
            company_name: supportCredentials.company_name,
            document: supportCredentials.document
          })
          .eq('support_id', supportCredentials.support_id);

        if (error) throw error;
        toast.success('Credenciais atualizadas com sucesso');
        loadSupportCredentials();
      }
    } catch (error) {
      toast.error('Erro ao atualizar credenciais');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6 w-full">
      <h1 className="text-2xl font-bold">Configurações</h1>
      
      {/* Configurações da Empresa - Visível apenas para admin */}
      {isAdmin && (
        <form onSubmit={updateSettings} className="space-y-6 w-full">
          <div className="card space-y-4 w-full">
            <h2 className="text-xl font-semibold">Configurações da Empresa</h2>
            <div className="w-full">
              <label className="block text-sm font-medium text-muted-foreground">
                Nome da Empresa
              </label>
              <input
                type="text"
                className="input w-full mt-1"
                value={settings?.name || ''}
                onChange={(e) => setSettings(prev => ({ ...prev!, name: e.target.value }))}
                required
              />
            </div>

            <div className="w-full">
              <label className="block text-sm font-medium text-muted-foreground">
                Logo da Empresa
              </label>
              <FileUpload
                onUpload={(url) => setSettings(prev => ({ ...prev!, logo_url: url }))}
                currentUrl={settings?.logo_url}
                maxSize={2}
              />
            </div>

            <div className="w-full">
              <label className="block text-sm font-medium text-muted-foreground">
                Mensagem de Boas-vindas
              </label>
              <textarea
                className="input w-full mt-1"
                rows={3}
                value={settings?.welcome_message || ''}
                onChange={(e) => setSettings(prev => ({ ...prev!, welcome_message: e.target.value }))}
              />
            </div>

            <div className="w-full">
              <label className="block text-sm font-medium text-muted-foreground">
                URL da Página de Suporte
              </label>
              <input
                type="url"
                className="input w-full mt-1"
                value={settings?.support_url || ''}
                onChange={(e) => setSettings(prev => ({ ...prev!, support_url: e.target.value }))}
                placeholder="https://exemplo.com/suporte"
                required
              />
              <p className="text-sm text-muted-foreground mt-1">
                Esta URL será exibida na página de suporte para todos os usuários
              </p>
            </div>
          </div>

          <div className="card space-y-4 w-full">
            <h2 className="text-xl font-semibold">Configurações API WhatsApp</h2>
            <div className="w-full">
              <label className="block text-sm font-medium text-muted-foreground">
                URL da API
              </label>
              <input
                type="url"
                className="input w-full mt-1"
                value={settings?.api_url || ''}
                onChange={(e) => setSettings(prev => ({ ...prev!, api_url: e.target.value }))}
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
                value={settings?.api_key || ''}
                onChange={(e) => setSettings(prev => ({ ...prev!, api_key: e.target.value }))}
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
                value={settings?.instance_name || ''}
                onChange={(e) => setSettings(prev => ({ ...prev!, instance_name: e.target.value }))}
                placeholder="Nome da sua instância"
              />
            </div>
          </div>

          <button
            type="submit"
            className="btn btn-primary w-full"
            disabled={loading}
          >
            {loading ? 'Salvando...' : 'Salvar Configurações'}
          </button>
        </form>
      )}

      {/* Dados do Cliente - Visível para todos */}
      {supportCredentials && !isAdmin && (
        <form onSubmit={updateSupportCredentials} className="card space-y-4 w-full">
          <h2 className="text-xl font-semibold">Dados do Cliente</h2>
          
          <div className="w-full">
            <label className="block text-sm font-medium text-muted-foreground">
              ID de Suporte
            </label>
            <input
              type="text"
              className="input w-full mt-1 bg-gray-700"
              value={supportCredentials.support_id}
              readOnly
            />
          </div>

          <div className="w-full">
            <label className="block text-sm font-medium text-muted-foreground">
              Nome do Cliente
            </label>
            <input
              type="text"
              className="input w-full mt-1"
              value={supportCredentials.client_name}
              onChange={(e) => setSupportCredentials(prev => ({ ...prev!, client_name: e.target.value }))}
              required
            />
          </div>

          <div className="w-full">
            <label className="block text-sm font-medium text-muted-foreground">
              Nome da Empresa
            </label>
            <input
              type="text"
              className="input w-full mt-1"
              value={supportCredentials.company_name}
              onChange={(e) => setSupportCredentials(prev => ({ ...prev!, company_name: e.target.value }))}
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
              value={supportCredentials.document}
              onChange={(e) => setSupportCredentials(prev => ({ ...prev!, document: e.target.value }))}
              required
            />
          </div>

          <button
            type="submit"
            className="btn btn-primary w-full"
            disabled={loading}
          >
            {loading ? 'Salvando...' : 'Salvar Dados'}
          </button>
        </form>
      )}

      {/* Seção de API - Visível apenas para admin */}
      {isAdmin && supportCredentials && (
        <div className="card space-y-4 w-full">
          <h2 className="text-xl font-semibold">Identificação API de Suporte</h2>
          
          <div className="w-full">
            <label className="block text-sm font-medium text-muted-foreground">
              ID de Suporte
            </label>
            <input
              type="text"
              className="input w-full mt-1 bg-gray-700"
              value={supportCredentials.support_id}
              readOnly
            />
          </div>

          <div className="w-full">
            <label className="block text-sm font-medium text-muted-foreground">
              Nome do Cliente
            </label>
            <input
              type="text"
              className="input w-full mt-1"
              value={supportCredentials.client_name}
              onChange={(e) => setSupportCredentials(prev => ({ ...prev!, client_name: e.target.value }))}
              required
            />
          </div>

          <div className="w-full">
            <label className="block text-sm font-medium text-muted-foreground">
              Nome da Empresa
            </label>
            <input
              type="text"
              className="input w-full mt-1"
              value={supportCredentials.company_name}
              onChange={(e) => setSupportCredentials(prev => ({ ...prev!, company_name: e.target.value }))}
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
              value={supportCredentials.document}
              onChange={(e) => setSupportCredentials(prev => ({ ...prev!, document: e.target.value }))}
              required
            />
          </div>

          <div className="space-y-4">
            <h3 className="text-lg font-medium">Configuração da API</h3>
            <div>
              <h4 className="text-sm font-medium text-muted-foreground mb-2">Exemplo de Uso</h4>
              <pre className="bg-gray-700 p-4 rounded-lg text-sm overflow-x-auto">
{`fetch('${window.location.origin}/api/${supportCredentials.support_id}', {
  method: 'GET',
  headers: {
    'Authorization': 'Bearer ${import.meta.env.VITE_SUPPORT_API_KEY}',
    'Content-Type': 'application/json'
  }
})
.then(response => response.json())
.then(data => {
  // Resposta contém: support_id, client_name, company_name
  console.log(data);
})
.catch(error => console.error(error));`}
              </pre>
            </div>
          </div>

          <button
            type="submit"
            className="btn btn-primary w-full"
            disabled={loading}
            onClick={updateSupportCredentials}
          >
            {loading ? 'Salvando...' : 'Salvar Credenciais'}
          </button>
        </div>
      )}
    </div>
  );
}