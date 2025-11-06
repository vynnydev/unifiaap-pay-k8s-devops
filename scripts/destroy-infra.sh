#!/bin/bash

# UniFIAP Pay - Destroy Infrastructure
# Remove TODA infraestrutura AWS

set -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "========================================="
echo -e "${RED}UniFIAP Pay - DESTROY Infrastructure${NC}"
echo "========================================="
echo ""
echo -e "${RED}⚠️  ATENÇÃO: Isso vai DELETAR toda infraestrutura!${NC}"
echo ""

read -p "Tem certeza? Digite 'yes' para confirmar: " -r
echo ""

if [ "$REPLY" != "yes" ]; then
    echo "Cancelado."
    exit 0
fi

# 1. Deletar recursos Kubernetes
echo -e "${YELLOW}1. Deletando recursos Kubernetes...${NC}"
cd k8s
kubectl delete -f . --ignore-not-found=true
kubectl delete namespace unifiappay --ignore-not-found=true
cd ..

echo -e "${GREEN}✓ Recursos K8s deletados${NC}"

# 2. Terraform Destroy
echo ""
echo -e "${YELLOW}2. Destruindo infraestrutura AWS...${NC}"
cd terraform
terraform destroy -auto-approve

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Infraestrutura destruída${NC}"
else
    echo -e "${RED}✗ Erro ao destruir${NC}"
    exit 1
fi

cd ..

echo ""
echo "========================================="
echo -e "${GREEN}Infraestrutura removida com sucesso!${NC}"
echo "========================================="
echo ""