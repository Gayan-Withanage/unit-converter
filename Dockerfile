# =============================================================================
# Dockerfile - Unit Converter (Static HTML/CSS/JS)
# =============================================================================

# Use lightweight nginx for serving static files
FROM nginx:alpine

# Remove default nginx files
RUN rm -rf /usr/share/nginx/html/*

# Copy your custom nginx configuration (if you have one)
# Otherwise nginx will use default config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy all your static files (HTML, CSS, JS, images) into nginx
COPY . /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Optional healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Start nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
