#!/bin/bash

set -euo pipefail

## Project variables

export AWS_PREFIX=stuart-ellis
export AWS_OPS_USER_NAME=stuart.ellis
export AWS_OPS_USER_EMAIL=stuart@stuartellis.name

export AWS_OPS_PROJECT=ops
export AWS_OPS_ENV=all

export AWS_MANAGED_PROJECT=longhouse
export AWS_MANAGED_ENV=dev

export AWS_OPS_ACCOUNT=119559809358
export AWS_MANAGED_ACCOUNT=333594256635

## Constants

AWS_CLI=aws

export AWS_OPS_ACCESS_CFN=cfn-interactive-ops-access-users.yaml
export AWS_OPS_EXEC_CFN=cfn-interactive-ops-exec-role.yaml

export AWS_TF_BACKEND_CFN=cfn-tf-backend.yaml
export AWS_TF_KMS_BACKEND_EXPORT="$AWS_PREFIX-$AWS_MANAGED_PROJECT-$AWS_MANAGED_ENV-tf-statekey-kms-key-arn"
export AWS_TF_S3_BACKEND_EXPORT="$AWS_PREFIX-$AWS_MANAGED_PROJECT-$AWS_MANAGED_ENV-tf-backend-s3-state-arn"
export AWS_TF_DDB_BACKEND_EXPORT="$AWS_PREFIX-$AWS_MANAGED_PROJECT-$AWS_MANAGED_ENV-tf-backend-ddb-lock-arn"

export AWS_TF_EXEC_CFN=cfn-tf-exec-role.yaml
export AWS_TF_ACCESS_CFN=cfn-tf-access-users.yaml
export AWS_TF_KMS_CFN=cfn-tf-kms-keys.yaml
export AWS_TF_EXEC_ROLE_ARN="arn:aws:iam::$AWS_MANAGED_ACCOUNT:role/$AWS_PREFIX-$AWS_MANAGED_PROJECT-$AWS_MANAGED_ENV-tf-exec"

if [ ! "${1:-}" ]; then 
  echo "Specify a subcommand."
  exit 1
fi

case $1 in
  info)
    which $AWS_CLI
    $AWS_CLI --version
  ;;
  ops:access:create)
    aws cloudformation create-stack --capabilities CAPABILITY_NAMED_IAM --stack-name "$AWS_PREFIX-$AWS_OPS_PROJECT-$AWS_OPS_ENV-iactive-ops-access" --template-body file://"$PWD"/cloudformation/$AWS_OPS_ACCESS_CFN --parameters ParameterKey=UserName,ParameterValue="$AWS_OPS_USER_NAME" ParameterKey=UserEmail,ParameterValue="$AWS_OPS_USER_EMAIL" ParameterKey=Prefix,ParameterValue="$AWS_PREFIX" ParameterKey=ProjectName,ParameterValue="$AWS_OPS_PROJECT" ParameterKey=Environment,ParameterValue="$AWS_OPS_ENV" --tags Key=sje:managed-by,Value=CLI
  ;;
  ops:access:delete)
    aws cloudformation delete-stack --stack-name "$AWS_PREFIX-$AWS_OPS_PROJECT-$AWS_OPS_ENV-iactive-ops-access"
  ;;
  ops:access:update)
    aws cloudformation update-stack --capabilities CAPABILITY_NAMED_IAM --stack-name "$AWS_PREFIX-$AWS_OPS_PROJECT-$AWS_OPS_ENV-iactive-ops-access" --template-body file://"$PWD"/cloudformation/$AWS_OPS_ACCESS_CFN --parameters ParameterKey=UserName,ParameterValue="$AWS_OPS_USER_NAME" ParameterKey=UserEmail,ParameterValue="$AWS_OPS_USER_EMAIL" ParameterKey=Prefix,ParameterValue="$AWS_PREFIX" ParameterKey=ProjectName,ParameterValue="$AWS_OPS_PROJECT" ParameterKey=Environment,ParameterValue="$AWS_OPS_ENV" --tags Key=sje:managed-by,Value=CLI
  ;;
  ops:exec:create)
    aws cloudformation create-stack --capabilities CAPABILITY_NAMED_IAM --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-$AWS_MANAGED_ENV-iactive-ops-exec" --template-body file://"$PWD"/cloudformation/$AWS_OPS_EXEC_CFN --parameters ParameterKey=Prefix,ParameterValue="$AWS_PREFIX" ParameterKey=ProjectName,ParameterValue="$AWS_MANAGED_PROJECT" ParameterKey=Environment,ParameterValue="$AWS_MANAGED_ENV" ParameterKey=ManagingAccountID,ParameterValue="$AWS_OPS_ACCOUNT" --tags Key=sje:managed-by,Value=CLI
  ;;
  ops:exec:delete)
    aws cloudformation delete-stack --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-$AWS_MANAGED_ENV-iactive-ops-exec"
  ;;
  ops:exec:update)
    aws cloudformation update-stack --capabilities CAPABILITY_NAMED_IAM --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-$AWS_MANAGED_ENV-iactive-ops-exec" --template-body file://"$PWD"/cloudformation/$AWS_OPS_EXEC_CFN --parameters ParameterKey=Prefix,ParameterValue="$AWS_PREFIX" ParameterKey=ProjectName,ParameterValue="$AWS_MANAGED_PROJECT" ParameterKey=Environment,ParameterValue="$AWS_MANAGED_ENV" ParameterKey=ManagingAccountID,ParameterValue="$AWS_OPS_ACCOUNT" --tags Key=sje:managed-by,Value=CLI
  ;;
  tf:access:create)
    aws cloudformation create-stack --capabilities CAPABILITY_NAMED_IAM --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-$AWS_MANAGED_ENV-tf-access" --template-body file://"$PWD"/cloudformation/$AWS_TF_ACCESS_CFN --parameters ParameterKey=Prefix,ParameterValue="$AWS_PREFIX" ParameterKey=ProjectName,ParameterValue="$AWS_MANAGED_PROJECT" ParameterKey=Environment,ParameterValue="$AWS_MANAGED_ENV" ParameterKey=TfExecRoleArn,ParameterValue="$AWS_TF_EXEC_ROLE_ARN" ParameterKey=TfKmsKeyBackendImport,ParameterValue="$AWS_TF_KMS_BACKEND_EXPORT" ParameterKey=TfS3BackendImport,ParameterValue="$AWS_TF_S3_BACKEND_EXPORT" ParameterKey=TfDdbBackendImport,ParameterValue="$AWS_TF_DDB_BACKEND_EXPORT" --tags Key=sje:managed-by,Value=CLI
  ;;
  tf:access:delete)
    aws cloudformation delete-stack --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-$AWS_MANAGED_ENV-tf-access"
  ;;
  tf:access:update)
    aws cloudformation update-stack --capabilities CAPABILITY_NAMED_IAM --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-$AWS_MANAGED_ENV-tf-access" --template-body file://"$PWD"/cloudformation/$AWS_TF_ACCESS_CFN --parameters ParameterKey=Prefix,ParameterValue="$AWS_PREFIX" ParameterKey=ProjectName,ParameterValue="$AWS_MANAGED_PROJECT" ParameterKey=Environment,ParameterValue="$AWS_MANAGED_ENV" ParameterKey=TfExecRoleArn,ParameterValue="$AWS_TF_EXEC_ROLE_ARN" ParameterKey=TfKmsKeyBackendImport,ParameterValue="$AWS_TF_KMS_BACKEND_EXPORT" ParameterKey=TfS3BackendImport,ParameterValue="$AWS_TF_S3_BACKEND_EXPORT" ParameterKey=TfDdbBackendImport,ParameterValue="$AWS_TF_DDB_BACKEND_EXPORT" --tags Key=sje:managed-by,Value=CLI
  ;;
  tf:backend:create)
    aws cloudformation create-stack --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-$AWS_MANAGED_ENV-tf-backend" --template-body file://"$PWD"/cloudformation/$AWS_TF_BACKEND_CFN --parameters ParameterKey=Prefix,ParameterValue="$AWS_PREFIX" ParameterKey=ProjectName,ParameterValue="$AWS_MANAGED_PROJECT" ParameterKey=Environment,ParameterValue="$AWS_MANAGED_ENV" ParameterKey=TfKmsKeyBackendImport ParameterValue="$AWS_TF_KMS_BACKEND_EXPORT" --tags Key=sje:managed-by,Value=CLI
  ;;
  tf:backend:delete)
    aws cloudformation delete-stack --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-$AWS_MANAGED_ENV-tf-backend"
  ;;
  tf:backend:update)
    aws cloudformation update-stack --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-$AWS_MANAGED_ENV-tf-backend" --template-body file://"$PWD"/cloudformation/$AWS_TF_BACKEND_CFN --parameters ParameterKey=Prefix,ParameterValue="$AWS_PREFIX" ParameterKey=ProjectName,ParameterValue="$AWS_MANAGED_PROJECT" ParameterKey=Environment,ParameterValue="$AWS_MANAGED_ENV" ParameterKey=KmsKeyImport,ParameterValue="$AWS_TF_KMS_BACKEND_EXPORT" --tags Key=sje:managed-by,Value=CLI
  ;;
  tf:exec:create)
    aws cloudformation create-stack --capabilities CAPABILITY_NAMED_IAM --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-$AWS_MANAGED_ENV-tf-exec" --template-body file://"$PWD"/cloudformation/$AWS_TF_EXEC_CFN --parameters ParameterKey=Prefix,ParameterValue="$AWS_PREFIX" ParameterKey=ProjectName,ParameterValue="$AWS_MANAGED_PROJECT" ParameterKey=Environment,ParameterValue="$AWS_MANAGED_ENV" ParameterKey=ManagingAccountID,ParameterValue="$AWS_OPS_ACCOUNT" --tags Key=sje:managed-by,Value=CLI
  ;;
  tf:exec:delete)
    aws cloudformation delete-stack --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-$AWS_MANAGED_ENV-tf-exec"
  ;;
  tf:exec:update)
    aws cloudformation update-stack --capabilities CAPABILITY_NAMED_IAM --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-$AWS_MANAGED_ENV-tf-exec" --template-body file://"$PWD"/cloudformation/$AWS_TF_EXEC_CFN --parameters ParameterKey=Prefix,ParameterValue="$AWS_PREFIX" ParameterKey=ProjectName,ParameterValue="$AWS_MANAGED_PROJECT" ParameterKey=Environment,ParameterValue="$AWS_MANAGED_ENV" ParameterKey=ManagingAccountID,ParameterValue="$AWS_OPS_ACCOUNT" --tags Key=sje:managed-by,Value=CLI
  ;;
  tf:kms:create)
    aws cloudformation create-stack --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-$AWS_MANAGED_ENV-tf-statekey" --template-body file://"$PWD"/cloudformation/$AWS_TF_KMS_CFN --parameters ParameterKey=Prefix,ParameterValue="$AWS_PREFIX" ParameterKey=ProjectName,ParameterValue="$AWS_MANAGED_PROJECT" ParameterKey=ServiceName,ParameterValue=s3 ParameterKey=Environment,ParameterValue="$AWS_MANAGED_ENV" --tags Key=sje:managed-by,Value=CLI
  ;;
  tf:kms:delete)
    aws cloudformation delete-stack --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-$AWS_MANAGED_ENV-tf-statekey"
  ;;
  tf:kms:update)
    aws cloudformation update-stack --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-$AWS_MANAGED_ENV-tf-statekey" --template-body file://"$PWD"/cloudformation/$AWS_TF_KMS_CFN --parameters ParameterKey=Prefix,ParameterValue="$AWS_PREFIX" ParameterKey=ProjectName,ParameterValue="$AWS_MANAGED_PROJECT" ParameterKey=ServiceName,ParameterValue=s3 ParameterKey=Environment,ParameterValue="$AWS_MANAGED_ENV" --tags Key=sje:managed-by,Value=CLI
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
