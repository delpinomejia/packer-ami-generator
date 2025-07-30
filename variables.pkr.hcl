# variables.pkr.hcl

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "aws_region" {
  type        = string
  description = "AWS region to build the AMI in"
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.aws_region))
    error_message = "AWS region must be in the format 'us-east-1', 'eu-west-1', etc."
  }
}

variable "source_ami" {
  type        = string
  description = "Source AMI to build from"
}

variable "instance_type" {
  type        = string
  description = "Instance type to use for the build"
  default     = "t3.micro"

  validation {
    condition     = can(regex("^[a-z][0-9][a-z]?\\.?[a-z]+$", var.instance_type))
    error_message = "Instance type must be a valid EC2 instance type."
  }
}

variable "ami_name_prefix" {
  type        = string
  description = "Prefix for the AMI name"
}

variable "ami_description" {
  type        = string
  description = "Description of the AMI"
}

variable "ssh_username" {
  type        = string
  description = "SSH username for the build instance"
  default     = "ubuntu"
}

variable "root_volume_size" {
  type        = number
  description = "Size of the root volume in GB"
  default     = 20

  validation {
    condition     = var.root_volume_size >= 8 && var.root_volume_size <= 1000
    error_message = "Root volume size must be between 8 and 1000 GB."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the AMI and instance"
  default     = {}
}

variable "ansible_playbook" {
  type        = string
  description = "Path to the Ansible playbook to run"
}

variable "ansible_extra_vars" {
  type        = map(string)
  description = "Extra variables to pass to Ansible"
  default     = {}
}

variable "docker_image" {
  type        = string
  description = "Base Docker image to build from"
  default     = "ubuntu:22.04"
}

variable "docker_commit" {
  type        = bool
  description = "Whether to commit the Docker image"
  default     = true
}

variable "docker_pull" {
  type        = bool
  description = "Whether to pull the base Docker image"
  default     = true
}

variable "docker_changes" {
  type        = list(string)
  description = "Changes to apply to the Docker image"
  default     = []
}

variable "docker_repository" {
  type        = string
  description = "Docker repository to push to"
  default     = ""
}

variable "docker_tag" {
  type        = string
  description = "Tag for the Docker image"
  default     = "latest"
}

variable "ecr_login" {
  type        = bool
  description = "Whether to log in to ECR"
  default     = false
}

variable "login_server" {
  type        = string
  description = "Docker login server"
  default     = ""
}

variable "login_user" {
  type        = string
  description = "Docker login user"
  default     = ""
  sensitive   = true
}

variable "login_password" {
  type        = string
  description = "Docker login password"
  default     = ""
  sensitive   = true
}
