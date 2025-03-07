export interface Client {
  id: string;
  name: string;
  formal_name: string;
  phone: string;
  registration_date: string;
  address: string;
  number: string;
  neighborhood: string;
  city: string;
  state: string;
  notes: string;
  send_maintenance_reminders: boolean;
  send_welcome_message: boolean;
  next_maintenance_date: string | null;
  created_at: string;
  created_by: string;
}

export interface Service {
  id: string;
  client_id: string;
  service_number: number;
  service_date: string;
  service_type_id: string;
  collaborator_id: string;
  use_client_address: boolean;
  service_address: string | null;
  notes: string | null;
  total: number;
  created_at: string;
  created_by: string;
  client?: Client;
  service_type?: ServiceType;
  collaborator?: Collaborator;
}

export interface ServiceType {
  id: string;
  name: string;
  created_at: string;
}

export interface Collaborator {
  id: string;
  name: string;
  active: boolean;
  created_at: string;
}

export interface FinancialRecord {
  id: string;
  service_id: string;
  amount: number;
  date: string;
  created_at: string;
  service?: Service;
}

export interface SystemSettings {
  id: string;
  company_name: string;
  logo_url: string | null;
  welcome_message: string | null;
  timezone: string;
  whatsapp_api_url: string | null;
  whatsapp_api_key: string | null;
  whatsapp_instance_name: string | null;
  support_id: string;
  support_user_name: string;
  support_document: string;
  support_url: string | null;
  enable_product_requests: boolean;
  maintenance_interval: number;
  maintenance_price: number;
  maintenance_template_id: string | null;
  welcome_template_id: string | null;
  created_at: string;
  updated_at: string;
}

export interface User {
  id: string;
  email: string;
  role: 'admin' | 'user';
  created_at: string;
}

export interface Log {
  id: string;
  user_id: string;
  product_id?: string;
  client_id?: string;
  action: string;
  created_at: string;
  profiles?: {
    email: string;
  };
  products?: {
    name: string;
  };
  clients?: {
    name: string;
  };
}