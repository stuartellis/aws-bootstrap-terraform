#!/bin/bash

set -euo pipefail

## Project variables

export AWS_PREFIX=stuartellis
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
  ops:access:deploy)
    aws cloudformation deploy --capabilities CAPABILITY_NAMED_IAM --stack-name "$AWS_PREFIX-$AWS_OPS_PROJECT-$AWS_OPS_ENV-manual-ops-access" --template-file "$PWD"/cloudformation/$AWS_OPS_ACCESS_CFN --parameter-overrides UserEmail=$AWS_OPS_USER_EMAIL UserName=$AWS_OPS_USER_NAME Prefix=$AWS_PREFIX ProjectName=$AWS_OPS_PROJECT Environment=$AWS_OPS_ENV --tags sje:managed-by=CLI
  ;;
  ops:access:delete)
    aws cloudformation delete-stack --stack-name "$AWS_PREFIX-$AWS_OPS_PROJECT-$AWS_OPS_ENV-manual-ops-access"
  ;;
  ops:exec:deploy)
    aws cloudformation deploy --capabilities CAPABILITY_NAMED_IAM --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-$AWS_MANAGED_ENV-manual-ops-exec" --template-file "$PWD"/cloudformation/$AWS_OPS_EXEC_CFN --parameter-overrides Prefix=$AWS_PREFIX ProjectName=$AWS_MANAGED_PROJECT Environment=$AWS_MANAGED_ENV ManagingAccountID=$AWS_OPS_ACCOUNT --tags sje:managed-by=CLI
  ;;
  ops:exec:delete)
    aws cloudformation delete-stack --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-$AWS_MANAGED_ENV-manual-ops-exec"
  ;;
  tf:access:deploy)
    aws cloudformation deploy --capabilities CAPABILITY_NAMED_IAM --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-$AWS_MANAGED_ENV-tf-access" --template-file "$PWD"/cloudformation/$AWS_TF_ACCESS_CFN --parameter-overrides Prefix=$AWS_PREFIX ProjectName=$AWS_MANAGED_PROJECT Environment=$AWS_MANAGED_ENV TfExecRoleArn=$AWS_TF_EXEC_ROLE_ARN TfKmsKeyBackendImport=$AWS_TF_KMS_BACKEND_EXPORT TfS3BackendImport=$AWS_TF_S3_BACKEND_EXPORT TfDdbBackendImport=$AWS_TF_DDB_BACKEND_EXPORT --tags sje:managed-by=CLI
  ;;
  tf:access:delete)
    aws cloudformation delete-stack --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-$AWS_MANAGED_ENV-tf-access"
  ;;
  tf:backend:deploy)
    aws cloudformation deploy --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-$AWS_MANAGED_ENV-tf-backend" --template-file "$PWD"/cloudformation/$AWS_TF_BACKEND_CFN --parameter-overrides Prefix=$AWS_PREFIX ProjectName=$AWS_MANAGED_PROJECT Environment=$AWS_MANAGED_ENV KmsKeyImport=$AWS_TF_KMS_BACKEND_EXPORT --tags sje:managed-by=CLI
  ;;
  tf:backend:delete)
    aws cloudformation delete-stack --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-$AWS_MANAGED_ENV-tf-backend"
  ;;
  tf:exec:deploy)
    aws cloudformation deploy --capabilities CAPABILITY_NAMED_IAM --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-$AWS_MANAGED_ENV-tf-exec" --template-file "$PWD"/cloudformation/$AWS_TF_EXEC_CFN --parameter-overrides Prefix=$AWS_PREFIX ProjectName=$AWS_MANAGED_PROJECT Environment=$AWS_MANAGED_ENV ManagingAccountID=$AWS_OPS_ACCOUNT --tags sje:managed-by=CLI
  ;;
  tf:exec:delete)
    aws cloudformation delete-stack --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-$AWS_MANAGED_ENV-tf-exec"
  ;;
  tf:kms:deploy)
    aws cloudformation deploy --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-$AWS_MANAGED_ENV-tf-statekey" --template-file "$PWD"/cloudformation/$AWS_TF_KMS_CFN --parameter-overrides Prefix=$AWS_PREFIX ProjectName=$AWS_MANAGED_PROJECT ServiceName=s3 Environment=$AWS_MANAGED_ENV --tags sje:managed-by=CLI
  ;;
  tf:kms:delete)
    aws cloudformation delete-stack --stack-name "$AWS_PREFIX-$AWS_MANAGED_PROJECT-$AWS_MANAGED_ENV-tf-statekey"
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
