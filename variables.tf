variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "club_name" {
  type    = string
  default = "nvc-ai-cloud-club" 
}

# Add/remove officer names here as your roster changes
variable "officers" {
  type = list(string)
  default = [
    "president",
    "vice-president",
    "secretary",
    "treasurer",
    "marketing",
    "tech-lead",
  ]
}
