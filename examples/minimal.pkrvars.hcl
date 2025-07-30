# =====================================================
# Minimal Configuration Example
# =====================================================
# This example creates a basic Ubuntu AMI with only essential packages
# Usage: packer build -var-file="examples/minimal.pkrvars.hcl" packer.pkr.hcl

# AWS Configuration
aws_region = "us-east-1"

# EC2 Instance Configuration
instance_type = "t3.small"  # Smaller instance for basic builds

# AMI Configuration
ami_name_prefix  = "ubuntu-minimal"
root_volume_size = 15  # Smaller volume for minimal setup

# Minimal package list
essential_packages = [
  "curl",
  "vim",
  "git"
]

additional_packages = [
  "wget",
  "htop"
]
