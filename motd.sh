#!/usr/bin/env bash

main() {
    cat << EOF
########################################################################
# Welcome to the Terraform and AWS CLI container.
# You can use the following commands to interact with AWS and Terraform.

# Configuring AWS CLI
aws configure --profile developer
> AWS Access Key ID [None]: \${AWS_ACCESS_KEY_ID}
> AWS Secret Access Key [None]: \${AWS_SECRET_ACCESS_KEY}
> Default region name [None]: ap-northeast-1
> Default output format [None]: json

# Configuring and applying Terraform
terraform init
terraform fmt
terraform validate
export AWS_PROFILE=developer
terraform apply
########################################################################
EOF
}

main "$@"
