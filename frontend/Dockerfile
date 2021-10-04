# pull official base image
ARG NODE_VERSION=16
ARG ALPINE_VERSION=3.12

FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS frontend-development

# set working directory
WORKDIR /app

# add `/app/node_modules/.bin` to $PATH
ENV PATH /app/node_modules/.bin:$PATH

# Add app dependencies
COPY package.json ./
COPY yarn.lock ./

# RUN yarn install \
RUN yarn install \
&& yarn global add react-scripts@4.0.3 -g

# add app
COPY . ./

# start app
CMD ["yarn", "start"]
