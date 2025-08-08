#!/bin/bash

ENV=$1

if [ -z "$ENV" ]; then
  echo "Usage: ./tf-init.sh <env>"
  exit 1
fi

LOWER_ENV=$(echo "$ENV" | tr '[:upper:]' '[:lower:]')
VALID_ENVS=("test" "beta" "feature" "main")
IS_VALID_ENV=false

for valid_env in "${VALID_ENVS[@]}"; do
  if [ "$LOWER_ENV" == "$valid_env" ]; then
    IS_VALID_ENV=true
    break
  fi
done

if [ "$IS_VALID_ENV" == false ]; then
  echo "Error: Invalid environment"
  echo "Valid Jenkins environments are: ${VALID_ENVS[*]}"
  exit 1
fi

STATE_FILE="jenkins/npe-cisystem-${LOWER_ENV}/terraform.tfstate"

echo -e "Initializing Terraform for environment:$LOWER_ENV with state file: $STATE_FILE\n"
echo "Running terraform init..."
terraform init --reconfigure --backend-config="key=$STATE_FILE"
