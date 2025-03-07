export interface Database {
  public: {
    Tables: {
      clients: {
        Row: {
          id: string;
          full_name: string;
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
        };
        Insert: {
          id?: string;
          full_name: string;
          formal_name: string;
          phone: string;
          registration_date?: string;
          address?: string;
          number?: string;
          neighborhood?: string;
          city?: string;
          state?: string;
          notes?: string;
          send_maintenance_reminders?: boolean;
          send_welcome_message?: boolean;
          next_maintenance_date?: string | null;
          created_at?: string;
          created_by?: string;
        };
        Update: {
          id?: string;
          full_name?: string;
          formal_name?: string;
          phone?: string;
          registration_date?: string;
          address?: string;
          number?: string;
          neighborhood?: string;
          city?: string;
          state?: string;
          notes?: string;
          send_maintenance_reminders?: boolean;
          send_welcome_message?: boolean;
          next_maintenance_date?: string | null;
          created_at?: string;
          created_by?: string;
        };
      };
      services: {
        Row: {
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
        };
        Insert: {
          id?: string;
          client_id: string;
          service_number?: number;
          service_date: string;
          service_type_id: string;
          collaborator_id: string;
          use_client_address?: boolean;
          service_address?: string | null;
          notes?: string | null;
          total: number;
          created_at?: string;
          created_by?: string;
        };
        Update: {
          id?: string;
          client_id?: string;
          service_number?: number;
          service_date?: string;
          service_type_id?: string;
          collaborator_id?: string;
          use_client_address?: boolean;
          service_address?: string | null;
          notes?: string | null;
          total?: number;
          created_at?: string;
          created_by?: string;
        };
      };
      service_types: {
        Row: {
          id: string;
          name: string;
          created_at: string;
        };
        Insert: {
          id?: string;
          name: string;
          created_at?: string;
        };
        Update: {
          id?: string;
          name?: string;
          created_at?: string;
        };
      };
      collaborators: {
        Row: {
          id: string;
          name: string;
          active: boolean;
          created_at: string;
        };
        Insert: {
          id?: string;
          name: string;
          active?: boolean;
          created_at?: string;
        };
        Update: {
          id?: string;
          name?: string;
          active?: boolean;
          created_at?: string;
        };
      };
      system_settings: {
        Row: {
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
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          company_name: string;
          logo_url?: string | null;
          welcome_message?: string | null;
          timezone?: string;
          whatsapp_api_url?: string | null;
          whatsapp_api_key?: string | null;
          whatsapp_instance_name?: string | null;
          support_id: string;
          support_user_name: string;
          support_document: string;
          support_url?: string | null;
          enable_product_requests?: boolean;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          company_name?: string;
          logo_url?: string | null;
          welcome_message?: string | null;
          timezone?: string;
          whatsapp_api_url?: string | null;
          whatsapp_api_key?: string | null;
          whatsapp_instance_name?: string | null;
          support_id?: string;
          support_user_name?: string;
          support_document?: string;
          support_url?: string | null;
          enable_product_requests?: boolean;
          created_at?: string;
          updated_at?: string;
        };
      };
    };
    Functions: {
      next_service_number: {
        Args: { client_id: string };
        Returns: number;
      };
    };
  };
}