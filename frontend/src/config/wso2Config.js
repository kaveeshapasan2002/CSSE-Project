// WSO2 API Manager Configuration
export const WSO2_CONFIG = {
  // Enable/Disable WSO2 API Manager
  enabled: true, // ✅ WSO2 Gateway enabled!
  
  // WSO2 API Gateway URL
  gatewayUrl: 'https://localhost:8243/healthcare/1.0.0',
  
  // Direct backend URL (used when WSO2 is disabled)
  directBackendUrl: 'http://localhost:8080',
  
  // Token endpoint for OAuth2
  tokenEndpoint: 'https://localhost:8243/token',
  
  // Revoke endpoint
  revokeEndpoint: 'https://localhost:8243/revoke',
  
  // Application credentials (from Developer Portal)
  clientId: 'bq0o5FjhaEJWPt17802f8yuKXxQa',
  clientSecret: '5zR6A0aaU8g7hAXEMo9sWRkbGGka',
  
  // OAuth2 Grant Types
  grantType: {
    PASSWORD: 'password',
    CLIENT_CREDENTIALS: 'client_credentials',
    REFRESH_TOKEN: 'refresh_token',
  },
  
  // Default grant type to use
  defaultGrantType: 'password',
  
  // Scopes (if needed)
  scope: 'default',
  
  // Token storage keys
  storageKeys: {
    accessToken: 'wso2_access_token',
    refreshToken: 'wso2_refresh_token',
    tokenExpiry: 'wso2_token_expiry',
    backendToken: 'backend_jwt_token', // Your original JWT token
  },
  
  // Request timeout (ms)
  timeout: 30000,
  
  // Retry configuration
  retry: {
    maxRetries: 3,
    retryDelay: 1000,
  },
};

// Get the appropriate base URL based on WSO2 configuration
export const getBaseURL = () => {
  return WSO2_CONFIG.enabled 
    ? WSO2_CONFIG.gatewayUrl 
    : WSO2_CONFIG.directBackendUrl;
};

// Check if WSO2 is properly configured
export const isWSO2Configured = () => {
  return (
    WSO2_CONFIG.enabled &&
    WSO2_CONFIG.clientId !== 'YOUR_CONSUMER_KEY' &&
    WSO2_CONFIG.clientSecret !== 'YOUR_CONSUMER_SECRET'
  );
};

export default WSO2_CONFIG;
