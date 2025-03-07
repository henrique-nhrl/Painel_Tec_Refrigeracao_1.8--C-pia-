const fs = require('fs');
const path = require('path');
const { Client } = require('pg');
const { createClient } = require('@supabase/supabase-js');

// Configure timezone
process.env.TZ = 'America/Sao_Paulo';

// Utility to format dates in BR format
const formatDateBR = (date) => {
  return date.toLocaleString('pt-BR', { timeZone: 'America/Sao_Paulo' });
};

// Singleton for database connection
class DatabaseConnection {
  static instance = null;
  static async getInstance() {
    if (!this.instance) {
      const connectionString = process.env.DB_CONNECTION_STRING;
      this.instance = new Client({ connectionString });
      await this.connectWithRetry();
    }
    return this.instance;
  }

  static async connectWithRetry(retries = 5, delay = 1000) {
    for (let i = 0; i < retries; i++) {
      try {
        await this.instance.connect();
        console.log(`[${formatDateBR(new Date())}] Database connected successfully`);
        return;
      } catch (error) {
        if (i === retries - 1) throw error;
        console.log(`[${formatDateBR(new Date())}] Connection attempt ${i + 1} failed, retrying...`);
        await new Promise(resolve => setTimeout(resolve, delay * Math.pow(2, i)));
      }
    }
  }
}

// Migration manager
class MigrationManager {
  constructor() {
    this.migrationsDir = '/migrations';
    this.supabase = createClient(
      process.env.VITE_SUPABASE_URL,
      process.env.VITE_SUPABASE_ANON_KEY
    );
  }

  async initialize() {
    const db = await DatabaseConnection.getInstance();
    
    // Create migrations table if it doesn't exist
    await db.query(`
      CREATE TABLE IF NOT EXISTS migracoes_do_sistema (
        id SERIAL PRIMARY KEY,
        timestamp TIMESTAMP WITH TIME ZONE,
        titulo VARCHAR(255),
        data_aplicacao TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
    `);
  }

  async getAppliedMigrations() {
    const db = await DatabaseConnection.getInstance();
    const result = await db.query('SELECT timestamp FROM migracoes_do_sistema');
    return result.rows.map(row => row.timestamp);
  }

  async applyMigration(file, timestamp, title) {
    const db = await DatabaseConnection.getInstance();
    const sql = fs.readFileSync(path.join(this.migrationsDir, file), 'utf8');

    try {
      await db.query('BEGIN');
      
      // Apply migration
      await db.query(sql);
      
      // Record migration
      await db.query(
        'INSERT INTO migracoes_do_sistema (timestamp, titulo) VALUES ($1, $2)',
        [timestamp, title]
      );
      
      await db.query('COMMIT');
      
      console.log(`[${formatDateBR(new Date())}] Applied migration: ${file}`);
    } catch (error) {
      await db.query('ROLLBACK');
      throw new Error(`Migration ${file} failed: ${error.message}`);
    }
  }

  async run() {
    try {
      await this.initialize();
      
      const appliedMigrations = await this.getAppliedMigrations();
      const files = fs.readdirSync(this.migrationsDir)
        .filter(f => f.endsWith('.sql'))
        .sort();

      for (const file of files) {
        const match = file.match(/^(\d{14})_(.+)\.sql$/);
        if (!match) continue;

        const timestamp = new Date(
          match[1].replace(
            /(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/,
            '$1-$2-$3T$4:$5:$6.000Z'
          )
        );

        if (!appliedMigrations.find(t => t.getTime() === timestamp.getTime())) {
          await this.applyMigration(file, timestamp, match[2]);
        }
      }

      console.log(`[${formatDateBR(new Date())}] All migrations completed successfully`);
    } catch (error) {
      console.error(`[${formatDateBR(new Date())}] Migration error:`, error);
      process.exit(1);
    } finally {
      const db = await DatabaseConnection.getInstance();
      await db.end();
    }
  }
}

// Run migrations
new MigrationManager().run();