# aws-bootstrap-terraform

Tooling to bootstrap Terraform on AWS.

## Usage

Use the *do.sh* script to setup and run this tooling.

    ./do.sh info

This script uses two AWS accounts:

- The operations account - The account that hosts IAM users and Terraform backends. Terraform refers to this as the *administrative account*.
- The managed account - An account that is being managed by the operations account. Terraform refers to this as the *environment account*.

To check the CloudFormation templates, first set your AWS profile to the operations account and region. Then run this command:

    ./do.sh validate

To create a Terraform backend, first set your AWS profile to the operations account and region. Then run this command:

    ./do.sh tf:backend:create

To create an IAM user for Terraform, first set your AWS profile to the operations account and region. Then run this command:

    ./do.sh ops:access:create

Subcommands:

- *ops:access* - Manage IAM users for human operators in the operations account
- *ops:exec* - Manage IAM role in the managed account
- *tf:backend* - Manage Terraform backend in the operations account
- *tf:access* - Manage IAM users for Terraform in the operations account
- *tf:exec* - Manage IAM role for Terraform in the managed account

> The valid options are: *create*, *update* and *delete*.
