# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --legacy-peer-deps || (npm install --legacy-peer-deps && npm cache clean --force)
COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine
RUN apk add --no-cache nginx curl && \
    npm install -g supabase@latest && \
    mkdir -p /var/run/nginx && \
    mkdir -p /etc/nginx/http.d

COPY --from=builder /app/dist /usr/share/nginx/html
COPY supabase /app/supabase
COPY nginx.conf /etc/nginx/http.d/default.conf

# Environment variables
ENV VITE_API_BASE_URL=$VITE_API_BASE_URL
ENV VITE_SUPPORT_API_KEY=$VITE_SUPPORT_API_KEY
ENV VITE_SUPABASE_URL=$VITE_SUPABASE_URL
ENV VITE_SUPABASE_ANON_KEY=$VITE_SUPABASE_ANON_KEY
ENV SUPABASE_SERVICE_KEY=$SUPABASE_SERVICE_KEY
ENV SUPABASE_DATABASE_URL=$SUPABASE_DATABASE_URL

EXPOSE 80
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:80 || exit 1

CMD sh -c "npx supabase db push --db-url $SUPABASE_DATABASE_URL || echo 'Migração falhou - continuando...'; nginx -g 'daemon off;'"
