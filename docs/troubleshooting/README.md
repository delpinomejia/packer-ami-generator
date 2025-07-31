# 🐛 Troubleshooting Guide

This directory contains comprehensive troubleshooting documentation for the AWS AMI Builder project.

## 📚 Available Guides

### 🔧 **Critical Issues**
- **[Unicode Encoding Issues](unicode-encoding-gitlab-ci.md)** - Fix GitLab CI YAML syntax errors caused by Windows encoding issues
- **YAML Validation** - Use yamllint.com and other validators to catch syntax errors
- **before_script Configuration** - Resolve GitLab CI array format requirements

### 🏗️ **Pipeline Issues**
- **Build Failures** - Common Packer build problems and solutions
- **AWS Credential Issues** - Authentication and permission problems
- **Cost Management** - Unexpected charges and optimization tips
- **Indentation Errors** - YAML formatting and structure issues

### 🛠️ **General Issues**
- **Local Development** - Setting up and testing locally
- **Version Compatibility** - Packer, AWS CLI, and dependency issues
- **Performance Optimization** - Build time and resource optimization

## 🆘 Quick Help

### Most Common Issues
1. **GitLab CI Pipeline Fails** → Check [Unicode Encoding Issues](unicode-encoding-gitlab-ci.md)
2. **Packer Validation Errors** → Verify AWS credentials and template syntax
3. **High Build Costs** → Review instance type configuration and build frequency

### Getting Support
- 📋 Check existing [GitLab Issues](https://gitlab.com/pdelpino/packer-ami-generator-v1/-/issues)
- 🧪 Run the testing script: `./test-pipeline-simple.ps1`
- 📊 Review build logs in GitLab CI/CD interface

---

**Need to add a new troubleshooting guide?** Please contribute by:
1. Creating a detailed markdown file in this directory
2. Adding it to this index
3. Submitting a merge request

---

*Last Updated: 2025-01-31*
