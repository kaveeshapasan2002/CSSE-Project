# WSO2 API Manager Integration Guide

## Prerequisites

1. Install WSO2 API Manager (v4.6.0 or later)
2. Start WSO2 API Manager:
   ```bash
   cd <WSO2_API_MANAGER_HOME>/bin
   ./api-manager.sh
   ```
3. Access portals:
   - Publisher Portal: https://localhost:9443/publisher
   - Developer Portal: https://localhost:9443/devportal
   - Admin Portal: https://localhost:9443/admin
   - Default credentials: admin/admin

## Step 1: Configure Your Backend as an API

### 1.1 Create API Definition (OpenAPI Spec)

Create a file `backend/src/main/resources/api-definition.yaml`:

```yaml
openapi: 3.0.0
info:
  title: CSSE Healthcare API
  description: Healthcare Management System API
  version: 1.0.0
servers:
  - url: http://localhost:8080
    description: Development server

paths:
  /api/auth/login:
    post:
      tags:
        - Authentication
      summary: User login
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                email:
                  type: string
                password:
                  type: string
      responses:
        '200':
          description: Login successful
          content:
            application/json:
              schema:
                type: object
                properties:
                  token:
                    type: string
                  role:
                    type: string

  /api/auth/register:
    post:
      tags:
        - Authentication
      summary: User registration
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
      responses:
        '200':
          description: Registration successful

  /api/doctors:
    get:
      tags:
        - Doctors
      summary: Get all doctors
      security:
        - bearerAuth: []
      responses:
        '200':
          description: List of doctors
          content:
            application/json:
              schema:
                type: array
                items:
                  type: object

  /api/doctors/{id}:
    get:
      tags:
        - Doctors
      summary: Get doctor by ID
      security:
        - bearerAuth: []
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: integer
      responses:
        '200':
          description: Doctor details

  /api/staff:
    get:
      tags:
        - Staff
      summary: Get all staff
      security:
        - bearerAuth: []
      responses:
        '200':
          description: List of staff

  /api/users:
    get:
      tags:
        - Users
      summary: Get all users
      security:
        - bearerAuth: []
      responses:
        '200':
          description: List of users

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
```

## Step 2: Publish API to WSO2 API Manager

### Using Publisher Portal (UI Method)

1. **Login to Publisher Portal**: https://localhost:9443/publisher
2. **Create API from OpenAPI Definition**:
   - Click "Create API" → "Import OpenAPI"
   - Upload the `api-definition.yaml` file
   - Set API name: `HealthcareAPI`
   - Context: `/healthcare`
   - Version: `1.0.0`
   
3. **Configure Backend Endpoint**:
   - Go to "Endpoints" section
   - Production Endpoint: `http://localhost:8080`
   - Sandbox Endpoint: `http://localhost:8080`

4. **Configure Runtime Settings**:
   - Navigate to "Runtime" → "Backend"
   - Enable CORS if needed
   - Set timeout values

5. **Apply Rate Limiting**:
   - Go to "Runtime" → "Rate Limiting"
   - Select throttling policy: `10PerMin`, `20PerMin`, or `Unlimited`

6. **Publish the API**:
   - Click "Deploy" button
   - Then click "Publish"

### Using REST API (Automated Method)

See the `scripts/publish-to-wso2.sh` script below.

## Step 3: Create Application in Developer Portal

1. **Login to Developer Portal**: https://localhost:9443/devportal
2. **Create Application**:
   - Go to "Applications" → "Add New Application"
   - Name: `HealthcareFrontendApp`
   - Throttling Policy: `10PerMin`
   - Description: "Frontend application for healthcare system"
   - Click "Save"

3. **Subscribe to API**:
   - Go to "APIs" and find `HealthcareAPI`
   - Click "Subscribe"
   - Select your application: `HealthcareFrontendApp`
   - Choose throttling tier
   - Click "Subscribe"

4. **Generate Access Tokens**:
   - Go to "Applications" → Select your app
   - Navigate to "Production Keys" or "Sandbox Keys"
   - Click "Generate Keys"
   - Copy the **Consumer Key** and **Consumer Secret**
   - Generate access token (or use OAuth2 flow)

## Step 4: Update Frontend to Use WSO2 Gateway

### 4.1 Create WSO2 API Configuration

Create `frontend/src/config/wso2Config.js`:

```javascript
export const WSO2_CONFIG = {
  // WSO2 API Gateway URL
  gatewayUrl: 'https://localhost:8243/healthcare/1.0.0',
  
  // Token endpoint for OAuth2
  tokenEndpoint: 'https://localhost:8243/token',
  
  // Application credentials (from Developer Portal)
  clientId: 'YOUR_CONSUMER_KEY',
  clientSecret: 'YOUR_CONSUMER_SECRET',
  
  // Grant type
  grantType: 'password', // or 'client_credentials'
  
  // Scopes (if needed)
  scope: 'default'
};

export default WSO2_CONFIG;
```

### 4.2 Create WSO2 Auth Service

Create `frontend/src/services/wso2Auth.js`:

```javascript
import axios from 'axios';
import WSO2_CONFIG from '../config/wso2Config';

class WSO2AuthService {
  async getAccessToken(username, password) {
    const params = new URLSearchParams();
    params.append('grant_type', WSO2_CONFIG.grantType);
    params.append('username', username);
    params.append('password', password);
    params.append('scope', WSO2_CONFIG.scope);

    const authHeader = btoa(`${WSO2_CONFIG.clientId}:${WSO2_CONFIG.clientSecret}`);

    try {
      const response = await axios.post(
        WSO2_CONFIG.tokenEndpoint,
        params,
        {
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': `Basic ${authHeader}`
          }
        }
      );

      return {
        accessToken: response.data.access_token,
        refreshToken: response.data.refresh_token,
        expiresIn: response.data.expires_in
      };
    } catch (error) {
      console.error('Error getting access token:', error);
      throw error;
    }
  }

  async refreshAccessToken(refreshToken) {
    const params = new URLSearchParams();
    params.append('grant_type', 'refresh_token');
    params.append('refresh_token', refreshToken);

    const authHeader = btoa(`${WSO2_CONFIG.clientId}:${WSO2_CONFIG.clientSecret}`);

    try {
      const response = await axios.post(
        WSO2_CONFIG.tokenEndpoint,
        params,
        {
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': `Basic ${authHeader}`
          }
        }
      );

      return {
        accessToken: response.data.access_token,
        refreshToken: response.data.refresh_token,
        expiresIn: response.data.expires_in
      };
    } catch (error) {
      console.error('Error refreshing access token:', error);
      throw error;
    }
  }
}

export default new WSO2AuthService();
```

### 4.3 Update API Service to Use WSO2 Gateway

Update `frontend/src/services/api.js`:

```javascript
import axios from 'axios';
import WSO2_CONFIG from '../config/wso2Config';

// Use WSO2 Gateway URL instead of direct backend
const API_URL = WSO2_CONFIG.gatewayUrl;

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add request interceptor to include access token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('wso2_access_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Add response interceptor to handle token refresh
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;

      try {
        const refreshToken = localStorage.getItem('wso2_refresh_token');
        const wso2Auth = (await import('./wso2Auth')).default;
        const tokens = await wso2Auth.refreshAccessToken(refreshToken);
        
        localStorage.setItem('wso2_access_token', tokens.accessToken);
        localStorage.setItem('wso2_refresh_token', tokens.refreshToken);
        
        originalRequest.headers.Authorization = `Bearer ${tokens.accessToken}`;
        return api(originalRequest);
      } catch (refreshError) {
        // Redirect to login
        localStorage.clear();
        window.location.href = '/login';
        return Promise.reject(refreshError);
      }
    }

    return Promise.reject(error);
  }
);

export default api;
```

## Step 5: Update Login Flow

Update your login page to use WSO2 tokens:

```javascript
import wso2Auth from '../services/wso2Auth';
import api from '../services/api';

const handleLogin = async (email, password) => {
  try {
    // Step 1: Get WSO2 access token
    const tokens = await wso2Auth.getAccessToken(email, password);
    
    // Store tokens
    localStorage.setItem('wso2_access_token', tokens.accessToken);
    localStorage.setItem('wso2_refresh_token', tokens.refreshToken);
    
    // Step 2: Call your backend login through WSO2 gateway
    const response = await api.post('/api/auth/login', {
      email,
      password
    });
    
    // Store user info and JWT (if your backend still uses it)
    localStorage.setItem('user', JSON.stringify(response.data));
    
    // Redirect based on role
    redirectToDashboard(response.data.role);
  } catch (error) {
    console.error('Login failed:', error);
    // Handle error
  }
};
```

## Step 6: Backend CORS Configuration

Update your Spring Boot backend to allow requests from WSO2 Gateway:

```java
// backend/src/main/java/com/pavan/csse/backend/config/SecurityConfig.java

@Bean
public CorsConfigurationSource corsConfigurationSource() {
    CorsConfiguration configuration = new CorsConfiguration();
    configuration.setAllowedOrigins(Arrays.asList(
        "http://localhost:5173",
        "https://localhost:8243",  // WSO2 Gateway
        "https://localhost:9443"   // WSO2 Portals
    ));
    configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
    configuration.setAllowedHeaders(Arrays.asList("*"));
    configuration.setAllowCredentials(true);
    
    UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/**", configuration);
    return source;
}
```

## Alternative: API Key Authentication

If you prefer simpler API Key authentication instead of OAuth2:

### 1. In Developer Portal:
- Generate API Key for your application
- Use the generated key in your requests

### 2. Frontend configuration:
```javascript
// Use API Key instead of Bearer token
api.interceptors.request.use((config) => {
  const apiKey = 'YOUR_API_KEY';
  config.headers['apikey'] = apiKey;
  return config;
});
```

## Testing Your Integration

### 1. Direct Backend (without WSO2):
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'
```

### 2. Through WSO2 Gateway:
```bash
# Get access token first
curl -k -X POST https://localhost:8243/token \
  -H "Authorization: Basic BASE64(clientId:clientSecret)" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&username=test@example.com&password=password"

# Use access token to call API
curl -k -X POST https://localhost:8243/healthcare/1.0.0/api/auth/login \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'
```

## Benefits of Using WSO2 API Manager

1. **Rate Limiting**: Protect your backend from overload
2. **Analytics**: Track API usage, response times, errors
3. **Security**: Centralized authentication and authorization
4. **API Versioning**: Manage multiple API versions
5. **Developer Portal**: Easy API discovery for developers
6. **Monetization**: Set up subscription tiers (if needed)
7. **Gateway Caching**: Improve performance

## Monitoring & Analytics

Access analytics at: https://localhost:9443/analytics

You can view:
- API usage statistics
- Response time metrics
- Error rates
- Top users/applications
- Geographic distribution

## Troubleshooting

### Common Issues:

1. **SSL Certificate Errors**:
   - Use `-k` flag with curl for testing
   - Import WSO2 certificates to your browser/system

2. **CORS Errors**:
   - Enable CORS in WSO2 API Manager
   - Update backend CORS configuration

3. **401 Unauthorized**:
   - Check access token validity
   - Verify subscription is active
   - Check API permissions

4. **Connection Refused**:
   - Ensure backend is running on localhost:8080
   - Verify WSO2 API Manager is running
   - Check endpoint configuration in Publisher Portal

## Next Steps

1. ✅ Install and start WSO2 API Manager
2. ✅ Create OpenAPI definition
3. ✅ Publish API to WSO2
4. ✅ Create application in Developer Portal
5. ✅ Update frontend configuration
6. ✅ Test the integration
7. 📊 Monitor analytics
8. 🔒 Configure additional security policies
9. 🚀 Deploy to production
