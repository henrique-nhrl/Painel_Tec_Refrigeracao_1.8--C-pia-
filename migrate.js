const { Client } = require('pg');
const fs = require('fs');
const path = require('path');
const { promisify } = require('util');

const readFile = promisify(fs.readFile);

const client = new Client({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

async function runMigrations() {
  try {
    await client.connect();
    
    // Create migrations table if not exists
    await client.query(`
      CREATE TABLE IF NOT EXISTS applied_migrations (
        id SERIAL PRIMARY KEY,
        filename VARCHAR(255) UNIQUE NOT NULL,
        executed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Get applied migrations
    const res = await client.query('SELECT filename FROM applied_migrations');
    const appliedMigrations = new Set(res.rows.map(row => row.filename));

    // Read and sort migration files
    const migrationFiles = fs.readdirSync('./migrations')
      .filter(file => file.endsWith('.sql'))
      .sort();

    // Execute new migrations
    for (const file of migrationFiles) {
      if (!appliedMigrations.has(file)) {
        const filePath = path.join('./migrations', file);
        const sql = await readFile(filePath, 'utf8');
        
        await client.query('BEGIN');
        try {
          await client.query(sql);
          await client.query(
            'INSERT INTO applied_migrations (filename) VALUES ($1)',
            [file]
          );
          await client.query('COMMIT');
          console.log(`Migration applied: ${file}`);
        } catch (err) {
          await client.query('ROLLBACK');
          throw new Error(`Failed to apply ${file}: ${err.message}`);
        }
      }
    }
    
    console.log('All migrations applied successfully');
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  } finally {
    await client.end();
  }
}

runMigrations();
