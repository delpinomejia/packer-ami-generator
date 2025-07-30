# environments/staging.pkrvars.hcl

# AWS settings
aws_region = "us-east-1"
source_ami = "ami-0866a3c8686eaeeba" # Ubuntu 24.04 LTS (latest) - us-east-1
instance_type = "t3.small"

# AMI settings
ami_name_prefix = "base-ubuntu-staging"
ami_description = "Base Ubuntu 24.04 LTS image for staging environment with PHP, Nginx, and production-ready tools"

# Ansible settings
ansible_playbook = "ansible/playbook.yml"
ansible_extra_vars = {
  environment = "staging"
  email       = "staging-infrastructure@example.com"
  php_version = "8.3"
}

# Docker settings
docker_repository = "your-ecr-repo-here"
docker_tag        = "staging-latest"

# Resource tags
tags = {
  Environment = "staging"
  Project     = "base-ami"
  CreatedBy   = "packer"
  OS          = "ubuntu-24.04"
}
