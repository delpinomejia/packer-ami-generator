# main.pkr.hcl

# Data sources for AMI lookup
data "amazon-ami" "ubuntu" {
  filters = {
    name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"] # Canonical
  region      = var.aws_region
}

# Local values for computed fields
locals {
  timestamp = formatdate("YYYY-MM-DD-hhmm", timestamp())
  ami_name  = "${var.ami_name_prefix}-${var.environment}-${local.timestamp}"
  
  common_tags = merge(var.tags, {
    Name         = local.ami_name
    Environment  = var.environment
    CreatedBy    = "packer"
    CreatedDate  = local.timestamp
    SourceAMI    = var.source_ami != "" ? var.source_ami : data.amazon-ami.ubuntu.id
  })
}

# Amazon EBS builder
source "amazon-ebs" "ubuntu" {
  ami_name                    = local.ami_name
  ami_description             = var.ami_description
  instance_type               = var.instance_type
  region                      = var.aws_region
  source_ami                  = var.source_ami != "" ? var.source_ami : data.amazon-ami.ubuntu.id
  ssh_username                = var.ssh_username
  force_deregister            = true
  force_delete_snapshot       = true
  associate_public_ip_address = true
  
  # EBS settings
  ebs_optimized = true
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  # Security
  temporary_security_group_source_cidrs = ["0.0.0.0/0"]
  
  tags          = local.common_tags
  snapshot_tags = local.common_tags
}

# Docker builder
source "docker" "ubuntu" {
  image  = var.docker_image
  commit = var.docker_commit
  pull   = var.docker_pull
  
  changes = concat([
    "WORKDIR /var/www/html",
    "CMD [\"nginx\", \"-g\", \"daemon off;\"]",
    "EXPOSE 80"
  ], var.docker_changes)
}

# Build definition
build {
  name    = "ubuntu-base"
  sources = [
    "source.amazon-ebs.ubuntu",
    "source.docker.ubuntu"
  ]

  # Copy files to the instance
  provisioner "file" {
    source      = "ansible/files/"
    destination = "/tmp/"
  }

  # Initial system setup
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "ENV=${var.environment}",
    ]
    inline = [
      "echo 'Starting system update and basic setup...'",
      "sleep 30", # Wait for cloud-init to finish
      "sudo apt-get update -y",
      "sudo apt-get install -y software-properties-common apt-transport-https ca-certificates curl gnupg lsb-release",
      "echo 'System update completed'",
    ]
    only = ["amazon-ebs.ubuntu"]
  }

  # Docker-specific setup
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "ENV=${var.environment}",
    ]
    inline = [
      "apt-get update -y",
      "apt-get install -y software-properties-common apt-transport-https ca-certificates curl gnupg",
      "apt-get install -y python3 python3-pip",
      "pip3 install ansible",
    ]
    only = ["docker.ubuntu"]
  }

  # Run Ansible playbook
  provisioner "ansible-local" {
    playbook_file = var.ansible_playbook
    extra_arguments = [
      for key, value in var.ansible_extra_vars : "--extra-vars"
      if value != ""
    ]
    extra_arguments = [
      for key, value in var.ansible_extra_vars : "${key}=${value}"
      if value != ""
    ]
  }

  # Final cleanup and optimization
  provisioner "shell" {
    inline = [
      "echo 'Running final cleanup...'",
      "sudo apt-get autoremove -y",
      "sudo apt-get autoclean",
      "sudo rm -rf /tmp/*",
      "sudo rm -rf /var/cache/apt/archives/*",
      "sudo rm -rf /var/lib/apt/lists/*",
      "history -c",
      "echo 'AMI build completed successfully'",
    ]
    only = ["amazon-ebs.ubuntu"]
  }

  # Docker post-processors
  post-processor "docker-tag" {
    repository = var.docker_repository
    tags       = [var.docker_tag, "${var.docker_tag}-${local.timestamp}"]
    only       = ["docker.ubuntu"]
  }

  post-processor "docker-push" {
    ecr_login = var.ecr_login
    login_server = var.login_server
    only = ["docker.ubuntu"]
  }
}
