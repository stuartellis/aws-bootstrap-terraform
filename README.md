# aws-bootstrap-terraform

Tooling to bootstrap Terraform on AWS.

## Usage

Use the *do.sh* script to setup and run this tooling.

    ./do.sh info

To create a Terraform backend, first set your AWS profile to the target account and region. Then run this command:

    ./do.sh backend:create

To create an IAM user for Terraform, first set your AWS profile to the target account and region. Then run this command:

    ./do.sh users:create

> Other valid subcommands for *backend* and *users* are: *update*, *delete* and *validate* template.
