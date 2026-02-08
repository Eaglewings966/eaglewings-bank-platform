import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:3001';

const authService = {
  register: (data) => axios.post(`${API_BASE_URL}/api/auth/register`, data),
  login: (data) => axios.post(`${API_BASE_URL}/api/auth/login`, data),
  logout: () => axios.post(`${API_BASE_URL}/api/auth/logout`),
  getProfile: () => axios.get(`${API_BASE_URL}/api/auth/profile`),
  changePassword: (data) => axios.put(`${API_BASE_URL}/api/auth/change-password`, data),
};

export default authService;
