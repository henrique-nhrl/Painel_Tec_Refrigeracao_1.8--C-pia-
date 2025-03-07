import React from 'react';
import { Client, ServiceType, Collaborator } from '../types/database';

interface ServiceFormProps {
  service: {
    client_id: string;
    service_date: string;
    service_type_id: string;
    collaborator_id: string;
    use_client_address: boolean;
    service_address: string;
    notes: string;
    total: string;
  };
  clients: Client[];
  serviceTypes: ServiceType[];
  collaborators: Collaborator[];
  searchTerm: string;
  filteredClients: Client[];
  selectedClient: Client | undefined;
  onSearchChange: (term: string) => void;
  onClientSelect: (client: Client) => void;
  onChange: (service: any) => void;
  onSubmit: (e: React.FormEvent) => void;
  loading: boolean;
  isEditing?: boolean;
  onCancelEdit?: () => void;
}

export function ServiceForm({
  service,
  clients,
  serviceTypes,
  collaborators,
  searchTerm,
  filteredClients,
  selectedClient,
  onSearchChange,
  onClientSelect,
  onChange,
  onSubmit,
  loading,
  isEditing,
  onCancelEdit
}: ServiceFormProps) {
  return (
    <form onSubmit={onSubmit} className="space-y-4">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-muted-foreground">
            Data do Serviço
          </label>
          <input
            type="date"
            className="input w-full mt-1"
            value={service.service_date}
            onChange={(e) => onChange({ ...service, service_date: e.target.value })}
            required
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-muted-foreground">
            Cliente
          </label>
          <div className="relative">
            <input
              type="text"
              className="input w-full mt-1"
              placeholder="Digite o nome do cliente"
              value={searchTerm}
              onChange={(e) => onSearchChange(e.target.value)}
              required
            />
            {filteredClients.length > 0 && (
              <div className="absolute z-10 w-full mt-1 bg-card border border-border rounded-md shadow-lg max-h-60 overflow-auto">
                {filteredClients.map((client) => (
                  <button
                    key={client.id}
                    type="button"
                    className="w-full text-left px-4 py-2 hover:bg-secondary/50"
                    onClick={() => onClientSelect(client)}
                  >
                    {client.name}
                  </button>
                ))}
              </div>
            )}
          </div>
        </div>

        <div>
          <label className="block text-sm font-medium text-muted-foreground">
            Tipo de Serviço
          </label>
          <select
            className="input w-full mt-1"
            value={service.service_type_id}
            onChange={(e) => onChange({ ...service, service_type_id: e.target.value })}
            required
          >
            <option value="">Selecione o tipo</option>
            {serviceTypes.map((type) => (
              <option key={type.id} value={type.id}>
                {type.name}
              </option>
            ))}
          </select>
        </div>

        <div>
          <label className="block text-sm font-medium text-muted-foreground">
            Colaborador
          </label>
          <select
            className="input w-full mt-1"
            value={service.collaborator_id}
            onChange={(e) => onChange({ ...service, collaborator_id: e.target.value })}
            required
          >
            <option value="">Selecione o colaborador</option>
            {collaborators.map((collaborator) => (
              <option key={collaborator.id} value={collaborator.id}>
                {collaborator.name}
              </option>
            ))}
          </select>
        </div>
      </div>

      {selectedClient && (
        <div className="space-y-4">
          <div>
            <label className="flex items-center gap-2">
              <input
                type="checkbox"
                checked={service.use_client_address}
                onChange={(e) => onChange({ 
                  ...service, 
                  use_client_address: e.target.checked,
                  service_address: e.target.checked ? '' : service.service_address
                })}
                className="rounded border-input"
              />
              <span className="text-sm">
                O serviço será realizado no endereço do cliente: {' '}
                <span className="font-medium">
                  {selectedClient.address}, {selectedClient.number} - {selectedClient.neighborhood}, {selectedClient.city}
                </span>
              </span>
            </label>
          </div>

          {!service.use_client_address && (
            <div>
              <label className="block text-sm font-medium text-muted-foreground">
                Endereço do Serviço
              </label>
              <input
                type="text"
                className="input w-full mt-1"
                placeholder="Rua exemplo 123, Centro - Cidade - Estado"
                value={service.service_address}
                onChange={(e) => onChange({ ...service, service_address: e.target.value })}
                required
              />
            </div>
          )}
        </div>
      )}

      <div>
        <label className="block text-sm font-medium text-muted-foreground">
          Anotações
        </label>
        <textarea
          className="input w-full mt-1"
          rows={3}
          value={service.notes}
          onChange={(e) => onChange({ ...service, notes: e.target.value })}
          placeholder="Observações sobre o serviço"
        />
      </div>

      <div>
        <label className="block text-sm font-medium text-muted-foreground">
          Total (R$)
        </label>
        <input
          type="number"
          className="input w-full mt-1"
          step="0.01"
          min="0"
          value={service.total}
          onChange={(e) => onChange({ ...service, total: e.target.value })}
          required
        />
      </div>

      <div className="flex gap-2">
        <button
          type="submit"
          className="btn btn-primary flex-1"
          disabled={loading}
        >
          {loading ? 'Salvando...' : isEditing ? 'Atualizar Serviço' : 'Salvar Serviço'}
        </button>
        {isEditing && onCancelEdit && (
          <button
            type="button"
            onClick={onCancelEdit}
            className="btn btn-danger"
          >
            Cancelar
          </button>
        )}
      </div>
    </form>
  );
}