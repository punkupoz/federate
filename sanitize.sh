#!/bin/bash

_=$(command -v docker);
if [ "$?" != "0" ]; then
  printf -- "You don't seem to have Docker installed.\n";
  printf -- "Get it: https://www.docker.com/community-edition\n";
  printf -- "Exiting with code 127...\n";
  exit 127;
fi;

_=$(command -v node);
if [ "$?" != "0" ]; then
  printf -- "You don't seem to have Docker installed.\n";
  printf -- "Get it: https://nodejs.org/en/\n";
  printf -- "Exiting with code 127...\n";
  exit 127;
fi;

_=$(command -v prisma);
if [ "$?" != "0" ]; then
  printf -- "You don't seem to have Docker installed.\n";
  printf -- "Get it: https://www.prisma.io/\n";
  printf -- "Exiting with code 127...\n";
  exit 127;
fi;

_=$(command -v yarn);
if [ "$?" != "0" ]; then
  printf -- "You don't seem to have Docker installed.\n";
  printf -- "Get it: https://yarnpkg.com/en/\n";
  printf -- "Exiting with code 127...\n";
  exit 127;
fi;
