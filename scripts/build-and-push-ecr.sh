#!/bin/bash

# UniFIAP Pay - Build and Push to ECR
# Build da imagem Docker e push para ECR

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "========================================="
echo "UniFIAP Pay - Build & Push to ECR"
echo "========================================="
echo ""

# Variáveis
AWS_REGION="${AWS_REGION:-us-east-1}"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REPO="${ECR_REPO:-unifiaap-pay-dev-api}"
IMAGE_TAG="${IMAGE_TAG:-latest}"

ECR_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
FULL_IMAGE="${ECR_URL}/${ECR_REPO}:${IMAGE_TAG}"

echo "Configurações:"
echo "  AWS Account: ${AWS_ACCOUNT_ID}"
echo "  AWS Region: ${AWS_REGION}"
echo "  ECR Repo: ${ECR_REPO}"
echo "  Image Tag: ${IMAGE_TAG}"
echo "  Full Image: ${FULL_IMAGE}"
echo ""

# 1. Login no ECR
echo -e "${YELLOW}1. Login no ECR...${NC}"
aws ecr get-login-password --region ${AWS_REGION} | \
    docker login --username AWS --password-stdin ${ECR_URL}

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Login OK${NC}"
else
    echo -e "${RED}✗ Erro no login${NC}"
    exit 1
fi

# 2. Build da imagem
echo ""
echo -e "${YELLOW}2. Building imagem...${NC}"
docker build \
    -f docker/Dockerfile \
    -t ${FULL_IMAGE} \
    --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
    .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Build OK${NC}"
else
    echo -e "${RED}✗ Erro no build${NC}"
    exit 1
fi

# 3. Push da imagem
echo ""
echo -e "${YELLOW}3. Pushing para ECR...${NC}"
docker push ${FULL_IMAGE}

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Push OK${NC}"
else
    echo -e "${RED}✗ Erro no push${NC}"
    exit 1
fi

# 4. Tag latest
if [ "${IMAGE_TAG}" != "latest" ]; then
    echo ""
    echo -e "${YELLOW}4. Tagging como latest...${NC}"
    docker tag ${FULL_IMAGE} ${ECR_URL}/${ECR_REPO}:latest
    docker push ${ECR_URL}/${ECR_REPO}:latest
    echo -e "${GREEN}✓ Tag latest criada${NC}"
fi

echo ""
echo "========================================="
echo -e "${GREEN}Build e Push concluídos!${NC}"
echo "========================================="
echo ""
echo "Imagem disponível:"
echo "  ${FULL_IMAGE}"
echo ""
echo "Atualize o deployment:"
echo "  image: ${FULL_IMAGE}"
echo ""