#!/bin/bash

# exit straight away if issues
set -e

# Stops aws commands for stopping, requiring user input
export AWS_PAGER=""
export PAGER=""

if ! command -v aws &> /dev/null; then
  echo "This script requires the aws cli, please install it..."
  exit 1
fi

# region and account id
AWS_REGION="us-east-1"
AWS_ACCOUNT_ID="654654409426"

PLATFORM="linux/amd64"

# ecr stuff
API_NAME="expenseflow-api"
UI_NAME="expenseflow-ui"

# ecs stuff
ECS_CLUSTER="expenseflow"

API_ECR="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$API_NAME"
UI_ECR="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$UI_NAME"

# finding where credentials are
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # directory where script lives
CRED_FILE="$SCRIPT_DIR/credentials"

if ! test -f $CRED_FILE; then
    echo "credentials file does not exist..."
    exit 1
fi

# Export the credentials to environment variables
eval $(awk '
  $1 == "[default]" { in_default=1; next }
  /^\[.*\]/ { in_default=0 }
  in_default && $1 ~ /=/ {
    gsub(/ /, "", $0)
    split($0, kv, "=")
    key = toupper(kv[1])
    print "export " key "=" kv[2]
  }
' "$CRED_FILE")

# Ensure credentials were set
if [[ -z "$AWS_ACCESS_KEY_ID" || -z "$AWS_SECRET_ACCESS_KEY" || -z "$AWS_SESSION_TOKEN" ]]; then
    echo "❌ Failed to export temporary credentials"
    exit 1
fi

# docker auth
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"


# build and push api
docker build --platform $PLATFORM -t "$API_NAME" ./api
docker tag "$API_NAME" "$API_ECR:latest"
docker push "$API_ECR:latest"

# build and push ui
docker build --platform $PLATFORM -t "$UI_NAME" ./ui
docker tag "$UI_NAME" "$UI_ECR:latest"
docker push "$UI_ECR:latest"

echo "done pushing images..."

# get cluster 
CLUSTER_NAME=$(aws ecs list-clusters --region $AWS_REGION --query "clusterArns[0]" --output text | xargs -n1 basename)

if [[ -z "$CLUSTER_NAME" ]]; then
  echo "no ECS clusters found"
  exit 1
fi

echo "Using ECS cluster: $CLUSTER_NAME"

# make ecs pull new images
aws ecs update-service --cluster "$CLUSTER_NAME" \
  --service "$UI_NAME" \
  --force-new-deployment \
  --region us-east-1

aws ecs update-service --cluster "$CLUSTER_NAME" \
  --service "$API_NAME" \
  --force-new-deployment \
  --region us-east-1

echo "ecs service are now pulling new images"
