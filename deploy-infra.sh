#!/usr/bin/env bash
set -e

cd "$(dirname $0)"

if [ $# -ne 1 ]; then
  cat <<USAGE
Usage: $(basename $0) stack name
  stack-name    : name of stack to create
USAGE
  exit 1
fi

STACK_NAME=$1
CLI_PROFILE=bonkydog
EC2_INSTANCE_TYPE=t2.micro

# Deploy the CloudFormation template
echo -e "\n\n=========== Deploying main.yml ==========="
aws cloudformation deploy \
  --profile $CLI_PROFILE \
  --stack-name $STACK_NAME \
  --template-file main.yml \
  --no-fail-on-empty-changeset \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    EC2InstanceType=$EC2_INSTANCE_TYPE

# If the deploy succeeded, show the DNS name of the created instance
if [ $? -eq 0 ]; then
  aws cloudformation list-exports \
    --profile "$STACK_NAME" \
    --query "Exports[?Name=='InstanceEndpoint'].Value"
else
  aws cloudformation describe-stack-events --stack-name "$STACK_NAME"
fi
