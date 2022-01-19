#!/bin/sh
set -e

[ -z $VPC_NAME ] && echo "VPC_NAME is required" && exit 1
[ -z $ENVIRONMENT_NAME ] && echo "ENVIRONMENT_NAME is required" && exit 1
[ -z $AWS_REGION ] && echo "AWS_REGION is required" && exit 1
[ -z $ECS_TASK_FAMILY ] && echo "ECS_TASK_FAMILY is required" && exit 1
[ -z $ECS_CLUSTER ] && echo "ECS_CLUSTER is required" && exit 1

echo "Fetching subnets with tag:role=application_hosting"
subnets=$(aws ec2 describe-subnets \
    --filters Name=tag:environment_name,Values=$VPC_NAME Name=tag:role,Values=application_hosting \
    --region $AWS_REGION --query "Subnets[].SubnetId")

echo "Find appropriate task definition"
taskdeflist=( $(aws ecs list-task-definitions --family-prefix $ECS_TASK_FAMILY \
    --region $AWS_REGION --status ACTIVE --sort DESC --query "taskDefinitionArns[*]" --output text) \
)

for taskdefarn in "${taskdeflist[@]}"
do
  echo "Fetching task definition with tag:environment_name=$ENVIRONMENT_NAME"
  env=$(aws ecs describe-task-definition --task-definition $taskdefarn --include TAGS \
    --query "tags[?key=='environment_name'].value" --output text)

  if [ "$env" == "$ENVIRONMENT_NAME" ]
  then
    echo "Task definition found. Triggering adhoc ecs task"
    taskarn=$(aws ecs run-task --cluster $ECS_CLUSTER \
      --region $AWS_REGION \
      --network-configuration "{\"awsvpcConfiguration\": { \"subnets\": $subnets }}" \
      --task-definition $taskdefarn --launch-type FARGATE \
      --query "tasks[].taskArn" --output text)

    echo "New task started: $taskarn"
    exit 0
  else
    echo "No task definition found" && exit 1
  fi
done
