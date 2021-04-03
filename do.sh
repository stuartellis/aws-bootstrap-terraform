#!/bin/bash

set -euo pipefail

AWS_CLI=aws
PYTHON_EXE=python3

export TIMESTAMP=$(date +%Y-%m-%dT%H:%M%z)
export AWS_PREFIX=stuartellis
export AWS_PROJECT=longhouse
export AWS_ENV=dev
export AWS_TF_BACKEND_CFN=cfn-tf-backend.yaml
export AWS_TF_USERS_CFN=cfn-tf-users.yaml

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
  backend:create)
    aws cloudformation create-stack --stack-name "$AWS_PREFIX-$AWS_PROJECT-tfstate-$AWS_ENV" --template-body file://"$PWD"/cloudformation/$AWS_TF_BACKEND_CFN --parameters ParameterKey=Prefix,ParameterValue="$AWS_PREFIX" ParameterKey=ProjectName,ParameterValue="$AWS_PROJECT" ParameterKey=Environment,ParameterValue="$AWS_ENV" --tags Key=ManagedBy,Value=CLI
  ;;
  backend:delete)
    aws cloudformation delete-stack --stack-name "$AWS_PREFIX-$AWS_PROJECT-tfstate-$AWS_ENV"
  ;;
  backend:update)
    aws cloudformation update-stack --stack-name "$AWS_PREFIX-$AWS_PROJECT-tfstate-$AWS_ENV" --template-body file://"$PWD"/cloudformation/$AWS_TF_BACKEND_CFN --parameters ParameterKey=Prefix,ParameterValue="$AWS_PREFIX" ParameterKey=ProjectName,ParameterValue="$AWS_PROJECT" ParameterKey=Environment,ParameterValue="$AWS_ENV" --tags Key=ManagedBy,Value=CLI
  ;;
  backend:validate)
    aws cloudformation validate-template --template-body file://"$PWD"/cloudformation/$AWS_TF_BACKEND_CFN > /dev/null
  ;;
  users:create)
    aws cloudformation create-stack --capabilities CAPABILITY_NAMED_IAM --stack-name "$AWS_PREFIX-$AWS_PROJECT-tfusers-$AWS_ENV" --template-body file://"$PWD"/cloudformation/$AWS_TF_USERS_CFN --parameters ParameterKey=Prefix,ParameterValue="$AWS_PREFIX" ParameterKey=ProjectName,ParameterValue="$AWS_PROJECT" ParameterKey=Environment,ParameterValue="$AWS_ENV" --tags Key=ManagedBy,Value=CLI
  ;;
  users:delete)
    aws cloudformation delete-stack --stack-name "$AWS_PREFIX-$AWS_PROJECT-tfusers-$AWS_ENV"
  ;;
  users:update)
    aws cloudformation update-stack --capabilities CAPABILITY_NAMED_IAM --stack-name "$AWS_PREFIX-$AWS_PROJECT-tfusers-$AWS_ENV" --template-body file://"$PWD"/cloudformation/$AWS_TF_USERS_CFN --parameters ParameterKey=Prefix,ParameterValue="$AWS_PREFIX" ParameterKey=ProjectName,ParameterValue="$AWS_PROJECT" ParameterKey=Environment,ParameterValue="$AWS_ENV" --tags Key=ManagedBy,Value=CLI
  ;;
  users:validate)
    aws cloudformation validate-template --template-body file://"$PWD"/cloudformation/$AWS_TF_USERS_CFN > /dev/null
  ;;
  *)
    echo "$1 is not a valid command"
  ;;
esac
