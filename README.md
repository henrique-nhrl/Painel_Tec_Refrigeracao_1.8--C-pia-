# Docker Infrastructure

This project includes a complete Docker infrastructure for development and deployment.

## Prerequisites

- Docker
- Docker Compose
- Node.js 20+

## Environment Variables

Create a `.env` file with the following variables:

```env
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
DB_CONNECTION_STRING=postgresql://postgres:password@host:5432/database
```

## Commands

Start the application:
```bash
docker-compose up
```

Run migrations only:
```bash
docker-compose run migration
```

Build for production:
```bash
docker-compose -f docker-compose.prod.yml up --build
```

## Migration System

Migrations are stored in `supabase/migrations` and follow the naming convention:
```
YYYYMMDDHHMMSS_description.sql
```

Example:
```
20240301123000_create_users_table.sql
```

Migrations are tracked in the `migracoes_do_sistema` table and only run once.

## Development

The application runs on port 3000 with hot-reload enabled. Changes to the source code will automatically reflect in the browser.

## Production

For production deployment, use:
```bash
docker-compose -f docker-compose.prod.yml up -d
```

This will build an optimized image and run the application in production mode.