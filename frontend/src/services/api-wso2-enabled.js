import axios from 'axios';
import WSO2_CONFIG, { getBaseURL, isWSO2Configured } from '../config/wso2Config';
import wso2Auth from './wso2Auth';

// Use WSO2 Gateway URL if enabled, otherwise use direct backend URL
const API_URL = getBaseURL();

const api = axios.create({
  baseURL: API_URL,
  timeout: WSO2_CONFIG.timeout || 30000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add authentication tokens
api.interceptors.request.use(
  (config) => {
    if (WSO2_CONFIG.enabled && isWSO2Configured()) {
      // Use WSO2 access token
      const wso2Token = wso2Auth.getStoredAccessToken();
      if (wso2Token) {
        config.headers.Authorization = `Bearer ${wso2Token}`;
      }
    } else {
      // Use original backend JWT token
      const backendToken = localStorage.getItem(WSO2_CONFIG.storageKeys.backendToken);
      if (backendToken) {
        config.headers.Authorization = `Bearer ${backendToken}`;
      }
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor to handle token refresh and errors
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    // Handle 401 Unauthorized errors
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;

      if (WSO2_CONFIG.enabled && isWSO2Configured()) {
        try {
          // Try to refresh WSO2 token
          const refreshToken = wso2Auth.getStoredRefreshToken();
          
          if (refreshToken) {
            const tokens = await wso2Auth.refreshAccessToken(refreshToken);
            
            // Retry the original request with new token
            originalRequest.headers.Authorization = `Bearer ${tokens.accessToken}`;
            return api(originalRequest);
          } else {
            // No refresh token available, redirect to login
            handleAuthFailure();
          }
        } catch (refreshError) {
          console.error('Token refresh failed:', refreshError);
          handleAuthFailure();
          return Promise.reject(refreshError);
        }
      } else {
        // Direct backend mode - redirect to login
        handleAuthFailure();
      }
    }

    return Promise.reject(error);
  }
);

// Helper function to handle authentication failures
const handleAuthFailure = () => {
  // Clear all tokens
  wso2Auth.clearTokens();
  localStorage.removeItem(WSO2_CONFIG.storageKeys.backendToken);
  localStorage.removeItem('user');
  
  // Redirect to login page
  if (window.location.pathname !== '/login') {
    window.location.href = '/login';
  }
};

// Authentication API calls
export const login = async (credentials) => {
  if (WSO2_CONFIG.enabled && isWSO2Configured()) {
    // Step 1: Get WSO2 access token first
    await wso2Auth.getAccessToken(credentials.email, credentials.password);
  }
  
  // Step 2: Call backend login (either through WSO2 gateway or directly)
  const response = await api.post('/auth/login', credentials);
  
  // Store backend JWT token if provided
  if (response.data.token) {
    localStorage.setItem(WSO2_CONFIG.storageKeys.backendToken, response.data.token);
  }
  
  return response;
};

export const register = (userData) => {
  return api.post('/auth/register', userData);
};

export const logout = async () => {
  try {
    if (WSO2_CONFIG.enabled && isWSO2Configured()) {
      const accessToken = wso2Auth.getStoredAccessToken();
      if (accessToken) {
        await wso2Auth.revokeToken(accessToken);
      }
    }
  } catch (error) {
    console.error('Logout error:', error);
  } finally {
    // Clear all local storage
    wso2Auth.clearTokens();
    localStorage.removeItem(WSO2_CONFIG.storageKeys.backendToken);
    localStorage.removeItem('user');
  }
};

// Doctor API calls
export const getDoctorDashboard = (token) => {
  // Token is now handled by interceptor, but keeping parameter for backward compatibility
  return api.get('/doctor/dashboard');
};

export const getAllDoctors = () => {
  return api.get('/doctors');
};

export const getDoctorById = (id) => {
  return api.get(`/doctors/${id}`);
};

// Staff API calls
export const getStaffDashboard = (token) => {
  // Token is now handled by interceptor, but keeping parameter for backward compatibility
  return api.get('/staff/dashboard');
};

export const getAllStaff = () => {
  return api.get('/staff');
};

export const getStaffById = (id) => {
  return api.get(`/staff/${id}`);
};

// User API calls
export const getAllUsers = () => {
  return api.get('/users');
};

export const getUserById = (id) => {
  return api.get(`/users/${id}`);
};

// Test endpoints
export const testPublicEndpoint = () => {
  return axios.get(`${API_URL.replace('/api', '')}/test`);
};

export const testAuthenticatedEndpoint = () => {
  return api.get('/test');
};

export default api;
