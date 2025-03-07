import { supabase } from '../../lib/supabase';
import { API_CONFIG } from '../../config/api';

export async function handler(req: Request) {
  // Verificar método
  if (!['GET', 'POST', 'PUT', 'DELETE'].includes(req.method)) {
    return new Response(JSON.stringify({ error: 'Método não permitido' }), {
      status: 405,
      headers: { 'Content-Type': 'application/json' }
    });
  }

  // Extrair support_id da URL
  const url = new URL(req.url);
  const support_id = url.pathname.split('/').pop();

  // Verificar autenticação
  const authHeader = req.headers.get('Authorization');
  if (!authHeader?.startsWith('Bearer ')) {
    return new Response(JSON.stringify({ error: 'Não autorizado' }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' }
    });
  }

  const api_key = authHeader.replace('Bearer ', '');

  // Verificar se a chave API corresponde à configurada
  if (api_key !== API_CONFIG.supportApiKey) {
    return new Response(JSON.stringify({ error: 'Chave API inválida' }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' }
    });
  }

  try {
    // Buscar credenciais
    const { data: credentials, error } = await supabase
      .from('support_api_credentials')
      .select('support_id, client_name, company_name, document')
      .eq('support_id', support_id)
      .single();

    if (error || !credentials) {
      return new Response(JSON.stringify({ error: 'ID de suporte inválido' }), {
        status: 401,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    // Retornar dados solicitados
    return new Response(JSON.stringify(credentials), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: 'Erro interno do servidor' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
}