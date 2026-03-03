# Install Terraform, then in the folder with these files:
```bash 
 terraform init
 terraform plan        
 terraform apply       
 ```

# After apply, get the temp passwords with:
```bash
terraform output -json officer_passwords
```