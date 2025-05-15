
FROM nginx:stable-alpine3.21-slim

# FROM bitnami/nginx
COPY index.html /usr/share/nginx/html
COPY cicd.jpg /usr/share/nginx/html

EXPOSE 80


