#!/bin/bash

# Packer Build Script
# Usage: ./scripts/build.sh <environment> <action>
# Example: ./scripts/build.sh dev build
# Example: ./scripts/build.sh prod validate

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required parameters are provided
if [ $# -lt 2 ]; then
    print_error "Usage: $0 <environment> <action>"
    print_error "Environment: dev, staging, prod"
    print_error "Action: validate, build, inspect, format"
    exit 1
fi

ENVIRONMENT=$1
ACTION=$2
PROJECT_ROOT=$(dirname "$(dirname "$(realpath "$0")")")

# Validate environment
case $ENVIRONMENT in
    dev|staging|prod)
        print_status "Building for $ENVIRONMENT environment"
        ;;
    *)
        print_error "Invalid environment: $ENVIRONMENT"
        print_error "Valid environments: dev, staging, prod"
        exit 1
        ;;
esac

# Check if environment config exists
ENV_CONFIG="$PROJECT_ROOT/environments/${ENVIRONMENT}.pkrvars.hcl"
if [ ! -f "$ENV_CONFIG" ]; then
    print_error "Environment configuration not found: $ENV_CONFIG"
    exit 1
fi

# Change to project root
cd "$PROJECT_ROOT"

print_status "Working directory: $(pwd)"
print_status "Environment: $ENVIRONMENT"
print_status "Action: $ACTION"

# Execute Packer command based on action
case $ACTION in
    init)
        print_status "Initializing Packer..."
        packer init .
        print_success "Packer initialized successfully"
        ;;
    
    validate)
        print_status "Validating Packer configuration..."
        packer validate -var-file="$ENV_CONFIG" .
        print_success "Packer configuration is valid"
        ;;
    
    format)
        print_status "Formatting Packer files..."
        packer fmt -recursive .
        print_success "Packer files formatted"
        ;;
    
    build)
        print_status "Building AMI for $ENVIRONMENT environment..."
        print_warning "This will create AWS resources and may incur costs!"
        
        # Check for required environment variables
        if [ -z "$AWS_ACCESS_KEY_ID" ] && [ -z "$AWS_PROFILE" ]; then
            print_warning "No AWS credentials found. Make sure AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY or AWS_PROFILE is set"
        fi
        
        packer build \
            -var-file="$ENV_CONFIG" \
            -var "environment=$ENVIRONMENT" \
            .
        print_success "AMI build completed successfully"
        ;;
    
    inspect)
        print_status "Inspecting Packer configuration..."
        packer inspect -var-file="$ENV_CONFIG" .
        ;;
    
    clean)
        print_status "Cleaning up build artifacts..."
        rm -f packer_cache/
        rm -f *.log
        print_success "Cleanup completed"
        ;;
    
    *)
        print_error "Invalid action: $ACTION"
        print_error "Valid actions: init, validate, format, build, inspect, clean"
        exit 1
        ;;
esac

print_success "Operation completed successfully!"
