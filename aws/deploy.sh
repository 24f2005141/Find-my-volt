#!/usr/bin/env bash
# ==============================================================================
# Find My Volt - Automated AWS Free Tier Deployment Script (Bash / CI/CD)
# Provisions EC2 (t2.micro/t3.micro, 30GB EBS) with SQLite and Python REST Server
# 100% Covered under the AWS 12-Month Free Tier ($0.00/mo)
# ==============================================================================

set -euo pipefail

REGION="${AWS_DEFAULT_REGION:-us-east-1}"
STACK_NAME="${STACK_NAME:-find-my-volt-backend}"
INSTANCE_TYPE="${INSTANCE_TYPE:-t2.micro}"

echo "================================================================="
echo "   FIND MY VOLT - AWS FREE TIER BACKEND & DATABASE DEPLOYMENT   "
echo "================================================================="

if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI not found on PATH." >&2
    exit 1
fi

echo "[1/4] Checking AWS caller identity..."
aws sts get-caller-identity --output json

echo "[2/4] Deploying CloudFormation Stack: $STACK_NAME (Region: $REGION)..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
aws cloudformation deploy \
    --template-file "$SCRIPT_DIR/cloudformation.yaml" \
    --stack-name "$STACK_NAME" \
    --parameter-overrides InstanceType="$INSTANCE_TYPE" \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    --no-fail-on-empty-changeset

echo "[3/4] Fetching stack outputs..."
PUBLIC_IP=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --query "Stacks[0].Outputs[?OutputKey=='PublicIp'].OutputValue" --output text)
API_URL=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --query "Stacks[0].Outputs[?OutputKey=='BackendApiUrl'].OutputValue" --output text)
HEALTH_URL=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --query "Stacks[0].Outputs[?OutputKey=='HealthCheckUrl'].OutputValue" --output text)

echo "================================================================="
echo "   AWS DEPLOYMENT COMPLETE!                                     "
echo "================================================================="
echo "Public IP:       $PUBLIC_IP"
echo "REST API URL:    $API_URL"
echo "Health Check:    $HEALTH_URL"
echo "Standard HTTP:   http://$PUBLIC_IP/api"
echo "================================================================="

echo "[4/4] Verifying health check..."
sleep 20
curl -f "$HEALTH_URL" || echo "Instance UserData is booting; check back in ~1 minute."
