# ============================================================
# Club Officers IAM Setup
# ============================================================
# HOW TO USE:
#   1. Fill in officer usernames in variables.tf
#   2. Run: terraform init
#   3. Run: terraform plan   (preview changes)
#   4. Run: terraform apply  (create resources)
# ============================================================

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment once you have an S3 bucket for shared state:
  # backend "s3" {
  #   bucket = "your-club-terraform-state-bucket"
  #   key    = "iam/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "aws" {
  region = var.aws_region
}
