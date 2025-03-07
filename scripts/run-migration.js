#!/usr/bin/env node

const { spawn } = require('child_process');
const path = require('path');

const args = process.argv.slice(2);
const command = args[0] === 'create' ? 'create' : 'run';

if (command === 'create' && args[1]) {
  const timestamp = new Date().toISOString().replace(/\D/g, '').slice(0, 14);
  const filename = `${timestamp}_${args[1]}.sql`;
  const filepath = path.join(__dirname, '..', 'supabase', 'migrations', filename);
  
  require('fs').writeFileSync(filepath, '-- Migration: ' + args[1] + '\n\n');
  console.log(`Created migration file: ${filename}`);
} else if (command === 'run') {
  const docker = spawn('docker-compose', ['run', 'migration'], {
    stdio: 'inherit',
    shell: true
  });

  docker.on('error', (err) => {
    console.error('Failed to run migration:', err);
    process.exit(1);
  });
}