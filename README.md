# Tarot Reader Application

A modern web application for tarot card readings, built with Rust (Rocket) backend and Vue.js (Vite + Vuetify) frontend. Designed to run locally for development and on a Synology NAS with Traefik reverse proxy for production.

## 🎯 Features

- RESTful API backend built with Rust and Rocket framework
- Modern Vue 3 frontend with Vuetify material design components
- PostgreSQL database for persistent storage
- Docker containerization for easy deployment
- Traefik-ready for production reverse proxy
- Health check endpoints for monitoring
- CORS configuration for secure cross-origin requests

## 🏗️ Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│    Frontend     │────▶│     Backend     │────▶│   PostgreSQL    │
│   (Vue.js)      │     │     (Rust)      │     │    Database     │
│                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
       :80                    :8000                    :5432
```

## 📋 Prerequisites

- Docker and Docker Compose (v2.0+)
- Make (optional, for using Makefile commands)
- For local development without Docker:
  - Node.js 20+ and pnpm
  - Rust 1.75+
  - PostgreSQL 16+

## 🚀 Quick Start

### Using Make (Recommended)

```bash
# Clone the repository
git clone https://github.com/yourusername/tarotreader.git
cd tarotreader

# Set up environment and start development servers
make quickstart

# Services will be available at:
# - Frontend: http://localhost:3000
# - Backend API: http://localhost:8000
# - Database: postgresql://localhost:5432/tarotreader
```

### Manual Setup

1. **Create environment file:**
```bash
cp .env.example .env
# Edit .env with your configuration
```

2. **Start development environment:**
```bash
docker compose -f docker-compose.dev.yml up --build
```

## 🔧 Development

### Available Make Commands

```bash
make help              # Show all available commands
make dev              # Start development environment
make dev-logs         # Show container logs
make db-shell         # Connect to PostgreSQL shell
make backend-test     # Run backend tests
make frontend-dev     # Run frontend dev server locally
```

### Project Structure

```
tarotreader/
├── backend/              # Rust backend application
│   ├── src/
│   │   └── main.rs      # API endpoints and business logic
│   ├── Cargo.toml       # Rust dependencies
│   └── Dockerfile       # Backend container definition
├── frontend/            # Vue.js frontend application
│   ├── src/            # Vue components and assets
│   ├── package.json    # Node dependencies
│   └── Dockerfile      # Frontend container definition
├── docker/             # Docker-related files
│   └── init.sql       # Database initialization script
├── docker-compose.dev.yml    # Development environment
├── compose.yaml            # Production environment
├── compose.override.yaml   # Local overrides
└── Makefile           # Development commands
```

### Backend API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | API information and version |
| GET | `/health` | Health check endpoint |
| GET | `/api/readings` | Get all readings |
| GET | `/api/readings/{id}` | Get specific reading |
| POST | `/api/readings` | Create new reading |

### Database Schema

```sql
CREATE TABLE readings (
    id UUID PRIMARY KEY,
    question TEXT NOT NULL,
    cards TEXT[] NOT NULL,
    interpretation TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ,
    user_id UUID REFERENCES users(id)
);
```

## 🐛 Troubleshooting

### Docker Build Issues

**Problem: "Sending tarball" stalls during build**

This typically happens when large directories (like `node_modules` or `target`) are being sent to the Docker daemon.

**Solution:**
1. Ensure `.dockerignore` files are properly configured
2. Clean local build artifacts:
```bash
make clean
# or manually:
rm -rf frontend/node_modules frontend/dist
rm -rf backend/target
```
3. Rebuild:
```bash
docker compose -f docker-compose.dev.yml up --build
```

**Problem: Docker build fails with network errors**

**Solution:**
```bash
# Clean Docker cache and rebuild
docker system prune -af
docker compose -f docker-compose.dev.yml build --no-cache
```

### Database Connection Issues

**Problem: Backend can't connect to database**

**Solution:**
1. Check if PostgreSQL is running:
```bash
docker compose -f docker-compose.dev.yml ps postgres
```

2. Verify DATABASE_URL in .env:
```bash
# For Docker Compose:
DATABASE_URL=postgres://postgres:postgres@postgres:5432/tarotreader

# For local development:
DATABASE_URL=postgres://postgres:postgres@localhost:5432/tarotreader
```

3. Check database logs:
```bash
make dev-db-logs
```

### Frontend Build Issues

**Problem: Frontend fails to build with vite/rolldown errors**

**Solution:**
```bash
cd frontend
rm -rf node_modules pnpm-lock.yaml
pnpm install
pnpm build
```

### Port Conflicts

**Problem: "Port already in use" errors**

**Solution:**
```bash
# Find processes using the ports
lsof -i :3000  # Frontend
lsof -i :8000  # Backend
lsof -i :5432  # PostgreSQL

# Kill the processes or change ports in .env
```

## 🚢 Production Deployment (Synology)

### Prerequisites on Synology

- Docker package installed via Package Center
- Traefik reverse proxy running
- PostgreSQL container or external database

### Deployment Steps

1. **Build production images:**
```bash
make prod-build
```

2. **Transfer to Synology:**
- Option A: Push to Docker registry and pull on Synology
- Option B: Save images and transfer via SSH:
```bash
docker save tarotreader-backend:latest | ssh user@synology docker load
docker save tarotreader-frontend:latest | ssh user@synology docker load
```

3. **Configure on Synology:**
```bash
# SSH to Synology
ssh user@synology

# Create project directory
mkdir -p /volume1/docker/tarotreader

# Copy compose files and .env
# Update .env with production values:
# - Set proper domain names for FRONTEND_HOST and BACKEND_HOST
# - Update DATABASE_URL to production database
# - Set ALLOWED_ORIGINS for CORS
```

4. **Start services:**
```bash
cd /volume1/docker/tarotreader
docker compose up -d
```

### Traefik Configuration

The application includes Traefik labels in `compose.yaml` for automatic reverse proxy configuration:

- Frontend: `https://yourdomain.com`
- Backend API: `https://api.yourdomain.com`

Ensure your DNS records point to your Synology's IP address.

## 📝 Environment Variables

Key environment variables (see `.env.example` for full list):

| Variable | Description | Default |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | postgres://postgres:postgres@localhost:5432/tarotreader |
| `BACKEND_PORT` | Backend server port | 8000 |
| `FRONTEND_HOST` | Frontend domain for Traefik | yourdomain.com |
| `BACKEND_HOST` | Backend API domain for Traefik | api.yourdomain.com |
| `VITE_API_URL` | Backend URL for frontend API calls | http://localhost:8000 |
| `ALLOWED_ORIGINS` | CORS allowed origins | http://localhost:3000 |

## 🔒 Security Considerations

1. **Database**: Change default PostgreSQL passwords in production
2. **CORS**: Configure `ALLOWED_ORIGINS` to restrict API access
3. **HTTPS**: Use Traefik's Let's Encrypt integration for SSL certificates
4. **Environment**: Never commit `.env` files with sensitive data
5. **Container Security**: Images run as non-root users

## 📊 Monitoring

### Health Checks

- Backend: `GET http://localhost:8000/health`
- Frontend: `GET http://localhost:3000/`
- Database: `docker exec tarotreader-postgres pg_isready`

### Logs

```bash
# All logs
docker compose logs -f

# Specific service
docker compose logs -f backend
docker compose logs -f frontend
docker compose logs -f postgres
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `make test`
5. Submit a pull request

## 📜 License

[Your License Here]

## 🆘 Support

For issues and questions:
- GitHub Issues: [your-repo-url]/issues
- Documentation: [your-docs-url]

## 🎉 Acknowledgments

Built with:
- [Rocket](https://rocket.rs/) - Rust web framework
- [Vue.js](https://vuejs.org/) - Progressive JavaScript framework
- [Vuetify](https://vuetifyjs.com/) - Material Design component framework
- [PostgreSQL](https://www.postgresql.org/) - Open source database
- [Docker](https://www.docker.com/) - Containerization platform