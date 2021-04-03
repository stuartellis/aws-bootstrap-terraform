#!/bin/bash

set -euo pipefail

AWS_CLI=aws
PYTHON_EXE=python3

export TIMESTAMP=$(date +%Y-%m-%dT%H:%M%z)
export AWS_PREFIX=stuartellis
export AWS_PROJECT=longhouse
export AWS_ENV=dev

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
  create)
    aws cloudformation create-stack --stack-name "$AWS_PREFIX-$AWS_PROJECT-$AWS_ENV" --template-body file://"$PWD"/cloudformation/cfn-tf-backend.yaml --parameters ParameterKey=Prefix,ParameterValue="$AWS_PREFIX" ParameterKey=ProjectName,ParameterValue="$AWS_PROJECT" ParameterKey=Environment,ParameterValue="$AWS_ENV" --tags Key=ManagedBy,Value=CLI
  ;;
  destroy)
    aws cloudformation delete-stack --stack-name "$AWS_PREFIX-$AWS_PROJECT-$AWS_ENV"
  ;;
  update)
    aws cloudformation update-stack --stack-name "$AWS_PREFIX-$AWS_PROJECT-$AWS_ENV" --template-body file://"$PWD"/cloudformation/cfn-tf-backend.yaml --parameters ParameterKey=Prefix,ParameterValue="$AWS_PREFIX" ParameterKey=ProjectName,ParameterValue="$AWS_PROJECT" ParameterKey=Environment,ParameterValue="$AWS_ENV" --tags Key=ManagedBy,Value=CLI
  ;;
  validate)
    aws cloudformation validate-template --template-body file://"$PWD"/cloudformation/cfn-tf-backend.yaml > /dev/null
  ;;
  *)
    echo "$1 is not a valid command"
  ;;
esac
