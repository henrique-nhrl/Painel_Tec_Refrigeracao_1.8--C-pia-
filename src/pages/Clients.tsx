import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { ClientForm } from '../components/ClientForm';
import { ClientList } from '../components/ClientList';
import { ConfirmDialog } from '../components/ConfirmDialog';
import { useAuthStore } from '../store/authStore';
import toast from 'react-hot-toast';

export function Clients() {
  const [clients, setClients] = useState([]);
  const [selectedCountryCode, setSelectedCountryCode] = useState('55');
  const [editingClient, setEditingClient] = useState(null);
  const [showDeleteDialog, setShowDeleteDialog] = useState(false);
  const [clientToDelete, setClientToDelete] = useState(null);
  const [expandedClient, setExpandedClient] = useState(null);
  const [clientHistory, setClientHistory] = useState([]);
  const { user } = useAuthStore();

  const defaultClient = {
    name: '',
    formal_name: '',
    phone: '',
    address: '',
    number: '',
    neighborhood: '',
    city: '',
    state: '',
    notes: '',
    send_maintenance_reminders: false,
    send_welcome_message: false
  };

  const [newClient, setNewClient] = useState(defaultClient);

  useEffect(() => {
    loadClients();
  }, []);

  const loadClients = async () => {
    try {
      const { data, error } = await supabase
        .from('clients')
        .select('*')
        .order('name');

      if (error) throw error;
      setClients(data || []);
    } catch (error) {
      console.error('Erro ao carregar clientes:', error);
      toast.error('Erro ao carregar lista de clientes');
    }
  };

  const loadClientHistory = async (clientId) => {
    if (!clientId) return;
    
    try {
      const { data, error } = await supabase
        .from('client_history')
        .select('*, profiles(email)')
        .eq('client_id', clientId)
        .order('created_at', { ascending: false });
      
      if (error) throw error;
      setClientHistory(data || []);
    } catch (error) {
      console.error('Erro ao carregar histórico:', error);
      toast.error('Erro ao carregar histórico do cliente');
      setClientHistory([]);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    try {
      const clientData = {
        name: newClient.name,
        formal_name: newClient.formal_name,
        phone: selectedCountryCode + newClient.phone,
        address: newClient.address,
        number: newClient.number,
        neighborhood: newClient.neighborhood,
        city: newClient.city,
        state: newClient.state,
        notes: newClient.notes,
        send_maintenance_reminders: newClient.send_maintenance_reminders,
        send_welcome_message: newClient.send_welcome_message,
        created_by: user?.id
      };

      if (editingClient) {
        const { error } = await supabase
          .from('clients')
          .update(clientData)
          .eq('id', editingClient.id);

        if (error) throw error;
        toast.success('Cliente atualizado com sucesso');
      } else {
        const { error } = await supabase
          .from('clients')
          .insert([clientData]);

        if (error) throw error;
        toast.success('Cliente adicionado com sucesso');
      }

      setNewClient(defaultClient);
      setEditingClient(null);
      loadClients();
    } catch (error) {
      console.error('Erro ao salvar cliente:', error);
      toast.error('Erro ao salvar cliente. Verifique os dados e tente novamente.');
    }
  };

  const handleEdit = (client) => {
    setEditingClient(client);
    setNewClient({
      name: client.name,
      formal_name: client.formal_name,
      phone: client.phone.substring(2),
      address: client.address || '',
      number: client.number || '',
      neighborhood: client.neighborhood || '',
      city: client.city || '',
      state: client.state || '',
      notes: client.notes || '',
      send_maintenance_reminders: client.send_maintenance_reminders,
      send_welcome_message: client.send_welcome_message
    });
    setSelectedCountryCode(client.phone.substring(0, 2));
  };

  const handleDelete = async () => {
    if (!clientToDelete?.id) return;

    try {
      const { error } = await supabase
        .from('clients')
        .delete()
        .eq('id', clientToDelete.id);

      if (error) throw error;

      toast.success('Cliente removido com sucesso');
      loadClients();
      setClientToDelete(null);
      setShowDeleteDialog(false);
    } catch (error) {
      console.error('Erro ao remover cliente:', error);
      toast.error('Erro ao remover cliente');
    }
  };

  const handleClientClick = (clientId) => {
    if (expandedClient === clientId) {
      setExpandedClient(null);
      setClientHistory([]);
    } else {
      setExpandedClient(clientId);
      loadClientHistory(clientId);
    }
  };

  return (
    <div className="space-y-6 w-full">
      <h1 className="text-2xl font-bold">
        {editingClient ? 'Editar Cliente' : 'Novo Cliente'}
      </h1>

      <div className="card">
        <ClientForm
          client={newClient}
          onChange={setNewClient}
          onSubmit={handleSubmit}
          selectedCountryCode={selectedCountryCode}
          onCountryCodeChange={setSelectedCountryCode}
          isEditing={!!editingClient}
          onCancelEdit={() => {
            setEditingClient(null);
            setNewClient(defaultClient);
          }}
        />
      </div>

      <h2 className="text-xl font-bold mt-8">Lista de Clientes</h2>

      <ClientList
        clients={clients}
        expandedClient={expandedClient}
        onClientClick={handleClientClick}
        onEdit={handleEdit}
        onDelete={(client) => {
          setClientToDelete(client);
          setShowDeleteDialog(true);
        }}
        clientHistory={clientHistory}
      />

      <ConfirmDialog
        isOpen={showDeleteDialog}
        onClose={() => {
          setShowDeleteDialog(false);
          setClientToDelete(null);
        }}
        onConfirm={handleDelete}
        title="Confirmar Exclusão"
        message="Tem certeza que deseja excluir este cliente? Esta ação não pode ser desfeita."
        confirmText="Excluir"
        cancelText="Cancelar"
      />
    </div>
  );
}