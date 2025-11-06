#!/bin/bash

# UniFIAP Pay - Deploy Script para EKS
# Autor: DevOps Team

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "========================================="
echo "UniFIAP Pay - Kubernetes Deployment (EKS)"
echo "========================================="
echo ""

# Verificar kubectl
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}✗ kubectl não encontrado!${NC}"
    exit 1
fi

# Verificar conexão com cluster
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}✗ Não conectado ao cluster EKS${NC}"
    echo "Configure: aws eks update-kubeconfig --name unifiaap-pay-dev-eks --region us-east-1"
    exit 1
fi

echo -e "${GREEN}✓ Conectado ao cluster EKS${NC}"
kubectl cluster-info | head -n 1
echo ""

# Lista de recursos
resources=(
    "01-namespace.yaml"
    "02-configmap.yaml"
    "03-secrets.yaml"
    "04-storageclass-pvc.yaml"
    "05-api-deployment.yaml"
    "06-job-cronjob.yaml"
    "07-rbac.yaml"
    "08-hpa.yaml"
    "09-daemonset.yaml"
    "10-network-policy.yaml"
    "11-quotas.yaml"
)

# Deploy
echo -e "${YELLOW}Aplicando recursos...${NC}"
echo ""

for resource in "${resources[@]}"; do
    echo -e "${YELLOW}► ${resource}${NC}"
    kubectl apply -f ${resource}
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Aplicado${NC}"
    else
        echo -e "${RED}✗ Erro${NC}"
        exit 1
    fi
    echo ""
done

echo "========================================="
echo -e "${GREEN}Deploy concluído!${NC}"
echo "========================================="
echo ""

# Aguardar pods
echo -e "${YELLOW}Aguardando pods...${NC}"
kubectl wait --for=condition=ready pod -l app=unifiaap-api -n unifiappay --timeout=120s

echo ""
echo -e "${GREEN}Status dos recursos:${NC}"
echo ""

echo "--- Pods ---"
kubectl get pods -n unifiappay -o wide

echo ""
echo "--- Services ---"
kubectl get svc -n unifiappay

echo ""
echo "--- PVC ---"
kubectl get pvc -n unifiappay

echo ""
echo "========================================="
echo -e "${GREEN}Informações de Acesso:${NC}"
echo "========================================="

# Obter LoadBalancer URL
LB_URL=$(kubectl get svc unifiaap-api-service -n unifiappay -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

if [ -n "$LB_URL" ]; then
    echo ""
    echo "API URL:"
    echo "  http://${LB_URL}"
    echo ""
    echo "Testar API:"
    echo "  curl http://${LB_URL}/health"
else
    echo ""
    echo "LoadBalancer ainda provisionando..."
    echo "Execute: kubectl get svc -n unifiappay"
fi

echo ""
echo "Comandos úteis:"
echo "  kubectl get all -n unifiappay"
echo "  kubectl logs -f deployment/unifiaap-api-deployment -n unifiappay"
echo "  kubectl describe svc unifiaap-api-service -n unifiappay"
echo ""