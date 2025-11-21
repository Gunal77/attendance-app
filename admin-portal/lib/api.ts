import axios, { AxiosInstance, AxiosError } from 'axios';

const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL || 'https://api.my-backend.com/v1';

// Create axios instance
export const api: AxiosInstance = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  withCredentials: true, // Important for HttpOnly cookies
});

// Request interceptor to add auth token if available
api.interceptors.request.use(
  async (config) => {
    // For client-side requests, we'll use Next.js API routes that handle cookies
    // The token is stored in HttpOnly cookie, so we can't access it from client
    // All client-side API calls should go through /api/proxy routes
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor for error handling
api.interceptors.response.use(
  (response) => response,
  (error: AxiosError) => {
    if (error.response?.status === 401) {
      // Handle unauthorized - redirect to login
      if (typeof window !== 'undefined') {
        window.location.href = '/login';
      }
    }
    return Promise.reject(error);
  }
);

// Auth API
export const authAPI = {
  login: async (email: string, password: string) => {
    // Backend supports both /api/admin/auth and /admin/auth
    const response = await api.post('/api/admin/auth/login', { email, password });
    return response.data;
  },
};

// Employees API - using Next.js API routes as proxy to handle HttpOnly cookies
export const employeesAPI = {
  getAll: async () => {
    const response = await fetch('/api/proxy/employees', {
      credentials: 'include',
    });
    const data = await response.json();
    if (!response.ok) throw { response: { status: response.status, data } };
    return data;
  },
  getById: async (id: string) => {
    const response = await fetch(`/api/proxy/employees/${id}`, {
      credentials: 'include',
    });
    const data = await response.json();
    if (!response.ok) throw { response: { status: response.status, data } };
    return data;
  },
  create: async (data: {
    name: string;
    email?: string;
    phone?: string;
    role?: string;
    project_id?: string;
  }) => {
    const response = await fetch('/api/proxy/employees', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
      credentials: 'include',
    });
    const responseData = await response.json();
    if (!response.ok) throw { response: { status: response.status, data: responseData } };
    return responseData;
  },
  update: async (id: string, data: {
    name?: string;
    email?: string;
    phone?: string;
    role?: string;
    project_id?: string;
  }) => {
    const response = await fetch(`/api/proxy/employees/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
      credentials: 'include',
    });
    const responseData = await response.json();
    if (!response.ok) throw { response: { status: response.status, data: responseData } };
    return responseData;
  },
  delete: async (id: string) => {
    const response = await fetch(`/api/proxy/employees/${id}`, {
      method: 'DELETE',
      credentials: 'include',
    });
    const data = await response.json();
    if (!response.ok) throw { response: { status: response.status, data } };
    return data;
  },
};

// Attendance API - using Next.js API routes as proxy to handle HttpOnly cookies
export const attendanceAPI = {
  getAll: async (params?: {
    employeeId?: string;
    from?: string;
    to?: string;
    user?: string;
    date?: string;
    month?: number;
    year?: number;
    sortBy?: string;
    sortOrder?: string;
  }) => {
    const queryString = params
      ? '?' + new URLSearchParams(
          Object.entries(params).reduce((acc, [key, value]) => {
            if (value !== undefined && value !== null && value !== '') {
              acc[key] = String(value);
            }
            return acc;
          }, {} as Record<string, string>)
        ).toString()
      : '';
    const response = await fetch(`/api/proxy/attendance${queryString}`, {
      credentials: 'include',
    });
    const data = await response.json();
    if (!response.ok) throw { response: { status: response.status, data } };
    return data;
  },
  getById: async (id: string) => {
    const response = await api.get(`/api/attendance/${id}`);
    return response.data;
  },
  create: async (data: {
    user_id: string;
    check_in_time?: string;
    check_out_time?: string;
    latitude?: number;
    longitude?: number;
  }) => {
    const response = await fetch('/api/proxy/attendance', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
      credentials: 'include',
    });
    const responseData = await response.json();
    if (!response.ok) throw { response: { status: response.status, data: responseData } };
    return responseData;
  },
};

// Projects API - using Next.js API routes as proxy to handle HttpOnly cookies
export const projectsAPI = {
  getAll: async () => {
    const response = await fetch('/api/proxy/projects', {
      credentials: 'include',
    });
    const data = await response.json();
    if (!response.ok) throw { response: { status: response.status, data } };
    return data;
  },
  getById: async (id: string) => {
    const response = await fetch(`/api/proxy/projects/${id}`, {
      credentials: 'include',
    });
    const data = await response.json();
    if (!response.ok) throw { response: { status: response.status, data } };
    return data;
  },
  create: async (data: {
    name: string;
    location?: string;
    start_date?: string;
    end_date?: string;
  }) => {
    const response = await fetch('/api/proxy/projects', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
      credentials: 'include',
    });
    const responseData = await response.json();
    if (!response.ok) throw { response: { status: response.status, data: responseData } };
    return responseData;
  },
  update: async (id: string, data: {
    name?: string;
    location?: string;
    start_date?: string;
    end_date?: string;
  }) => {
    const response = await fetch(`/api/proxy/projects/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
      credentials: 'include',
    });
    const responseData = await response.json();
    if (!response.ok) throw { response: { status: response.status, data: responseData } };
    return responseData;
  },
  delete: async (id: string) => {
    const response = await fetch(`/api/proxy/projects/${id}`, {
      method: 'DELETE',
      credentials: 'include',
    });
    const data = await response.json();
    if (!response.ok) throw { response: { status: response.status, data } };
    return data;
  },
};

// Types
export interface Employee {
  id: string;
  name: string;
  email?: string;
  phone?: string;
  role?: string;
  project_id?: string;
  created_at: string;
  projects?: {
    id: string;
    name: string;
    location?: string;
  };
}

export interface AttendanceRecord {
  id: string;
  user_id: string;
  user_email?: string;
  check_in_time: string;
  check_out_time?: string;
  image_url?: string;
  latitude?: number;
  longitude?: number;
}

export interface LoginResponse {
  token: string;
  message: string;
  user: {
    id: string;
    email: string;
    role: string;
  };
}

export interface Project {
  id: string;
  name: string;
  location?: string;
  start_date?: string;
  end_date?: string;
  created_at: string;
}

