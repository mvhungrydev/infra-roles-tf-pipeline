# IAM Policies for CodeBuild

# Base CodeBuild policy for CloudWatch logs
resource "aws_iam_policy" "codebuild_base_policy" {
  name        = "${var.project_name}-${var.environment}-codebuild-base-policy"
  description = "Base policy for CodeBuild service"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.project_name}-*"
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
        ]
        Resource = "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:report-group/${var.project_name}-*"
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:*"
        ]
        Resource = "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:project/${var.project_name}-*"
      }
    ]
  })

  tags = var.tags
}

# EC2 and VPC permissions for CodeBuild
resource "aws_iam_policy" "codebuild_ec2_vpc_policy" {
  name        = "${var.project_name}-${var.environment}-codebuild-ec2-vpc-policy"
  description = "Policy for EC2 and VPC operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
          "vpc:*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# Secrets Manager permissions for CodeBuild
resource "aws_iam_policy" "codebuild_secrets_policy" {
  name        = "${var.project_name}-${var.environment}-codebuild-secrets-policy"
  description = "Policy for Secrets Manager operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:CreateSecret",
          "secretsmanager:DeleteSecret",
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:ListSecrets",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecret",
          "secretsmanager:RestoreSecret",
          "secretsmanager:TagResource",
          "secretsmanager:UntagResource"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# Lambda permissions for CodeBuild
resource "aws_iam_policy" "codebuild_lambda_policy" {
  name        = "${var.project_name}-${var.environment}-codebuild-lambda-policy"
  description = "Policy for Lambda operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*lambda*"
      }
    ]
  })

  tags = var.tags
}

# ACM (Certificate Manager) permissions for CodeBuild
resource "aws_iam_policy" "codebuild_acm_policy" {
  name        = "${var.project_name}-${var.environment}-codebuild-acm-policy"
  description = "Policy for ACM operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "acm:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:GetChange",
          "route53:ChangeResourceRecordSets"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# ECR permissions for CodeBuild
resource "aws_iam_policy" "codebuild_ecr_policy" {
  name        = "${var.project_name}-${var.environment}-codebuild-ecr-policy"
  description = "Policy for ECR operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# EventBridge permissions for CodeBuild
resource "aws_iam_policy" "codebuild_eventbridge_policy" {
  name        = "${var.project_name}-${var.environment}-codebuild-eventbridge-policy"
  description = "Policy for EventBridge operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "events:*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# S3 permissions for CodeBuild (for Terraform state and artifacts)
resource "aws_iam_policy" "codebuild_s3_policy" {
  name        = "${var.project_name}-${var.environment}-codebuild-s3-policy"
  description = "Policy for S3 operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# IAM permissions for CodeBuild (to create service roles for resources)
resource "aws_iam_policy" "codebuild_iam_policy" {
  name        = "${var.project_name}-${var.environment}-codebuild-iam-policy"
  description = "Policy for IAM operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:ListRoles",
          "iam:PassRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:GetPolicy",
          "iam:ListPolicies",
          "iam:CreateInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:GetInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:TagPolicy",
          "iam:UntagPolicy"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}