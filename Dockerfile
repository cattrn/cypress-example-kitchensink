# This Docker file is for building this project on Codeship Pro
# https://documentation.codeship.com/pro/languages-frameworks/nodejs/

# use Cypress provided image with all dependencies included
FROM cypress/base:16 AS cypress

RUN node --version
RUN npm --version
WORKDIR /home/node/app
# copy our test application
COPY package.json package-lock.json .npmrc ./

# install NPM dependencies and Cypress binary
RUN npm ci

COPY app ./app
COPY cypress ./cypress
COPY serve.json \
     cypress.config.js \
     cypress ./

# avoid many lines of progress bars during install
# https://github.com/cypress-io/cypress/issues/1243
ENV CI=1

# check if the binary was installed successfully
RUN $(npm bin)/cypress verify

# --------------------

FROM node:16 AS unit

WORKDIR /app
COPY package.json package-lock.json .npmrc ./

ENV CYPRESS_INSTALL_BINARY=0

RUN npm ci

COPY app ./app
COPY .eslintrc \
     .eslintignore \
     .prettierrc.json \
     .prettierignore \
     serve.json ./
