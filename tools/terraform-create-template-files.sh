#!/usr/bin/env bash
set -e

echo "Create base terraform templates"
touch main.tf data.tf outputs.tf

if [ ! -f providers.tf ]
then
  echo "Create providers file"
  cat > providers.tf <<- PROVIDERS
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      created_by = "terraform"
      workspace = terraform.workspace
    }
  }
}
PROVIDERS
fi

if [ ! -f variables.tf ]
then
  echo "Create variables file"
  cat > variables.tf <<- VARIABLES
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
  cat > locals.tf <<- LOCALS
locals {
}
LOCALS
fi

if [ ! -f backend.tf ]
then
  echo "Create backend template file"
  cat > backend.tf <<- BACKEND
terraform {
  backend "remote" {
    hostname = "app.terraform.io"
  }
}
BACKEND
fi

echo "Create default terraform variable file"
mkdir -p tfvars && touch tfvars/main.tfvars

echo "Create .gitignore file"
cat > .gitignore <<- IGNORE
**/.terraform/**
**/.terragrunt-cache/**
IGNORE


# echo "Create terraform prehook"
# mkdir -p hooks

# tee hooks/pre-commit <<- PRECOMMIT
# #!/bin/sh -e

# base_path=`pwd`
# processed_paths=()

# for changed_file in `git diff --name-only`
# do
#   changed_path=`dirname $changed_file`
#   if [[ ! ${processed_paths[*]} =~ $changed_path ]]
#   then
#     cd $base_path/$changed_path && terraform fmt -recursive && \
#       terraform init -backend=false && terraform validate

#     processed_paths+=($changed_path)
#   fi
# done
# PRECOMMIT
# chmod +x hooks/pre-commit