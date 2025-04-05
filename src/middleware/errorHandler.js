/**
 * Global error handler middleware
 */
const errorHandler = (err, req, res, next) => {
  console.error(err.stack);

  const statusCode = err.statusCode || 500;
  const message = err.message || 'Internal Server Error';
  
  res.status(statusCode).json({
    error: {
      message,
      status: statusCode,
      ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
    }
  });
};

/**
 * Custom error class for API errors
 */
class ApiError extends Error {
  /**
   * Create an API error
   * @param {String} message - Error message
   * @param {Number} statusCode - HTTP status code
   * @param {Object} errors - Additional error details
   */
  constructor(message, statusCode, errors = null) {
    super(message);
    this.statusCode = statusCode;
    this.errors = errors;
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
  }

  /**
   * Create a 400 Bad Request error
   * @param {String|Object} message - Error message or error object
   * @returns {ApiError} ApiError instance
   */
  static badRequest(message) {
    if (typeof message === 'string') {
      return new ApiError(message, 400);
    }
    return new ApiError('Bad Request', 400, message);
  }

  /**
   * Create a 401 Unauthorized error
   * @param {String} message - Error message
   * @returns {ApiError} ApiError instance
   */
  static unauthorized(message = 'Unauthorized - Authentication required') {
    return new ApiError(message, 401);
  }

  /**
   * Create a 403 Forbidden error
   * @param {String} message - Error message
   * @returns {ApiError} ApiError instance
   */
  static forbidden(message = 'Forbidden - Insufficient permissions') {
    return new ApiError(message, 403);
  }

  /**
   * Create a 404 Not Found error
   * @param {String} message - Error message
   * @returns {ApiError} ApiError instance
   */
  static notFound(message = 'Resource not found') {
    return new ApiError(message, 404);
  }

  /**
   * Create a 409 Conflict error
   * @param {String} message - Error message
   * @returns {ApiError} ApiError instance
   */
  static conflict(message = 'Resource conflict') {
    return new ApiError(message, 409);
  }

  /**
   * Create a 422 Unprocessable Entity error
   * @param {String} message - Error message
   * @returns {ApiError} ApiError instance
   */
  static unprocessableEntity(message = 'Unprocessable entity') {
    return new ApiError(message, 422);
  }

  /**
   * Create a 500 Internal Server Error
   * @param {String} message - Error message
   * @returns {ApiError} ApiError instance
   */
  static internal(message = 'Internal server error') {
    return new ApiError(message, 500);
  }
}

/**
 * Handle 404 errors for undefined routes
 * @param {Object} req - Request object
 * @param {Object} res - Response object
 * @param {Function} next - Next middleware function
 */
const notFoundHandler = (req, res, next) => {
  const error = new ApiError(`Route not found: ${req.originalUrl}`, 404);
  next(error);
};

module.exports = {
  ApiError,
  errorHandler,
  notFoundHandler
}; 