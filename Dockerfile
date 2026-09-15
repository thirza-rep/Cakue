# ─────────────────────────────────────────────────
# Production: Serve prebuilt Flutter Web with Nginx
# ─────────────────────────────────────────────────
FROM nginx:alpine AS runner

# Copy built web files into Nginx root
COPY build/web /usr/share/nginx/html

# Copy custom nginx config
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]


