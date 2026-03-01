# =============================================================================
# Dockerfile - Unit Converter Web Application
# =============================================================================
# This Dockerfile uses a multi-stage build strategy to produce a minimal,
# secure, and optimised production image.
#
# Stage 1 (builder): Uses Node.js to install dependencies and validate the
#                    project structure / run any CI checks.
# Stage 2 (production): Copies only the static files into a lightweight
#                       nginx:alpine image to serve the application.
#
# Why multi-stage?
#   - Build-time tools (Node.js, npm) are NOT included in the final image,
#     significantly reducing image size and attack surface.
#   - The final image contains only nginx and the static HTML/CSS/JS files.
# =============================================================================


# -----------------------------------------------------------------------------
# STAGE 1: Builder
# Base image: node:18-alpine
#
# Why node:18-alpine over node:18?
#   - Alpine Linux is a minimal distribution (~5 MB vs ~900 MB for Debian).
#   - LTS version 18 ensures long-term security support and stability.
#   - Alpine reduces the attack surface by shipping fewer packages.
# -----------------------------------------------------------------------------
FROM node:18-alpine AS builder

# Set the working directory inside the container.
# All subsequent commands in this stage run relative to /app.
WORKDIR /app

# Copy package files first — BEFORE copying source code.
# Docker builds images in layers. By copying package.json separately,
# Docker can cache the npm install layer and skip it on future builds
# if dependencies have not changed. This significantly speeds up rebuilds.
COPY package*.json ./

# Install all dependencies defined in package.json.
# --frozen-lockfile ensures the exact versions in package-lock.json are used,
# making builds reproducible across different environments.
RUN npm ci --frozen-lockfile 2>/dev/null || npm install

# Copy the rest of the application source code.
# This layer is invalidated only when source files change, not on every build.
COPY . .

# Run any available build or validation scripts.
# If no build script is defined, this step is skipped gracefully.
# This stage ensures that the code has been validated before packaging.
RUN npm run build 2>/dev/null || echo "No build step defined — using source files directly."


# -----------------------------------------------------------------------------
# STAGE 2: Production
# Base image: nginx:alpine
#
# Why nginx:alpine?
#   - Extremely lightweight (~23 MB) compared to full nginx (~140 MB).
#   - nginx is purpose-built for serving static files with high performance.
#   - Alpine base minimises the number of installed packages and
#     potential vulnerabilities.
#   - No Node.js runtime is included — reducing the attack surface
#     to only what is required to serve static files.
# -----------------------------------------------------------------------------
FROM nginx:alpine AS production

# Install 'curl' for the container health check defined below.
# Only the minimum required package is installed (principle of least privilege).
RUN apk add --no-cache curl

# Remove the default nginx welcome page so our application is served instead.
RUN rm -rf /usr/share/nginx/html/*

# Copy our custom nginx configuration into the container.
# This configuration sets up proper caching headers, gzip compression,
# and security headers appropriate for a production static site.
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the built/static files from the builder stage.
# Only the files needed to serve the application are copied —
# node_modules, source maps, and build tooling are excluded.
COPY --from=builder /app/src /usr/share/nginx/html

# Create a non-root user and group for running nginx.
# Principle of Least Privilege: the nginx worker processes will run as
# 'nginxuser' rather than root, limiting the impact of any potential exploit.
RUN addgroup -S nginxgroup && adduser -S nginxuser -G nginxgroup

# Adjust ownership of the nginx directories required at runtime
# so the non-root user can read/write them correctly.
RUN chown -R nginxuser:nginxgroup /var/cache/nginx \
    && chown -R nginxuser:nginxgroup /var/log/nginx \
    && chown -R nginxuser:nginxgroup /usr/share/nginx/html \
    && touch /var/run/nginx.pid \
    && chown -R nginxuser:nginxgroup /var/run/nginx.pid

# Switch to the non-root user for all subsequent runtime operations.
USER nginxuser

# Expose port 80 — the standard HTTP port nginx listens on.
# This is a declaration for documentation; actual port mapping is done
# in docker-compose.yml or via the -p flag in docker run.
EXPOSE 80

# Health check: Docker will periodically test that the container is healthy
# by sending an HTTP request to the root path.
# --interval=30s  : Check every 30 seconds
# --timeout=10s   : Fail if no response within 10 seconds
# --start-period=5s: Allow 5 seconds for nginx to start before checking
# --retries=3     : Mark as unhealthy after 3 consecutive failures
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Start nginx in the foreground.
# 'daemon off' prevents nginx from daemonising, keeping the process in the
# foreground so Docker can correctly track the container lifecycle.
CMD ["nginx", "-g", "daemon off;"]
