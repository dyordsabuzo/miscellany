#!/usr/bin/env bash

echo "Create base terraform templates"
touch main.tf variables.tf providers.tf data.tf

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
mkdir -p tfvars && touch tfvars/default.tfvars