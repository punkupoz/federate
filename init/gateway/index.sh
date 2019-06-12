#!/bin/sh

cat > ./${PROJECT_NAME}/index.js <<EOF
// const { ApolloServer } = require('apollo-server')
const { ApolloServer } = require('apollo-server-express')
const { ApolloGateway } = require('@apollo/gateway')
const express = require('express')

const serviceList = [
  { name: 'account-service', url: 'http://localhost:${FIRST_SERVICE_PORT}/graphql' },
  { name: 'post-service', url: 'http://localhost:${SECOND_SERVICE_PORT}/graphql' },
]
const gateway = new ApolloGateway({ serviceList })

;(async () => {
  const { schema, executor } = await gateway.load()

  const server = new ApolloServer({
    schema, executor,
    tracing: true
  })
  const app = express()

  app.get('/serviceList', (req, res) => {
    res.send(serviceList)
  })

  server.applyMiddleware({ app, path: '/' })

  app
    .listen(${GATE_WAY_PORT}, () => console.log(\`Server ready at http://localhost:${GATE_WAY_PORT}\`))
    // .then(({ url }) => {
    //
    // })
})()
EOF

cat > ./${PROJECT_NAME}/package.json <<EOF
{
  "name": "gateway",
  "version": "1.0.0",
  "main": "index.js",
  "license": "MIT",
  "dependencies": {
    "@apollo/gateway": "^0.6.5",
    "apollo-server-express": "^2.6.2",
    "express": "^4.17.1",
    "graphql": "^14.3.1"
  }
}
EOF

echo 'Installing dependencies for gate-way'
( cd ./${PROJECT_NAME} && yarn )