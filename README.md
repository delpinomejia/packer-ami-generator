# Packer EC2 AMI Builder

A modern, infrastructure-as-code solution for building custom Ubuntu AMIs on AWS using Packer and Ansible. This project creates hardened, production-ready AMI images with a complete LAMP stack optimized for web applications.

## 🏗️ Architecture

This project uses:
- **Packer (HCL2)** - Infrastructure provisioning and AMI building
- **Ansible** - Configuration management and software provisioning
- **Ubuntu 24.04 LTS** - Base operating system
- **GitLab CI/CD** - Automated building and deployment

## 🚀 Quick Start

### Prerequisites

- [Packer](https://www.packer.io/downloads) = 1.9.0
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) = 6.0
- AWS CLI configured with appropriate credentials
- EC2 keypair named 'packer' in your target region

### Environment Setup

1. **Clone the repository:**
   ```bash
   git clone repository-url
   cd packer-ec2-ami
   ```

2. **Configure environment variables:**
   ```bash
   # Set your AWS credentials
   export AWS_ACCESS_KEY_ID="your-access-key"
   export AWS_SECRET_ACCESS_KEY="your-secret-key"
   export AWS_DEFAULT_REGION="us-east-1"
   ```

3. **Customize environment configurations:**
   Edit the files in `environments/` directory to match your requirements.

### Building AMIs

#### Using the Build Script (Recommended)

```bash
# Development environment
./scripts/build.sh dev validate
./scripts/build.sh dev build

# Staging environment
./scripts/build.sh staging build

# Production environment
./scripts/build.sh prod build
```

#### Using Packer Directly

```bash
# Development
packer validate -var-file="environments/dev.pkrvars.hcl" .
packer build -var-file="environments/dev.pkrvars.hcl" .

# Production
packer validate -var-file="environments/prod.pkrvars.hcl" .
packer build -var-file="environments/prod.pkrvars.hcl" .
```

## 📁 Project Structure

```
packer-ec2-ami/
├── main.pkr.hcl                 # Main Packer configuration
├── variables.pkr.hcl            # Variable definitions
├── versions.pkr.hcl             # Required providers and versions
├── environments/                # Environment-specific configurations
│   ├── dev.pkrvars.hcl         # Development variables
│   ├── staging.pkrvars.hcl     # Staging variables
│   └── prod.pkrvars.hcl        # Production variables
├── ansible/                     # Ansible configuration
│   ├── playbook.yml            # Main playbook
│   └── files/                  # Configuration files
├── scripts/
│   └── build.sh                # Build helper script
├── .gitlab-ci.yml              # GitLab CI/CD pipeline
└── README.md                   # This file
```

## 🔧 Configuration

### Environment Variables

Each environment has its own configuration file in the `environments/` directory:

- **dev.pkrvars.hcl** - Development environment settings
- **staging.pkrvars.hcl** - Staging environment settings  
- **prod.pkrvars.hcl** - Production environment settings

### Key Configuration Options

| Variable | Description | Example |
|----------|-------------|----------|
| `aws_region` | AWS region for AMI creation | `us-east-1` |
| `source_ami` | Base Ubuntu AMI ID | `ami-0866a3c8686eaeeba` |
| `instance_type` | EC2 instance type for building | `t3.small` |
| `ami_name_prefix` | Prefix for generated AMI names | `base-ubuntu-dev` |
| `php_version` | PHP version to install | `8.3` |
| `docker_repository` | Docker repository for container builds | `your-ecr-repo` |

## 🔒 Security Features

- **Hardened Ubuntu 24.04 LTS** base image
- **Fail2ban** intrusion prevention
- **ClamAV** antivirus protection
- **Automatic security updates** configured
- **Non-root user configurations**
- **Firewall rules** (via security groups)
- **PHP security configurations**

## 📦 Installed Software

### Web Stack
- **Nginx** - Web server
- **PHP 8.3** - Application runtime
- **Redis** - In-memory data store
- **PostgreSQL client** - Database client

### Development Tools
- **Git** - Version control
- **Composer** - PHP dependency manager
- **Node.js  npm** - JavaScript runtime and package manager
- **AWS CLI** - AWS command line interface

### System Utilities
- **Supervisor** - Process control system
- **Fail2ban** - Intrusion prevention
- **ClamAV** - Antivirus engine
- **ImageMagick** - Image processing
- **wkhtmltopdf** - HTML to PDF converter

## 🔄 CI/CD Pipeline

The included GitLab CI/CD pipeline (`/.gitlab-ci.yml`) provides:

- **Automated validation** of Packer configurations
- **Multi-environment builds** (dev, staging, prod)
- **Security scanning** of generated AMIs
- **Artifact management** and storage
- **Rollback capabilities**

### Pipeline Stages

1. **Validate** - Syntax and configuration validation
2. **Build** - AMI creation for each environment
3. **Test** - Basic functionality testing
4. **Deploy** - AMI registration and tagging

## 🐛 Debugging

### Enable Debug Logging
```bash
export PACKER_LOG=1
export PACKER_LOG_PATH="packer-debug.log"
```

### Common Issues

1. **AMI not found errors** - Verify the `source_ami` ID is correct for your region
2. **Permission denied** - Ensure your AWS credentials have EC2 permissions
3. **Ansible failures** - Check the Ansible playbook syntax with `ansible-playbook --syntax-check`
4. **Build timeouts** - Increase instance size or optimize provisioning scripts

### Accessing Build Instance

During builds, you can SSH into the instance:
```bash
ssh -i ~/.ssh/packer ubuntu@instance-ip
```

## 🔐 IAM Permissions

Minimum required IAM permissions:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AttachVolume",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CopyImage",
                "ec2:CreateImage",
                "ec2:CreateKeypair",
                "ec2:CreateSecurityGroup",
                "ec2:CreateSnapshot",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:DeleteKeyPair",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteSnapshot",
                "ec2:DeleteVolume",
                "ec2:DeregisterImage",
                "ec2:DescribeImageAttribute",
                "ec2:DescribeImages",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus",
                "ec2:DescribeRegions",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSnapshots",
                "ec2:DescribeSubnets",
                "ec2:DescribeTags",
                "ec2:DescribeVolumes",
                "ec2:DetachVolume",
                "ec2:GetPasswordData",
                "ec2:ModifyImageAttribute",
                "ec2:ModifyInstanceAttribute",
                "ec2:ModifySnapshotAttribute",
                "ec2:RegisterImage",
                "ec2:RunInstances",
                "ec2:StopInstances",
                "ec2:TerminateInstances"
            ],
            "Resource": "*"
        }
    ]
}
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow HCL2 best practices for Packer configurations
- Use Ansible best practices for playbook development
- Include tests for new features
- Update documentation for any changes
- Ensure all CI/CD pipeline checks pass

## 📋 Roadmap

- [ ] **Multi-OS Support** - Add CentOS and Amazon Linux variants
- [ ] **Container Support** - Enhanced Docker image building
- [ ] **Terraform Integration** - Infrastructure deployment automation
- [ ] **Ansible Vault** - Secrets management integration
- [ ] **Testing Framework** - Automated AMI testing with InSpec
- [ ] **Monitoring Integration** - Built-in monitoring and logging
- [ ] **Blue-Green Deployments** - Zero-downtime deployment strategies

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:

- Create an [Issue](../../issues) for bug reports
- Check existing [Discussions](../../discussions) for questions
- Review the [Wiki](../../wiki) for additional documentation

---

**Built with ❤️ using Packer, Ansible, and modern DevOps practices**

