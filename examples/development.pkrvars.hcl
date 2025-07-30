# =====================================================
# Development Configuration Example
# =====================================================
# This example creates a development-ready Ubuntu AMI with extensive tooling
# Usage: packer build -var-file="examples/development.pkrvars.hcl" packer.pkr.hcl

# AWS Configuration
aws_region = "us-west-2"

# EC2 Instance Configuration
instance_type = "t3.large"  # Larger instance for development builds

# AMI Configuration
ami_name_prefix  = "ubuntu-dev"
root_volume_size = 30  # Larger volume for development tools

# Extended package list for development
essential_packages = [
  "curl",
  "clamav",
  "vim",
  "git",
  "nano",
  "screen",
  "tmux"
]

additional_packages = [
  "wget",
  "htop",
  "unzip",
  "zip",
  "tree",
  "jq",
  "build-essential",
  "software-properties-common",
  "python3",
  "python3-pip",
  "python3-dev",
  "nodejs",
  "npm",
  "awscli",
  "nginx",
  "apache2-utils",
  "certbot",
  "mysql-client",
  "postgresql-client",
  "redis-tools",
  "nmap",
  "telnet",
  "netcat"
]
