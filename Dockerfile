# =============================================================================
# Dockerfile - Unit Converter (Static HTML/CSS/JS)
# =============================================================================

# Simple nginx for static HTML/CSS/JS
FROM nginx:alpine

# Remove default nginx files
RUN rm -rf /usr/share/nginx/html/*

# Copy everything from src/ to nginx root
COPY src/ /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
