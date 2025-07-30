# environments/prod.pkrvars.hcl

# AWS settings
aws_region = "us-east-1"
source_ami = "ami-0866a3c8686eaeeba" # Ubuntu 24.04 LTS (latest) - us-east-1
instance_type = "t3.micro" # Smaller instance for prod builds to save costs

# AMI settings
ami_name_prefix = "base-ubuntu-prod"
ami_description = "Base Ubuntu 24.04 LTS image for production environment with PHP, Nginx, and security hardening"

# Ansible settings
ansible_playbook = "ansible/playbook.yml"
ansible_extra_vars = {
  environment = "prod"
  email       = "infrastructure@example.com"
  php_version = "8.3"
}

# Docker settings
docker_repository = "your-ecr-repo-here"
docker_tag        = "prod-latest"

# Resource tags
tags = {
  Environment = "prod"
  Project     = "base-ami"
  CreatedBy   = "packer"
  OS          = "ubuntu-24.04"
  Backup      = "required"
}
