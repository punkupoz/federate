#!/bin/bash

echo -en "\e[1;32m? \e[0mGateway port? [ 5000 ]:";
read GATE_WAY_PORT;
if [ -z "$GATE_WAY_PORT" ]; then
  GATE_WAY_PORT='5000';
fi

echo -en "\e[1;32m? \e[0mFirst service port? [ 5001 ]:";
read FIRST_SERVICE_PORT;
if [ -z "$FIRST_SERVICE_PORT" ]; then
  FIRST_SERVICE_PORT='5001';
fi

echo -en "\e[1;32m? \e[0mSecond service port? [ 5002 ]:";
read SECOND_SERVICE_PORT;
if [ -z "$SECOND_SERVICE_PORT" ]; then
  SECOND_SERVICE_PORT='5002';
fi

printf -- 'Creating gateway ...\n';
mkdir ${PROJECT_NAME} 2>/dev/null
if [ $? != 0 ]; then
  printf -- 'Folder exists\n';
  exit 2;
fi

. ./init/gateway/index.sh;

printf -- 'Creating services ...\n';
mkdir ./${PROJECT_NAME}/services
. ./init/services/post-service.sh
. ./init/services/account-service.sh
