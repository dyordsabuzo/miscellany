#!/bin/bash
##########################################################
# Script to run the following:
# 1) extract workspace details
# 2) check if workspace exists
# 3) create workspace if it does not exist
##########################################################
set -e

organization=${TF_ORGANIZATION:="pablosspot"}
terraformapiurl=${TF_API_URL:="https://app.terraform.io/api/v2"}
terraformversion=${TF_VERSION:=1.0.0}
AGENT_HOMEDIRECTORY=${AGENT_HOMEDIRECTORY:="$HOME"}

[ -z $TF_WORKSPACE ] && echo "TF_WORKSPACE not defined" && exit 1
[ -z $TF_MODULE_PATH ] || [ ! -d $TF_MODULE_PATH ] && echo "TF_MODULE_PATH not defined or does not exist" && exit 1

echo "==========================================="
echo "Get workspace to be created"
echo "==========================================="
backend=$(cat $TF_MODULE_PATH/backend.tf | \
  sed 's/\"remote\"//g;s/^ *//g;s/\([a-z_]*\) *=/"\1":/;s/\([a-z_]*\) *{/"\1":{/g;s/\"terraform\"://g;s/\"$/",/g' | \
  grep -v '^#' | tr -d '\n' | sed 's/,}/}/g')
prefix=$(echo $backend | jq -rM '.backend.workspaces.prefix')
host=$(echo $backend | jq -rM '.backend.hostname')
host=${host:="app.terraform.io"}

workspacename=$prefix$TF_WORKSPACE
if [ -z $prefix ]
then
  echo "No workspace prefix found in backend.tf.  Checking for workspace name"
  workspacename=$(echo $backend | jq -rM '.backend.workspaces.name')
fi

[ -z $workspacename ] && echo "Unknown workspace. Please check your backend.tf" && exit 1

echo "==========================================="
echo "Workspace: $workspacename"
echo "==========================================="
api_token=$(cat $AGENT_HOMEDIRECTORY/.terraformrc | grep 'token' | sed 's/^.*token\s*=\s*//' | sed 's/"//g')
result=$(curl \
  --header "Authorization: Bearer $api_token" \
  --header "Content-Type: application/vnd.api+json" \
  ${terraformapiurl}/organizations/${organization}/workspaces/${workspacename} | \
  jq -rM '.data.attributes.name')

if [ "$result" == "null" ]
then
  echo "Workspace $workspacename does not exist and will be created."
  result=$(curl -s -X POST \
    -H "Cache-Control: no-cache" \
    -H "Content-Type: application/vnd.api+json" \
    -H "Authorization: Bearer ${api_token}" \
    -d '{
          "data": {
            "attributes": {
              "name": "'"$workspacename"'",
              "operations": "false"
            },
            "type": "workspaces"
          }
        }' "${terraformapiurl}/organizations/${organization}/workspaces" | \
        jq -rM '.data.attributes.name')

  [ "$result" != "$workspacename" ] \
    && echo "Workspace creation for $workspacename failed: $result." \
    && exit 1
  
  echo "Workspace creation completed successfully"    
else
  echo "Workspace already exists"
fi