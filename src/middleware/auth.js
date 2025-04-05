const jwt = require('jsonwebtoken');
const { ApiError } = require('./errorHandler');

/**
 * Middleware to authenticate requests using JWT
 * Verifies the token and adds user data to the request object
 */
const authenticate = (req, res, next) => {
  try {
    // Get token from header
    const authHeader = req.header('Authorization');
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw ApiError.unauthorized('Authentication token is required');
    }
    
    const token = authHeader.split(' ')[1];
    
    if (!token) {
      throw ApiError.unauthorized('Authentication token is required');
    }
    
    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Add user info to request
    req.user = decoded;
    
    next();
  } catch (err) {
    if (err.name === 'JsonWebTokenError' || err.name === 'TokenExpiredError') {
      return next(ApiError.unauthorized('Invalid or expired token'));
    }
    next(err);
  }
};

/**
 * Middleware to check if user has admin role
 * Must be used after authenticate middleware
 */
const isAdmin = (req, res, next) => {
  if (!req.user || req.user.role !== 'admin') {
    return next(ApiError.forbidden('Access denied: Admin privileges required'));
  }
  next();
};

module.exports = { authenticate, isAdmin }; 