#!/bin/bash

echo -en "\e[1;32m? \e[0mService name? [ neko ]:";
read SERVICE_NAME;
if [ -z "$SERVICE_NAME" ]; then
  SERVICE_NAME='neko';
fi

echo -en "\e[1;32m? \e[0mService port? [ 5003 ]:";
read SERVICE_PORT;
if [ -z "$SERVICE_PORT" ]; then
  SERVICE_PORT='5003';
fi

echo "asd $PROJECT_NAME"

mkdir -p ./${PROJECT_NAME}/services/${SERVICE_NAME}/${SERVICE_NAME}-db;
mkdir -p ./${PROJECT_NAME}/services/${SERVICE_NAME}/src;

cat > ./${PROJECT_NAME}/services/${SERVICE_NAME}/package.json <<EOF
{
  "name": "${SERVICE_NAME}",
  "version": "1.0.0",
  "main": "index.js",
  "license": "MIT",
  "dependencies": {
    "@apollo/federation": "^0.6.2",
    "apollo-server": "^2.6.2",
    "graphql": "^14.3.1",
    "prisma-client-lib": "^1.34.0"
  }
}
EOF

echo "Installing dependencies for ${SERVICE_NAME}"

( cd ./${PROJECT_NAME}/services/${SERVICE_NAME} && yarn )

cat > ./${PROJECT_NAME}/services/${SERVICE_NAME}/index.js <<EOF
const { ApolloServer } = require('apollo-server')
const { buildFederatedSchema } = require('@apollo/federation')
const { prisma } = require('./${SERVICE_NAME}-db/generated/prisma-client')

const resolvers = require('./src/resolvers')
const typeDefs = require('./src/schema')

const server = new ApolloServer({
  schema: buildFederatedSchema([{ typeDefs, resolvers }]),
  context: req => ({
    ...req,
    db: prisma
  })
})

server
  .listen({ port: ${FIRST_SERVICE_PORT} })
  .then(({ url }) => {
    console.log(\`Server ready at ${FIRST_SERVICE_PORT}\`)
  })
EOF

cat > ./${PROJECT_NAME}/services/${SERVICE_NAME}/src/schema.js <<EOF
const { ApolloServer, gql } = require('apollo-server')

module.exports = gql\`
  extend type Query {
    me: User
  }

  type User @key(fields: "id") {
    id: ID!

    email: String!
    name: String
  }
\`
EOF

cat > ./${PROJECT_NAME}/services/${SERVICE_NAME}/src/resolvers.js <<EOF
module.exports = {
  Query: {
    me: (_, args, ctx) => ctx.db.user({ email: 'beatyshot@gmail.com' })
  },
  User: {
    __resolveReference: (_, args) => args.db.user({ id: _.id })
  }
}
EOF

cat > ./${PROJECT_NAME}/services/${SERVICE_NAME}/${SERVICE_NAME}-db/docker-compose.yml <<EOF
version: '3'
services:
  prisma:
    image: prismagraphql/prisma:1.34
    restart: always
    ports:
    - "4466:4466"
    environment:
      PRISMA_CONFIG: |
        port: 4466
        # uncomment the next line and provide the env var PRISMA_MANAGEMENT_API_SECRET=my-secret to activate cluster security
        # managementApiSecret: my-secret
        databases:
          default:
            connector: postgres
            host: postgres
            user: prisma
            password: prisma
            rawAccess: true
            port: 5432
            migrations: true
  postgres:
    image: postgres
    restart: always
    # Uncomment the next two lines to connect to your your database from outside the Docker environment, e.g. using a database GUI like Postico
    # ports:
    # - "5432:5432"
    environment:
      POSTGRES_USER: prisma
      POSTGRES_PASSWORD: prisma
    volumes:
      - postgres:/var/lib/postgresql/data
volumes:
  postgres:
EOF

cat > ./${PROJECT_NAME}/services/${SERVICE_NAME}/${SERVICE_NAME}-db/prisma.yml <<EOF
endpoint: http://localhost:4466
datamodel: datamodel.prisma

generate:
  - generator: javascript-client
    output: ./generated/prisma-client/
EOF

cat > ./${PROJECT_NAME}/services/${SERVICE_NAME}/${SERVICE_NAME}-db/datamodel.prisma <<EOF
type User {
  id: ID! @id

  email: String! @unique
  name: String
}
EOF

sed -i "/const serviceList = \[/ a\
    { name: '${SERVICE_NAME}', url: 'http://localhost:${SERVICE_PORT}/graphql' },
" ./${PROJECT_NAME}/index.js