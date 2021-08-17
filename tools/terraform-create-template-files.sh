#!/usr/bin/env bash
set -e

echo "Create base terraform templates"
touch main.tf data.tf outputs.tf

if [ ! -f providers.tf ]
then
  echo "Create providers file"
  tee providers.tf <<- PROVIDERS
provider "aws" {
  region = var.region
}
PROVIDERS
fi

if [ ! -f variables.tf ]
then
  echo "Create variables file"
  tee variables.tf <<- VARIABLES
variable "region" {
  description = "AWS region to create resources in"
  type  = string
  default = "ap-southeast-2"
}
VARIABLES
fi

if [ ! -f locals.tf ]
then
  echo "Create locals template file"
  tee locals.tf <<- LOCALS
locals {
  tags = {
    created_by = "terraform"
  }
}
LOCALS
fi

if [ ! -f backend.tf ]
then
  echo "Create backend template file"
  tee backend.tf <<- BACKEND
terraform {

}
BACKEND
fi

echo "Create default terraform variable file"
mkdir -p tfvars && touch tfvars/main.tfvars

echo "Create terraform prehook"
mkdir -p hooks

tee hooks/pre-commit <<- PRECOMMIT
#!/bin/sh -e

base_path=`pwd`
processed_paths=()

for changed_file in `git diff --name-only`
do
  changed_path=`dirname $changed_file`
  if [[ ! ${processed_paths[*]} =~ $changed_path ]]
  then
    cd $base_path/$changed_path && terraform fmt -recursive && \
      terraform init -backend=false && terraform validate

    processed_paths+=($changed_path)
  fi
done
PRECOMMIT
chmod +x hooks/pre-commit