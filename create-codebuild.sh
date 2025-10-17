#!/bin/bash

# Script to create CodeBuild project connected to GitHub
# Usage: ./create-codebuild.sh <github-repo-url> <project-name>

set -e

# Check if required arguments are provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <github-repo-url> <project-name> [aws-region] [project-name-override] [environment]"
    echo "Example: $0 https://github.com/username/repo-name terraform-iam-roles"
    echo "Example: $0 https://github.com/username/repo-name terraform-iam-roles us-east-1 my-project prod"
    exit 1
fi

GITHUB_REPO_URL=$1
PROJECT_NAME=$2
AWS_REGION=${3:-"us-east-1"}
TF_PROJECT_NAME=${4:-"terraform-cicd"}
TF_ENVIRONMENT=${5:-"dev"}

# Validate GitHub URL format
if [[ ! "$GITHUB_REPO_URL" =~ ^https://github\.com/.+/.+$ ]]; then
    echo "❌ Error: Invalid GitHub URL format. Expected: https://github.com/username/repo-name"
    exit 1
fi

echo "🚀 Creating CodeBuild project: $PROJECT_NAME"
echo "📦 GitHub Repository: $GITHUB_REPO_URL"
echo "🌍 AWS Region: $AWS_REGION"
echo "📋 Terraform Project Name: $TF_PROJECT_NAME"
echo "🏷️  Environment: $TF_ENVIRONMENT"

# Get the CodeBuild role ARN from Terraform output
echo "📋 Getting CodeBuild role ARN from Terraform..."
CODEBUILD_ROLE_ARN=$(terraform output -raw codebuild_role_arn)

if [ -z "$CODEBUILD_ROLE_ARN" ]; then
    echo "❌ Error: Could not get CodeBuild role ARN. Make sure Terraform has been applied."
    exit 1
fi

echo "✅ CodeBuild Role ARN: $CODEBUILD_ROLE_ARN"

# Create the CodeBuild project
echo "🔨 Creating CodeBuild project..."

aws codebuild create-project \
    --name "$PROJECT_NAME" \
    --description "Terraform IAM roles deployment project" \
    --source type=GITHUB,location="$GITHUB_REPO_URL",gitCloneDepth=1,buildspec=buildspec.yml \
    --artifacts type=NO_ARTIFACTS \
    --environment type=LINUX_CONTAINER,image=aws/codebuild/amazonlinux2-x86_64-standard:5.0,computeType=BUILD_GENERAL1_MEDIUM,privilegedMode=false,environmentVariables='[
        {"name":"TERRAFORM_ACTION","value":"apply","type":"PLAINTEXT"},
        {"name":"TF_VAR_aws_region","value":"'$AWS_REGION'","type":"PLAINTEXT"},
        {"name":"TF_VAR_project_name","value":"'$TF_PROJECT_NAME'","type":"PLAINTEXT"},
        {"name":"TF_VAR_environment","value":"'$TF_ENVIRONMENT'","type":"PLAINTEXT"},
        {"name":"TF_VAR_tags","value":"{\"ManagedBy\":\"Terraform\",\"Environment\":\"'$TF_ENVIRONMENT'\",\"DeployedBy\":\"CodeBuild\"}","type":"PLAINTEXT"}
    ]' \
    --service-role "$CODEBUILD_ROLE_ARN" \
    --timeout-in-minutes=60 \
    --badge-enabled

if [ $? -eq 0 ]; then
    echo "✅ CodeBuild project '$PROJECT_NAME' created successfully!"
    echo ""
    echo "📝 Next steps:"
    echo "1. Go to AWS CodeBuild console to view your project"
    echo "2. Optionally set up webhooks for automatic builds"
    echo "3. Run a test build to verify everything works"
    echo ""
    echo "🔗 AWS Console URL:"
    echo "https://console.aws.amazon.com/codesuite/codebuild/projects/$PROJECT_NAME/history"
else
    echo "❌ Failed to create CodeBuild project"
    exit 1
fi