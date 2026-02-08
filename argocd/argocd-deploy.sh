#!/bin/bash
# Argo CD deployment and management script

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

print_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

print_info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO:${NC} $1"
}

usage() {
    cat <<EOF
Usage: ./argocd-deploy.sh [COMMAND]

Commands:
    install     Install Argo CD
    uninstall   Uninstall Argo CD
    login       Login to Argo CD
    password    Get admin password
    status      Check Argo CD status
    apps        List applications
    sync        Sync all applications
    ui          Open Argo CD UI
    help        Show this help message

Examples:
    ./argocd-deploy.sh install
    ./argocd-deploy.sh login
    ./argocd-deploy.sh sync

EOF
    exit 1
}

check_requirements() {
    print_status "Checking requirements..."
    
    local missing=0
    
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed"
        missing=1
    fi
    
    if ! command -v helm &> /dev/null; then
        print_error "Helm is not installed"
        missing=1
    fi
    
    if [ $missing -eq 1 ]; then
        exit 1
    fi
    
    print_status "All requirements met"
}

install_argocd() {
    print_status "Installing Argo CD..."
    
    # Create namespace
    print_status "Creating argocd namespace..."
    kubectl apply -f argocd-namespace.yaml
    
    # Add Helm repository
    print_status "Adding Helm repository..."
    helm repo add argo https://argoproj.github.io/argo-helm
    helm repo update
    
    # Install Argo CD
    print_status "Installing Argo CD Helm chart..."
    helm install argocd argo/argo-cd \
        -n argocd \
        --set server.service.type=LoadBalancer \
        --set server.ingress.enabled=true \
        --set server.ingress.ingressClassName=nginx \
        --wait \
        --timeout 10m
    
    # Create AppProject
    print_status "Creating Argo CD AppProject..."
    kubectl apply -f application-project.yaml
    
    # Create root application
    print_status "Creating root application..."
    kubectl apply -f root-app.yaml
    
    # Deploy service applications
    print_status "Deploying service applications..."
    kubectl apply -f applications/
    
    print_status "Argo CD installation completed successfully!"
    print_info "Run './argocd-deploy.sh login' to access Argo CD"
}

uninstall_argocd() {
    print_warning "Uninstalling Argo CD... This cannot be undone!"
    read -p "Continue? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        print_status "Uninstall cancelled"
        return
    fi
    
    print_status "Removing applications..."
    kubectl delete -f applications/ 2>/dev/null || true
    kubectl delete -f root-app.yaml 2>/dev/null || true
    kubectl delete -f application-project.yaml 2>/dev/null || true
    
    print_status "Uninstalling Argo CD..."
    helm uninstall argocd -n argocd 2>/dev/null || true
    
    print_status "Removing namespace..."
    kubectl delete namespace argocd 2>/dev/null || true
    
    print_status "Argo CD uninstalled successfully"
}

get_admin_password() {
    print_status "Retrieving admin password..."
    
    local password
    password=$(kubectl get secret -n argocd argocd-initial-admin-secret \
        -o jsonpath='{.data.password}' | base64 -d 2>/dev/null || echo "")
    
    if [ -z "$password" ]; then
        print_error "Could not retrieve password. Argo CD may not be fully installed."
        return 1
    fi
    
    echo -e "${GREEN}Admin Password:${NC} $password"
}

login_argocd() {
    print_status "Logging into Argo CD..."
    
    # Get password
    local password
    password=$(kubectl get secret -n argocd argocd-initial-admin-secret \
        -o jsonpath='{.data.password}' | base64 -d 2>/dev/null || echo "")
    
    if [ -z "$password" ]; then
        print_error "Could not retrieve password"
        return 1
    fi
    
    # Get Argo CD server
    local argocd_server
    print_info "Getting Argo CD server address..."
    
    # Try LoadBalancer first
    argocd_server=$(kubectl get service -n argocd argocd-server \
        -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
    
    if [ -z "$argocd_server" ]; then
        argocd_server=$(kubectl get service -n argocd argocd-server \
            -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    fi
    
    if [ -z "$argocd_server" ]; then
        print_warning "LoadBalancer not ready, using port-forward instead"
        print_info "Setting up port-forward to Argo CD..."
        kubectl port-forward -n argocd svc/argocd-server 8080:443 &
        sleep 2
        argocd_server="localhost:8080"
    fi
    
    print_info "Argo CD Server: https://$argocd_server"
    print_info "Username: admin"
    print_info "Password: $password"
    
    # Try to login with argocd CLI if available
    if command -v argocd &> /dev/null; then
        print_status "Logging in with Argo CD CLI..."
        argocd login "$argocd_server" --username admin --password "$password" --insecure
    else
        print_info "Argo CD CLI not installed. Visit the URL above to login via web UI."
    fi
}

check_status() {
    print_status "Checking Argo CD status..."
    
    if ! kubectl get namespace argocd &>/dev/null; then
        print_error "Argo CD namespace not found"
        return 1
    fi
    
    print_info "Argo CD Components:"
    kubectl get pods -n argocd
    
    print_info "\nArgoCD Services:"
    kubectl get svc -n argocd
}

list_apps() {
    print_status "Listing Argo CD applications..."
    kubectl get application -n argocd -o wide
}

sync_apps() {
    print_status "Syncing all applications..."
    
    local apps
    apps=$(kubectl get applications -n argocd -o jsonpath='{.items[*].metadata.name}')
    
    for app in $apps; do
        print_status "Syncing application: $app"
        kubectl patch application "$app" -n argocd \
            -p '{"spec":{"syncPolicy":{"syncOptions":["PrunePropagationPolicy=foreground"]}}}' \
            --type merge
    done
    
    print_status "Sync initiated for all applications"
}

open_ui() {
    local argocd_server
    
    print_status "Opening Argo CD UI..."
    
    argocd_server=$(kubectl get service -n argocd argocd-server \
        -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
    
    if [ -z "$argocd_server" ]; then
        argocd_server=$(kubectl get service -n argocd argocd-server \
            -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    fi
    
    if [ -z "$argocd_server" ]; then
        print_warning "LoadBalancer not ready, setting up port-forward..."
        kubectl port-forward -n argocd svc/argocd-server 8080:443 &
        sleep 2
        argocd_server="localhost:8080"
    fi
    
    local url="https://$argocd_server"
    print_info "Opening: $url"
    
    if command -v xdg-open &> /dev/null; then
        xdg-open "$url"
    elif command -v open &> /dev/null; then
        open "$url"
    elif command -v start &> /dev/null; then
        start "$url"
    else
        print_info "Please open this URL in your browser: $url"
    fi
}

main() {
    local command=${1:-help}
    
    check_requirements
    
    case "$command" in
        install)
            install_argocd
            ;;
        uninstall)
            uninstall_argocd
            ;;
        login)
            login_argocd
            ;;
        password)
            get_admin_password
            ;;
        status)
            check_status
            ;;
        apps)
            list_apps
            ;;
        sync)
            sync_apps
            ;;
        ui)
            open_ui
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            print_error "Unknown command: $command"
            usage
            ;;
    esac
}

main "$@"
