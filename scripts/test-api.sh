#!/bin/bash

# UniFIAP Pay - Test API Script

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "========================================="
echo "UniFIAP Pay - API Tests"
echo "========================================="
echo ""

# Obter URL da API
API_URL=$(kubectl get svc unifiaap-api-service -n unifiappay -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)

if [ -z "$API_URL" ]; then
    echo -e "${RED}✗ LoadBalancer URL não encontrada${NC}"
    echo "Verifique: kubectl get svc -n unifiappay"
    exit 1
fi

API_URL="http://${API_URL}"
echo "API URL: ${API_URL}"
echo ""

PASSED=0
FAILED=0

test_endpoint() {
    local name=$1
    local url=$2
    
    echo -n "Testing ${name}... "
    
    if curl -s -f "${url}" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASSED${NC}"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗ FAILED${NC}"
        FAILED=$((FAILED + 1))
    fi
}

# Executar testes
echo "=== Running Tests ==="
test_endpoint "Health Check" "${API_URL}/health"
test_endpoint "Root Endpoint" "${API_URL}/"
test_endpoint "Get Balance" "${API_URL}/api/v1/pix/balance/12345678900"
test_endpoint "List Transactions" "${API_URL}/api/v1/pix/transactions"
test_endpoint "Audit Report" "${API_URL}/api/v1/audit/report"

# Teste POST
echo -n "Testing PIX Transfer... "
response=$(curl -s -w "\n%{http_code}" -X POST "${API_URL}/api/v1/pix/transfer" \
  -H "Content-Type: application/json" \
  -d '{
    "from_cpf": "12345678900",
    "to_cpf": "98765432100",
    "amount": 10.00,
    "description": "Teste automatizado"
  }')

http_code=$(echo "$response" | tail -n 1)

if [ "$http_code" -eq "201" ]; then
    echo -e "${GREEN}✓ PASSED${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗ FAILED${NC} (HTTP $http_code)"
    FAILED=$((FAILED + 1))
fi

echo ""
echo "========================================="
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}"
echo "========================================="

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed!${NC}"
    exit 1
fi