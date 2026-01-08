#!/bin/bash

# Test script for WSO2 API Manager integration
# This script tests the API endpoints through both direct backend and WSO2 Gateway

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
BACKEND_URL="http://localhost:8080"
WSO2_GATEWAY_URL="https://localhost:8243/healthcare/1.0.0"
WSO2_TOKEN_URL="https://localhost:8243/token"

# Test credentials (use credentials from your backend)
TEST_EMAIL="admin@example.com"
TEST_PASSWORD="admin123"

# WSO2 Application credentials (replace with your actual credentials)
CLIENT_ID="YOUR_CONSUMER_KEY"
CLIENT_SECRET="YOUR_CONSUMER_SECRET"

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}WSO2 API Manager Integration Test${NC}"
echo -e "${BLUE}==========================================${NC}"
echo ""

# Test 1: Direct Backend Access
echo -e "${YELLOW}[Test 1]${NC} Testing direct backend access..."
DIRECT_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${BACKEND_URL}/api/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"${TEST_EMAIL}\",\"password\":\"${TEST_PASSWORD}\"}")

HTTP_CODE=$(echo "$DIRECT_RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$DIRECT_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓ Direct backend access works${NC}"
    BACKEND_TOKEN=$(echo "$RESPONSE_BODY" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
    echo -e "  Token: ${BACKEND_TOKEN:0:50}..."
else
    echo -e "${RED}✗ Direct backend access failed (HTTP $HTTP_CODE)${NC}"
    echo -e "  Response: $RESPONSE_BODY"
fi
echo ""

# Test 2: WSO2 Token Generation
echo -e "${YELLOW}[Test 2]${NC} Testing WSO2 token generation..."

if [ "$CLIENT_ID" = "YOUR_CONSUMER_KEY" ]; then
    echo -e "${RED}✗ WSO2 credentials not configured${NC}"
    echo -e "  Please update CLIENT_ID and CLIENT_SECRET in this script"
    echo ""
    exit 1
fi

# Encode credentials for Basic Auth
AUTH_HEADER=$(echo -n "${CLIENT_ID}:${CLIENT_SECRET}" | base64)

TOKEN_RESPONSE=$(curl -k -s -w "\n%{http_code}" -X POST "${WSO2_TOKEN_URL}" \
  -H "Authorization: Basic ${AUTH_HEADER}" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&username=${TEST_EMAIL}&password=${TEST_PASSWORD}&scope=default")

HTTP_CODE=$(echo "$TOKEN_RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$TOKEN_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓ WSO2 token generation works${NC}"
    WSO2_ACCESS_TOKEN=$(echo "$RESPONSE_BODY" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
    WSO2_REFRESH_TOKEN=$(echo "$RESPONSE_BODY" | grep -o '"refresh_token":"[^"]*' | cut -d'"' -f4)
    EXPIRES_IN=$(echo "$RESPONSE_BODY" | grep -o '"expires_in":[0-9]*' | cut -d':' -f2)
    echo -e "  Access Token: ${WSO2_ACCESS_TOKEN:0:50}..."
    echo -e "  Expires In: ${EXPIRES_IN} seconds"
else
    echo -e "${RED}✗ WSO2 token generation failed (HTTP $HTTP_CODE)${NC}"
    echo -e "  Response: $RESPONSE_BODY"
    echo ""
    exit 1
fi
echo ""

# Test 3: API Call through WSO2 Gateway
echo -e "${YELLOW}[Test 3]${NC} Testing API call through WSO2 Gateway..."
GATEWAY_RESPONSE=$(curl -k -s -w "\n%{http_code}" -X POST "${WSO2_GATEWAY_URL}/api/auth/login" \
  -H "Authorization: Bearer ${WSO2_ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"${TEST_EMAIL}\",\"password\":\"${TEST_PASSWORD}\"}")

HTTP_CODE=$(echo "$GATEWAY_RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$GATEWAY_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓ API call through WSO2 Gateway works${NC}"
    echo -e "  Response: $(echo "$RESPONSE_BODY" | head -c 100)..."
else
    echo -e "${RED}✗ API call through WSO2 Gateway failed (HTTP $HTTP_CODE)${NC}"
    echo -e "  Response: $RESPONSE_BODY"
fi
echo ""

# Test 4: Get Doctors (Authenticated Endpoint)
echo -e "${YELLOW}[Test 4]${NC} Testing authenticated endpoint (GET /api/doctors)..."
DOCTORS_RESPONSE=$(curl -k -s -w "\n%{http_code}" -X GET "${WSO2_GATEWAY_URL}/api/doctors" \
  -H "Authorization: Bearer ${WSO2_ACCESS_TOKEN}")

HTTP_CODE=$(echo "$DOCTORS_RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$DOCTORS_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓ Authenticated endpoint works${NC}"
    DOCTOR_COUNT=$(echo "$RESPONSE_BODY" | grep -o '{' | wc -l)
    echo -e "  Retrieved $DOCTOR_COUNT doctors"
else
    echo -e "${RED}✗ Authenticated endpoint failed (HTTP $HTTP_CODE)${NC}"
    echo -e "  Response: $RESPONSE_BODY"
fi
echo ""

# Test 5: Token Refresh
echo -e "${YELLOW}[Test 5]${NC} Testing token refresh..."
REFRESH_RESPONSE=$(curl -k -s -w "\n%{http_code}" -X POST "${WSO2_TOKEN_URL}" \
  -H "Authorization: Basic ${AUTH_HEADER}" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=refresh_token&refresh_token=${WSO2_REFRESH_TOKEN}")

HTTP_CODE=$(echo "$REFRESH_RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$REFRESH_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓ Token refresh works${NC}"
    NEW_ACCESS_TOKEN=$(echo "$RESPONSE_BODY" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
    echo -e "  New Access Token: ${NEW_ACCESS_TOKEN:0:50}..."
else
    echo -e "${RED}✗ Token refresh failed (HTTP $HTTP_CODE)${NC}"
    echo -e "  Response: $RESPONSE_BODY"
fi
echo ""

# Summary
echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}Test Summary${NC}"
echo -e "${BLUE}==========================================${NC}"
echo ""
echo -e "All critical tests completed."
echo -e "Check the results above for any failures."
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo -e "1. If tests pass, you can enable WSO2 in your frontend"
echo -e "2. Update wso2Config.js with your actual credentials"
echo -e "3. Set WSO2_CONFIG.enabled = true"
echo -e "4. Test the frontend application"
echo ""
