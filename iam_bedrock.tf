# Bedrock Users Group scoped to Cloud Club chatbot use case
# Claude 3 Haiku via Bedrock, S3 knowledge bucket, API Gateway

resource "aws_iam_group" "bedrock_users" {
  name = "${var.club_name}-bedrock-users"
}

# Add other officers when ready
resource "aws_iam_user_group_membership" "bedrock_users" {
  for_each = toset([
    "Jennifer",
    
  ])

  user   = aws_iam_user.officers[each.value].name
  groups = [aws_iam_group.bedrock_users.name]
}

resource "aws_iam_policy" "bedrock_policy" {
  name        = "${var.club_name}-bedrock-policy"
  description = "Scoped Bedrock access for Cloud Club chatbot (Claude 3 Haiku)"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # Bedrock Claude 3 Haiku only
      {
        Sid    = "BedrockClaude3Haiku"
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream",
          "bedrock:ListFoundationModels",
          "bedrock:GetFoundationModel",
          "bedrock:ListInferenceProfiles",
        ]
        Resource = [
          "arn:aws:bedrock:*::foundation-model/anthropic.claude-3-haiku*",
          "arn:aws:bedrock:*:*:inference-profile/*",
        ]
      },

      # S3 — read only, scoped to knowledge bucket
      {
        Sid    = "S3KnowledgeBucketRead"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
        ]
        Resource = [
          "arn:aws:s3:::cloud-club-knowledge.json",
          "arn:aws:s3:::cloud-club-knowledge.json/*",
        ]
      },

      # API Gateway — manage the /chat endpoint
      {
        Sid    = "APIGatewayAccess"
        Effect = "Allow"
        Action = [
          "apigateway:GET",
          "apigateway:POST",
          "apigateway:PUT",
          "apigateway:DELETE",
          "apigateway:PATCH",
        ]
        Resource = ["arn:aws:apigateway:*::/*"]
      },
    ]
  })
}

resource "aws_iam_group_policy_attachment" "bedrock_users" {
  group      = aws_iam_group.bedrock_users.name
  policy_arn = aws_iam_policy.bedrock_policy.arn
}