#!/bin/bash

if [ ${#@} -ne 0 ] && [[ "${@#"--help"}" == "" ]]; then
  printf "Initiate template\n";
  printf "%s init\n\n" $NAME
  printf "Create or delete service\n";
  printf "%-10s %-10s %-30s\n" "CMD" "ARG" "DESCRIPTION";
  printf "%-10s %-10s %-30s\n" "service" "create" "create new service";
  printf "%-10s %-10s %-30s\n" "service" "delete" "delete a service";
  exit 0;
fi;