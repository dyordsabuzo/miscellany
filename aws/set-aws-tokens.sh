[ -z $IAM_ROLE ] && echo "IAM_ROLE is not defined" && exit 1
[ -z $AWS_PROFILE ] && echo "AWS_POFILE is not set" && exit 1

EXTERNAL_ID=${EXTERNAL_ID:=EXTERNAL_ID}
AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:=ap-southeast-2}

echo "==========================================="
echo "Fetching sts token"
echo "==========================================="
awsaccount=$(aws sts get-caller-identity --query "Account" --output text)
externalid=$(aws ssm get-parameter --name $EXTERNAL_ID \
    --region $AWS_DEFAULT_REGION --query "Parameter.Value" \
    --with-decryption --output text)

tokens=$(aws sts assume-role \
--role-arn arn:aws:iam::${awsaccount}:role/$IAM_ROLE \
--external-id $externalid \
--duration-seconds 900 \
--role-session-name assumed-access | \
jq -rM '.Credentials | [.AccessKeyId,.SecretAccessKey,.SessionToken] | "\(.[0]) \(.[1]) \(.[2])"')

unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN

AWS_ACCESS_KEY_ID=$(echo $tokens | cut -f1 -d' ')
AWS_SECRET_ACCESS_KEY=$(echo $tokens | cut -f2 -d' ')
AWS_SESSION_TOKEN=$(echo $tokens | cut -f3 -d' ')
export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN