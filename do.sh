#!/bin/bash

set -euo pipefail

AWS_CLI=aws
PYTHON_EXE=python3

export TIMESTAMP=$(date +%Y-%m-%dT%H:%M%z)

if [ ! "${1:-}" ]; then 
  echo "Specify a subcommand."
  exit 1
fi

case $1 in
  info)
    which $AWS_CLI
    which $PYTHON_EXE
    $AWS_CLI --version
  ;;
  clean)
   [ -d "bin" ] && rm -r bin 
   [ -d "log" ] && rm -r log
   [ -d ".venv" ] && rm -r .venv  
  ;;
  setup)
    [ -d "bin" ] || mkdir bin
    [ -d "log" ] || mkdir log
    [ -d ".venv" ] || python3 -m venv .venv
  ;;
  run)
    aws cloudformation validate-template --template-body file://"$PWD"/cloudformation/cfn-tf-backend.yaml > /dev/null
  ;;
  *)
    echo "$1 is not a valid command"
  ;;
esac
