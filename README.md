# Packer EC2 AMI Builder

<div align="center">

![Packer](https://img.shields.io/badge/Packer-1.9+-02A8EF?style=for-the-badge&logo=packer&logoColor=white)
![Ansible](https://img.shields.io/badge/Ansible-6.0+-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04_LTS-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-EC2-FF9900?style=for-the-badge&logo=amazon-aws&logoColor=white)

![GitLab CI](https://img.shields.io/badge/GitLab_CI-Ready-FC6D26?style=for-the-badge&logo=gitlab&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Version](https://img.shields.io/badge/Version-1.0-blue?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Production_Ready-success?style=for-the-badge)

</div>

---

<p align="center">
  <strong>🚀 A modern, infrastructure-as-code solution for building custom Ubuntu AMIs on AWS using Packer and Ansible</strong>
</p>

<p align="center">
  This project creates hardened, production-ready AMI images with a complete LAMP stack optimized for web applications.
</p>

<div align="center">

### ⭐ **Key Features**

🔧 **Modern HCL2 Syntax** • 🌍 **Multi-Environment** • 🔒 **Security Hardened** • 🤖 **CI/CD Ready**

</div>

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

## 📦 Technology Stack

<div align="center">

### 🌐 Web Stack

![Nginx](https://img.shields.io/badge/Nginx-009639?style=flat-square&logo=nginx&logoColor=white)
![PHP](https://img.shields.io/badge/PHP-8.3-777BB4?style=flat-square&logo=php&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-DC382D?style=flat-square&logo=redis&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-336791?style=flat-square&logo=postgresql&logoColor=white)

### 🛠️ Development Tools

![Git](https://img.shields.io/badge/Git-F05032?style=flat-square&logo=git&logoColor=white)
![Composer](https://img.shields.io/badge/Composer-885630?style=flat-square&logo=composer&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-339933?style=flat-square&logo=node.js&logoColor=white)
![npm](https://img.shields.io/badge/npm-CB3837?style=flat-square&logo=npm&logoColor=white)
![AWS CLI](https://img.shields.io/badge/AWS_CLI-232F3E?style=flat-square&logo=amazon-aws&logoColor=white)

### 🔧 System Utilities

![Supervisor](https://img.shields.io/badge/Supervisor-Process_Control-blue?style=flat-square)
![Fail2ban](https://img.shields.io/badge/Fail2ban-Security-red?style=flat-square)
![ClamAV](https://img.shields.io/badge/ClamAV-Antivirus-green?style=flat-square)
![ImageMagick](https://img.shields.io/badge/ImageMagick-Image_Processing-purple?style=flat-square)
![wkhtmltopdf](https://img.shields.io/badge/wkhtmltopdf-PDF_Generation-orange?style=flat-square)

</div>

## 📊 **Installed Software Details**

<table align="center">
<tr>
<td width="33%">

**🌐 Web Stack**
- **Nginx** - High-performance web server
- **PHP 8.3** - Modern PHP runtime with latest features
- **Redis** - In-memory data store and cache
- **PostgreSQL Client** - Database connectivity

</td>
<td width="33%">

**🛠️ Development Tools**
- **Git** - Distributed version control
- **Composer** - PHP dependency manager
- **Node.js & npm** - JavaScript ecosystem
- **AWS CLI** - Cloud management interface

</td>
<td width="33%">

**🔧 System Utilities**
- **Supervisor** - Process monitoring
- **Fail2ban** - Intrusion prevention
- **ClamAV** - Real-time antivirus
- **ImageMagick** - Image manipulation
- **wkhtmltopdf** - HTML to PDF conversion

</td>
</tr>
</table>

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

<div align="center">

## 📈 **Project Stats**

![Lines of Code](https://img.shields.io/badge/Lines_of_Code-2000+-brightgreen?style=flat-square)
![Files](https://img.shields.io/badge/Files-20+-blue?style=flat-square)
![Environments](https://img.shields.io/badge/Environments-3-orange?style=flat-square)
![Build Time](https://img.shields.io/badge/Build_Time-~15_min-yellow?style=flat-square)

### 🏆 **Quality Metrics**

![Security](https://img.shields.io/badge/Security-Hardened-green?style=flat-square&logo=shield)
![Documentation](https://img.shields.io/badge/Documentation-Complete-blue?style=flat-square&logo=book)
![Testing](https://img.shields.io/badge/Testing-CI/CD_Ready-purple?style=flat-square&logo=github-actions)
![Maintainability](https://img.shields.io/badge/Maintainability-High-brightgreen?style=flat-square&logo=code-climate)

</div>

<div align="center">

### 🌟 **If this project helped you, please give it a star!** ⭐

**Built with ❤️ using Packer, Ansible, and modern DevOps practices**

<sub>Made by [Pablo del Pino](https://github.com/pdelpino) • Follow me for more DevOps content!</sub>

</div>

