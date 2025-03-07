import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';

export function Support() {
  const [supportUrl, setSupportUrl] = useState('');

  useEffect(() => {
    loadSupportUrl();
  }, []);

  const loadSupportUrl = async () => {
    try {
      const { data, error } = await supabase
        .from('system_settings')
        .select('support_url')
        .eq('id', '1')
        .single();
      
      if (error) throw error;
      if (data?.support_url) {
        setSupportUrl(data.support_url);
      }
    } catch (error) {
      console.error('Erro ao carregar URL de suporte:', error);
    }
  };

  if (!supportUrl) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <p className="text-muted-foreground">
          URL de suporte não configurada. Entre em contato com o administrador.
        </p>
      </div>
    );
  }

  return (
    <div className="h-[calc(100vh-14rem)]">
      <iframe
        src={supportUrl}
        className="w-full h-full rounded-lg border border-border"
        title="Página de Suporte"
        sandbox="allow-same-origin allow-scripts allow-popups allow-forms allow-top-navigation"
        allow="camera; microphone; geolocation"
      />
    </div>
  );
}