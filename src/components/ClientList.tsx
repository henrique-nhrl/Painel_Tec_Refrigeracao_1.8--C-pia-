import React from 'react';
import { Edit, Trash2, ChevronDown, ChevronUp } from 'lucide-react';

interface ClientListProps {
  clients: any[];
  expandedClient: string | null;
  onClientClick: (id: string) => void;
  onEdit: (client: any) => void;
  onDelete: (id: string) => void;
  clientHistory: any[];
}

export function ClientList({
  clients,
  expandedClient,
  onClientClick,
  onEdit,
  onDelete,
  clientHistory
}: ClientListProps) {
  const formatValue = (value: any) => {
    if (value === null || value === undefined) return 'Não definido';
    if (typeof value === 'boolean') return value ? 'Sim' : 'Não';
    if (value instanceof Date || typeof value === 'string' && value.match(/^\d{4}-\d{2}-\d{2}/)) {
      return new Date(value).toLocaleDateString('pt-BR');
    }
    return String(value);
  };

  const getFieldDescription = (key: string) => {
    const descriptions: Record<string, string> = {
      name: 'Nome',
      formal_name: 'Nome Formal',
      phone: 'Telefone',
      address: 'Endereço',
      number: 'Número',
      neighborhood: 'Bairro',
      city: 'Cidade',
      state: 'Estado',
      notes: 'Anotações',
      send_maintenance_reminders: 'Enviar Lembretes',
      send_welcome_message: 'Mensagem de Boas-vindas'
    };
    return descriptions[key] || key;
  };

  return (
    <div className="grid gap-4">
      {clients.map((client) => (
        <div key={client.id} className="card">
          <div 
            className="flex justify-between items-start cursor-pointer"
            onClick={() => onClientClick(client.id)}
          >
            <div>
              <h3 className="text-lg font-semibold">{client.name}</h3>
              <p className="text-sm text-muted-foreground">{client.formal_name}</p>
              <p className="text-sm text-muted-foreground">{client.phone}</p>
              {client.address && (
                <p className="text-sm text-muted-foreground">
                  {client.address}, {client.number} - {client.neighborhood}, {client.city}/{client.state}
                </p>
              )}
              {client.notes && (
                <p className="text-sm text-muted-foreground mt-2">
                  {client.notes}
                </p>
              )}
            </div>
            <div className="flex gap-2">
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  onEdit(client);
                }}
                className="text-primary hover:text-primary/80"
              >
                <Edit size={18} />
              </button>
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  onDelete(client.id);
                }}
                className="text-destructive hover:text-destructive/80"
              >
                <Trash2 size={18} />
              </button>
              {expandedClient === client.id ? (
                <ChevronUp size={18} />
              ) : (
                <ChevronDown size={18} />
              )}
            </div>
          </div>

          {expandedClient === client.id && clientHistory && clientHistory.length > 0 && (
            <div className="mt-4 pt-4 border-t border-border">
              <h4 className="text-lg font-medium mb-2">Histórico de Alterações</h4>
              <div className="space-y-4">
                {clientHistory.map((history, index) => (
                  <div key={index} className="bg-secondary/10 p-4 rounded-lg">
                    <p className="text-sm font-medium">
                      Por: {history.profiles?.email || 'Sistema'}
                    </p>
                    <div className="mt-2 space-y-1">
                      {history.changes && Object.entries(history.changes.after || {}).map(([key, newValue]) => {
                        const oldValue = history.changes.before?.[key];
                        if (newValue !== oldValue && 
                            !['id', 'created_by', 'created_at'].includes(key)) {
                          return (
                            <p key={key} className="text-sm">
                              <span className="font-medium">{getFieldDescription(key)}:</span>{' '}
                              <span className="text-destructive">{formatValue(oldValue)}</span>
                              {' → '}
                              <span className="text-primary">{formatValue(newValue)}</span>
                            </p>
                          );
                        }
                        return null;
                      })}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      ))}
      {clients.length === 0 && (
        <p className="text-center text-muted-foreground">
          Nenhum cliente encontrado.
        </p>
      )}
    </div>
  );
}