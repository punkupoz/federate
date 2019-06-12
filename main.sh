#!/bin/bash

NAME="neko"
. ./help.sh
. ./sanitize.sh

TAB=$'\t'

case $1 in
  init)
    . ./init/init.sh;;
  service)
    . ./service/service.sh;;
  *)
    echo '--help for more information';;
esac