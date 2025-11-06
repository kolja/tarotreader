# Stage 1: Build the Vue application
FROM node:20-slim AS builder

# Install pnpm
RUN npm install -g pnpm

# Set working directory
WORKDIR /app

# Copy package.json and pnpm-lock.yaml
COPY package.json pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install

# Copy the rest of the application source code
COPY . .

# Build the application for production
RUN pnpm build

# Stage 2: Serve the static files with Nginx
FROM nginx:1.25-alpine

# Copy the built files from the builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
