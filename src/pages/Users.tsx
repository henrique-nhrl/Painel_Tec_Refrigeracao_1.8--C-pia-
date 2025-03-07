import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { User } from '../types/database';
import toast from 'react-hot-toast';

export function Users() {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadUsers();
  }, []);

  const loadUsers = async () => {
    try {
      setLoading(true);
      setError(null);
      
      // Use RPC call instead of direct query to bypass RLS
      const { data, error } = await supabase.rpc('get_all_profiles');
      
      if (error) {
        // Fallback to direct query if RPC fails
        const { data: directData, error: directError } = await supabase
          .from('profiles')
          .select('*')
          .order('created_at', { ascending: false });
        
        if (directError) throw directError;
        setUsers(directData || []);
      } else {
        setUsers(data || []);
      }
    } catch (error) {
      console.error('Error loading users:', error);
      setError('Erro ao carregar usuários. Por favor, tente novamente.');
      toast.error('Erro ao carregar usuários');
    } finally {
      setLoading(false);
    }
  };

  const updateUserRole = async (userId: string, role: 'admin' | 'user') => {
    try {
      const { error } = await supabase
        .from('profiles')
        .update({ role })
        .eq('id', userId);
      
      if (error) throw error;
      
      toast.success('Permissão atualizada com sucesso');
      loadUsers();
    } catch (error) {
      console.error('Error updating user role:', error);
      toast.error('Erro ao atualizar permissão');
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="w-16 h-16 border-4 border-primary border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
          <p className="text-muted-foreground">Carregando usuários...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="text-center p-8">
        <p className="text-destructive mb-4">{error}</p>
        <button 
          onClick={loadUsers}
          className="btn btn-primary"
        >
          Tentar novamente
        </button>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Usuários do Sistema</h1>
      
      {users.length === 0 ? (
        <p className="text-center text-muted-foreground">Nenhum usuário encontrado.</p>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {users.map((user) => (
            <div key={user.id} className="card">
              <div className="space-y-4">
                <div className="min-h-[3rem]">
                  <p className="font-medium break-all">{user.email}</p>
                  <p className="text-sm text-muted-foreground">
                    Criado em: {new Date(user.created_at).toLocaleDateString('pt-BR')}
                  </p>
                </div>
                <select
                  value={user.role}
                  onChange={(e) => updateUserRole(user.id, e.target.value as 'admin' | 'user')}
                  className="input w-full"
                >
                  <option value="user">Usuário</option>
                  <option value="admin">Admin</option>
                </select>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}