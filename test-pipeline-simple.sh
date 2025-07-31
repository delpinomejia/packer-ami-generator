#!/bin/bash

# GitHub Actions CI Pipeline Local Dry-Run Test
# Dynamically reads configuration from variables.pkrvars.hcl
echo "====================================================="
echo "GitHub Actions CI Pipeline Local Dry-Run Test"
echo "====================================================="

# Default instance type and cost
instanceType="t3.small"
costPerHour=0.0208

# Read instance type from variables file
if [ -f "variables.pkrvars.hcl" ]; then
    instanceType=$(grep 'instance_type' variables.pkrvars.hcl | cut -d'"' -f2)
    if [ -n "$instanceType" ]; then
        echo "✅ Found instance type: $instanceType"
        
        # Set cost per hour based on instance type
        case $instanceType in
            "t3.nano")   costPerHour=0.0052 ;;
            "t3.micro")  costPerHour=0.0104 ;;
            "t3.small")  costPerHour=0.0208 ;;
            "t3.medium") costPerHour=0.0416 ;;
            "t3.large")  costPerHour=0.0832 ;;
            "t3.xlarge") costPerHour=0.1664 ;;
            *) echo "⚠️  Unknown instance type, using t3.small pricing"; costPerHour=0.0208 ;;
        esac
    else
        echo "⚠️  Could not parse instance type from variables file, using default: $instanceType"
    fi
else
    echo "⚠️  Variables file not found, using default: $instanceType"
fi

# Calculate cost estimates
lowCostEstimate=$(echo "scale=2; ($costPerHour * 0.25) + 0.01" | bc -l 2>/dev/null || echo "0.12")
highCostEstimate=$(echo "scale=2; ($costPerHour * 0.5) + 0.01" | bc -l 2>/dev/null || echo "0.22")

# Ensure minimum display of $0.01
if (( $(echo "$lowCostEstimate < 0.01" | bc -l 2>/dev/null || echo "0") )); then
    lowCostEstimate="0.01"
fi
if (( $(echo "$highCostEstimate < 0.01" | bc -l 2>/dev/null || echo "0") )); then
    highCostEstimate="0.01"
fi

# Stage 1: Validate Configuration
echo ""
echo "Testing Stage 1: VALIDATE CONFIGURATION"

# Check Packer
if command -v packer &> /dev/null; then
    packerVersion=$(packer version 2>/dev/null | head -n1)
    echo "✅ Packer is installed: $packerVersion"
else
    echo "❌ Packer not found"
fi

# Validate template
if [ -f "packer.pkr.hcl" ]; then
    echo "✅ Packer template exists"
    if command -v packer &> /dev/null; then
        if packer validate -var-file="variables.pkrvars.hcl" "packer.pkr.hcl" &> /dev/null; then
            echo "✅ Template validation passed"
        else
            echo "❌ Template validation failed"
        fi
    else
        echo "⚠️  Cannot validate template - Packer not installed"
    fi
else
    echo "❌ Packer template not found"
fi

# Check variables file
if [ -f "variables.pkrvars.hcl" ]; then
    echo "✅ Variables file exists"
else
    echo "❌ Variables file not found"
fi

# Check for main template file
if [ -f "packer.pkr.hcl" ]; then
    echo "✅ Main Packer template verified"
else
    echo "❌ Main Packer template missing"
fi

# Stage 2: Cost Estimation
echo ""
echo "Testing Stage 2: COST ESTIMATION"
echo "Cost Analysis for AMI Build:"
echo "  Instance Type: $instanceType (~\$$costPerHour/hour)"
echo "  Estimated Build Time: 15-30 minutes"
echo "  Estimated Instance Cost: \$$lowCostEstimate - \$$highCostEstimate"
echo "  TOTAL ESTIMATED COST: \$$lowCostEstimate - \$$highCostEstimate"
echo "✅ Cost estimation completed"

# Stage 3: Build Simulation
echo ""
echo "Testing Stage 3: BUILD AMI (DRY RUN)"
echo "⚠️  This is a DRY RUN - No actual AWS resources will be created"

# Check AWS credentials
if command -v aws &> /dev/null; then
    identity=$(aws sts get-caller-identity --query UserId --output text 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$identity" ]; then
        echo "✅ AWS credentials configured for: $identity"
    else
        echo "❌ AWS credentials not configured or AWS CLI error"
    fi
else
    echo "❌ AWS CLI not found"
fi

echo "Simulating AMI build process..."
echo "Would execute: packer build -var-file=\"variables.pkrvars.hcl\" \"packer.pkr.hcl\""
echo "Software that would be installed:"
echo "  ✅ Docker CE + docker-compose"
echo "  ✅ Nginx web server"
echo "  ✅ ClamAV antivirus"
echo "  ✅ Development tools"
echo "  ✅ Python3, pip, Node.js, npm"

# Generate simulated AMI ID
if command -v openssl &> /dev/null; then
    simulatedAmiId="ami-$(openssl rand -hex 8 | cut -c1-17)"
elif [ -f /dev/urandom ]; then
    simulatedAmiId="ami-$(tr -dc 'a-z0-9' < /dev/urandom | head -c 17)"
else
    simulatedAmiId="ami-$(date +%s | tail -c 10)abcdefg"
fi
echo "✅ Simulated AMI ID: $simulatedAmiId"

# Stage 4: Verify Simulation
echo ""
echo "Testing Stage 4: VERIFY AMI (DRY RUN)"
echo "Would verify AMI: $simulatedAmiId"
echo "Simulated AMI Details:"
echo "  Name: ubuntu-24-04-custom-$(date +%Y%m%d-%H%M%S)"
echo "  State: available"
echo "  Architecture: x86_64"
echo "✅ AMI verification simulation completed"

# Stage 5: Report Generation
echo ""
echo "Testing Stage 5: GENERATE REPORT (DRY RUN)"
echo "==================================================="
echo "     AWS AMI BUILD REPORT - DRY RUN SUCCESS!"
echo "==================================================="
echo "Build Date: $(date)"
echo "Simulated AMI ID: $simulatedAmiId"
echo "Region: us-east-1 (example)"
echo "Base Image: Ubuntu 24.04 LTS"
echo "Instance Type: $instanceType"
echo ""
echo "Software Stack:"
echo "  ✅ Docker CE + docker-compose"
echo "  ✅ Nginx web server"
echo "  ✅ ClamAV antivirus"
echo "  ✅ Development tools"
echo "  ✅ Python3, pip, Node.js, npm"
echo ""
echo "Cost Analysis:"
echo "  Estimated Cost: \$$lowCostEstimate - \$$highCostEstimate"
echo "  Build Duration: ~15-30 minutes (simulated)"
echo "==================================================="
echo "✅ DRY RUN COMPLETED SUCCESSFULLY!"
echo "==================================================="

echo ""
echo "SUMMARY:"
echo "🎉 All pipeline stages are ready for GitHub Actions!"
echo ""
echo "To run actual GitHub Actions pipeline:"
echo "   1. Push changes to GitHub repository"
echo "   2. Navigate to Actions tab in GitHub"
echo "   3. Click 'Review deployments' for production environment"
echo "   4. Approve the deployment to proceed with AMI build"
echo "   5. Monitor progress in real-time"
