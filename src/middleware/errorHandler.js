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
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode;
    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
  }

  static badRequest(message) {
    return new ApiError(message || 'Bad Request', 400);
  }

  static unauthorized(message) {
    return new ApiError(message || 'Unauthorized', 401);
  }

  static forbidden(message) {
    return new ApiError(message || 'Forbidden', 403);
  }

  static notFound(message) {
    return new ApiError(message || 'Resource not found', 404);
  }

  static internal(message) {
    return new ApiError(message || 'Internal Server Error', 500);
  }
}

module.exports = { errorHandler, ApiError }; 