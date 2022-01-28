#!/usr/bin/env bash
set -e

file_locations=$(find . -type f \( -name "variables.tf" \))

for f in $file_locations
do
    input_block=$(awk '/variable/ && gsub(/"/,"") {printf "  %s = \"\"\n", $2}' $f)

    config=$(cat <<EOL
include {
  path = find_in_parent_folders()
}

terraform {
  source = "."
}

dependency {}

inputs = {
$input_block
}
EOL
)

    echo -e "$config" > $(dirname $f)/terragrunt.hcl
done

echo -e "locals {\n}" > terragrunt.hcl