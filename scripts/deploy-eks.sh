#!/bin/bash

# UniFIAP Pay - Deploy Completo (Terraform + K8s)

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "========================================="
echo "UniFIAP Pay - Deploy Completo EKS"
echo "========================================="
echo ""

# 1. Terraform Apply
echo -e "${YELLOW}1. Criando infraestrutura AWS...${NC}"
cd terraform

if [ ! -d ".terraform" ]; then
    echo "Inicializando Terraform..."
    terraform init
fi

echo "Aplicando infraestrutura..."
terraform apply -auto-approve

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Erro no Terraform${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Infraestrutura criada${NC}"

# Obter outputs
CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
ECR_URL=$(terraform output -raw ecr_repository_url)
RDS_ENDPOINT=$(terraform output -raw rds_endpoint)

cd ..

# 2. Configurar kubectl
echo ""
echo -e "${YELLOW}2. Configurando kubectl...${NC}"
aws eks update-kubeconfig --name ${CLUSTER_NAME} --region us-east-1

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ kubectl configurado${NC}"
else
    echo -e "${RED}✗ Erro ao configurar kubectl${NC}"
    exit 1
fi

# 3. Build e Push imagem
echo ""
echo -e "${YELLOW}3. Build e Push da imagem...${NC}"
./scripts/build-and-push-ecr.sh

# 4. Atualizar secrets com RDS endpoint
echo ""
echo -e "${YELLOW}4. Atualizando secrets...${NC}"
sed -i "s/TERRAFORM_OUTPUT_RDS_ENDPOINT/${RDS_ENDPOINT}/g" k8s/03-secrets.yaml

# 5. Atualizar deployment com ECR URL
echo ""
echo -e "${YELLOW}5. Atualizando deployment...${NC}"
AWS_ACCOUNT=$(echo ${ECR_URL} | cut -d'.' -f1)
sed -i "s/ACCOUNT_ID/${AWS_ACCOUNT}/g" k8s/05-api-deployment.yaml

# 6. Deploy Kubernetes
echo ""
echo -e "${YELLOW}6. Deploy no Kubernetes...${NC}"
cd k8s
./deploy.sh

echo ""
echo "========================================="
echo -e "${GREEN}Deploy completo concluído!${NC}"
echo "========================================="
echo ""