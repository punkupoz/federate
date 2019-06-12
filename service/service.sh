#!/bin/bash
echo -en "\e[1;32m? \e[0mProject name?: ";
read PROJECT_NAME;
if [ -z "$PROJECT_NAME" ]; then
  echo 'Project name not provided'
  exit 127
fi
export PROJECT_NAME;

if [ ! -d "$PROJECT_NAME" ]; then
  echo 'Project not exists in current directory, exitting with code 127'
  exit 127
fi

. ./service/create.sh