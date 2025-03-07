import React, { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { Service, Client, ServiceType, Collaborator } from '../types/database';
import { ServiceForm } from '../components/ServiceForm';
import { ServiceList } from '../components/ServiceList';
import { useAuthStore } from '../store/authStore';
import toast from 'react-hot-toast';

export function Services() {
  const { user } = useAuthStore();
  const [services, setServices] = useState<Service[]>([]);
  const [clients, setClients] = useState<Client[]>([]);
  const [serviceTypes, setServiceTypes] = useState<ServiceType[]>([]);
  const [collaborators, setCollaborators] = useState<Collaborator[]>([]);
  const [filteredClients, setFilteredClients] = useState<Client[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [loading, setLoading] = useState(false);
  const [editingService, setEditingService] = useState<Service | null>(null);

  const [newService, setNewService] = useState({
    client_id: '',
    service_date: new Date().toISOString().split('T')[0],
    service_type_id: '',
    collaborator_id: '',
    use_client_address: true,
    service_address: '',
    notes: '',
    total: ''
  });

  useEffect(() => {
    loadServices();
    loadClients();
    loadServiceTypes();
    loadCollaborators();
  }, []);

  useEffect(() => {
    if (searchTerm) {
      const filtered = clients.filter(client => 
        client.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        client.formal_name.toLowerCase().includes(searchTerm.toLowerCase())
      );
      setFilteredClients(filtered);
    } else {
      setFilteredClients([]);
    }
  }, [searchTerm, clients]);

  const loadServices = async () => {
    try {
      const { data, error } = await supabase
        .from('services')
        .select(`
          *,
          client:clients(*),
          service_type:service_types(*),
          collaborator:collaborators(*)
        `)
        .order('service_date', { ascending: false });

      if (error) throw error;
      setServices(data || []);
    } catch (error) {
      console.error('Erro ao carregar serviços:', error);
      toast.error('Erro ao carregar lista de serviços');
    }
  };

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

  const loadServiceTypes = async () => {
    try {
      const { data, error } = await supabase
        .from('service_types')
        .select('*')
        .order('name');

      if (error) throw error;
      setServiceTypes(data || []);
    } catch (error) {
      console.error('Erro ao carregar tipos de serviço:', error);
      toast.error('Erro ao carregar tipos de serviço');
    }
  };

  const loadCollaborators = async () => {
    try {
      const { data, error } = await supabase
        .from('collaborators')
        .select('*')
        .eq('active', true)
        .order('name');

      if (error) throw error;
      setCollaborators(data || []);
    } catch (error) {
      console.error('Erro ao carregar colaboradores:', error);
      toast.error('Erro ao carregar colaboradores');
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      if (!newService.client_id) {
        throw new Error('Selecione um cliente');
      }

      const serviceNumber = await supabase.rpc('next_service_number', {
        client_id: newService.client_id
      });

      const serviceData = {
        ...newService,
        service_number: serviceNumber.data,
        total: parseFloat(newService.total),
        service_address: newService.use_client_address ? null : newService.service_address,
        created_by: user?.id
      };

      if (editingService) {
        const { error } = await supabase
          .from('services')
          .update(serviceData)
          .eq('id', editingService.id);

        if (error) throw error;
        toast.success('Serviço atualizado com sucesso');
      } else {
        const { error } = await supabase
          .from('services')
          .insert([serviceData]);

        if (error) throw error;
        toast.success('Serviço cadastrado com sucesso');
      }

      setNewService({
        client_id: '',
        service_date: new Date().toISOString().split('T')[0],
        service_type_id: '',
        collaborator_id: '',
        use_client_address: true,
        service_address: '',
        notes: '',
        total: ''
      });
      setEditingService(null);
      setSearchTerm('');
      loadServices();
    } catch (error) {
      console.error('Erro ao salvar serviço:', error);
      toast.error(error instanceof Error ? error.message : 'Erro ao salvar serviço');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id: string) => {
    try {
      const { error } = await supabase
        .from('services')
        .delete()
        .eq('id', id);

      if (error) throw error;
      toast.success('Serviço removido com sucesso');
      loadServices();
    } catch (error) {
      console.error('Erro ao remover serviço:', error);
      toast.error('Erro ao remover serviço');
    }
  };

  const selectedClient = clients.find(c => c.id === newService.client_id);

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">
        {editingService ? 'Editar Serviço' : 'Novo Serviço'}
      </h1>

      <div className="card">
        <ServiceForm
          service={newService}
          clients={clients}
          serviceTypes={serviceTypes}
          collaborators={collaborators}
          searchTerm={searchTerm}
          filteredClients={filteredClients}
          selectedClient={selectedClient}
          onSearchChange={setSearchTerm}
          onClientSelect={(client) => {
            setNewService(prev => ({ ...prev, client_id: client.id }));
            setSearchTerm(client.name);
            setFilteredClients([]);
          }}
          onChange={setNewService}
          onSubmit={handleSubmit}
          loading={loading}
          isEditing={!!editingService}
          onCancelEdit={() => {
            setEditingService(null);
            setNewService({
              client_id: '',
              service_date: new Date().toISOString().split('T')[0],
              service_type_id: '',
              collaborator_id: '',
              use_client_address: true,
              service_address: '',
              notes: '',
              total: ''
            });
            setSearchTerm('');
          }}
        />
      </div>

      <h2 className="text-xl font-bold mt-8">Lista de Serviços</h2>

      <ServiceList
        services={services}
        onEdit={(service) => {
          setEditingService(service);
          setNewService({
            client_id: service.client_id,
            service_date: service.service_date,
            service_type_id: service.service_type_id,
            collaborator_id: service.collaborator_id,
            use_client_address: service.use_client_address,
            service_address: service.service_address || '',
            notes: service.notes || '',
            total: service.total.toString()
          });
          setSearchTerm(service.client?.name || '');
        }}
        onDelete={handleDelete}
      />
    </div>
  );
}