# Argo CD Setup and Usage Guide

## Overview
This directory contains all configurations for Argo CD continuous deployment on the Eaglewings Bank Platform.

## Directory Structure
- `argocd-namespace.yaml` - Argo CD namespace and RBAC setup
- `argocd-installation.yaml` - Argo CD Helm Chart installation configuration
- `application-project.yaml` - AppProject definition for Eaglewings Bank
- `root-app.yaml` - Root Argo CD Application that manages all services
- `applications/` - Individual service application manifests
- `kustomize/` - Kustomize bases and overlays for different environments

## Installation Steps

### 1. Prerequisites
- EKS cluster running and configured
- `kubectl` configured to access your cluster
- Helm 3+ installed
- Git repository with access credentials

### 2. Deploy Argo CD

#### Step 1: Create Namespace
```bash
kubectl apply -f argocd-namespace.yaml
```

#### Step 2: Add Helm Repository
```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```

#### Step 3: Install Argo CD using Helm
```bash
helm install argocd argo/argo-cd \
  -n argocd \
  --set server.service.type=LoadBalancer \
  --set server.ingress.enabled=true \
  --set server.ingress.ingressClassName=nginx
```

Alternatively, apply the Helm Chart manifest:
```bash
kubectl apply -f argocd-installation.yaml
```

### 3. Access Argo CD UI

#### Get the Argo CD Server URL
```bash
# For LoadBalancer service
kubectl get svc -n argocd argocd-server

# For port forwarding (if needed)
kubectl port-forward -n argocd svc/argocd-server 8080:443
```

#### Get Initial Admin Password
```bash
kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d && echo
```

#### Login
- Default username: `admin`
- Password: Use the command above
- URL: `https://<LOAD_BALANCER_IP>` or `https://localhost:8080` (if port-forwarding)

### 4. Configure Git Repository Access

```bash
# Create a secret with your Git credentials
kubectl create secret generic git-credentials \
  -n argocd \
  --from-literal=username=<github-username> \
  --from-literal=password=<github-token> \
  --from-literal=url=https://github.com/yourusername/eaglewings-bank-platform
```

### 5. Deploy Application Project
```bash
kubectl apply -f application-project.yaml
```

### 6. Deploy Root Application
```bash
kubectl apply -f root-app.yaml
```

### 7. Deploy Individual Service Applications
```bash
kubectl apply -f applications/
```

## Environment-Specific Deployments

### Production
- Located in `kustomize/overlays/prod/`
- 3 replicas per service
- Higher resource limits
- TLS enabled
- Production logging level

### Staging
- Located in `kustomize/overlays/staging/`
- 2 replicas per service
- Medium resource limits
- TLS enabled
- Info logging level

### Development
- Located in `kustomize/overlays/dev/`
- 1 replica per service
- Lower resource limits
- Development logging level

## Key Features

### Auto-Sync
All applications are configured with auto-sync enabled:
- Changes to the Git repository are automatically deployed
- Prune enabled - removes resources not in Git
- Self-heal enabled - restores desired state

### Retry Policy
Applications will retry failed syncs:
- Max 5 retries with exponential backoff
- Initial backoff: 5 seconds
- Max backoff: 3 minutes

### Resource Management
- All services have resource requests and limits defined
- Liveness probes for health monitoring
- Readiness probes for traffic routing

## Troubleshooting

### Check Argo CD Status
```bash
kubectl get all -n argocd
```

### View Application Status
```bash
kubectl get applications -n argocd
kubectl describe application <app-name> -n argocd
```

### View Sync Logs
```bash
# Connect to Argo CD pod and check logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller -f
```

### Manual Sync
```bash
# Refresh from Git
argocd app refresh <app-name>

# Sync changes
argocd app sync <app-name>
```

### Reset Admin Password
```bash
kubectl patch secret argocd-secret \
  -n argocd \
  -p='{"data":{"admin.password":"'$(bcrypt_hash "newpassword")'"}}'
```

## Best Practices

1. **Use separate Git branches** for each environment
2. **Pin image tags** in production overlays
3. **Use Kustomize** for environment-specific customizations
4. **Monitor Argo CD logs** for sync failures
5. **Regularly backup** your Git repository
6. **Use RBAC** to control access to applications
7. **Enable notifications** for sync events

## Security Considerations

- Change default admin password immediately after installation
- Use SSH instead of HTTPS for Git repository access
- Enable RBAC and audit logging
- Use Kubernetes secrets for sensitive data
- Restrict Argo CD service account permissions
- Enable TLS for all ingress routes
- Use image pull secrets for private registries

## Integration with CI/CD

When a new image is built:
1. Update the image tag in the appropriate `overlays/*/kustomization.yaml`
2. Push changes to Git
3. Argo CD automatically detects the change
4. Application is synced with the new image

## Useful Commands

```bash
# List all Argo CD applications
argocd app list

# Get application status
argocd app get <app-name>

# Delete an application
argocd app delete <app-name>

# Create applications via CLI
argocd app create <app-name> \
  --repo https://github.com/yourusername/eaglewings-bank-platform \
  --path argocd/kustomize/overlays/prod \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace production
```

## References

- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [Kustomize Documentation](https://kustomize.io/)
- [Helm Documentation](https://helm.sh/docs/)
