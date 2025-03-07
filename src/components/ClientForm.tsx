import React from 'react';
import { useAuthStore } from '../store/authStore';

interface ClientFormProps {
  client: {
    name: string;
    formal_name: string;
    phone: string;
    address: string;
    address_number: string;
    neighborhood: string;
    city: string;
    notes: string;
    send_maintenance_reminders: boolean;
    welcome_message_sent: boolean;
  };
  onChange: (client: any) => void;
  onSubmit: (e: React.FormEvent) => void;
  selectedCountryCode: string;
  onCountryCodeChange: (code: string) => void;
  isEditing?: boolean;
  onCancelEdit?: () => void;
}

export function ClientForm({
  client,
  onChange,
  onSubmit,
  selectedCountryCode,
  onCountryCodeChange,
  isEditing,
  onCancelEdit
}: ClientFormProps) {
  const { user } = useAuthStore();

  const countryCodes = [
    { code: '55', name: 'Brasil', flag: '🇧🇷' },
    { code: '595', name: 'Paraguai', flag: '🇵🇾' },
    { code: '54', name: 'Argentina', flag: '🇦🇷' }
  ];

  return (
    <form onSubmit={onSubmit} className="space-y-4">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-muted-foreground">
            Nome completo
          </label>
          <input
            type="text"
            className="input w-full mt-1"
            placeholder="Nome completo"
            value={client.name}
            onChange={(e) => onChange({ ...client, name: e.target.value })}
            required
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-muted-foreground">
            Nome formal
          </label>
          <input
            type="text"
            className="input w-full mt-1"
            placeholder="Para mensagem fidelidade"
            value={client.formal_name}
            onChange={(e) => onChange({ ...client, formal_name: e.target.value })}
            required
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-muted-foreground">
            Telefone
          </label>
          <div className="flex gap-2">
            <select
              className="input w-24"
              value={selectedCountryCode}
              onChange={(e) => onCountryCodeChange(e.target.value)}
            >
              {countryCodes.map((country) => (
                <option key={country.code} value={country.code}>
                  {country.flag} +{country.code}
                </option>
              ))}
            </select>
            <input
              type="text"
              className="input flex-1"
              placeholder="45988110011"
              value={client.phone}
              onChange={(e) => onChange({ ...client, phone: e.target.value })}
              required
            />
          </div>
        </div>

        <div>
          <label className="block text-sm font-medium text-muted-foreground">
            Endereço
          </label>
          <input
            type="text"
            className="input w-full mt-1"
            placeholder="Rua/Avenida"
            value={client.address}
            onChange={(e) => onChange({ ...client, address: e.target.value })}
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-muted-foreground">
            Número
          </label>
          <input
            type="text"
            className="input w-full mt-1"
            placeholder="123"
            value={client.address_number}
            onChange={(e) => onChange({ ...client, address_number: e.target.value })}
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-muted-foreground">
            Bairro
          </label>
          <input
            type="text"
            className="input w-full mt-1"
            placeholder="Centro"
            value={client.neighborhood}
            onChange={(e) => onChange({ ...client, neighborhood: e.target.value })}
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-muted-foreground">
            Cidade
          </label>
          <input
            type="text"
            className="input w-full mt-1"
            placeholder="Cidade"
            value={client.city}
            onChange={(e) => onChange({ ...client, city: e.target.value })}
          />
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-muted-foreground">
          Anotações
        </label>
        <textarea
          className="input w-full mt-1"
          rows={3}
          placeholder="Observações importantes sobre o cliente"
          value={client.notes}
          onChange={(e) => onChange({ ...client, notes: e.target.value })}
        />
      </div>

      <div className="space-y-4">
        <div>
          <label className="block text-sm font-medium text-muted-foreground mb-2">
            Enviar lembretes de manutenção
          </label>
          <div className="flex gap-4">
            <label className="flex items-center gap-2">
              <input
                type="radio"
                checked={client.send_maintenance_reminders}
                onChange={() => onChange({ ...client, send_maintenance_reminders: true })}
                className="text-primary"
              />
              <span>Sim</span>
            </label>
            <label className="flex items-center gap-2">
              <input
                type="radio"
                checked={!client.send_maintenance_reminders}
                onChange={() => onChange({ ...client, send_maintenance_reminders: false })}
                className="text-primary"
              />
              <span>Não</span>
            </label>
          </div>
        </div>

        <div>
          <label className="block text-sm font-medium text-muted-foreground mb-2">
            Enviar mensagem de boas-vindas
          </label>
          <div className="flex gap-4">
            <label className="flex items-center gap-2">
              <input
                type="radio"
                checked={client.welcome_message_sent}
                onChange={() => onChange({ ...client, welcome_message_sent: true })}
                className="text-primary"
              />
              <span>Sim</span>
            </label>
            <label className="flex items-center gap-2">
              <input
                type="radio"
                checked={!client.welcome_message_sent}
                onChange={() => onChange({ ...client, welcome_message_sent: false })}
                className="text-primary"
              />
              <span>Não</span>
            </label>
          </div>
        </div>
      </div>

      <div className="flex gap-2">
        <button type="submit" className="btn btn-primary flex-1">
          {isEditing ? 'Atualizar Cliente' : 'Adicionar Cliente'}
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