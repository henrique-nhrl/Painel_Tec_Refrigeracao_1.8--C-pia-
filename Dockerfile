
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM node:18-alpine
RUN apk add --no-cache nginx && \
    npm install -g supabase-cli
COPY --from=builder /app/dist /usr/share/nginx/html
COPY supabase /app/supabase
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Environment variables
ENV VITE_API_BASE_URL=$VITE_API_BASE_URL
ENV VITE_SUPPORT_API_KEY=$VITE_SUPPORT_API_KEY
ENV VITE_SUPABASE_URL=$VITE_SUPABASE_URL
ENV VITE_SUPABASE_ANON_KEY=$VITE_SUPABASE_ANON_KEY
ENV SUPABASE_SERVICE_KEY=$SUPABASE_SERVICE_KEY
ENV SUPABASE_DATABASE_URL=$SUPABASE_DATABASE_URL

EXPOSE 80
CMD sh -c "supabase db push --db-url $SUPABASE_DATABASE_URL && nginx -g 'daemon off;'"
