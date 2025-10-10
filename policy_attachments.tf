# Policy Attachments for CodeBuild Role

resource "aws_iam_role_policy_attachment" "codebuild_base_policy_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_base_policy.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_ec2_vpc_policy_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_ec2_vpc_policy.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_secrets_policy_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_secrets_policy.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_lambda_policy_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_acm_policy_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_acm_policy.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_ecr_policy_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_ecr_policy.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_eventbridge_policy_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_eventbridge_policy.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_s3_policy_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_iam_policy_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_iam_policy.arn
}

# Policy Attachments for CodePipeline Role

resource "aws_iam_role_policy_attachment" "codepipeline_base_policy_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_base_policy.arn
}

resource "aws_iam_role_policy_attachment" "codepipeline_codecommit_policy_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_codecommit_policy.arn
}

resource "aws_iam_role_policy_attachment" "codepipeline_github_policy_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_github_policy.arn
}

resource "aws_iam_role_policy_attachment" "codepipeline_sns_policy_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_sns_policy.arn
}