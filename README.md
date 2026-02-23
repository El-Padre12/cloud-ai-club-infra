# Install Terraform, then in the folder with these files:
terraform init
terraform plan        # shows what it will create — review this!
terraform apply       # actually creates everything

# After apply, get the temp passwords with:
terraform output -json officer_passwords
