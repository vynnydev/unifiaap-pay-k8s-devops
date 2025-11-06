#!/bin/bash

# UniFIAP Pay - AWS Setup Script
# Configura credenciais e ferramentas AWS

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "========================================="
echo "UniFIAP Pay - AWS Setup"
echo "========================================="
echo ""

# Verificar AWS CLI
if ! command -v aws &> /dev/null; then
    echo -e "${RED}✗ AWS CLI não encontrado!${NC}"
    echo "Instale: https://aws.amazon.com/cli/"
    exit 1
fi

echo -e "${GREEN}✓ AWS CLI instalado${NC}"
aws --version

# Verificar kubectl
if ! command -v kubectl &> /dev/null; then
    echo -e "${YELLOW}⚠ kubectl não encontrado${NC}"
    echo "Instale: https://kubernetes.io/docs/tasks/tools/"
fi

# Verificar Terraform
if ! command -v terraform &> /dev/null; then
    echo -e "${YELLOW}⚠ Terraform não encontrado${NC}"
    echo "Instale: https://www.terraform.io/downloads"
fi

# Configurar credenciais
echo ""
echo -e "${YELLOW}Configurando credenciais AWS...${NC}"
echo ""
echo "Você precisará de:"
echo "  - AWS Access Key ID"
echo "  - AWS Secret Access Key"
echo "  - Região (padrão: us-east-1)"
echo ""

read -p "Configurar agora? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    aws configure
    echo ""
    echo -e "${GREEN}✓ Credenciais configuradas${NC}"
    
    # Testar conexão
    echo ""
    echo "Testando conexão..."
    if aws sts get-caller-identity &> /dev/null; then
        echo -e "${GREEN}✓ Conexão OK${NC}"
        aws sts get-caller-identity
    else
        echo -e "${RED}✗ Erro na conexão${NC}"
        exit 1
    fi
fi

echo ""
echo "========================================="
echo -e "${GREEN}Setup concluído!${NC}"
echo "========================================="
echo ""
echo "Próximos passos:"
echo "  1. cd terraform"
echo "  2. terraform init"
echo "  3. terraform plan"
echo "  4. terraform apply"
echo ""