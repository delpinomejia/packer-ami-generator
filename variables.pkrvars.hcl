# =====================================================
# User Variables for Ubuntu AMI Builder
# =====================================================
# Copy this file and customize the values below for your needs
# Usage: packer build -var-file="variables.pkrvars.hcl" packer.pkr.hcl

# AWS Configuration
aws_region           = "us-east-1"     # Change to your preferred AWS region
# aws_access_key_id    = null          # Use environment variable AWS_ACCESS_KEY_ID
# aws_secret_access_key = null         # Use environment variable AWS_SECRET_ACCESS_KEY

# EC2 Instance Configuration
instance_type = "t3.small"   # Instance type for building the AMI (cost-optimized)

# AMI Configuration
# Final AMI name format: {prefix}-{ubuntu_version}-{ami_version}-{timestamp}
# Example: ubuntu-custom-24.04-v1.0-2025-01-31-0135
ami_name_prefix    = "ubuntu-custom"     # Prefix for your AMI name
ami_version        = "v1.0"              # AMI version (e.g., v1.0, v2.1)
ubuntu_version     = "24.04"             # Ubuntu version (e.g., 24.04, 22.04, 20.04)
root_volume_size   = 8                   # Root volume size in GB
ssh_username       = "ubuntu"            # SSH username (typically 'ubuntu' for Ubuntu AMIs)

# Package Configuration - Customize these lists as needed
essential_packages = [
  "curl",
  "clamav",
  "vim", 
  "git"
]

additional_packages = [
  "wget",
  "htop",
  "unzip",
  "zip",
  "build-essential",
  "software-properties-common",
  "python3",
  "python3-pip",
  "nginx"
]

# Example: Minimal package list (uncomment to use)
# essential_packages = ["curl", "vim", "git"]
# additional_packages = ["wget", "htop"]

# Example: Extended package list (uncomment to use)
# essential_packages = ["curl", "clamav", "vim", "git", "nano", "screen"]
# additional_packages = [
#   "wget", "htop", "unzip", "zip", "tree", "jq",
#   "build-essential", "software-properties-common",
#   "python3", "python3-pip", "nodejs", "npm",
#   "awscli", "nginx", "apache2-utils", "certbot"
# ]
