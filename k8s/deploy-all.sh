#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "========================================="
echo "UniFIAP Pay - Deploy Completo (11 Recursos)"
echo "========================================="
echo ""

# Verificar cluster
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}✗ Cluster não conectado${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Cluster conectado${NC}"
kubectl cluster-info | head -n 1
echo ""

# Lista de recursos NA ORDEM CORRETA
echo -e "${BLUE}Aplicando recursos...${NC}"
echo ""

echo -e "${YELLOW}► 01-namespace.yaml${NC}"
kubectl apply -f 01-namespace.yaml
echo -e "${GREEN}✓ Namespace criado${NC}"
echo ""

echo -e "${YELLOW}► 02-configmap.yaml${NC}"
kubectl apply -f 02-configmap.yaml
echo -e "${GREEN}✓ ConfigMap criado${NC}"
echo ""

echo -e "${YELLOW}► 03-secrets.yaml${NC}"
kubectl apply -f 03-secrets.yaml
echo -e "${GREEN}✓ Secrets criados${NC}"
echo ""

echo -e "${YELLOW}► 04-storageclass-pvc.yaml${NC}"
kubectl apply -f 04-storageclass-pvc.yaml
echo -e "${GREEN}✓ PVC criado${NC}"
echo ""

echo -e "${YELLOW}► 07-rbac.yaml${NC}"
kubectl apply -f 07-rbac.yaml
echo -e "${GREEN}✓ RBAC configurado${NC}"
echo ""

echo -e "${YELLOW}► 05-postgres-deployment.yaml${NC}"
kubectl apply -f 05-postgres-deployment.yaml
echo -e "${GREEN}✓ Deployment e Service criados${NC}"
echo ""

echo -e "${YELLOW}► 06-job-cronjob.yaml${NC}"
kubectl apply -f 06-job-cronjob.yaml
echo -e "${GREEN}✓ Job e CronJob criados${NC}"
echo ""

echo -e "${YELLOW}► 08-daemonset.yaml${NC}"
kubectl apply -f 08-daemonset.yaml
echo -e "${GREEN}✓ DaemonSet criado${NC}"
echo ""

echo -e "${YELLOW}► 09-network-policy.yaml${NC}"
kubectl apply -f 09-network-policy.yaml
echo -e "${GREEN}✓ NetworkPolicies criadas${NC}"
echo ""

if [ -f "10-network-policy.yaml" ]; then
    echo -e "${YELLOW}► 10-network-policy.yaml${NC}"
    kubectl apply -f 10-network-policy.yaml
    echo -e "${GREEN}✓ NetworkPolicies adicionais criadas${NC}"
    echo ""
fi

if [ -f "11-hpa-quotas.yaml" ]; then
    echo -e "${YELLOW}► 11-hpa-quotas.yaml${NC}"
    kubectl apply -f 11-hpa-quotas.yaml
    echo -e "${GREEN}✓ HPA e Quotas criados${NC}"
    echo ""
fi

echo "========================================="
echo -e "${GREEN}Deploy concluído com sucesso!${NC}"
echo "========================================="
echo ""

# Aguardar pods
echo -e "${YELLOW}Aguardando pods iniciarem...${NC}"
sleep 10

# Status dos recursos
echo ""
echo -e "${BLUE}=== STATUS DOS RECURSOS ===${NC}"
echo ""

echo -e "${YELLOW}Namespaces:${NC}"
kubectl get ns | grep unifiappay

echo ""
echo -e "${YELLOW}Todos os recursos:${NC}"
kubectl get all -n unifiappay

echo ""
echo -e "${YELLOW}ConfigMaps e Secrets:${NC}"
kubectl get configmap,secret -n unifiappay

echo ""
echo -e "${YELLOW}PVCs:${NC}"
kubectl get pvc -n unifiappay

echo ""
echo -e "${YELLOW}Jobs e CronJobs:${NC}"
kubectl get jobs,cronjobs -n unifiappay

echo ""
echo -e "${YELLOW}DaemonSets:${NC}"
kubectl get daemonsets -n unifiappay

echo ""
echo -e "${YELLOW}RBAC:${NC}"
kubectl get serviceaccount,role,rolebinding -n unifiappay

echo ""
echo -e "${YELLOW}NetworkPolicies:${NC}"
kubectl get networkpolicies -n unifiappay

if kubectl get hpa -n unifiappay &> /dev/null; then
    echo ""
    echo -e "${YELLOW}HPA:${NC}"
    kubectl get hpa -n unifiappay
fi

if kubectl get resourcequota -n unifiappay &> /dev/null; then
    echo ""
    echo -e "${YELLOW}Resource Quotas:${NC}"
    kubectl get resourcequota,limitrange -n unifiappay
fi

echo ""
echo "========================================="
echo -e "${GREEN}Informações de Acesso:${NC}"
echo "========================================="

# Obter NodePort
NODE_PORT=$(kubectl get svc unifiaap-api-service -n unifiappay -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "N/A")

if [ "$NODE_PORT" != "N/A" ]; then
    echo ""
    echo "API disponível em:"
    echo "  http://localhost:${NODE_PORT}/"
    echo "  http://localhost:${NODE_PORT}/health"
    echo ""
    echo "Testar:"
    echo "  curl http://localhost:${NODE_PORT}/health"
else
    echo ""
    echo "Use port-forward:"
    echo "  kubectl port-forward -n unifiappay svc/unifiaap-api-service 8080:80"
    echo "  curl http://localhost:8080/health"
fi

echo ""
echo "Comandos úteis:"
echo "  kubectl get all -n unifiappay"
echo "  kubectl logs -f -n unifiappay -l app=unifiaap-api"
echo "  kubectl describe pod -n unifiappay -l app=unifiaap-api"
echo ""

# Contagem de recursos
PODS=$(kubectl get pods -n unifiappay --no-headers 2>/dev/null | wc -l)
SERVICES=$(kubectl get svc -n unifiappay --no-headers 2>/dev/null | wc -l)
JOBS=$(kubectl get jobs -n unifiappay --no-headers 2>/dev/null | wc -l)
CRONJOBS=$(kubectl get cronjobs -n unifiappay --no-headers 2>/dev/null | wc -l)
DAEMONSETS=$(kubectl get daemonsets -n unifiappay --no-headers 2>/dev/null | wc -l)

echo "========================================="
echo -e "${GREEN}Resumo:${NC}"
echo "  Pods: $PODS"
echo "  Services: $SERVICES"
echo "  Jobs: $JOBS"
echo "  CronJobs: $CRONJOBS"
echo "  DaemonSets: $DAEMONSETS"
echo "========================================="
echo ""