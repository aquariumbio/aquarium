ARG NGINX_VERSION=stable

FROM nginx:${NGINX_VERSION}-alpine AS aquarium-nginx

EXPOSE 80

# Remove default nginx page
RUN rm /usr/share/nginx/html/*

COPY default.conf /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]
