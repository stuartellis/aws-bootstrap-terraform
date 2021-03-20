#!/bin/bash

set -euo pipefail

AWS_CLI=aws

export TIMESTAMP=$(date +%Y-%m-%dT%H:%M%z)

if [ ! "${1:-}" ]; then 
  echo "Specify a subcommand."
  exit 1
fi

case $1 in
  info)
    $AWS_CLI --version
  ;;
  clean)
   [ -d "bin" ] && rm -r bin 
   [ -d "log" ] && rm -r log 
  ;;
  setup)
    [ -d "bin" ] || mkdir bin
    [ -d "log" ] || mkdir log
  ;;
  *)
    echo "$1 is not a valid command"
  ;;
esac
