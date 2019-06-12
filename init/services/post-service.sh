#!/bin/sh
#
mkdir -p ./${PROJECT_NAME}/services/post-service/post-db;
mkdir -p ./${PROJECT_NAME}/services/post-service/src;

cat > ./${PROJECT_NAME}/services/post-service/package.json <<EOF
{
  "name": "post-service",
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

echo 'Installing dependencies for post-service'

( cd ./${PROJECT_NAME}/services/post-service && yarn )

cat > ./${PROJECT_NAME}/services/post-service/index.js <<EOF
const { ApolloServer } = require('apollo-server')
const { buildFederatedSchema } = require('@apollo/federation')
const { prisma } = require('./post-db/generated/prisma-client')

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
  .listen({ port: ${SECOND_SERVICE_PORT} })
  .then(({ url }) => {
    console.log(\`Server ready at ${SECOND_SERVICE_PORT}\`)
  })
EOF

cat > ./${PROJECT_NAME}/services/post-service/src/schema.js <<EOF
const { ApolloServer, gql } = require('apollo-server')

module.exports = gql\`
  extend type Query {
    posts: [Post!]!
  }

  type Post @key(fields: "id") {
    id: ID!
    title: String
    content: String

    author: User
  }

  extend type User @key(fields: "id") {
    id: ID! @external

    posts: [Post!]!
  }
\`
EOF

cat > ./${PROJECT_NAME}/services/post-service/src/resolvers.js <<EOF
module.exports = {
  Query: {
    posts: (_, args, ctx) => ctx.db.posts()
  },
  Post: {
    author: (_, args, ctx) => ({ __typename: 'User', id: _.authorId })
  },
  User: {
    posts: (_, args, ctx) => ctx.db.posts({
      where: {
        authorId: _.id
      }
    })
  }
}
EOF

cat > ./${PROJECT_NAME}/services/post-service/post-db/docker-compose.yml <<EOF
version: '3'
services:
  prisma:
    image: prismagraphql/prisma:1.34
    restart: always
    ports:
    - "4467:4466"
    environment:
      PRISMA_CONFIG: |
        port: 4466
        # uncomment the next line and provide the env var PRISMA_MANAGEMENT_API_SECRET=my-secret to activate cluster security
        # managementApiSecret: my-secret
        databases:
          default:
            connector: mysql
            host: mysql
            user: root
            password: prisma
            rawAccess: true
            port: 3306
            migrations: true
  mysql:
    image: mysql:5.7
    restart: always
    # Uncomment the next two lines to connect to your your database from outside the Docker environment, e.g. using a database GUI like Workbench
    # ports:
    # - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: prisma
    volumes:
      - mysql:/var/lib/mysql
volumes:
  mysql:
EOF

cat > ./${PROJECT_NAME}/services/post-service/post-db/prisma.yml <<EOF
endpoint: http://localhost:4467
datamodel: datamodel.prisma

generate:
  - generator: javascript-client
    output: ./generated/prisma-client/
EOF

cat > ./${PROJECT_NAME}/services/post-service/post-db/datamodel.prisma <<EOF
type Post {
  id: ID! @id
  title: String
  content: String

  authorId: ID!
}
EOF