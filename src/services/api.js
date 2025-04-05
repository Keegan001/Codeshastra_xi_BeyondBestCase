import axios from 'axios'

// Create axios instance with default config
const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:5000/api',
  headers: {
    'Content-Type': 'application/json'
  },
  timeout: 10000 // 10 seconds timeout
})

// Request interceptor for adding auth token
api.interceptors.request.use(
  config => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  error => Promise.reject(error)
)

// Response interceptor for handling errors
api.interceptors.response.use(
  response => response,
  async error => {
    const originalRequest = error.config
    
    // Handle 401 Unauthorized errors
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true
      
      // Try to refresh the token
      try {
        const refreshToken = localStorage.getItem('token')
        if (refreshToken) {
          // Create a new instance to avoid circular requests
          const refreshResponse = await axios.post(
            `${import.meta.env.VITE_API_URL || 'http://localhost:5000/api'}/auth/refresh`,
            { token: refreshToken },
            { headers: { 'Content-Type': 'application/json' } }
          )
          
          const { token } = refreshResponse.data
          localStorage.setItem('token', token)
          
          // Retry the original request with the new token
          originalRequest.headers.Authorization = `Bearer ${token}`
          return axios(originalRequest)
        }
      } catch (refreshError) {
        // If refresh token fails, redirect to login
        localStorage.removeItem('token')
        localStorage.removeItem('user')
        window.location.href = '/login'
      }
    }
    
    return Promise.reject(error)
  }
)

export default api 