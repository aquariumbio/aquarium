# pull official base image
ARG NODE_VERSION=16
ARG ALPINE_VERSION=3.12
ARG NGINX_VERSION=stable

# Build development image
#
FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS frontend-development
WORKDIR /app
ENV PATH /app/node_modules/.bin:$PATH

# Add app dependencies
COPY package.json ./
COPY yarn.lock ./

# RUN yarn install \
RUN yarn install \
&& yarn global add react-scripts@4.0.3 -g

COPY . ./

CMD ["yarn", "start"]

# Temporary build stage
#
FROM frontend-development AS frontend-builder
ENV NODE_ENV production
RUN yarn run build

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
