# Terraform Configuration for AWS IAM Roles

This Terraform configuration creates AWS IAM roles and policies for CodeBuild and CodePipeline that can deploy and manage AWS infrastructure including:

- EC2 instances and VPC components
- Secrets Manager operations
- Lambda functions
- ACM certificates
- ECR repositories and Docker operations
- EventBridge rules
- S3 buckets (for Terraform state)

## Resources Created

### IAM Roles
- **CodeBuild Role**: Used by AWS CodeBuild projects
- **CodePipeline Role**: Used by AWS CodePipeline

### IAM Policies
- **CodeBuild Policies**: Base policy, EC2/VPC, Secrets Manager, Lambda, ACM, ECR, EventBridge, S3, IAM permissions
- **CodePipeline Policies**: Base policy, CodeCommit, GitHub, SNS notifications

## Prerequisites

Before deploying, ensure you have:

### 1. **AWS CLI Configured**
```bash
# Install AWS CLI (if not already installed)
# macOS: brew install awscli

# Configure with your credentials
aws configure
# Enter your AWS Access Key ID, Secret Access Key, and region
```

### 2. **Required AWS Permissions**
Your AWS user needs IAM permissions to create roles and policies. The easiest solution:

**Go to AWS Console → IAM → Users → Find your user → Add permissions → Attach policies:**
- Attach **`PowerUserAccess`** policy (recommended)

**Or have an admin run:**
```bash
aws iam attach-user-policy \
  --user-name YOUR_USERNAME \
  --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
```

### 3. **Verify Setup**
```bash
# Test your credentials and permissions
aws sts get-caller-identity

# Check permissions (optional)
chmod +x check-permissions.sh
./check-permissions.sh
```

## Deployment

### Deploy the IAM Roles

1. **Initialize Terraform:**
```bash
terraform init
```

2. **Review what will be created:**
```bash
terraform plan
```

3. **Deploy the resources:**
```bash
terraform apply
```

4. **Note the outputs** - you'll get the role ARNs that can be used in CodeBuild/CodePipeline projects.

## Variables

You can customize the deployment by creating a `terraform.tfvars` file:

```hcl
aws_region   = "us-west-2"
project_name = "my-infrastructure" 
environment  = "production"

tags = {
  ManagedBy   = "Terraform"
  Environment = "production"
  Team        = "DevOps"
}
```

## Outputs

After successful deployment, you'll get:
- `codebuild_role_arn`: ARN of the CodeBuild role
- `codebuild_role_name`: Name of the CodeBuild role  
- `codepipeline_role_arn`: ARN of the CodePipeline role
- `codepipeline_role_name`: Name of the CodePipeline role

## Troubleshooting

### Permission Denied Errors
```bash
# Error: "User is not authorized to perform: iam:CreateRole"
```

**Solution:** Add IAM permissions to your AWS user (see Prerequisites section above)

### Common Issues
- **AWS CLI not configured**: Run `aws configure`
- **Wrong region**: Make sure your CLI region matches your desired deployment region
- **Terraform not found**: Install Terraform locally if needed

## Files Description

- `main.tf`: Main configuration and provider setup
- `variables.tf`: Input variables
- `iam_roles.tf`: IAM role definitions
- `codebuild_policies.tf`: CodeBuild IAM policies
- `codepipeline_policies.tf`: CodePipeline IAM policies
- `policy_attachments.tf`: Policy-to-role attachments
- `outputs.tf`: Output values
- `check-permissions.sh`: Script to verify AWS permissions
- `.gitignore`: Git ignore file for Terraform files

## Additional Files (For Future Use)

These files are ready for when you want to set up CodeBuild integration:

- `buildspec.yml`: CodeBuild build specification with parameterized actions
- `setup-s3-backend.sh`: Script to configure S3 backend  
- `create-codebuild.sh`: Script to create CodeBuild project
- `trigger-build.sh`: Script to trigger builds with different actions
- `terraform.tfvars.example`: Example variables file

## Next Steps

Once the IAM roles are successfully deployed:

1. The role ARNs can be used to create CodeBuild projects
2. The role ARNs can be used to create CodePipeline pipelines  
3. Consider setting up S3 backend for shared state if working in a team
4. Consider setting up CodeBuild integration for automated deployments

## Usage

### Option 1: Local State (Quick Start)

1. Clone this repository
2. Configure your AWS credentials
3. Customize variables in `terraform.tfvars` (optional)
4. Run the following commands:

```bash
terraform init
terraform plan
terraform apply
```

### Option 2: S3 Backend (Recommended for Teams)

1. Set up S3 backend for shared state:

```bash
# Make the script executable
chmod +x setup-s3-backend.sh

# Run the setup script with your unique bucket name
./setup-s3-backend.sh my-terraform-state-bucket-unique-name us-east-1
```

2. Initialize and deploy:

```bash
terraform init  # Will prompt to migrate state to S3
terraform plan
terraform apply
```

## Variables

- `aws_region`: AWS region (default: us-east-1)
- `project_name`: Project name for resource naming (default: terraform-cicd)
- `environment`: Environment name (default: dev)
- `terraform_state_bucket`: S3 bucket for Terraform state (optional)
- `terraform_state_key`: S3 key path for state file (default: iam-roles/terraform.tfstate)
- `tags`: Common tags for all resources

## S3 Backend Configuration

This configuration supports S3 backend for shared Terraform state without DynamoDB locking:

**Benefits:**

- ✅ Shared state across team members
- ✅ State versioning and backup
- ✅ Server-side encryption
- ✅ No additional costs for locking

**Considerations:**

- ⚠️ No state locking - coordinate team access to avoid conflicts
- ⚠️ Manual coordination needed for concurrent operations

## Outputs

- `codebuild_role_arn`: ARN of the CodeBuild role
- `codebuild_role_name`: Name of the CodeBuild role
- `codepipeline_role_arn`: ARN of the CodePipeline role
- `codepipeline_role_name`: Name of the CodePipeline role

## Security Considerations

⚠️ **Important**: These roles have broad permissions for infrastructure management. Consider:

1. **Principle of Least Privilege**: Review and restrict permissions based on your specific needs
2. **Resource-Level Restrictions**: Add resource ARN restrictions where possible
3. **Environment Separation**: Use different roles for different environments
4. **Monitoring**: Enable CloudTrail logging for these roles
5. **Regular Audits**: Periodically review and update permissions

### Required AWS Permissions for Deployment

Your AWS user needs these permissions to deploy this infrastructure:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:GetRole",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:CreatePolicy",
        "iam:DeletePolicy",
        "iam:GetPolicy",
        "iam:TagRole",
        "iam:TagPolicy",
        "s3:CreateBucket",
        "s3:GetBucketVersioning",
        "s3:PutBucketVersioning",
        "s3:PutBucketEncryption",
        "s3:PutPublicAccessBlock",
        "codebuild:CreateProject",
        "codebuild:UpdateProject",
        "sts:GetCallerIdentity"
      ],
      "Resource": "*"
    }
  ]
}
```

### AWS Managed Policies (Alternative)

Alternatively, you can use these AWS managed policies:

- `PowerUserAccess` (recommended for development)
- Or `AdministratorAccess` (for full access)

## Example terraform.tfvars

```hcl
aws_region   = "us-west-2"
project_name = "my-infrastructure"
environment  = "production"

tags = {
  ManagedBy   = "Terraform"
  Environment = "production"
  Team        = "DevOps"
}
```

## Deployment Guide

### Prerequisites

Before running any scripts or deploying infrastructure, ensure you have:

#### 1. **AWS CLI Installed and Configured**

```bash
# Install AWS CLI (if not already installed)
# macOS
brew install awscli

# Or download from: https://aws.amazon.com/cli/

# Configure AWS CLI with your credentials
aws configure
# Enter your AWS Access Key ID, Secret Access Key, and default region
```

#### 2. **Required AWS Permissions**

Your AWS user/role needs the following permissions:

- **IAM Full Access** (to create roles and policies)
- **S3 Full Access** (for Terraform state storage)
- **CodeBuild Full Access** (to create CodeBuild projects)
- **CodePipeline Full Access** (if using CodePipeline)

#### 3. **Verify AWS Access**

```bash
# Test your AWS credentials
aws sts get-caller-identity

# Should return something like:
# {
#     "UserId": "AIDACKCEVSQ6C2EXAMPLE",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/YourUsername"
# }

# Check if you have all required permissions
chmod +x check-permissions.sh
./check-permissions.sh
```

#### 4. **Install Terraform Locally (Optional)**

```bash
# macOS
brew install terraform

# Or download from: https://www.terraform.io/downloads
```

#### 5. **GitHub Setup (for CodeBuild integration)**

- Create a GitHub repository for this code
- Ensure you have push access to the repository
- GitHub personal access token (if using private repos)

### Step 1: Deploy the IAM Roles Locally

1. **Configure AWS CLI:**

   ```bash
   aws configure
   # Enter your AWS Access Key ID, Secret Access Key, and default region
   ```

2. **Deploy the roles:**

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. **Note the output role ARNs** - you'll need them for CodeBuild setup.

### Step 2: Commit to GitHub

1. **Initialize git repository:**

   ```bash
   git init
   git add .
   git commit -m "Initial commit: Terraform IAM roles for CodeBuild/CodePipeline"
   ```

2. **Create GitHub repository and push:**
   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
   git branch -M main
   git push -u origin main
   ```

### Step 3: Create CodeBuild Project

**Option A: Using AWS Console**

1. Go to AWS CodeBuild console
2. Click "Create build project"
3. Configure:
   - **Project name**: `terraform-iam-roles-build`
   - **Source provider**: GitHub
   - **Repository**: Connect to your GitHub repo
   - **Webhook**: Enable for automatic builds on push
   - **Environment**: Amazon Linux 2
   - **Service role**: Use the CodeBuild role created by this Terraform
   - **Buildspec**: Use `buildspec.yml` in source root

**Option B: Using AWS CLI**

```bash
# Get the CodeBuild role ARN from Terraform output
CODEBUILD_ROLE_ARN=$(terraform output -raw codebuild_role_arn)

# Create CodeBuild project
aws codebuild create-project \
  --name terraform-iam-roles-build \
  --source type=GITHUB,location=https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git \
  --artifacts type=NO_ARTIFACTS \
  --environment type=LINUX_CONTAINER,image=aws/codebuild/standard:5.0,computeType=BUILD_GENERAL1_MEDIUM \
  --service-role $CODEBUILD_ROLE_ARN
```

### Step 4: Set up GitHub Webhook (Optional)

To trigger builds automatically on git push:

1. In CodeBuild project settings, enable "Webhook"
2. Select "Rebuild every time a code change is pushed"
3. Add filter groups if needed (e.g., only on main branch)

## Parameterized Builds

The buildspec.yml supports different Terraform actions via the `TERRAFORM_ACTION` environment variable:

### Available Actions:

- **`apply`** (default) - Deploy/update infrastructure
- **`destroy`** - Destroy all infrastructure
- **`plan`** - Plan changes only (no apply)

### Method 1: Using the Helper Script

```bash
# Make the script executable
chmod +x trigger-build.sh

# Deploy infrastructure
./trigger-build.sh terraform-iam-roles-build apply

# Plan changes only
./trigger-build.sh terraform-iam-roles-build plan

# Destroy infrastructure (with confirmation prompt)
./trigger-build.sh terraform-iam-roles-build destroy
```

### Method 2: Using AWS CLI Directly

```bash
# Start build with apply action
aws codebuild start-build \
  --project-name terraform-iam-roles-build \
  --environment-variables-override name=TERRAFORM_ACTION,value=apply

# Start build with destroy action
aws codebuild start-build \
  --project-name terraform-iam-roles-build \
  --environment-variables-override name=TERRAFORM_ACTION,value=destroy

# Start build with plan action
aws codebuild start-build \
  --project-name terraform-iam-roles-build \
  --environment-variables-override name=TERRAFORM_ACTION,value=plan
```

### Method 3: Using AWS Console

1. Go to CodeBuild project
2. Click "Start build"
3. Expand "Environment variables override"
4. Add variable:
   - **Name**: `TERRAFORM_ACTION`
   - **Value**: `apply`, `destroy`, or `plan`
5. Click "Start build"

## Troubleshooting

### Common Issues and Solutions

#### 1. **AWS CLI Not Configured**

```bash
# Error: "Unable to locate credentials"
# Solution: Configure AWS CLI
aws configure
```

#### 2. **Permission Denied Errors**

```bash
# Error: "User: arn:aws:iam::730335317277:user/mvdevtfuser is not authorized to perform: iam:CreatePolicy"
# This means your AWS user lacks IAM permissions to create policies and roles
```

**Solution Options:**

**Option A: Add AWS Managed Policy (Recommended)**

1. Go to AWS Console → IAM → Users → Find your user (`mvdevtfuser`)
2. Click "Add permissions" → "Attach policies directly"
3. Search and attach one of these policies:
   - `PowerUserAccess` (recommended - allows most actions except user management)
   - `IAMFullAccess` (for IAM operations only)
   - `AdministratorAccess` (full access - use with caution)

**Option B: Create Custom Policy**

1. Go to AWS Console → IAM → Policies → Create Policy
2. Use JSON and paste the policy from the "Security Considerations" section above
3. Attach the policy to your user

**Option C: Use AWS CLI (if you have admin access elsewhere)**

```bash
# Attach PowerUserAccess policy
aws iam attach-user-policy \
  --user-name mvdevtfuser \
  --policy-arn arn:aws:iam::aws:policy/PowerUserAccess

# Attach IAMFullAccess policy
aws iam attach-user-policy \
  --user-name mvdevtfuser \
  --policy-arn arn:aws:iam::aws:policy/IAMFullAccess
```

**Verify permissions after adding:**

```bash
# Test if you can now create IAM resources
aws iam list-policies --max-items 1
```

#### 3. **S3 Bucket Already Exists**

```bash
# Error: "BucketAlreadyExists"
# Solution: Choose a globally unique bucket name
./setup-s3-backend.sh my-unique-bucket-name-$(date +%s) us-east-1
```

#### 4. **Terraform Command Not Found in CodeBuild**

```bash
# Error: "terraform: command not found"
# Solution: The buildspec.yml automatically installs Terraform - ensure the build is using the correct buildspec.yml
```

#### 5. **GitHub Connection Issues**

```bash
# Error: "Repository not found"
# Solution: Ensure the GitHub repository is public or set up proper authentication for private repos
```

#### 6. **Region Mismatch**

```bash
# Error: "Error creating S3 bucket: InvalidLocationConstraint"
# Solution: Ensure the region in your AWS CLI config matches the region specified in scripts
aws configure get region
```

### Useful Commands

```bash
# Check AWS credentials
aws sts get-caller-identity

# List CodeBuild projects
aws codebuild list-projects

# Check build status
aws codebuild batch-get-builds --ids BUILD_ID

# View Terraform state (if using S3 backend)
terraform state list

# Check what resources will be created
terraform plan
```

## Next Steps

After creating these roles, you can:

1. Create CodeBuild projects that assume the CodeBuild role
2. Create CodePipeline pipelines that assume the CodePipeline role
3. Use these roles in your Terraform configurations for CI/CD

## Files Description

- `main.tf`: Main Terraform configuration and provider setup
- `variables.tf`: Input variables
- `iam_roles.tf`: IAM role definitions
- `codebuild_policies.tf`: CodeBuild IAM policies
- `codepipeline_policies.tf`: CodePipeline IAM policies
- `policy_attachments.tf`: Policy-to-role attachments
- `outputs.tf`: Output values
- `buildspec.yml`: CodeBuild build specification with parameterized actions
- `setup-s3-backend.sh`: Script to configure S3 backend
- `create-codebuild.sh`: Script to create CodeBuild project
- `trigger-build.sh`: Script to trigger builds with different actions
- `.gitignore`: Git ignore file for Terraform
- `terraform.tfvars.example`: Example variables file
