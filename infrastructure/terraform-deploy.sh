#!/bin/bash
# Terraform deployment script with environment support

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

print_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

# Function to display usage
usage() {
    cat <<EOF
Usage: ./terraform-deploy.sh [COMMAND] [ENVIRONMENT]

Commands:
    init        Initialize Terraform
    plan        Plan changes
    apply       Apply changes
    destroy     Destroy infrastructure
    validate    Validate configuration
    fmt         Format Terraform files
    output      Show outputs
    backend     Setup backend

Environments:
    dev         Development
    staging     Staging
    prod        Production (default)

Examples:
    ./terraform-deploy.sh plan dev
    ./terraform-deploy.sh apply staging
    ./terraform-deploy.sh destroy prod
    ./terraform-deploy.sh backend

EOF
    exit 1
}

# Check if required tools are installed
check_requirements() {
    print_status "Checking requirements..."
    
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed"
        exit 1
    fi
    
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed"
        exit 1
    fi
    
    print_status "All requirements met"
}

# Initialize Terraform
terraform_init() {
    local env=${1:-prod}
    print_status "Initializing Terraform for $env environment..."
    terraform init -upgrade
    print_status "Terraform initialized successfully"
}

# Plan Terraform
terraform_plan() {
    local env=${1:-prod}
    local tfvars_file="${env}.tfvars"
    
    if [ ! -f "$tfvars_file" ]; then
        print_error "Configuration file $tfvars_file not found"
        exit 1
    fi
    
    print_status "Planning Terraform for $env environment..."
    terraform plan \
        -var-file="$tfvars_file" \
        -out="${env}.tfplan"
    
    print_status "Plan saved to ${env}.tfplan"
}

# Apply Terraform
terraform_apply() {
    local env=${1:-prod}
    local plan_file="${env}.tfplan"
    
    if [ ! -f "$plan_file" ]; then
        print_warning "Plan file $plan_file not found, creating plan first..."
        terraform_plan "$env"
    fi
    
    print_warning "About to apply changes to $env environment"
    read -p "Continue? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        print_status "Apply cancelled"
        return
    fi
    
    print_status "Applying Terraform for $env environment..."
    terraform apply "$plan_file"
    print_status "Terraform applied successfully"
}

# Destroy Terraform
terraform_destroy() {
    local env=${1:-prod}
    local tfvars_file="${env}.tfvars"
    
    print_error "You are about to destroy infrastructure in $env environment!"
    read -p "Type the environment name to confirm: " confirm
    
    if [ "$confirm" != "$env" ]; then
        print_status "Destroy cancelled"
        return
    fi
    
    print_status "Destroying Terraform for $env environment..."
    terraform destroy -var-file="$tfvars_file"
    print_status "Infrastructure destroyed"
}

# Validate Terraform
terraform_validate() {
    print_status "Validating Terraform configuration..."
    terraform validate
    print_status "Configuration is valid"
}

# Format Terraform
terraform_fmt() {
    print_status "Formatting Terraform files..."
    terraform fmt -recursive
    print_status "Files formatted successfully"
}

# Show outputs
terraform_output() {
    local env=${1:-prod}
    print_status "Outputs for $env environment..."
    terraform output -json | jq '.'
}

# Setup backend
setup_backend() {
    print_status "Setting up Terraform backend..."
    terraform apply -target=aws_s3_bucket.terraform_state \
                    -target=aws_dynamodb_table.terraform_locks
    print_status "Backend setup completed"
}

# Main script
main() {
    local command=${1:-plan}
    local environment=${2:-prod}
    
    if [ -z "$command" ]; then
        usage
    fi
    
    check_requirements
    
    case "$command" in
        init)
            terraform_init "$environment"
            ;;
        plan)
            terraform_plan "$environment"
            ;;
        apply)
            terraform_apply "$environment"
            ;;
        destroy)
            terraform_destroy "$environment"
            ;;
        validate)
            terraform_validate
            ;;
        fmt)
            terraform_fmt
            ;;
        output)
            terraform_output "$environment"
            ;;
        backend)
            setup_backend
            ;;
        *)
            print_error "Unknown command: $command"
            usage
            ;;
    esac
}

# Run main function
main "$@"
