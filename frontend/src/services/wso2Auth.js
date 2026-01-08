import axios from 'axios';
import WSO2_CONFIG from '../config/wso2Config';

/**
 * WSO2 Authentication Service
 * Handles OAuth2 token management for WSO2 API Manager
 */
class WSO2AuthService {
  /**
   * Get access token using password grant type
   * @param {string} username - User's email/username
   * @param {string} password - User's password
   * @returns {Promise<Object>} Token response
   */
  async getAccessToken(username, password) {
    if (!WSO2_CONFIG.enabled) {
      console.warn('WSO2 is not enabled. Skipping token generation.');
      return null;
    }

    const params = new URLSearchParams();
    params.append('grant_type', WSO2_CONFIG.grantType.PASSWORD);
    params.append('username', username);
    params.append('password', password);
    params.append('scope', WSO2_CONFIG.scope);

    const authHeader = this._getBasicAuthHeader();

    try {
      const response = await axios.post(
        WSO2_CONFIG.tokenEndpoint,
        params,
        {
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': authHeader,
          },
          timeout: WSO2_CONFIG.timeout,
        }
      );

      const tokens = {
        accessToken: response.data.access_token,
        refreshToken: response.data.refresh_token,
        expiresIn: response.data.expires_in,
        tokenType: response.data.token_type,
        scope: response.data.scope,
      };

      // Store tokens
      this._storeTokens(tokens);

      return tokens;
    } catch (error) {
      console.error('Error getting WSO2 access token:', error.response?.data || error.message);
      throw new Error('Failed to authenticate with WSO2 API Manager');
    }
  }

  /**
   * Refresh access token using refresh token
   * @param {string} refreshToken - Refresh token
   * @returns {Promise<Object>} New token response
   */
  async refreshAccessToken(refreshToken) {
    if (!WSO2_CONFIG.enabled) {
      return null;
    }

    const params = new URLSearchParams();
    params.append('grant_type', WSO2_CONFIG.grantType.REFRESH_TOKEN);
    params.append('refresh_token', refreshToken);

    const authHeader = this._getBasicAuthHeader();

    try {
      const response = await axios.post(
        WSO2_CONFIG.tokenEndpoint,
        params,
        {
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': authHeader,
          },
          timeout: WSO2_CONFIG.timeout,
        }
      );

      const tokens = {
        accessToken: response.data.access_token,
        refreshToken: response.data.refresh_token,
        expiresIn: response.data.expires_in,
        tokenType: response.data.token_type,
        scope: response.data.scope,
      };

      // Store new tokens
      this._storeTokens(tokens);

      return tokens;
    } catch (error) {
      console.error('Error refreshing WSO2 access token:', error.response?.data || error.message);
      // If refresh fails, clear tokens and force re-login
      this.clearTokens();
      throw new Error('Failed to refresh token. Please login again.');
    }
  }

  /**
   * Get client credentials token (for machine-to-machine communication)
   * @returns {Promise<Object>} Token response
   */
  async getClientCredentialsToken() {
    if (!WSO2_CONFIG.enabled) {
      return null;
    }

    const params = new URLSearchParams();
    params.append('grant_type', WSO2_CONFIG.grantType.CLIENT_CREDENTIALS);
    params.append('scope', WSO2_CONFIG.scope);

    const authHeader = this._getBasicAuthHeader();

    try {
      const response = await axios.post(
        WSO2_CONFIG.tokenEndpoint,
        params,
        {
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': authHeader,
          },
          timeout: WSO2_CONFIG.timeout,
        }
      );

      return {
        accessToken: response.data.access_token,
        expiresIn: response.data.expires_in,
        tokenType: response.data.token_type,
        scope: response.data.scope,
      };
    } catch (error) {
      console.error('Error getting client credentials token:', error.response?.data || error.message);
      throw new Error('Failed to get client credentials token');
    }
  }

  /**
   * Revoke access token
   * @param {string} token - Token to revoke
   * @returns {Promise<void>}
   */
  async revokeToken(token) {
    if (!WSO2_CONFIG.enabled) {
      return;
    }

    const params = new URLSearchParams();
    params.append('token', token);
    params.append('token_type_hint', 'access_token');

    const authHeader = this._getBasicAuthHeader();

    try {
      await axios.post(
        WSO2_CONFIG.revokeEndpoint,
        params,
        {
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': authHeader,
          },
          timeout: WSO2_CONFIG.timeout,
        }
      );

      this.clearTokens();
    } catch (error) {
      console.error('Error revoking token:', error.response?.data || error.message);
      // Clear tokens anyway on error
      this.clearTokens();
    }
  }

  /**
   * Check if access token is expired
   * @returns {boolean} True if expired
   */
  isTokenExpired() {
    const expiry = localStorage.getItem(WSO2_CONFIG.storageKeys.tokenExpiry);
    if (!expiry) return true;
    
    return Date.now() >= parseInt(expiry);
  }

  /**
   * Get stored access token
   * @returns {string|null} Access token
   */
  getStoredAccessToken() {
    return localStorage.getItem(WSO2_CONFIG.storageKeys.accessToken);
  }

  /**
   * Get stored refresh token
   * @returns {string|null} Refresh token
   */
  getStoredRefreshToken() {
    return localStorage.getItem(WSO2_CONFIG.storageKeys.refreshToken);
  }

  /**
   * Clear all stored tokens
   */
  clearTokens() {
    localStorage.removeItem(WSO2_CONFIG.storageKeys.accessToken);
    localStorage.removeItem(WSO2_CONFIG.storageKeys.refreshToken);
    localStorage.removeItem(WSO2_CONFIG.storageKeys.tokenExpiry);
  }

  /**
   * Store tokens in localStorage
   * @private
   */
  _storeTokens(tokens) {
    localStorage.setItem(WSO2_CONFIG.storageKeys.accessToken, tokens.accessToken);
    
    if (tokens.refreshToken) {
      localStorage.setItem(WSO2_CONFIG.storageKeys.refreshToken, tokens.refreshToken);
    }
    
    // Calculate expiry time (current time + expires_in - 60 seconds buffer)
    const expiryTime = Date.now() + (tokens.expiresIn * 1000) - 60000;
    localStorage.setItem(WSO2_CONFIG.storageKeys.tokenExpiry, expiryTime.toString());
  }

  /**
   * Get Basic Auth header for client credentials
   * @private
   */
  _getBasicAuthHeader() {
    const credentials = `${WSO2_CONFIG.clientId}:${WSO2_CONFIG.clientSecret}`;
    const encodedCredentials = btoa(credentials);
    return `Basic ${encodedCredentials}`;
  }
}

export default new WSO2AuthService();
