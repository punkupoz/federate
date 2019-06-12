#!/bin/bash

NAME="neko"
. ./help.sh
. ./sanitize.sh

echo -en "\e[1;32m? \e[0mProject name?: ";
read PROJECT_NAME;
if [ -z "$PROJECT_NAME" ]; then
  PROJECT_NAME='neko';
fi
export PROJECT_NAME;

if [ ! -d "$PROJECT_NAME" ]; then
  echo 'Project not exists in current directory, exitting with code 127'
  exit 127
fi

case $1 in
  init)
    . ./init/init.sh;;
  service)
    . ./service/service.sh;;
  *)
    echo '--help for more information';;
esac