# Set versions for base images
ARG NODE_VERSION=14.15.1
ARG ALPINE_VERSION=3.12
ARG NGINX_VERSION=stable

# Build development image
#
FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS frontend-development
WORKDIR /app
ENV PATH /app/node_modules/.bin:$PATH

COPY package.json package-lock.json ./

RUN npm install \
 && npm install react-scripts@4.0.3 -g

COPY . ./

CMD ["npm", "start"]

# Temporary build stage
#
FROM frontend-development AS frontend-builder
ENV NODE_ENV production
RUN npm run build

# Build production image
#
FROM nginx:${NGINX_VERSION}-alpine AS aquarium-frontend

ENV NODE_ENV production
ENV BUILD_ROOT=/usr/share/nginx/html

COPY --from=frontend-builder /app/build ${BUILD_ROOT}

RUN rm /etc/nginx/conf.d/default.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

COPY production-entrypoint.sh /
RUN ["chmod", "+x", "/production-entrypoint.sh"]
ENTRYPOINT [ "/production-entrypoint.sh" ]

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]
