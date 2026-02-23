variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "club_name" {
  type    = string
  default = "myclub" # <-- change this
}

# Add/remove officer names here as your roster changes
variable "officers" {
  type = list(string)
  default = [
    "officer-president",
    "officer-vp",
    "officer-secretary",
    "officer-treasurer",
    "officer-tech-lead",
    "officer-dev-1",
  ]
}
