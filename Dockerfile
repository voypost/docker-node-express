FROM node:12-alpine

# can be deleted, `timezone` lib should contain it, to test
RUN apk add --no-cache tzdata
# for installing packages from git repos
RUN apk add --update make git

ONBUILD ARG NODE_ENV=development

ONBUILD ARG RUN_ESLINT=false
ONBUILD ARG RUN_JEST=false

ONBUILD ARG DATABASE_HOST
ONBUILD ARG DATABASE_PORT
ONBUILD ARG DATABASE_NAME
ONBUILD ARG DATABASE_NAME_TEST_SUFFIX
ONBUILD ARG DATABASE_USER
ONBUILD ARG DATABASE_PASSWORD

ONBUILD ARG TEST_ENV="\
DATABASE_HOST=$DATABASE_HOST \
DATABASE_PORT=$DATABASE_PORT \
DATABASE_NAME=$DATABASE_NAME \
DATABASE_NAME_TEST_SUFFIX=$DATABASE_NAME_TEST_SUFFIX \
DATABASE_USER=$DATABASE_USER \
DATABASE_PASSWORD=$DATABASE_PASSWORD"

RUN mkdir -p /usr/app
WORKDIR /usr/app

ONBUILD COPY --from=installer /usr/app/node_modules ./node_modules
ONBUILD COPY --from=installer /usr/app/package.json ./
ONBUILD COPY --from=installer /usr/app/yarn.lock ./
ONBUILD COPY --from=installer /usr/app/.npmrc ./
ONBUILD COPY --from=installer /usr/app/.yarnrc ./
ONBUILD RUN NODE_ENV=development yarn install

ONBUILD COPY babel.config.js ./
ONBUILD COPY jest.config.js ./
ONBUILD COPY .env.test ./
ONBUILD COPY data ./data
ONBUILD COPY src ./src
ONBUILD COPY tests ./tests

# Run ESLint
ONBUILD RUN sh -c "if [ $RUN_ESLINT == true ]; then yarn lint; else true; fi"

# Run Jest
ONBUILD RUN sh -c "if [ $RUN_JEST == true ]; then $TEST_ENV yarn test; else true; fi"

ONBUILD RUN NODE_ENV=$NODE_ENV yarn build
