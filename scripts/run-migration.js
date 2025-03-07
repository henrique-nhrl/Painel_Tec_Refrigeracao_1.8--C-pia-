const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

// Set up database connection
const client = new Client({
  host: process.env.SUPABASE_DB_HOST,
  database: process.env.SUPABASE_DB_NAME,
  user: process.env.SUPABASE_DB_USER,
  password: process.env.SUPABASE_DB_PASSWORD,
  port: process.env.SUPABASE_DB_PORT,
});

async function runMigrations() {
  try {
    await client.connect();
    console.log('Connected to the database.');

    // Read migration files from the migrations directory
    const migrationFiles = fs.readdirSync(path.join(__dirname, '../supabase/migrations')).sort();

    for (const file of migrationFiles) {
      const filePath = path.join(__dirname, '../supabase/migrations', file);
      const sql = fs.readFileSync(filePath, 'utf8');

      // Execute migration
      await client.query(sql);
      console.log(`Migration ${file} applied successfully.`);
    }

    console.log('All migrations applied successfully.');
  } catch (error) {
    console.error('Error applying migrations:', error);
  } finally {
    await client.end();
    console.log('Database connection closed.');
  }
}

// Run the migrations
runMigrations();
