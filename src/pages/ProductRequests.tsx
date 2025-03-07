import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { ProductRequest } from '../types/database';
import { useAuthStore } from '../store/authStore';
import { Check, X } from 'lucide-react';
import toast from 'react-hot-toast';

export function ProductRequests() {
  const [requests, setRequests] = useState<ProductRequest[]>([]);
  const { user } = useAuthStore();
  const isAdmin = user?.role === 'admin';

  useEffect(() => {
    loadRequests();
  }, []);

  const loadRequests = async () => {
    const query = supabase
      .from('product_requests')
      .select(`
        *,
        categories (
          name
        ),
        profiles (
          email
        )
      `)
      .order('created_at', { ascending: false });

    // Se não for admin, filtrar apenas as próprias solicitações
    if (!isAdmin) {
      query.eq('user_id', user?.id);
    }

    const { data } = await query;
    if (data) setRequests(data);
  };

  const handleRequest = async (id: string, status: 'approved' | 'rejected') => {
    try {
      const request = requests.find(r => r.id === id);
      if (!request) return;

      if (status === 'approved') {
        const nextOrder = await supabase.rpc('next_display_order');
        
        await supabase.from('products').insert({
          name: request.name,
          price: request.price,
          category_id: request.category_id,
          display_order: nextOrder
        });
      }

      await supabase
        .from('product_requests')
        .update({ status })
        .eq('id', id);

      toast.success(`Solicitação ${status === 'approved' ? 'aprovada' : 'rejeitada'}`);
      loadRequests();
    } catch (error) {
      toast.error('Erro ao processar solicitação');
    }
  };

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">
        {isAdmin ? 'Solicitações de Produtos' : 'Minhas Solicitações'}
      </h1>
      <div className="grid gap-6">
        {requests.map((request) => (
          <div key={request.id} className="card">
            <div className="flex justify-between items-start">
              <div>
                <h3 className="text-lg font-semibold">{request.name}</h3>
                <p className="text-muted-foreground">
                  Categoria: {request.categories?.name}
                </p>
                <p className="text-muted-foreground">R$ {request.price}</p>
                {isAdmin && request.profiles?.email && (
                  <p className="text-muted-foreground">
                    Solicitado por: {request.profiles.email}
                  </p>
                )}
                <p className="mt-2">{request.description}</p>
                <p className="mt-2 text-sm">
                  Status: {' '}
                  <span className={
                    request.status === 'approved' ? 'text-green-500' :
                    request.status === 'rejected' ? 'text-red-500' :
                    'text-yellow-500'
                  }>
                    {request.status === 'approved' ? 'Aprovado' :
                     request.status === 'rejected' ? 'Rejeitado' :
                     'Pendente'}
                  </span>
                </p>
              </div>
              {request.status === 'pending' && isAdmin && (
                <div className="flex gap-2">
                  <button
                    onClick={() => handleRequest(request.id, 'approved')}
                    className="btn btn-primary flex items-center gap-2"
                  >
                    <Check size={18} />
                    Aprovar
                  </button>
                  <button
                    onClick={() => handleRequest(request.id, 'rejected')}
                    className="btn btn-danger flex items-center gap-2"
                  >
                    <X size={18} />
                    Rejeitar
                  </button>
                </div>
              )}
            </div>
          </div>
        ))}
        {requests.length === 0 && (
          <p className="text-center text-muted-foreground">
            Nenhuma solicitação encontrada.
          </p>
        )}
      </div>
    </div>
  );
}