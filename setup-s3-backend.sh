#!/bin/bash

# Script to set up S3 backend for Terraform state
# Usage: ./setup-s3-backend.sh <bucket-name> [region]

set -e

# Check if bucket name is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <bucket-name> [region]"
    echo "Example: $0 my-terraform-state-bucket us-east-1"
    exit 1
fi

BUCKET_NAME=$1
REGION=${2:-us-east-1}

echo "🚀 Setting up S3 backend for Terraform state"
echo "📦 Bucket: $BUCKET_NAME"
echo "🌍 Region: $REGION"

# Check if AWS CLI is configured
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "❌ Error: AWS CLI not configured. Please run 'aws configure' first."
    exit 1
fi

# Create S3 bucket
echo "📋 Creating S3 bucket..."
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo "✅ Bucket '$BUCKET_NAME' already exists"
else
    if [ "$REGION" = "us-east-1" ]; then
        aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION"
    else
        aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" \
            --create-bucket-configuration LocationConstraint="$REGION"
    fi
    echo "✅ Created bucket '$BUCKET_NAME'"
fi

# Enable versioning
echo "📋 Enabling versioning..."
aws s3api put-bucket-versioning --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled
echo "✅ Versioning enabled"

# Enable server-side encryption
echo "📋 Enabling server-side encryption..."
aws s3api put-bucket-encryption --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'
echo "✅ Server-side encryption enabled"

# Block public access
echo "📋 Blocking public access..."
aws s3api put-public-access-block --bucket "$BUCKET_NAME" \
    --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
echo "✅ Public access blocked"

# Update main.tf with backend configuration
echo "📋 Updating Terraform backend configuration..."
sed -i.bak "s|# backend \"s3\" {|backend \"s3\" {|g" main.tf
sed -i.bak "s|#   bucket = \"your-terraform-state-bucket\"|  bucket = \"$BUCKET_NAME\"|g" main.tf
sed -i.bak "s|#   key    = \"iam-roles/terraform.tfstate\"|  key    = \"iam-roles/terraform.tfstate\"|g" main.tf
sed -i.bak "s|#   region = \"us-east-1\"|  region = \"$REGION\"|g" main.tf
sed -i.bak "s|#   # Note: No DynamoDB table for locking as requested|  # Note: No DynamoDB table for locking as requested|g" main.tf
sed -i.bak "s|# }|}|g" main.tf

# Remove backup file
rm -f main.tf.bak

echo "✅ Backend configuration updated in main.tf"

echo ""
echo "🎉 S3 backend setup complete!"
echo ""
echo "📝 Next steps:"
echo "1. Run 'terraform init' to initialize the backend"
echo "2. When prompted, type 'yes' to migrate existing state to S3"
echo "3. Run 'terraform plan' to verify everything works"
echo ""
echo "ℹ️  Note: This configuration does not use DynamoDB locking as requested."
echo "   Multiple users should coordinate to avoid concurrent modifications."