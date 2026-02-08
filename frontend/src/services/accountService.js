import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:3002';

const accountService = {
  createAccount: (data) => axios.post(`${API_BASE_URL}/api/accounts`, data),
  getAccounts: () => axios.get(`${API_BASE_URL}/api/accounts`),
  getAccountById: (accountId) => axios.get(`${API_BASE_URL}/api/accounts/${accountId}`),
  updateAccount: (accountId, data) => axios.put(`${API_BASE_URL}/api/accounts/${accountId}`, data),
  deleteAccount: (accountId) => axios.delete(`${API_BASE_URL}/api/accounts/${accountId}`),
  getBalance: (accountId) => axios.get(`${API_BASE_URL}/api/accounts/${accountId}/balance`),
};

export default accountService;
