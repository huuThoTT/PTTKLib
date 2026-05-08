// services/api.js — Tập trung tất cả API calls
import axios from 'axios';

const API = axios.create({
  baseURL: 'http://localhost:8001',
  headers: { 'Content-Type': 'application/json' },
});

export const getDashboardStats    = () => API.get('/api/dashboard/stats').then(r => r.data);
export const getDashboardRevenue  = () => API.get('/api/dashboard/revenue').then(r => r.data);
export const getDashboardCerts    = () => API.get('/api/dashboard/certificates').then(r => r.data);
export const getDashboardTx       = () => API.get('/api/dashboard/transactions').then(r => r.data);

export const getLichThi  = (cert) => API.get(`/api/lich-thi?cert=${cert}`).then(r => r.data);
export const postDangKy  = (payload) => API.post('/api/dang-ky', payload).then(r => r.data);
