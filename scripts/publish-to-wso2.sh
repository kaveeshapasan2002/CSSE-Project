#!/bin/bash

# Script to publish API to WSO2 API Manager using REST API
# This automates the manual process of using the Publisher Portal

# WSO2 API Manager Configuration
WSO2_HOST="localhost"
WSO2_PORT="9443"
WSO2_USERNAME="admin"
WSO2_PASSWORD="admin"

# API Configuration
API_NAME="HealthcareAPI"
API_VERSION="1.0.0"
API_CONTEXT="/healthcare"
BACKEND_ENDPOINT="http://localhost:8080"
API_DEFINITION_FILE="../backend/src/main/resources/api-definition.yaml"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}WSO2 API Manager - API Publisher Script${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""

# Step 1: Get Access Token
echo -e "${YELLOW}[Step 1/5]${NC} Getting access token..."

# Get client credentials for password grant
TOKEN_RESPONSE=$(curl -k -s -X POST "https://${WSO2_HOST}:${WSO2_PORT}/oauth2/token" \
  -H "Authorization: Basic YWRtaW46YWRtaW4=" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&username=${WSO2_USERNAME}&password=${WSO2_PASSWORD}&scope=apim:api_create apim:api_publish")

ACCESS_TOKEN=$(echo $TOKEN_RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$ACCESS_TOKEN" ]; then
    echo -e "${RED}❌ Failed to get access token${NC}"
    echo "Response: $TOKEN_RESPONSE"
    exit 1
fi

echo -e "${GREEN}✓ Access token obtained${NC}"
echo ""

# Step 2: Check if API already exists
echo -e "${YELLOW}[Step 2/5]${NC} Checking if API exists..."

API_CHECK=$(curl -k -s -X GET "https://${WSO2_HOST}:${WSO2_PORT}/api/am/publisher/v4/apis?query=name:${API_NAME}" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}")

API_ID=$(echo $API_CHECK | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)

if [ -n "$API_ID" ]; then
    echo -e "${YELLOW}⚠ API already exists with ID: ${API_ID}${NC}"
    echo -e "${YELLOW}Updating existing API...${NC}"
    UPDATE_MODE=true
else
    echo -e "${GREEN}✓ API does not exist. Will create new API.${NC}"
    UPDATE_MODE=false
fi
echo ""

# Step 3: Create or Import API from OpenAPI Definition
echo -e "${YELLOW}[Step 3/5]${NC} Creating/Importing API from OpenAPI definition..."

if [ "$UPDATE_MODE" = true ]; then
    # Update existing API
    API_IMPORT_RESPONSE=$(curl -k -s -X PUT "https://${WSO2_HOST}:${WSO2_PORT}/api/am/publisher/v4/apis/${API_ID}/swagger" \
      -H "Authorization: Bearer ${ACCESS_TOKEN}" \
      -H "Content-Type: multipart/form-data" \
      -F "apiDefinition=@${API_DEFINITION_FILE}")
else
    # Create new API from OpenAPI
    API_IMPORT_RESPONSE=$(curl -k -s -X POST "https://${WSO2_HOST}:${WSO2_PORT}/api/am/publisher/v4/apis/import-openapi" \
      -H "Authorization: Bearer ${ACCESS_TOKEN}" \
      -F "file=@${API_DEFINITION_FILE}" \
      -F "additionalProperties={\"name\":\"${API_NAME}\",\"version\":\"${API_VERSION}\",\"context\":\"${API_CONTEXT}\"}")
    
    API_ID=$(echo $API_IMPORT_RESPONSE | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)
fi

if [ -z "$API_ID" ]; then
    echo -e "${RED}❌ Failed to create/update API${NC}"
    echo "Response: $API_IMPORT_RESPONSE"
    exit 1
fi

echo -e "${GREEN}✓ API created/updated with ID: ${API_ID}${NC}"
echo ""

# Step 4: Update API Configuration
echo -e "${YELLOW}[Step 4/5]${NC} Updating API configuration..."

# Get current API details
API_DETAILS=$(curl -k -s -X GET "https://${WSO2_HOST}:${WSO2_PORT}/api/am/publisher/v4/apis/${API_ID}" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}")

# Update API with endpoint configuration
API_UPDATE=$(curl -k -s -X PUT "https://${WSO2_HOST}:${WSO2_PORT}/api/am/publisher/v4/apis/${API_ID}" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "'"${API_NAME}"'",
    "version": "'"${API_VERSION}"'",
    "context": "'"${API_CONTEXT}"'",
    "endpointConfig": {
      "endpoint_type": "http",
      "production_endpoints": {
        "url": "'"${BACKEND_ENDPOINT}"'"
      },
      "sandbox_endpoints": {
        "url": "'"${BACKEND_ENDPOINT}"'"
      }
    },
    "policies": ["Unlimited"],
    "visibility": "PUBLIC",
    "transport": ["http", "https"],
    "corsConfiguration": {
      "corsConfigurationEnabled": true,
      "accessControlAllowOrigins": ["*"],
      "accessControlAllowCredentials": false,
      "accessControlAllowHeaders": ["authorization", "Access-Control-Allow-Origin", "Content-Type", "SOAPAction", "apikey"],
      "accessControlAllowMethods": ["GET", "PUT", "POST", "DELETE", "PATCH", "OPTIONS"]
    }
  }')

echo -e "${GREEN}✓ API configuration updated${NC}"
echo ""

# Step 5: Deploy and Publish API
echo -e "${YELLOW}[Step 5/5]${NC} Deploying and publishing API..."

# Deploy API
DEPLOY_RESPONSE=$(curl -k -s -X POST "https://${WSO2_HOST}:${WSO2_PORT}/api/am/publisher/v4/apis/${API_ID}/deploy-revision" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Initial deployment"
  }')

# Change lifecycle to PUBLISHED
PUBLISH_RESPONSE=$(curl -k -s -X POST "https://${WSO2_HOST}:${WSO2_PORT}/api/am/publisher/v4/apis/change-lifecycle?apiId=${API_ID}&action=Publish" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}")

echo -e "${GREEN}✓ API deployed and published${NC}"
echo ""

# Summary
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ API Successfully Published!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "API Details:"
echo -e "  Name: ${API_NAME}"
echo -e "  Version: ${API_VERSION}"
echo -e "  Context: ${API_CONTEXT}"
echo -e "  API ID: ${API_ID}"
echo ""
echo -e "Access URLs:"
echo -e "  Publisher Portal: https://${WSO2_HOST}:${WSO2_PORT}/publisher/apis/${API_ID}/overview"
echo -e "  Developer Portal: https://${WSO2_HOST}:${WSO2_PORT}/devportal/apis/${API_ID}/overview"
echo -e "  Gateway URL: https://${WSO2_HOST}:8243${API_CONTEXT}/${API_VERSION}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo -e "1. Create an application in Developer Portal"
echo -e "2. Subscribe to this API"
echo -e "3. Generate access tokens"
echo -e "4. Test the API endpoints"
echo ""
