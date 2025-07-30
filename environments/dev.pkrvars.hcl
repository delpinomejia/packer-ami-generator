# environments/dev.pkrvars.hcl

# AWS settings
aws_region = "us-east-1"
source_ami = "ami-0866a3c8686eaeeba" # Ubuntu 24.04 LTS (latest) - us-east-1
instance_type = "t3.small"

# AMI settings
ami_name_prefix = "base-ubuntu-dev"
ami_description = "Base Ubuntu 24.04 LTS image for dev environment with PHP, Nginx, and development tools"

# Ansible settings
ansible_playbook = "ansible/playbook.yml"
ansible_extra_vars = {
  environment = "dev"
  email       = "dev-infrastructure@example.com"
  php_version = "8.3"
}

# Docker settings
docker_repository = "your-ecr-repo-here"
docker_tag        = "dev-latest"

# Resource tags
tags = {
  Environment = "dev"
  Project     = "base-ami"
  CreatedBy   = "packer"
  OS          = "ubuntu-24.04"
}
