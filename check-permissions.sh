#!/bin/bash

# Script to check if you have the required AWS permissions
# Usage: ./check-permissions.sh

set -e

echo "🔍 Checking AWS permissions for Terraform deployment..."

# Check if AWS CLI is configured
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "❌ Error: AWS CLI not configured. Please run 'aws configure' first."
    exit 1
fi

# Get current user info
USER_INFO=$(aws sts get-caller-identity)
USER_ARN=$(echo $USER_INFO | jq -r '.Arn' 2>/dev/null || echo $USER_INFO | grep -o '"Arn": "[^"]*"' | cut -d'"' -f4)

echo "✅ AWS CLI configured"
echo "👤 Current user: $USER_ARN"
echo ""

# Test required permissions
echo "🧪 Testing required permissions..."

# Test IAM permissions
echo -n "  📋 IAM CreateRole: "
if aws iam create-role --role-name terraform-permission-test-role \
    --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ec2.amazonaws.com"},"Action":"sts:AssumeRole"}]}' \
    --dry-run 2>/dev/null || aws iam create-role --role-name terraform-permission-test-role \
    --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ec2.amazonaws.com"},"Action":"sts:AssumeRole"}]}' 2>/dev/null; then
    echo "✅"
    # Clean up test role
    aws iam delete-role --role-name terraform-permission-test-role 2>/dev/null || true
else
    echo "❌"
    IAM_FAILED=true
fi

echo -n "  📋 IAM CreatePolicy: "
if aws iam create-policy --policy-name terraform-permission-test-policy \
    --policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":"s3:ListBucket","Resource":"*"}]}' 2>/dev/null; then
    echo "✅"
    # Clean up test policy
    POLICY_ARN=$(aws iam list-policies --query 'Policies[?PolicyName==`terraform-permission-test-policy`].Arn' --output text)
    aws iam delete-policy --policy-arn "$POLICY_ARN" 2>/dev/null || true
else
    echo "❌"
    IAM_FAILED=true
fi

echo -n "  📋 S3 CreateBucket: "
if aws s3api create-bucket --bucket terraform-permission-test-bucket-$(date +%s) --dry-run 2>/dev/null; then
    echo "✅"
else
    echo "❌"
    S3_FAILED=true
fi

echo -n "  📋 CodeBuild CreateProject: "
if aws codebuild create-project --name terraform-permission-test --dry-run 2>/dev/null; then
    echo "✅"
else
    echo "❌"
    CODEBUILD_FAILED=true
fi

echo ""

# Summary
if [ -z "$IAM_FAILED" ] && [ -z "$S3_FAILED" ] && [ -z "$CODEBUILD_FAILED" ]; then
    echo "🎉 All required permissions are available!"
    echo "✅ You can proceed with Terraform deployment."
else
    echo "❌ Some permissions are missing. You need to:"
    echo ""
    
    if [ ! -z "$IAM_FAILED" ]; then
        echo "   🔑 Add IAM permissions (CreateRole, CreatePolicy, etc.)"
        echo "      → Attach 'PowerUserAccess' or 'IAMFullAccess' policy"
    fi
    
    if [ ! -z "$S3_FAILED" ]; then
        echo "   🪣 Add S3 permissions (CreateBucket, etc.)"
        echo "      → Attach 'AmazonS3FullAccess' policy"
    fi
    
    if [ ! -z "$CODEBUILD_FAILED" ]; then
        echo "   🔨 Add CodeBuild permissions (CreateProject, etc.)"
        echo "      → Attach 'AWSCodeBuildDeveloperAccess' policy"
    fi
    
    echo ""
    echo "💡 Quick fix: Attach 'PowerUserAccess' policy to your user"
    echo "   AWS Console → IAM → Users → $USER_ARN → Add permissions"
    echo ""
    exit 1
fi