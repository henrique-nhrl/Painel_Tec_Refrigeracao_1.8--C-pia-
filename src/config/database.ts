import { createClient } from '@supabase/supabase-js';
import type { Pool } from 'mysql2/promise';

// Tipo de banco de dados suportado
type DatabaseType = 'supabase' | 'mysql';

// Configuração do banco de dados
interface DatabaseConfig {
  type: DatabaseType;
  supabase?: {
    url: string;
    anonKey: string;
  };
  mysql?: {
    host: string;
    user: string;
    password: string;
    database: string;
  };
}

// Configuração atual (pode ser alterada conforme necessário)
export const dbConfig: DatabaseConfig = {
  type: 'supabase', // Altere para 'mysql' se desejar usar MySQL
  supabase: {
    url: import.meta.env.VITE_SUPABASE_URL,
    anonKey: import.meta.env.VITE_SUPABASE_ANON_KEY,
  },
  mysql: {
    host: import.meta.env.VITE_MYSQL_HOST || 'localhost',
    user: import.meta.env.VITE_MYSQL_USER || 'root',
    password: import.meta.env.VITE_MYSQL_PASSWORD || '',
    database: import.meta.env.VITE_MYSQL_DATABASE || 'sistema_admin',
  },
};

// Cliente do banco de dados
class DatabaseClient {
  private static instance: DatabaseClient;
  private supabaseClient: ReturnType<typeof createClient> | null = null;
  private mysqlPool: Pool | null = null;

  private constructor() {
    if (dbConfig.type === 'supabase' && dbConfig.supabase) {
      this.supabaseClient = createClient(
        dbConfig.supabase.url,
        dbConfig.supabase.anonKey
      );
    } else if (dbConfig.type === 'mysql' && dbConfig.mysql) {
      // Importação dinâmica do mysql2
      import('mysql2/promise').then((mysql) => {
        this.mysqlPool = mysql.createPool(dbConfig.mysql!);
      });
    }
  }

  public static getInstance(): DatabaseClient {
    if (!DatabaseClient.instance) {
      DatabaseClient.instance = new DatabaseClient();
    }
    return DatabaseClient.instance;
  }

  public getClient() {
    if (dbConfig.type === 'supabase') {
      return this.supabaseClient;
    }
    return this.mysqlPool;
  }

  public getType(): DatabaseType {
    return dbConfig.type;
  }
}

export const db = DatabaseClient.getInstance();