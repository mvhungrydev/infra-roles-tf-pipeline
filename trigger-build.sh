#!/bin/bash

# Script to trigger CodeBuild with different Terraform actions
# Usage: ./trigger-build.sh <project-name> <action>
# Actions: apply, destroy, plan

set -e

# Check if required arguments are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <project-name> <action>"
    echo "Actions:"
    echo "  apply   - Deploy/update infrastructure (default)"
    echo "  destroy - Destroy all infrastructure"
    echo "  plan    - Plan changes only (no apply)"
    echo ""
    echo "Examples:"
    echo "  $0 terraform-iam-roles-build apply"
    echo "  $0 terraform-iam-roles-build destroy"
    echo "  $0 terraform-iam-roles-build plan"
    exit 1
fi

PROJECT_NAME=$1
ACTION=$2

# Validate action
if [[ ! "$ACTION" =~ ^(apply|destroy|plan)$ ]]; then
    echo "❌ Error: Invalid action '$ACTION'"
    echo "Valid actions: apply, destroy, plan"
    exit 1
fi

echo "🚀 Starting CodeBuild project: $PROJECT_NAME"
echo "📋 Terraform action: $ACTION"

# Add warning for destroy action
if [ "$ACTION" = "destroy" ]; then
    echo ""
    echo "⚠️  WARNING: You are about to DESTROY infrastructure!"
    echo "⚠️  This action will delete all resources managed by this Terraform configuration."
    echo ""
    read -p "Are you sure you want to continue? (type 'yes' to confirm): " confirm
    if [ "$confirm" != "yes" ]; then
        echo "❌ Aborted by user"
        exit 1
    fi
fi

# Start the build with environment variable override
BUILD_ID=$(aws codebuild start-build \
    --project-name "$PROJECT_NAME" \
    --environment-variables-override name=TERRAFORM_ACTION,value="$ACTION" \
    --query 'build.id' \
    --output text)

if [ $? -eq 0 ]; then
    echo "✅ Build started successfully!"
    echo "🔗 Build ID: $BUILD_ID"
    echo ""
    echo "📱 Monitor the build:"
    echo "AWS Console: https://console.aws.amazon.com/codesuite/codebuild/projects/$PROJECT_NAME/build/$BUILD_ID"
    echo ""
    echo "📋 Check build status:"
    echo "aws codebuild batch-get-builds --ids $BUILD_ID --query 'builds[0].buildStatus' --output text"
    echo ""
    echo "📜 View build logs:"
    echo "aws logs get-log-events --log-group-name /aws/codebuild/$PROJECT_NAME --log-stream-name \$(aws codebuild batch-get-builds --ids $BUILD_ID --query 'builds[0].logs.groupName' --output text | sed 's|/aws/codebuild/||')"
else
    echo "❌ Failed to start build"
    exit 1
fi