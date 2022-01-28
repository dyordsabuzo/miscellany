#!/usr/bin/env bash
set -e

file_locations=$(find . -maxdepth 2 -type f \( -name "backend.tf" \))

for f in $file_locations
do
    TF_MODULE_PATH=$(dirname $f) sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/dyordsabuzo/miscellany/8237af077493b63378d59efc4a8d9ea3859cc848/tools/terraform-workspace-local.sh)"
        # "$(curl -fsSL https://raw.githubusercontent.com/dyordsabuzo/miscellany/main/tools/terraform-workspace-local.sh)"
done