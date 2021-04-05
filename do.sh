#!/bin/bash

set -euo pipefail

AWS_CLI=aws
PYTHON_EXE=python3

export AWS_PREFIX=stuartellis
export AWS_OPS_USER_NAME=stuart.ellis
export AWS_OPS_USER_EMAIL=stuart@stuartellis.name

export AWS_OPS_PROJECT=ops
export AWS_OPS_ENV=all

export AWS_MANAGED_PROJECT=longhouse
export AWS_MANAGED_ENV=dev

export AWS_OPS_ACCOUNT=119559809358
export AWS_MANAGED_ACCOUNT=333594256635

export AWS_OPS_ACCESS_CFN=cfn-interactive-ops-access-users.yaml
export AWS_OPS_EXEC_CFN=cfn-interactive-ops-exec-role.yaml

export AWS_TF_BACKEND_CFN=cfn-tf-backend.yaml
export AWS_TF_S3_BACKEND_EXPORT="$AWS_PREFIX-$AWS_MANAGED_PROJECT-tf-backend-$AWS_MANAGED_ENV-s3-state-$AWS_REGION"
export AWS_TF_DDB_BACKEND_EXPORT="$AWS_PREFIX-$AWS_MANAGED_PROJECT-tf-backend-$AWS_MANAGED_ENV-ddb-lock-$AWS_REGION"

export AWS_TF_EXEC_CFN=cfn-tf-exec-role.yaml
export AWS_TF_ACCESS_CFN=cfn-tf-access-users.yaml
export AWS_TF_EXEC_ROLE_NAME="$AWS_PREFIX-$AWS_MANAGED_PROJECT-tf-exec-$AWS_MANAGED_ENV"

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
  ops:access:create)
    aws cloudformation create-stack --capabilities CAPABILITY_NAMED_IAM --stack-name "$AWS_PREFIX-$AWS_OPS_PROJECT-iactive-ops-access-$AWS_OPS_ENV" --template-body file://"$PWD"/cloudformation/$AWS_OPS_ACCESS_CFN --parameters ParameterKey=UserName,ParameterValue="$AWS_OPS_USER_NAME" ParameterKey=UserEmail,ParameterValue="$AWS_OPS_USER_EMAIL" ParameterKey=Prefix,ParameterValue="$AWS_PREFIX" ParameterKey=ProjectName,ParameterValue="$AWS_OPS_PROJECT" ParameterKey=Environment,ParameterValue="$AWS_OPS_ENV" --tags Key=sje:ManagedBy,Value=CLI
  ;;
  ops:access:delete)
    aws cloudformation delete-stack --stack-name "$AWS_PREFIX-$AWS_OPS_PROJECT-iactive-ops-access-$AWS_OPS_ENV"
  ;;
  ops:access:update)
    aws cloudformation update-stack --capabilities CAPABILITY_NAMED_IAM --stack-name "$AWS_PREFIX-$AWS_OPS_PROJECT-iactive-ops-access-$AWS_OPS_ENV" --template-body file://"$PWD"/cloudformation/$AWS_OPS_ACCESS_CFN --parameters ParameterKey=UserName,ParameterValue="$AWS_OPS_USER_NAME" ParameterKey=UserEmail,ParameterValue="$AWS_OPS_USER_EMAIL" ParameterKey=Prefix,ParameterValue="$AWS_PREFIX" ParameterKey=ProjectName,ParameterValue="$AWS_OPS_PROJECT" ParameterKey=Environment,ParameterValue="$AWS_OPS_ENV" --tags Key=sje:ManagedBy,Value=CLI
  ;;
  ops:exec:create)
    aws cloudformation create-stack --capabilities CAPABILITY_NAMED_IAM --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-iactive-ops-exec-$AWS_MANAGED_ENV" --template-body file://"$PWD"/cloudformation/$AWS_OPS_EXEC_CFN --parameters ParameterKey=Prefix,ParameterValue="$AWS_PREFIX" ParameterKey=ProjectName,ParameterValue="$AWS_MANAGED_PROJECT" ParameterKey=Environment,ParameterValue="$AWS_MANAGED_ENV" ParameterKey=ManagingAccountID,ParameterValue="$AWS_OPS_ACCOUNT" --tags Key=sje:ManagedBy,Value=CLI
  ;;
  ops:exec:delete)
    aws cloudformation delete-stack --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-iactive-ops-exec-$AWS_MANAGED_ENV"
  ;;
  ops:exec:update)
    aws cloudformation update-stack --capabilities CAPABILITY_NAMED_IAM --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-iactive-ops-exec-$AWS_MANAGED_ENV" --template-body file://"$PWD"/cloudformation/$AWS_OPS_EXEC_CFN --parameters ParameterKey=Prefix,ParameterValue="$AWS_PREFIX" ParameterKey=ProjectName,ParameterValue="$AWS_MANAGED_PROJECT" ParameterKey=Environment,ParameterValue="$AWS_MANAGED_ENV" ParameterKey=ManagingAccountID,ParameterValue="$AWS_OPS_ACCOUNT" --tags Key=sje:ManagedBy,Value=CLI
  ;;
  tf:backend:create)
    aws cloudformation create-stack --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-tf-backend-$AWS_MANAGED_ENV" --template-body file://"$PWD"/cloudformation/$AWS_TF_BACKEND_CFN --parameters ParameterKey=Prefix,ParameterValue="$AWS_PREFIX" ParameterKey=ProjectName,ParameterValue="$AWS_MANAGED_PROJECT" ParameterKey=Environment,ParameterValue="$AWS_MANAGED_ENV" --tags Key=sje:ManagedBy,Value=CLI
  ;;
  tf:backend:delete)
    aws cloudformation delete-stack --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-tf-backend-$AWS_MANAGED_ENV"
  ;;
  tf:backend:update)
    aws cloudformation update-stack --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-tf-backend-$AWS_MANAGED_ENV" --template-body file://"$PWD"/cloudformation/$AWS_TF_BACKEND_CFN --parameters ParameterKey=Prefix,ParameterValue="$AWS_PREFIX" ParameterKey=ProjectName,ParameterValue="$AWS_MANAGED_PROJECT" ParameterKey=Environment,ParameterValue="$AWS_MANAGED_ENV" --tags Key=sje:ManagedBy,Value=CLI
  ;;
  tf:access:create)
    aws cloudformation create-stack --capabilities CAPABILITY_NAMED_IAM --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-tf-access-$AWS_MANAGED_ENV" --template-body file://"$PWD"/cloudformation/$AWS_TF_ACCESS_CFN --parameters ParameterKey=Prefix,ParameterValue="$AWS_PREFIX" ParameterKey=ProjectName,ParameterValue="$AWS_MANAGED_PROJECT" ParameterKey=Environment,ParameterValue="$AWS_MANAGED_ENV" ParameterKey=ManagedAccountID,ParameterValue="$AWS_MANAGED_ACCOUNT" ParameterKey=ManagedAccountID,ParameterValue="$AWS_OPS_ACCOUNT" ParameterKey=TfS3BackendImport,ParameterValue="$AWS_TF_S3_BACKEND_EXPORT" ParameterKey=TfDdbBackendImport,ParameterValue="$AWS_TF_DDB_BACKEND_EXPORT" --tags Key=sje:ManagedBy,Value=CLI
  ;;
  tf:access:delete)
    aws cloudformation delete-stack --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-tf-access-$AWS_MANAGED_ENV"
  ;;
  tf:access:update)
    aws cloudformation update-stack --capabilities CAPABILITY_NAMED_IAM --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-tf-access-$AWS_MANAGED_ENV" --template-body file://"$PWD"/cloudformation/$AWS_TF_ACCESS_CFN --parameters ParameterKey=Prefix,ParameterValue="$AWS_PREFIX" ParameterKey=ProjectName,ParameterValue="$AWS_MANAGED_PROJECT" ParameterKey=Environment,ParameterValue="$AWS_MANAGED_ENV" ParameterKey=ManagedAccountID,ParameterValue="$AWS_MANAGED_ACCOUNT" ParameterKey=TfExecRoleName,ParameterValue="$AWS_TF_EXEC_ROLE_NAME" --tags Key=sje:ManagedBy,Value=CLI
  ;;
  tf:exec:create)
    aws cloudformation create-stack --capabilities CAPABILITY_NAMED_IAM --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-tf-exec-$AWS_MANAGED_ENV" --template-body file://"$PWD"/cloudformation/$AWS_TF_EXEC_CFN --parameters ParameterKey=Prefix,ParameterValue="$AWS_PREFIX" ParameterKey=ProjectName,ParameterValue="$AWS_MANAGED_PROJECT" ParameterKey=Environment,ParameterValue="$AWS_MANAGED_ENV" ParameterKey=ManagingAccountID,ParameterValue="$AWS_OPS_ACCOUNT" --tags Key=sje:ManagedBy,Value=CLI
  ;;
  tf:exec:delete)
    aws cloudformation delete-stack --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-tf-exec-$AWS_MANAGED_ENV"
  ;;
  tf:exec:update)
    aws cloudformation update-stack --capabilities CAPABILITY_NAMED_IAM --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-tf-exec-$AWS_MANAGED_ENV" --template-body file://"$PWD"/cloudformation/$AWS_TF_EXEC_CFN --parameters ParameterKey=Prefix,ParameterValue="$AWS_PREFIX" ParameterKey=ProjectName,ParameterValue="$AWS_MANAGED_PROJECT" ParameterKey=Environment,ParameterValue="$AWS_MANAGED_ENV" ParameterKey=ManagingAccountID,ParameterValue="$AWS_OPS_ACCOUNT" --tags Key=sje:ManagedBy,Value=CLI
  ;;
  validate)
    CFN_TEMPLATES=$(ls "$PWD"/cloudformation/*.yaml)
    for CFN_TEMPLATE in $CFN_TEMPLATES; do
      aws cloudformation validate-template --template-body file://"$CFN_TEMPLATE" > /dev/null
    done
  ;;
  *)
    echo "$1 is not a valid command"
  ;;
esac
