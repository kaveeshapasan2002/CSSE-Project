# WSO2 API Manager - Manual Publishing Guide

## Step-by-Step Instructions to Publish Your Healthcare API

### Prerequisites
- WSO2 API Manager is installed and running
- Backend is running on `http://localhost:8080`
- OpenAPI definition file is ready at `backend/src/main/resources/api-definition.yaml`

---

## Step 1: Access the Publisher Portal

1. Open your browser and navigate to:
   ```
   https://localhost:9443/publisher
   ```

2. **Login Credentials**:
   - Username: `admin`
   - Password: `admin`

3. Click **"Sign In"**

4. You'll see the Publisher Portal dashboard (like in your screenshot showing "PizzaShackAPI")

---

## Step 2: Import the OpenAPI Definition

### Method A: Import via File Upload (Recommended)

1. **Click the "+ Create API" button** (blue button in top right, similar to your screenshot)

2. **Select "Import OpenAPI"** from the dropdown options:
   - You'll see options like:
     - REST API
     - HTTP/SOAP Endpoint
     - GraphQL
     - **Import OpenAPI** ← Select this

3. **Upload the OpenAPI File**:
   - A dialog will appear titled "Import Open API"
   - Click **"Browse File to Upload"** or drag and drop
   - Navigate to: `/Users/kaveeshaathukorala/github/CSSE-Project/backend/src/main/resources/api-definition.yaml`
   - Select the `api-definition.yaml` file

4. **API Configuration** (these fields will auto-populate from your YAML file):
   - **Name**: `CSSE Healthcare API` (or it will show as defined in your YAML)
   - **Context**: `/healthcare` (or change to your preferred context)
   - **Version**: `1.0.0`
   - Click **"Next"**

5. **Review and Import**:
   - Review the detected endpoints (should show all your paths: /api/auth/login, /api/doctors, etc.)
   - Click **"Create"** or **"Import"**

---

## Step 3: Configure Backend Endpoint

After importing, you'll be taken to the API Overview page.

### 3.1 Navigate to Endpoints

1. In the left sidebar, click **"Endpoints"** (or look for "Develop" section)
   - The menu should show options like:
     - Overview
     - **Endpoints** ← Click here
     - Resources
     - Runtime
     - etc.

### 3.2 Configure Production Endpoint

1. Under **"Endpoint Type"**, ensure **"HTTP/REST Endpoint"** is selected

2. **Production Endpoint**:
   - Click on the **"Production Endpoint"** section
   - Enter: `http://localhost:8080`
   - **Important**: Do NOT include `/api` - just the base URL

3. **Sandbox Endpoint** (optional but recommended):
   - Click on the **"Sandbox Endpoint"** section
   - Enter: `http://localhost:8080`
   - (Same as production for local testing)

4. **Advanced Configurations** (optional):
   - Expand "Show Advanced Configurations" if needed
   - Set timeouts:
     - Production Endpoint Timeout: `30000` ms (30 seconds)
     - Sandbox Endpoint Timeout: `30000` ms

5. Click **"Save"** button (usually at the bottom or top right)

---

## Step 4: Configure Runtime Settings (Important!)

### 4.1 Enable CORS

1. Click **"Runtime"** in the left sidebar

2. Navigate to **"CORS Configuration"** section

3. **Enable CORS**:
   - Toggle **"Access Control Allow Credentials"** if needed
   - **Access Control Allow Origins**: 
     - Add: `http://localhost:5173` (your React frontend)
     - Or use: `*` for testing (not recommended for production)
   - **Access Control Allow Headers**:
     - Should include: `authorization, Access-Control-Allow-Origin, Content-Type, SOAPAction, apikey`
   - **Access Control Allow Methods**:
     - Select: `GET, PUT, POST, DELETE, PATCH, OPTIONS`

4. Click **"Save"**

### 4.2 Set Rate Limiting (Throttling)

1. Still in **"Runtime"** section, find **"Rate Limiting"**

2. **API Level Throttling**:
   - Select a throttling policy:
     - `Unlimited` - No rate limiting (for testing)
     - `10PerMin` - 10 requests per minute (like in your screenshot)
     - `20PerMin` - 20 requests per minute
     - Or create custom policy

3. **Resource Level Throttling** (optional):
   - You can set different limits for each endpoint
   - For example: login endpoint might have stricter limits

4. Click **"Save"**

---

## Step 5: Deploy the API

1. Look for the **"Deploy"** button in the top right area (next to "Publish")

2. Click **"Deploy"**

3. A dialog will appear:
   - **Create New Revision**: Toggle ON
   - **Revision Description**: Enter something like "Initial deployment" or "v1.0.0 release"
   - **Deploy to Gateways**: Ensure "Default" is checked

4. Click **"Deploy"**

5. Wait for confirmation message: "API deployed successfully"

---

## Step 6: Publish the API

1. After deployment, click the **"Publish"** button (also in top right, or under "Lifecycle")

2. A confirmation dialog will appear:
   - **Publish to Developer Portal**: Confirm you want to make it available
   
3. Click **"Publish"** or **"OK"**

4. **Lifecycle State** should now change from:
   - `CREATED` → `PUBLISHED`

5. You'll see a success message: "API published successfully"

---

## Step 7: Verify Your Published API

### In Publisher Portal:

1. Your API card should now show:
   - ✅ **Status**: PUBLISHED (green badge)
   - ✅ **REST** badge
   - Context: `/healthcare`
   - Version: `1.0.0`

### View API Summary:

1. Click on your API card to view details
2. You should see:
   - **Overview**: API description, version, context
   - **Endpoints**: Your configured endpoints
   - **Resources**: All your API paths (15 endpoints from your definition)
   - **Runtime**: CORS and throttling settings
   - **Subscriptions**: Shows who subscribed (after Step 8)

---

## Step 8: Test in Developer Portal

1. **Open Developer Portal**: 
   ```
   https://localhost:9443/devportal
   ```

2. **Login** with same credentials (admin/admin)

3. **Find Your API**:
   - You should see "CSSE Healthcare API" in the API listing
   - Click on it

4. **View API Details**:
   - You can see all endpoints
   - Try the "Try Out" feature to test endpoints

---

## Step 9: Create Application & Subscribe

### 9.1 Create Application

1. In Developer Portal, click **"Applications"** in top menu

2. Click **"+ Add New Application"** button

3. Fill in details:
   - **Application Name**: `HealthcareFrontendApp` (or any name you prefer)
   - **Per Token Quota**: `10PerMin` (or choose based on your needs)
   - **Description**: "Frontend application for healthcare system"
   - **Token Type**: `JWT` (recommended) or `OAuth`

4. Click **"Save"**

### 9.2 Subscribe to Your API

1. Go back to **"APIs"** in the top menu

2. Click on your **"CSSE Healthcare API"**

3. Click **"Subscribe"** button (usually on the left side)

4. **Subscription Details**:
   - **Application**: Select `HealthcareFrontendApp` (from dropdown)
   - **Throttling Policy**: Choose `10PerMin` or `Unlimited`

5. Click **"Subscribe"**

6. You should see: "Subscribed Successfully"

### 9.3 Generate Access Keys

1. Go to **"Applications"** → Select your app (`HealthcareFrontendApp`)

2. Click on **"Production Keys"** tab (or "Sandbox Keys" for testing)

3. **Generate Keys**:
   - You can either:
     - **Option A**: Click "Generate Keys" (generates Consumer Key and Secret)
     - **Option B**: Provide your own (if you have existing OAuth app)

4. **Copy Your Credentials**:
   ```
   Consumer Key: abc123xyz... (this is your CLIENT_ID)
   Consumer Secret: def456uvw... (this is your CLIENT_SECRET)
   ```
   
5. **Important**: Save these credentials! You need them for your frontend configuration

### 9.4 Generate Access Token (Optional - for testing)

1. Still in the same page, scroll down to **"Generate Access Token"**

2. **Token Generation**:
   - **Grant Types**: Select `Password` or `Client Credentials`
   - **Scopes**: `default` (or leave empty)
   - **Validity Period**: `3600` seconds (1 hour) or as needed

3. Click **"Generate"**

4. **Copy the Access Token** - you can use this immediately for testing

---

## Step 10: Update Your Frontend Configuration

1. **Open your project** and edit:
   ```
   frontend/src/config/wso2Config.js
   ```

2. **Replace the credentials**:
   ```javascript
   export const WSO2_CONFIG = {
     enabled: true,  // ← Change to true
     gatewayUrl: 'https://localhost:8243/healthcare/1.0.0',
     tokenEndpoint: 'https://localhost:8243/token',
     
     // Replace with your actual credentials from Step 9.3:
     clientId: 'abc123xyz...',        // ← Your Consumer Key
     clientSecret: 'def456uvw...',    // ← Your Consumer Secret
     
     defaultGrantType: 'password',
     scope: 'default',
   };
   ```

3. **Save the file**

---

## Step 11: Test Your Integration

### Test via Command Line:

```bash
# 1. Get access token
curl -k -X POST https://localhost:8243/token \
  -H "Authorization: Basic $(echo -n 'YOUR_CLIENT_ID:YOUR_CLIENT_SECRET' | base64)" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&username=admin@example.com&password=admin123&scope=default"

# 2. Use the token to call your API
curl -k -X POST https://localhost:8243/healthcare/1.0.0/api/auth/login \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123"}'
```

### Or use the test script:

```bash
cd scripts
./test-wso2-integration.sh
```

---

## Troubleshooting Common Issues

### Issue 1: "API not found" when calling gateway

**Solution**:
- Verify API is deployed and published (lifecycle state = PUBLISHED)
- Check the gateway URL format: `https://localhost:8243/{context}/{version}/path`
- Example: `https://localhost:8243/healthcare/1.0.0/api/auth/login`

### Issue 2: CORS errors in browser

**Solution**:
- Go to Publisher Portal → Your API → Runtime → CORS Configuration
- Enable CORS and add your frontend URL: `http://localhost:5173`
- Add required headers: `authorization, Content-Type, Access-Control-Allow-Origin`

### Issue 3: 401 Unauthorized

**Solution**:
- Check if access token is included in request: `Authorization: Bearer <token>`
- Verify token hasn't expired (default: 3600 seconds)
- Ensure application is subscribed to the API
- Check subscription is active in Developer Portal

### Issue 4: 500 Internal Server Error

**Solution**:
- Verify backend is running: `http://localhost:8080`
- Check endpoint configuration in Publisher Portal → Endpoints
- Ensure backend URL doesn't have trailing slash
- Check backend logs for actual errors

### Issue 5: SSL Certificate Errors

**Solution**:
- For testing, use `-k` flag with curl
- Or import WSO2 certificate to your system:
  ```bash
  # Find certificate
  cd <WSO2_HOME>/repository/resources/security/
  # Import wso2carbon.jks to your system
  ```

---

## Quick Reference

### Important URLs:
- **Publisher Portal**: https://localhost:9443/publisher
- **Developer Portal**: https://localhost:9443/devportal
- **Admin Portal**: https://localhost:9443/admin
- **Gateway (HTTP)**: http://localhost:8280
- **Gateway (HTTPS)**: https://localhost:8243
- **Token Endpoint**: https://localhost:8243/token

### Your API Gateway URL:
```
https://localhost:8243/healthcare/1.0.0
```

### Example API Calls:
```
POST https://localhost:8243/healthcare/1.0.0/api/auth/login
GET  https://localhost:8243/healthcare/1.0.0/api/doctors
GET  https://localhost:8243/healthcare/1.0.0/api/staff
GET  https://localhost:8243/healthcare/1.0.0/api/users
```

---

## Next Steps

✅ API is published and ready to use!

Now you can:
1. ✅ Test API endpoints through Developer Portal "Try Out" feature
2. ✅ Update your frontend to use WSO2 gateway
3. ✅ Monitor API analytics at: https://localhost:9443/analytics
4. ✅ Add more security policies (API Keys, OAuth scopes, etc.)
5. ✅ Set up API monetization (if needed)
6. ✅ Create different environments (dev, staging, prod)

---

## Visual Guide Summary

```
Publisher Portal Flow:
┌─────────────────┐
│  1. Import API  │ ← Upload api-definition.yaml
└────────┬────────┘
         │
┌────────▼────────┐
│ 2. Configure    │ ← Set backend endpoint
│    Endpoints    │   http://localhost:8080
└────────┬────────┘
         │
┌────────▼────────┐
│ 3. Runtime      │ ← Enable CORS, set rate limits
│    Settings     │
└────────┬────────┘
         │
┌────────▼────────┐
│ 4. Deploy       │ ← Create revision, deploy to gateway
└────────┬────────┘
         │
┌────────▼────────┐
│ 5. Publish      │ ← Make available in Dev Portal
└────────┬────────┘
         │
         ▼
    ✅ DONE!

Developer Portal Flow:
┌─────────────────┐
│ 6. Create App   │ ← HealthcareFrontendApp
└────────┬────────┘
         │
┌────────▼────────┐
│ 7. Subscribe    │ ← Subscribe to your API
└────────┬────────┘
         │
┌────────▼────────┐
│ 8. Generate     │ ← Get Consumer Key & Secret
│    Keys         │
└────────┬────────┘
         │
         ▼
    ✅ READY TO USE!
```

Good luck! 🚀
