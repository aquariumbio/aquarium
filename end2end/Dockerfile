# see https://github.com/cypress-io/cypress-example-docker-compose/blob/master/e2e/Dockerfile

# cypress image tags appear to be node versions, keep it roughly matched with frontend base
FROM cypress/base:14.15.0
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm install

# by setting CI environment variable we switch the Cypress install messages
# to small "started / finished" and avoid 1000s of lines of progress messages
# https://github.com/cypress-io/cypress/issues/1243
ENV CI=1
RUN npm ci
# verify that Cypress has been installed correctly.
# running this command separately from "cypress run" will also cache its result
# to avoid verifying again when running the tests
RUN npx cypress verify
