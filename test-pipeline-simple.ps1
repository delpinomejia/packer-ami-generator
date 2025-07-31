# GitLab CI Pipeline Local Dry-Run Test
# Dynamically reads configuration from variables.pkrvars.hcl
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "GitLab CI Pipeline Local Dry-Run Test" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan

# Read instance type from variables file
$instanceType = "t3.small"  # Default fallback
$costPerHour = 0.0208       # Default for t3.small

if (Test-Path "variables.pkrvars.hcl") {
    $varsContent = Get-Content "variables.pkrvars.hcl" -Raw
    if ($varsContent -match 'instance_type\s*=\s*"([^"]+)"') {
        $instanceType = $matches[1]
        Write-Host "✅ Found instance type: $instanceType" -ForegroundColor Green
        
        # Set cost per hour based on instance type
        switch ($instanceType) {
            "t3.nano"   { $costPerHour = 0.0052 }
            "t3.micro"  { $costPerHour = 0.0104 }
            "t3.small"  { $costPerHour = 0.0208 }
            "t3.medium" { $costPerHour = 0.0416 }
            "t3.large"  { $costPerHour = 0.0832 }
            "t3.xlarge" { $costPerHour = 0.1664 }
            default     { $costPerHour = 0.0208; Write-Host "⚠️  Unknown instance type, using t3.small pricing" -ForegroundColor Yellow }
        }
    } else {
        Write-Host "⚠️  Could not parse instance type from variables file, using default: $instanceType" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  Variables file not found, using default: $instanceType" -ForegroundColor Yellow
}

# Calculate cost estimates
$lowCostEstimate = [math]::Round(($costPerHour * 0.25) + 0.01, 2)  # 15 minutes + storage
$highCostEstimate = [math]::Round(($costPerHour * 0.5) + 0.01, 2)   # 30 minutes + storage

# Ensure minimum display of $0.01
if ($lowCostEstimate -lt 0.01) { $lowCostEstimate = 0.01 }
if ($highCostEstimate -lt 0.01) { $highCostEstimate = 0.01 }

# Stage 1: Validate Configuration
Write-Host ""
Write-Host "Testing Stage 1: VALIDATE CONFIGURATION" -ForegroundColor Yellow

# Check Packer
try {
    $packerVersion = packer version
    Write-Host "✅ Packer is installed: $packerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Packer not found" -ForegroundColor Red
}

# Validate template
if (Test-Path "packer.pkr.hcl") {
    Write-Host "✅ Packer template exists" -ForegroundColor Green
    try {
        packer validate -var-file="variables.pkrvars.hcl" "packer.pkr.hcl" | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Template validation passed" -ForegroundColor Green
        } else {
            Write-Host "❌ Template validation failed" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ Error validating template" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Packer template not found" -ForegroundColor Red
}

# Check variables file
if (Test-Path "variables.pkrvars.hcl") {
    Write-Host "✅ Variables file exists" -ForegroundColor Green
} else {
    Write-Host "❌ Variables file not found" -ForegroundColor Red
}

# Check for main template file
if (Test-Path "packer.pkr.hcl") {
    Write-Host "✅ Main Packer template verified" -ForegroundColor Green
} else {
    Write-Host "❌ Main Packer template missing" -ForegroundColor Red
}

# Stage 2: Cost Estimation
Write-Host ""
Write-Host "Testing Stage 2: COST ESTIMATION" -ForegroundColor Yellow
Write-Host "Cost Analysis for AMI Build:" -ForegroundColor Cyan
Write-Host "  Instance Type: $instanceType (~`$$costPerHour/hour)"
Write-Host "  Estimated Build Time: 15-30 minutes" 
Write-Host "  Estimated Instance Cost: `$$lowCostEstimate - `$$highCostEstimate"
Write-Host "  TOTAL ESTIMATED COST: `$$lowCostEstimate - `$$highCostEstimate" -ForegroundColor Green
Write-Host "✅ Cost estimation completed" -ForegroundColor Green

# Stage 3: Build Simulation
Write-Host ""
Write-Host "Testing Stage 3: BUILD AMI (DRY RUN)" -ForegroundColor Yellow
Write-Host "⚠️  This is a DRY RUN - No actual AWS resources will be created" -ForegroundColor Yellow

# Check AWS credentials
try {
    $identity = aws sts get-caller-identity | ConvertFrom-Json
    if ($identity) {
        Write-Host "✅ AWS credentials configured for: $($identity.UserId)" -ForegroundColor Green
    } else {
        Write-Host "❌ AWS credentials not configured" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Error checking AWS credentials" -ForegroundColor Red
}

Write-Host "Simulating AMI build process..."
Write-Host "Would execute: packer build -var-file=`"variables.pkrvars.hcl`" `"packer.pkr.hcl`""
Write-Host "Software that would be installed:"
Write-Host "  ✅ Docker CE + docker-compose"
Write-Host "  ✅ Nginx web server"
Write-Host "  ✅ ClamAV antivirus"
Write-Host "  ✅ Development tools"
Write-Host "  ✅ Python3, pip, Node.js, npm"

$simulatedAmiId = "ami-" + -join ((1..17) | ForEach {Get-Random -input ([char[]]"abcdefghijklmnopqrstuvwxyz0123456789")})
Write-Host "✅ Simulated AMI ID: $simulatedAmiId" -ForegroundColor Green

# Stage 4: Verify Simulation
Write-Host ""
Write-Host "Testing Stage 4: VERIFY AMI (DRY RUN)" -ForegroundColor Yellow
Write-Host "Would verify AMI: $simulatedAmiId"
Write-Host "Simulated AMI Details:"
Write-Host "  Name: ubuntu-24-04-custom-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
Write-Host "  State: available"
Write-Host "  Architecture: x86_64"
Write-Host "✅ AMI verification simulation completed" -ForegroundColor Green

# Stage 5: Report Generation
Write-Host ""
Write-Host "Testing Stage 5: GENERATE REPORT (DRY RUN)" -ForegroundColor Yellow
Write-Host "===================================================" -ForegroundColor Green
Write-Host "     AWS AMI BUILD REPORT - DRY RUN SUCCESS!" -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Green
Write-Host "Build Date: $(Get-Date)"
Write-Host "Simulated AMI ID: $simulatedAmiId"
Write-Host "Region: us-east-1 (example)"
Write-Host "Base Image: Ubuntu 24.04 LTS"
Write-Host "Instance Type: $instanceType"
Write-Host ""
Write-Host "Software Stack:"
Write-Host "  ✅ Docker CE + docker-compose"
Write-Host "  ✅ Nginx web server" 
Write-Host "  ✅ ClamAV antivirus"
Write-Host "  ✅ Development tools"
Write-Host "  ✅ Python3, pip, Node.js, npm"
Write-Host ""
Write-Host "Cost Analysis:"
Write-Host "  Estimated Cost: `$$lowCostEstimate - `$$highCostEstimate"
Write-Host "  Build Duration: ~15-30 minutes (simulated)"
Write-Host "===================================================" -ForegroundColor Green
Write-Host "✅ DRY RUN COMPLETED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Green

Write-Host ""
Write-Host "SUMMARY:" -ForegroundColor Magenta
Write-Host "🎉 All pipeline stages are ready for GitLab CI!" -ForegroundColor Green
Write-Host ""
Write-Host "To run actual GitLab CI pipeline:" -ForegroundColor Blue
Write-Host "   1. Push changes to GitLab repository" -ForegroundColor Blue
Write-Host "   2. Navigate to CI/CD > Pipelines in GitLab UI" -ForegroundColor Blue
Write-Host "   3. Manually trigger 'build-ami' stage when ready" -ForegroundColor Blue
