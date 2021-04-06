# aws-bootstrap-terraform

Tooling to bootstrap Terraform on AWS.

## Usage

Use the *do.sh* script to setup and run this tooling.

    ./do.sh info

Customize the project variables in the script before using it.

This script uses two AWS accounts:

- The operations account - The account that hosts IAM users and Terraform backends. Terraform refers to this as the *administrative account*.
- The managed account - An account that is being managed by the operations account. Terraform refers to this as the *environment account*.

To check the CloudFormation templates, first set your AWS profile to the operations account and region. Next, run this command:

    ./do.sh validate

To create an IAM user for interactive access, first set your AWS profile to the operations account and region. Run this command:

    ./do.sh ops:access:create

## Terraform Setup

Set your AWS profile to the managed account and region. Run these commands:

    ./do.sh tf:exec:create

Set your AWS profile to the operations account and region. Run these commands:

    ./do.sh tf:kms:create
    ./do.sh tf:backend:create
    ./do.sh tf:access:create

## Subcommands

- *ops:access* - Manage IAM users for human operators in the operations account
- *ops:exec* - Manage IAM role in the managed account
- *tf:access* - Manage IAM users for Terraform in the operations account
- *tf:backend* - Manage Terraform backend in the operations account
- *tf:exec* - Manage IAM role for Terraform in the managed account
- *tf:kms* - Manages KMS for the S3 Terraform backend in the operations account

> The valid options are: *create*, *update* and *delete*.
