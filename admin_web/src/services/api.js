import axios from 'axios';

const BASE_URL = 'http://localhost:5000/api';

const api = axios.create({ baseURL: BASE_URL });

// Auto-inject Firebase token from localStorage
api.interceptors.request.use((config) => {
    const token = localStorage.getItem('adminToken');
    if (token) config.headers.Authorization = `Bearer ${token}`;
    return config;
});

export const adminApi = {
    // Auth — verify google token with backend → returns user role
    loginWithGoogle: (idToken) => api.post('/auth/google', { idToken }),

    // Admin stats
    getPlatformStats: () => api.get('/admin/stats'),

    // Users
    getUsers: () => api.get('/admin/users'),
    getUserDetail: (uid) => api.get(`/admin/users/${uid}`),
    updateUserRole: (uid, role) => api.patch(`/admin/users/${uid}/role`, { role }),
};
