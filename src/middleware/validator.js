const { validationResult } = require('express-validator');
const { ApiError } = require('./errorHandler');

/**
 * Middleware to validate request data using express-validator
 * Must be used after validation rules are defined
 */
const validate = (req, res, next) => {
  const errors = validationResult(req);
  
  if (!errors.isEmpty()) {
    const messages = errors.array().map(error => ({
      field: error.path,
      message: error.msg
    }));
    
    return next(ApiError.badRequest({ 
      message: 'Validation error', 
      errors: messages 
    }));
  }
  
  next();
};

module.exports = { validate }; 