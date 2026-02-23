data "aws_caller_identity" "current" {}

output "officer_usernames" {
  value = [for u in aws_iam_user.officers : u.name]
}

output "officer_passwords" {
  description = "Temp passwords — share securely, NOT over Slack"
  value       = { for k, v in aws_iam_user_login_profile.officers : k => v.password }
  sensitive   = true
  # View with: terraform output -json officer_passwords
}

output "officers_group_name" {
  value = aws_iam_group.officers.name
}

output "aws_console_login_url" {
  value = "https://${data.aws_caller_identity.current.account_id}.signin.aws.amazon.com/console"
}
