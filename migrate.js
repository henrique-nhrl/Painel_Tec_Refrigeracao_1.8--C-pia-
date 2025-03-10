const { execSync } = require('child_process');
require('dotenv').config();

// Configurações do banco de dados via variáveis de ambiente
const DB_URL = process.env.DATABASE_URL;

try {
  console.log('Aplicando migrações...');
  execSync(`npx supabase migrate up --db-url ${DB_URL}`, {
    stdio: 'inherit',
    cwd: './supabase'
  });
  console.log('Migrações aplicadas com sucesso!');
} catch (error) {
  console.error('Erro ao aplicar migrações:', error);
  process.exit(1);
}
