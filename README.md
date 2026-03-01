# Unit Converter Web Application

## Group Information

| Student | ID | Role |
|---|---|---|
| Gayan Eranda | ITBNM-2313-0023 | DevOps Engineer |
| Isuru Sandaruwan | ITBNM-2313-0055 | Frontend Developer |
| Navodya Heshara | ITBNM-2313-0032 | JavaScript / Backend Logic Developer |

---

## Project Description

The Unit Converter Web Application is a responsive web-based system that allows users to convert values between different measurement units efficiently. The application is developed using HTML5, CSS3, and Vanilla JavaScript for client-side conversion logic.

The project follows modern Git and DevOps practices, including feature branching, pull requests, GitHub Actions CI/CD pipelines, and Docker containerisation for consistent deployment.

---

## Live Deployment

🔗 **Live URL:** https://unit-converter-2yq1.vercel.app/

---

## Technologies Used

- HTML5
- CSS3
- JavaScript (Vanilla JS)
- Git & GitHub
- GitHub Actions (CI/CD)
- Docker & Docker Compose
- Nginx (static file server)
- Vercel (cloud deployment)

---

## Features

- Convert values between multiple unit types
- Responsive and user-friendly interface
- Real-time conversion without page reload
- Cross-browser compatibility
- Containerised for consistent deployment across environments

---

## Docker Setup

### Prerequisites

Ensure the following are installed on your machine before proceeding:

- [Docker](https://docs.docker.com/get-docker/) (version 20.10 or higher)
- [Docker Compose](https://docs.docker.com/compose/install/) (version 2.0 or higher)

Verify your installation:

```bash
docker --version
docker compose version
```

---

### Environment Configuration

Before running the application, configure your environment variables:

```bash
# Copy the example environment file
cp .env.example .env
```

Edit `.env` if you wish to change the default port (default is `8080`):

```
HOST_PORT=8080
NODE_ENV=production
APP_VERSION=1.0.0
```

---

### Building and Running with Docker Compose (Recommended)

This is the simplest way to run the containerised application.

```bash
# Clone the repository
git clone https://github.com/Gayan-Withanage/unit-converter.git
cd unit-converter

# Copy environment file
cp .env.example .env

# Build and start the container
docker compose up --build

# Run in detached (background) mode
docker compose up --build -d
```

The application will be accessible at: **http://localhost:8080**

---

### Stopping the Application

```bash
# Stop and remove containers
docker compose down

# Stop, remove containers, and remove the built image
docker compose down --rmi local
```

---

### Building and Running Manually (without Docker Compose)

```bash
# Build the Docker image
docker build -t unit-converter:latest .

# Run the container
docker run -d \
  --name unit-converter-app \
  -p 8080:80 \
  unit-converter:latest
```

Access at: **http://localhost:8080**

```bash
# Stop and remove the container
docker stop unit-converter-app
docker rm unit-converter-app
```

---

### Checking Container Health

```bash
# View running containers and health status
docker ps

# View container logs
docker compose logs -f web

# Inspect health check details
docker inspect unit-converter-app | grep -A 10 '"Health"'
```

---

### Verifying the Build

After building, you can check the final image size:

```bash
docker images unit-converter
```

The final image should be approximately **40–60 MB** (nginx:alpine base), compared to ~900 MB for a standard Node.js image — demonstrating the efficiency of the multi-stage build.

---

## Docker Architecture Overview

The application uses a **multi-stage build** strategy:

| Stage | Base Image | Purpose |
|---|---|---|
| `builder` | `node:18-alpine` | Install dependencies, run build/validation |
| `production` | `nginx:alpine` | Serve static files — no Node.js in final image |

**Key design decisions:**
- `nginx:alpine` final image (~23 MB) instead of a Node.js image (~900 MB)
- Non-root user (`nginxuser`) for running nginx processes
- Health check via HTTP curl to verify the container is serving correctly
- Custom nginx configuration with gzip, caching headers, and security headers
- Resource limits set in docker-compose.yml (0.5 CPU, 128 MB RAM)
- `.dockerignore` excludes `node_modules`, `.git`, `.env`, and test files

---

## Repository Structure

```
unit-converter/
├── src/                        # Application source files
│   ├── index.html              # Main HTML file
│   ├── style.css               # Stylesheet
│   └── script.js               # Conversion logic
├── .github/
│   └── workflows/              # GitHub Actions CI/CD workflows
├── Dockerfile                  # Multi-stage Docker build definition
├── docker-compose.yml          # Service orchestration configuration
├── nginx.conf                  # Custom Nginx server configuration
├── .dockerignore               # Build context exclusions
├── .env.example                # Environment variable reference
├── .gitignore                  # Git exclusions
└── README.md                   # Project documentation
```

---

## Branch Strategy

- `main` – Production branch
- `develop` – Integration branch
- `feature/*` – Feature development branches

---

## Individual Contributions

### Gayan Eranda – ITBNM-2313-0023
- Repository initialisation and configuration
- Branching strategy implementation
- GitHub Actions CI workflow setup
- GitHub Actions deployment workflow
- Docker containerisation (Dockerfile, docker-compose.yml, nginx.conf, .dockerignore)
- Vercel deployment configuration
- Final merge from develop to main

### Isuru Sandaruwan – ITBNM-2313-0055
- HTML structure and layout design
- CSS styling and responsive design
- UI enhancements and usability improvements
- Feature branch development and pull requests

### Navodya Heshara – ITBNM-2313-0032
- JavaScript unit conversion logic
- Input validation and calculation handling
- Feature enhancements and bug fixes
- Code reviews and pull request participation

---

## Troubleshooting

**Port already in use:**
```bash
# Change the HOST_PORT in your .env file, then restart
HOST_PORT=9090 docker compose up
```

**Container not starting:**
```bash
# Check logs for errors
docker compose logs web
```

**Health check failing:**
```bash
# Test manually from inside the container
docker exec unit-converter-app curl -f http://localhost/
```

**Rebuilding after code changes:**
```bash
# Force a fresh build (no cache)
docker compose build --no-cache
docker compose up
```
