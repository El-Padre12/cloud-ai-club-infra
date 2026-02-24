# IAM Group — attach policies to the group, not individuals
resource "aws_iam_group" "officers" {
  name = "${var.club_name}-officers"
}

# One IAM user per officer, built from the list in variables.tf
resource "aws_iam_user" "officers" {
  for_each = toset(var.officers)

  name = "${var.club_name}-${each.value}"
  path = "/club-officers/"

  tags = {
    Club = var.club_name
    Role = "officer"
  }
}

# Add every user to the group
resource "aws_iam_user_group_membership" "officers" {
  for_each = toset(var.officers)

  user   = aws_iam_user.officers[each.value].name
  groups = [aws_iam_group.officers.name]
}

# Console login profiles — officers must reset password on first login
resource "aws_iam_user_login_profile" "officers" {
  for_each = toset(var.officers)

  user                    = aws_iam_user.officers[each.value].name
  password_reset_required = true

  lifecycle {
    ignore_changes = [password_length, password_reset_required, pgp_key]
  }
}

# The actual permissions policy
resource "aws_iam_policy" "officers_policy" {
  name        = "${var.club_name}-officers-policy"
  description = "Permissions for ${var.club_name} club officers"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # S3
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:CreateBucket",
          "s3:PutBucketPolicy",
          "s3:GetBucketPolicy",
          "s3:PutBucketWebsite",
          "s3:GetBucketWebsite",
          "s3:PutPublicAccessBlock",
          "s3:GetPublicAccessBlock",
          "s3:ListAllMyBuckets",
        ]
        Resource = ["arn:aws:s3:::*"]
      },

      # CloudFront
      {
        Sid    = "CloudFrontAccess"
        Effect = "Allow"
        Action = [
          "cloudfront:CreateDistribution",
          "cloudfront:UpdateDistribution",
          "cloudfront:GetDistribution",
          "cloudfront:ListDistributions",
          "cloudfront:DeleteDistribution",
          "cloudfront:CreateInvalidation",
          "cloudfront:GetInvalidation",
          "cloudfront:ListInvalidations",
          "cloudfront:TagResource",
        ]
        Resource = ["*"]
      },

      # DynamoDB
      {
        Sid    = "DynamoDBAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:CreateTable",
          "dynamodb:DescribeTable",
          "dynamodb:ListTables",
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchWriteItem",
          "dynamodb:BatchGetItem",
        ]
        Resource = ["arn:aws:dynamodb:*:*:table/*"]
      },

      # ACM
      {
        Sid    = "ACMAccess"
        Effect = "Allow"
        Action = [
          "acm:RequestCertificate",
          "acm:DescribeCertificate",
          "acm:ListCertificates",
          "acm:DeleteCertificate",
          "acm:GetCertificate",
          "acm:AddTagsToCertificate",
          "acm:ListTagsForCertificate",
        ]
        Resource = ["*"]
      },

      # Route 53
      {
        Sid    = "Route53Access"
        Effect = "Allow"
        Action = [
          "route53:CreateHostedZone",
          "route53:GetHostedZone",
          "route53:ListHostedZones",
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets",
          "route53:GetChange",
          "route53:ListTagsForResource",
          "route53:ChangeTagsForResource",
        ]
        Resource = ["*"]
      },

      # Lambda
      {
        Sid    = "LambdaAccess"
        Effect = "Allow"
        Action = [
          "lambda:CreateFunction",
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "lambda:GetFunction",
          "lambda:ListFunctions",
          "lambda:DeleteFunction",
          "lambda:InvokeFunction",
          "lambda:AddPermission",
          "lambda:GetPolicy",
          "lambda:TagResource",
          "lambda:ListTags",
        ]
        Resource = ["arn:aws:lambda:*:*:function:*"]
      },

      # PassRole scoped to Lambda only (prevents privilege escalation)
      {
        Sid    = "IAMPassRoleForLambda"
        Effect = "Allow"
        Action = ["iam:PassRole"]
        Resource = ["*"]
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "lambda.amazonaws.com"
          }
        }
      },

      # IAM read-only (so officers can see roles/policies)
      {
        Sid    = "IAMReadOnly"
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:ListRoles",
          "iam:GetPolicy",
          "iam:ListPolicies",
          "iam:ListAttachedRolePolicies",
        ]
        Resource = ["*"]
      },

      # CloudWatch Logs (essential for Lambda debugging)
      {
        Sid    = "CloudWatchLogsReadOnly"
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
        ]
        Resource = ["*"]
      },

      # Allow officers to manage their own credentials
      {
        Sid    = "SelfServiceCredentials"
        Effect = "Allow"
        Action = [
          "iam:ChangePassword",
          "iam:GetUser",
       ]
       Resource = [
          "*"             # "arn:aws:iam::*:user/$${aws:username}" for when users are already logged in
       ]
      },
      {
      Sid      = "GetPasswordPolicy"
      Effect   = "Allow"
      Action   = ["iam:GetAccountPasswordPolicy"]
      Resource = ["*"]
      },
    ]
  })
}

# Attach policy to group, not individual users
resource "aws_iam_group_policy_attachment" "officers" {
  group      = aws_iam_group.officers.name
  policy_arn = aws_iam_policy.officers_policy.arn
}
