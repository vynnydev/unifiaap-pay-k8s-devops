#!/bin/bash

# UniFIAP Pay - Verification Script para EKS

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

NAMESPACE="unifiappay"

echo "========================================="
echo "UniFIAP Pay - Kubernetes Verification (EKS)"
echo "========================================="
echo ""

# 1. Verificar namespace
echo -e "${YELLOW}1. Verificando Namespace...${NC}"
if kubectl get namespace $NAMESPACE > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Namespace '$NAMESPACE' existe${NC}"
else
    echo -e "${RED}✗ Namespace não encontrado${NC}"
    exit 1
fi

# 2. Verificar pods
echo ""
echo -e "${YELLOW}2. Verificando Pods...${NC}"
kubectl get pods -n $NAMESPACE

READY_PODS=$(kubectl get pods -n $NAMESPACE --no-headers 2>/dev/null | grep "Running" | wc -l)
echo -e "${GREEN}✓ $READY_PODS pods em execução${NC}"

# 3. Verificar services
echo ""
echo -e "${YELLOW}3. Verificando Services...${NC}"
kubectl get svc -n $NAMESPACE

# 4. Verificar volumes
echo ""
echo -e "${YELLOW}4. Verificando Persistent Volumes...${NC}"
kubectl get pvc -n $NAMESPACE

# 5. Verificar jobs
echo ""
echo -e "${YELLOW}5. Verificando Jobs...${NC}"
kubectl get jobs -n $NAMESPACE

# 6. Verificar daemonsets
echo ""
echo -e "${YELLOW}6. Verificando DaemonSets...${NC}"
kubectl get daemonsets -n $NAMESPACE

# 7. Verificar HPA
echo ""
echo -e "${YELLOW}7. Verificando HPA...${NC}"
kubectl get hpa -n $NAMESPACE

# 8. Teste de conectividade
echo ""
echo -e "${YELLOW}8. Testando API...${NC}"

LB_URL=$(kubectl get svc unifiaap-api-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)

if [ -n "$LB_URL" ]; then
    echo "API URL: http://${LB_URL}"
    
    if curl -s -f "http://${LB_URL}/health" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ API respondendo${NC}"
    else
        echo -e "${RED}✗ API não respondendo (pode estar provisionando)${NC}"
    fi
else
    echo -e "${YELLOW}⚠ LoadBalancer ainda provisionando${NC}"
fi

# 9. Verificar logs
echo ""
echo -e "${YELLOW}9. Verificando logs...${NC}"
ERROR_COUNT=$(kubectl logs -l app=unifiaap-api -n $NAMESPACE --tail=100 2>/dev/null | grep -i "error" | wc -l)

if [ $ERROR_COUNT -eq 0 ]; then
    echo -e "${GREEN}✓ Nenhum erro nos logs${NC}"
else
    echo -e "${YELLOW}⚠ $ERROR_COUNT erros encontrados${NC}"
fi

echo ""
echo "========================================="
echo -e "${GREEN}Verificação concluída!${NC}"
echo "========================================="
echo ""