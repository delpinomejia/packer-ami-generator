# =====================================================
# Ubuntu 24.04 LTS AMI Builder with Essential Packages
# =====================================================

# Variables (No hardcoded values)
variable "aws_region" {
  description = "AWS region where the AMI will be built"
  type        = string
  default     = null
}

variable "aws_access_key_id" {
  description = "AWS access key ID"
  type        = string
  default     = null
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS secret access key"
  type        = string
  default     = null
  sensitive   = true
}

variable "instance_type" {
  description = "EC2 instance type for building the AMI"
  type        = string
  default     = "t3.medium"
}

variable "ami_name_prefix" {
  description = "Prefix for the generated AMI name"
  type        = string
  default     = "ubuntu-custom"
}

variable "ami_version" {
  description = "Version number for the AMI (e.g., v1.0, v2.1)"
  type        = string
  default     = "v1.0"
}

variable "ubuntu_version" {
  description = "Ubuntu version to use (e.g., 24.04, 22.04, 20.04)"
  type        = string
  default     = "24.04"
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 8
}

variable "ssh_username" {
  description = "SSH username for connecting to the instance"
  type        = string
  default     = "ubuntu"
}

variable "essential_packages" {
  description = "Essential packages to install"
  type        = list(string)
  default     = [
    "curl",
    "clamav",
    "vim",
    "git"
  ]
}

variable "additional_packages" {
  description = "Additional useful packages to install"
  type        = list(string)
  default     = [
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
}

# Required Packer plugins
packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# Data source to get the latest Ubuntu 24.04 LTS AMI
data "amazon-ami" "ubuntu" {
  filters = {
    name                = "ubuntu/images/hvm-ssd*/ubuntu-noble-24.04-amd64-server-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"] # Canonical
  region      = var.aws_region
}

# Local values for computed fields
locals {
  # Enhanced timestamp format: YYYY-MM-DD-HHMM (24-hour format)
  timestamp    = formatdate("YYYY-MM-DD-HHMM", timestamp())
  # Comprehensive AMI name: prefix-ubuntu-version-ami-version-timestamp
  # Example: ubuntu-custom-24.04-v1.0-2025-01-31-0135
  ami_name     = "${var.ami_name_prefix}-${var.ubuntu_version}-${var.ami_version}-${local.timestamp}"
  
  # Docker configuration
  docker_gpg   = "https://download.docker.com/linux/ubuntu/gpg"
  docker_repo  = "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

  common_tags = {
    Name         = local.ami_name
    OS           = "Ubuntu 24.04 LTS"
    CreatedBy    = "packer"
    CreatedDate  = local.timestamp
    BuildSource  = "packer-ami-generator-v1"
  }
}

# Amazon EBS builder configuration
source "amazon-ebs" "ubuntu" {
  # AWS credentials (will use environment variables if not provided via vars)
  region                      = var.aws_region
  
  # AMI configuration
  ami_name                    = local.ami_name
  ami_description             = "Custom Ubuntu 24.04 LTS AMI"
  instance_type               = var.instance_type
  source_ami                  = data.amazon-ami.ubuntu.id
  ssh_username                = var.ssh_username
  force_deregister            = true
  force_delete_snapshot       = true
  associate_public_ip_address = true
  
  # EBS volume configuration
  ebs_optimized = true
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  # Security configuration
  temporary_security_group_source_cidrs = ["0.0.0.0/0"]
  
  # Resource tags
  tags          = local.common_tags
  snapshot_tags = merge(local.common_tags, { Name = "${local.ami_name}-snapshot" })
}

# Build configuration
build {
  name    = "ubuntu-24-04-essential"
  sources = ["source.amazon-ebs.ubuntu"]

  # Wait for cloud-init to complete
  provisioner "shell" {
    inline = [
      "echo 'ðŸ”„ Waiting for cloud-init to complete...'",
      "sudo cloud-init status --wait",
      "echo 'âœ… Cloud-init completed successfully'"
    ]
  }

  # System update and package installation
  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    inline = [
      "echo 'ðŸ”„ Starting system update and package installation...'",
      
      "sudo apt-get clean",
      "sudo apt-get update -y",
      "sudo apt-get upgrade -y",
      
      "echo 'ðŸ“¦ Installing essential packages...'",
      "sudo apt-get install -y ${join(" ", var.essential_packages)}",
      "sudo apt-get install -y ${join(" ", var.additional_packages)}",
      "echo 'âœ… Essential packages installed successfully'"
    ]
  }

  # Docker installation
  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    inline = [
      "echo 'ðŸ³ Installing Docker...'",
      
      "curl -fsSL ${local.docker_gpg} | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      
      "echo \"${local.docker_repo}\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      
      "sudo apt-get update -y",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
      
      "sudo usermod -aG docker ${var.ssh_username}",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "echo 'âœ… Docker installed and configured successfully'"
    ]
  }

  # ClamAV configuration
  provisioner "shell" {
    inline = [
      "echo 'ðŸ›¡ï¸ Configuring ClamAV...'",
      "sudo systemctl enable clamav-freshclam",
      "sudo systemctl start clamav-freshclam",
      "echo 'âœ… ClamAV configured successfully'"
    ]
  }

  # Web server setup
  provisioner "shell" {
    inline = [
      "echo 'ðŸŒ Setting up web server...'",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",
      
      "echo '<h1>ðŸš€ Custom Ubuntu AMI</h1>' | sudo tee /var/www/html/index.html > /dev/null",
      "echo '<p>Built with Packer on <strong>'$(date)'</strong></p>' | sudo tee -a /var/www/html/index.html > /dev/null",
      "echo '<p>Includes: ${join(", ", concat(var.essential_packages, var.additional_packages))}</p>' | sudo tee -a /var/www/html/index.html > /dev/null",
      "echo 'âœ… Web server configured successfully'"
    ]
  }

  # System optimization and cleanup
  provisioner "shell" {
    inline = [
      "echo 'ðŸ§¹ Running system cleanup and optimization...'",
      
      "sudo apt-get autoremove -y",
      "sudo apt-get autoclean",
      
      "sudo rm -rf /tmp/*",
      "sudo rm -rf /var/cache/apt/archives/*",
      "sudo rm -rf /var/lib/apt/lists/*",
      
      "sudo truncate -s 0 /var/log/*log",
      
      "cat /dev/null > ~/.bash_history",
      
      "echo 'âœ… System cleanup completed successfully'",
      "echo 'ðŸŽ‰ AMI build process completed! AMI name: ${local.ami_name}'"
    ]
  }
}

