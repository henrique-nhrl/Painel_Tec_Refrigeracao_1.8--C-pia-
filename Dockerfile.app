# Dockerfile.app
FROM node:16

WORKDIR /app

COPY package*.json ./
RUN npm install --save-dev supabase

COPY . .

# Comando para iniciar a aplicação
CMD ["npm", "run", "start"]

# Post-deployment script
RUN echo "#!/bin/sh" > /app/run-migrations.sh && \
    echo "docker build -t migrations -f Dockerfile.migrations ." >> /app/run-migrations.sh && \
    echo "docker run --rm -e DATABASE_URL migrations" >> /app/run-migrations.sh && \
    chmod +x /app/run-migrations.sh

# Adicionar o script ao post-deploy do Coolify
CMD ["sh", "-c", "/app/run-migrations.sh && npm run start"]
