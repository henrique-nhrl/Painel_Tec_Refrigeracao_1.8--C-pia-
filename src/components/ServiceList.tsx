import React from 'react';
import { Service } from '../types/database';
import { Edit, Trash2 } from 'lucide-react';

interface ServiceListProps {
  services: Service[];
  onEdit: (service: Service) => void;
  onDelete: (id: string) => void;
}

export function ServiceList({ services, onEdit, onDelete }: ServiceListProps) {
  return (
    <div className="space-y-4">
      {services.map((service) => (
        <div key={service.id} className="card">
          <div className="flex justify-between items-start">
            <div className="space-y-2">
              <div className="flex items-center gap-2">
                <span className="text-lg font-semibold">
                  {service.client?.name}
                </span>
                <span className="text-sm text-muted-foreground">
                  ({service.service_number}º Atendimento)
                </span>
              </div>
              <p className="text-muted-foreground">
                Data: {new Date(service.service_date).toLocaleDateString('pt-BR')}
              </p>
              <p className="text-muted-foreground">
                Tipo: {service.service_type?.name}
              </p>
              <p className="text-muted-foreground">
                Colaborador: {service.collaborator?.name}
              </p>
              <p className="text-muted-foreground">
                Endereço: {service.use_client_address 
                  ? `${service.client?.address}, ${service.client?.number} - ${service.client?.neighborhood}, ${service.client?.city}`
                  : service.service_address
                }
              </p>
              {service.notes && (
                <p className="text-muted-foreground">
                  Anotações: {service.notes}
                </p>
              )}
              <p className="text-lg font-medium text-green-500">
                Total: R$ {service.total.toFixed(2)}
              </p>
            </div>
            <div className="flex gap-2">
              <button
                onClick={() => onEdit(service)}
                className="text-primary hover:text-primary/80"
              >
                <Edit size={18} />
              </button>
              <button
                onClick={() => onDelete(service.id)}
                className="text-destructive hover:text-destructive/80"
              >
                <Trash2 size={18} />
              </button>
            </div>
          </div>
        </div>
      ))}
      {services.length === 0 && (
        <p className="text-center text-muted-foreground">
          Nenhum serviço encontrado.
        </p>
      )}
    </div>
  );
}